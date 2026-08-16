# Stage 01 — Schema Summary

**Stage:** `01_supabase_schema` · Database + auth
**Status:** Complete, awaiting review
**Layer 3 inputs loaded:** `_config/supabase/schema.sql`, `_config/supabase/rls_policies.sql`, `_config/doctrine/EVIDENCE-OVER-VIBES.md`

Every statement in this folder was applied to a real PostgreSQL 16 instance, in order,
against a stand-in for the Supabase `auth` schema. Results are quoted throughout. Nothing
below is asserted from reading the SQL alone.

---

## Run order

```
001_create_tables.sql    6 tables + RLS enabled on all of them
002_rls_policies.sql     is_operator() helper, grants, 16 policies
003_functions.sql        calculate_momentum_score + 7 triggers
004_indexes.sql          6 indexes incl. the first-doorway constraint
seed.sql                 1 practitioner, 28 rows of sample data
```

Apply in the Supabase SQL editor top to bottom, or `bash tools/supabase-migrate.sh`.
`seed.sql` is idempotent — running it twice produced identical row counts.

---

## Tables and expected row counts after seed

| Table | Rows after seed | What it holds |
|---|---:|---|
| `practitioners` | 1 | Major, tier `operator`, onboarding complete |
| `daily_entries` | 3 | Last three days of One Focus / One Action / One Step |
| `evidence_logs` | 14 | Two full weeks of binary proof, two missed days, live 4-day streak |
| `sprint_tasks` | 7 | A 7-day sprint spanning all six leak zones, one trip wire raised |
| `offers` | 2 | Stop the Bleed Sprint (first doorway, live) + BWYH (draft) |
| `ai_suggestions` | 2 | One `next_action`, one `pattern_insight` — both unconfirmed |

`seed.sql` resolves the practitioner by email against `auth.users`. **Sign in once with the
magic link before running it**, or it exits with a readable message rather than a foreign
key error.

---

## RLS: who can read what

RLS is enabled on all six tables in `001`, before a single policy exists — so between
migrations the tables are deny-all rather than briefly open.

| Role | practitioners | daily_entries | evidence_logs | sprint_tasks | offers | ai_suggestions |
|---|---|---|---|---|---|---|
| `anon` | — | — | — | — | — | — |
| practitioner (free/paid) | own row R/W | own R/W/D | own R/W | own read + update | own R/W/D | own read + confirm/dismiss |
| operator | read all | read all | read all | full write | read all | full write |
| `service_role` | bypasses RLS entirely — no policy needed | | | | | |

Three deliberate asymmetries:

- **No `DELETE` grant on `evidence_logs`.** A logged rep is a fact. A practitioner can
  correct today's entry (the `UNIQUE (practitioner_id, date)` constraint makes that an
  update, not a duplicate) but cannot delete history to make a streak look better than it
  was. Evidence Over Vibes only works if the evidence is not editable after the fact.
- **Practitioners cannot `INSERT` into `sprint_tasks`.** The operator authors the sprint.
  A practitioner who can add their own tasks can quietly rewrite the sprint into something
  more comfortable, which is the exact avoidance the sprint exists to interrupt.
- **Practitioners cannot `INSERT` into `ai_suggestions`.** Suggestions originate from the
  Stage 05 serverless function or an operator. That restriction is what lets the UI
  honestly label a row "Claude suggested this."

---

## The momentum score in plain English

> Count the days in the last week you did the thing, and the days in the week before that.
> The recent week is worth 70 points, the week before it 30. Add two points for every day
> in your current unbroken run, up to twenty. Cap the total at 100.

A practitioner who logged `did_it` on all fourteen days scores exactly 100 on the weighted
portion alone. Zero evidence logs returns 0.

`did_it = false` is real data and is stored, but it earns no points and ends a streak.
A streak is only counted if the most recent completed day is today or yesterday — today
being unlogged does not break it, because the day is not over.

Call it directly for a practitioner's **current** score:

```sql
SELECT calculate_momentum_score(id) FROM practitioners WHERE email = 'major@hanzo.ai';
```

The `momentum_score` column on each `evidence_logs` row is a **snapshot** — what momentum
was at the moment that rep was logged. Older rows are deliberately not rewritten when a new
log lands; the history of the score is itself evidence. **Stage 03 should call the function
for the number on the Today card, and read the stored column only when charting history.**

---

## Decisions made, and why

### `did_it` is `boolean NOT NULL`, never a scale

