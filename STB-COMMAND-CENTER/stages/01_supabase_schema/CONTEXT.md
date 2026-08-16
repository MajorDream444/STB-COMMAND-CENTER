# Stage 01 — Supabase Schema + Auth
**Layer 2 · Stage Contract · ~400 tokens**

---

## Inputs

| Layer | File | Purpose |
|-------|------|---------|
| L3 (reference) | `_config/supabase/schema.sql` | Canonical table definitions — read this first |
| L3 (reference) | `_config/doctrine/EVIDENCE-OVER-VIBES.md` | Evidence log logic — binary, no partial credit |
| L3 (reference) | `_config/doctrine/STABILITY-SEEKER-ARCHETYPE.md` | Practitioner profile shape |

Do not load other doctrine files at this stage. Schema work does not need brand voice or design tokens.

---

## Process

Create a complete, production-ready Supabase setup:

### 1. Tables (6 total)

**`practitioners`**
- `id` uuid PK (Supabase auth user id)
- `name` text
- `email` text unique
- `tier` text default 'free' — enum: free | paid | operator
- `onboarding_complete` boolean default false
- `one_sentence` text — their offer in one sentence
- `bleed_zone` text — the thing costing them clients right now
- `stability_goal` text — what "stable" looks like for them
- `created_at` timestamptz default now()

**`daily_entries`**
- `id` uuid PK
- `practitioner_id` uuid FK → practitioners
- `date` date
- `one_focus` text
- `one_action` text
- `one_step` text nullable
- `action_done` boolean default false
- `note` text nullable
- `created_at` timestamptz default now()
- UNIQUE (practitioner_id, date)

**`evidence_logs`**
- `id` uuid PK
- `practitioner_id` uuid FK → practitioners
- `date` date
- `did_it` boolean — binary only. No partial credit. No maybe.
- `note` text nullable — optional short note, max 140 chars
- `momentum_score` integer — computed 0–100, stored on write
- `created_at` timestamptz default now()

**`sprint_tasks`**
- `id` uuid PK
- `practitioner_id` uuid FK → practitioners
- `sprint_day` integer — 1–7 or 1–14
- `sprint_total` integer default 7
- `name` text
- `leak_zone` text — enum: offer_clarity | operations | visibility | pricing | delivery | mindset
- `done` boolean default false
- `order_index` integer
- `created_at` timestamptz default now()

**`offers`**
- `id` uuid PK
- `practitioner_id` uuid FK → practitioners
- `name` text — e.g. "Stop the Bleed Sprint"
- `one_sentence` text
- `price` numeric
- `status` text default 'draft' — enum: draft | live | paused
- `is_first_doorway` boolean default false
- `leak_zones` text[] — array of zone names this offer addresses
- `created_at` timestamptz default now()

**`ai_suggestions`**
- `id` uuid PK
- `practitioner_id` uuid FK → practitioners
- `type` text — enum: next_action | pattern_insight | trip_wire | check_in_draft
- `content` text — the suggestion text
- `confirmed` boolean default false
- `dismissed` boolean default false
- `created_at` timestamptz default now()

### 2. Row Level Security (RLS)

Enable RLS on all tables. Policies:

- Practitioners can only read and write their own rows (`auth.uid() = practitioner_id`)
- Operator role (tier = 'operator') can read all rows on all tables
- No anonymous reads on any table

### 3. Auth Setup

- Magic link only (no password)
- Email provider enabled
- Redirect URL: `https://stb-command-center.vercel.app/auth/callback` (update when Vercel URL is known)
- Session duration: 30 days

### 4. Momentum Score Function

Create a Postgres function `calculate_momentum_score(practitioner_id uuid)`:
- Look at the last 14 days of `evidence_logs`
- Weight recent days more heavily (last 7 days = 70% of score, previous 7 = 30%)
- Streak bonus: consecutive days add +2 per day (max +20)
- Return integer 0–100
- Call this function on every `evidence_logs` INSERT and store the result in the new row

### 5. Indexes

- `evidence_logs(practitioner_id, date)` — most common query pattern
- `daily_entries(practitioner_id, date)`
- `sprint_tasks(practitioner_id, done)`
- `ai_suggestions(practitioner_id, confirmed, dismissed)`

---

## Outputs

Write all output to `stages/01_supabase_schema/output/`:

```
output/
├── 001_create_tables.sql        ← All CREATE TABLE statements + RLS
├── 002_rls_policies.sql         ← All GRANT and POLICY statements
├── 003_functions.sql            ← calculate_momentum_score + any triggers
├── 004_indexes.sql              ← All CREATE INDEX statements
├── seed.sql                     ← Sample data for 1 practitioner (Major) for testing
└── SCHEMA_SUMMARY.md            ← Human-readable summary of what was created and why
```

`SCHEMA_SUMMARY.md` must include:
- Table list with row counts expected after seed
- RLS policy summary (who can read what)
- The momentum score formula in plain English
- Any decisions made and why (e.g. why `did_it` is boolean and not a scale)

---

## Verify

Before writing outputs, check:
- [ ] `did_it` in `evidence_logs` is strictly boolean — no integer scale, no nullable
- [ ] RLS is enabled on all 6 tables before any policies are written
- [ ] The momentum score function handles edge case: 0 evidence logs (return 0)
- [ ] `ai_suggestions.confirmed` defaults false — Claude never auto-confirms
- [ ] `offers.is_first_doorway` — only one offer per practitioner should have this true (add a partial unique index: `WHERE is_first_doorway = true`)

---

## Stop Here

After writing all output files, stop.
Report: "Stage 01 complete. Review `stages/01_supabase_schema/output/` before proceeding to Stage 02."
Do not begin Stage 02 until Major confirms.