Straight from Evidence Over Vibes. A 1–5 scale invites self-assessment, which is how vibes
get back in. Binary also forces the task definition to be clear: if you cannot say whether
you did it, the task was vague, and *that* is the problem to solve. Verified: the column is
`boolean`, `is_nullable = NO`.

### Three corrections to the reference `schema.sql`

`_config/supabase/schema.sql` is the Layer 3 source of truth, and these outputs match it on
every table, column, constraint and index. Three defects in its *behaviour* did not survive
being run, and are corrected here. Each was measured against the original.

**1. The momentum score could never reach 100.**
The reference multiplies a count-based score (`COUNT(*) * 10`) by the weights again
(`* 0.7`, `* 0.3`), applying the normalisation twice. Its "last 7 days" window also spans
eight calendar days. Measured on a perfect 14-day record:

| | Perfect 14-day record |
|---|---:|
| Reference implementation | **94** |
| This implementation | **100** |

The reference tops out at 94 and only gets there via the streak bonus; its 70/30 split was
not 70/30 of anything reachable. This version computes `(hits/7) × 70 + (hits/7) × 30`, so
the weights mean what the contract says they mean.

**2. The streak ignored the calendar.**
The reference walks logs newest-first and counts every consecutive `did_it = true` *row*,
never comparing dates. Two completed days ten days apart counted as a two-day streak.
Measured on exactly that input:

| | Two hits, 10 days apart |
|---|---:|
| Reference implementation | **14** (+4 streak bonus) |
| This implementation | **16** (+2 streak bonus) |

This version uses a gaps-and-islands ranking, so only genuinely consecutive calendar days
count, and the run must reach today or yesterday to be live.

**3. The first log of a practitioner's life scored 0.**
The trigger is `BEFORE INSERT`, so the row being written is not yet visible to a query
against `evidence_logs`. The reference calls `calculate_momentum_score(NEW.practitioner_id)`,
which therefore computes from every log *except* the one being logged. Measured on a
first-ever log:

| | First-ever evidence log |
|---|---:|
| Reference trigger | **0** |
| This trigger | **12** |

A practitioner logging their first rep and seeing a momentum score of 0 is the worst
possible first impression of a screen whose whole job is to show that reps compound.
`calculate_momentum_score` now takes two optional arguments so the trigger can hand it the
in-flight row. They default to `NULL`, so the one-argument call in the handoff doc still
works. The pending row also *replaces* any stored row for the same date, so re-logging a
day corrects the score instead of double-counting it — verified: flipping a logged day from
true to false moved the score to 0.

### Two corrections to the reference `rls_policies.sql`

**4. The operator policy on `practitioners` was unrunnable.**
The reference checks operator status with an inline `EXISTS (SELECT 1 FROM practitioners …)`
*inside a policy on `practitioners`*. Postgres re-applies RLS to that subquery and the
evaluation recurses. Applied verbatim, it fails:

```
ERROR:  infinite recursion detected in policy for relation "practitioners"
```

Replaced with a `SECURITY DEFINER` function `is_operator()`. A table owner bypasses RLS, so
the lookup inside is not re-filtered and the recursion never starts. It is also evaluated
once per statement rather than once per row, which removes the same repeated subquery from
the other five tables. `search_path` is pinned so it cannot be hijacked. Verified: an
operator now reads all practitioner rows; a `free`-tier practitioner reads exactly one.

**5. `ai_suggestions_service_insert` was an open door.**
The reference carries `WITH CHECK (true)` commented *"restricted at application layer via
service role key."* It is not. An unqualified policy applies to every role that can INSERT,
so any signed-in practitioner could have written an `ai_suggestions` row for **any**
`practitioner_id` — a fabricated "Claude said so" suggestion in someone else's feed. And
`service_role` never needed it: it has `BYPASSRLS` and policies are not consulted for it at
all. The policy is removed. Stage 05's serverless function writes suggestions with
`SUPABASE_SERVICE_ROLE_KEY` and is unaffected.

### Additions beyond the reference

- **`ai_suggestions_never_born_confirmed` trigger.** The contract requires `confirmed`
  to default false. A default is only a default — any caller can override it in the INSERT.
  This trigger forces `confirmed := false` on every insert, so consent cannot be
  manufactured by the code that writes the row, only granted by a later human UPDATE.
  Verified: an insert explicitly passing `confirmed = true` lands as `false`.
- **`CHECK (NOT (confirmed AND dismissed))`** — a suggestion is one or the other.
- **`offers_leak_zones_valid`** — constrains the `leak_zones` array to the same six zones as
  `sprint_tasks.leak_zone`, so the Sprint and Offer screens cannot drift apart.
- **`CHECK (sprint_day <= sprint_total)`** — day 9 of a 7-day sprint is not a thing.
- **`practitioners_tier` index** — the Stage 06 operator roster sorts by tier. Cheap now,
  saves a migration later.
- **`price >= 0`** on offers.

### Kept from the reference, though the contract did not list them

`updated_at` on four tables (with triggers), `sprint_tasks.trip_wire_flagged` (Stage 04
needs it), and the `note <= 140` character limit on evidence logs. `schema.sql` outranks the
stage contract's abbreviated column list per the source-of-truth hierarchy in `CLAUDE.md`.

`momentum_score` is left nullable, as in the reference. The `BEFORE` trigger always
populates it; making it `NOT NULL` would add nothing while breaking any future backfill that
legitimately runs before the trigger exists.

---

## Auth setup — manual, in the Supabase dashboard

Not expressible in SQL. Do these before Stage 02's magic-link flow will work:

- **Authentication → Providers → Email**: enabled, **"Confirm email" ON**, password sign-in
  **disabled**. Magic link only.
- **Authentication → URL Configuration**:
  - Site URL: `https://stb-command-center.vercel.app`
  - Redirect URLs: `https://stb-command-center.vercel.app/auth/callback`
    and `http://localhost:5173/auth/callback` for local development
  - Both need updating once the real Vercel URL is known.
- **Authentication → Sessions**: JWT expiry `2592000` (30 days).

A practitioner row is **not** created automatically on sign-up. Stage 02 must insert one
after first sign-in — the `practitioners_self_insert` policy allows exactly that and nothing
more. Alternatively add an `on_auth_user_created` trigger in a later migration; it was left
out here because the contract does not specify one and onboarding copy belongs to Stage 02.

---

## Verification against the contract's checklist

| Check | Result |
|---|---|
| `did_it` strictly boolean — no scale, not nullable | `boolean` / `is_nullable = NO` |
| RLS enabled on all 6 tables before any policy | `relrowsecurity = true` on all 6, enabled in `001` |
| Momentum handles 0 evidence logs | returns `0` |
| `ai_suggestions.confirmed` defaults false, never auto-confirms | default `false`; insert forcing `true` stored `false` |
| One first doorway per practitioner | second insert → `duplicate key … offers_one_first_doorway` |

Also confirmed on the live database: `anon` is denied on every table
(`permission denied for table practitioners`); a practitioner cannot write an evidence log
against another practitioner's id (`new row violates row-level security policy`); a
practitioner cannot delete evidence logs; the seed's newest row stores momentum `94`, which
matches the live function call exactly.

---

## What Stage 02 plugs into

- **Client**: `VITE_SUPABASE_URL` + `VITE_SUPABASE_ANON_KEY`. The anon key is safe in the
  browser precisely because these policies exist. `SUPABASE_SERVICE_ROLE_KEY` must never
  appear in a `VITE_`-prefixed variable — it bypasses every policy in `002`.
- **Types**: generate rather than hand-write, so they cannot drift from this schema —
  `supabase gen types typescript --project-id <id> > src/lib/database.types.ts`.
- **After sign-in**: insert the `practitioners` row, then route on `onboarding_complete`.
- **Tier gate**: `practitioners.tier` is the single source for `'paid'` feature gating in
  Stages 03–05.

---

## Open items for Major

1. **`_config/doctrine/STABILITY-SEEKER-ARCHETYPE.md` is missing from the seed**, though the
   Stage 01 contract lists it as a required Layer 3 input. The practitioner profile columns
   (`one_sentence`, `bleed_zone`, `stability_goal`) were built from the archetype description
   inside `EVIDENCE-OVER-VIBES.md` and from `schema.sql`. If that doctrine file specifies
   additional profile fields, the `practitioners` table will need a follow-up migration.
2. **The repo is nested one directory deep** — everything lives in
   `STB-COMMAND-CENTER/STB-COMMAND-CENTER/`. Every path in `CLAUDE.md`, `CONTEXT.md` and all
   five stage contracts assumes repo root, and Vite plus Vercel's build detection will both
   look at the root. Worth flattening before Stage 02 scaffolds `src/`.
3. **Nothing has been applied to a live Supabase project.** These files were verified against
   local PostgreSQL 16 with a stand-in `auth` schema. `auth.uid()` and `auth.users` behave
   the same way there, but the dashboard auth settings above still need doing by hand.
