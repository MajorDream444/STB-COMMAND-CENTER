# STB Command Center — Claude Code Identity File
**Layer 0 · Global Identity · ~800 tokens**
**Repo:** `MajorDream444/STB-COMMAND-CENTER`
**GitHub Source of Truth:** https://github.com/MajorDream444/STB-COMMAND-CENTER
**Parent system:** `MajorDream444/SPARK-LAB-STB` (doctrine + skills)
**Architecture:** Interpretable Context Methodology (ICM) — folder structure as agent orchestration

---

## What This Repo Is

The STB Command Center is a two-sided Progressive Web App (PWA) for the Spark Lab ecosystem:

- **Practitioner view** — the daily calm interface for coaches, healers, and conscious founders going through the Stop the Bleed (STB) sprint. One room. One focus. One action.
- **Operator view** — Major Dream and the Spark Lab team manage the full client cohort: momentum scores, trip wire alerts, sprint progress, check-in drafts.
- **AI layer** — Claude (Anthropic API) suggests next actions, detects resistance patterns, and drafts check-ins. Humans confirm every suggestion before it executes.

---

## Source of Truth Hierarchy

When any instruction conflicts, follow this order:

1. Major's latest explicit instruction (this conversation or a new message)
2. This `CLAUDE.md` file
3. Approved stage `CONTEXT.md` files (Layers 2)
4. `_config/` reference files (Layer 3 doctrine, design, schema)
5. Cross-agent handoff documents in `99_archive/`
6. Older exploratory notes or prior session memory

**Never** infer architectural decisions not explicitly stated here or in Layer 2 contracts. When in doubt, stop and ask.

---

## Repo Structure

```
STB-COMMAND-CENTER/
├── CLAUDE.md                    ← YOU ARE HERE (Layer 0)
├── CONTEXT.md                   ← Workspace routing (Layer 1)
├── README.md
│
├── _config/                     ← Layer 3: stable reference (the factory)
│   ├── doctrine/                ← STB core doctrine files
│   ├── design-system/           ← Tokens, components, UX copy
│   ├── brand-voice/             ← Major Dream brand guidelines
│   ├── supabase/                ← Schema + seed SQL
│   └── signals/                 ← Agent-Reach weekly signal drops
│
├── stages/                      ← Numbered = execution order (ICM)
│   ├── 01_supabase_schema/      ← Database + auth setup
│   ├── 02_pwa_shell/            ← React PWA, routing, bottom nav
│   ├── 03_today_screen/         ← Today view + Evidence log
│   ├── 04_sprint_offer/         ← Sprint board + Offer clarity
│   ├── 05_claude_ai_layer/      ← Anthropic API integration
│   ├── 06_operator_view/        ← Cohort dashboard (Phase 3)
│   └── 07_tiers_stripe/         ← Payments + gated features (Phase 4)
│
├── tools/                       ← Local scripts (no AI needed)
│   ├── run-stage.sh
│   ├── agent-reach-fetch.py
│   └── supabase-migrate.sh
│
├── graphify-out/                ← Knowledge graph (run /graphify after each stage)
└── 99_archive/                  ← Prior handoffs, doctrine versions
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + TypeScript + Tailwind CSS |
| PWA | Vite PWA plugin — manifest, service worker, offline |
| Database + Auth | Supabase (PostgreSQL + magic link auth, no password) |
| AI features | Anthropic API — `claude-sonnet-4-6` for suggestions |
| Signal intel | Agent-Reach (Twitter, Reddit, YouTube — zero API fees) |
| Knowledge graph | Graphify — queryable repo map, run after each stage |
| Deploy | Vercel |
| Payments (Phase 4) | Stripe |

---

## Design System (non-negotiable)

| Token | Value |
|-------|-------|
| Background | `#0d1f17` |
| Surface | `#122b1e` |
| Gold accent | `#c9a84c` |
| Cream text | `#f5f0e6` |
| Ember accent | `#c1622d` |
| Display font | Cormorant Garamond (serif) |
| Body font | DM Sans (sans-serif) |
| Border radius | 10–14px cards, 20px for pill badges |

The design is cinematic, dark, premium. Not a productivity app. A practitioner opens this at 7am and immediately knows exactly what to do. The room is small. The path is obvious.

Full design tokens: `_config/design-system/tokens.md`
UX copy rules: `_config/design-system/ux-copy.md`

---

## Core Doctrine (summaries — full files in `_config/doctrine/`)

**One-Room Rule:** The practitioner interface must always be peaceful and simple. Backend can be complex. Client-facing surface must never be. Maximum 3 items visible at a time.

**Evidence Over Vibes:** Binary proof only. Did it / didn't. No partial credit. No feelings tracking. Reps compound into momentum.

**Trip Wire System:** When a practitioner shows resistance signals, route to the correct intervention type (somatic / identity / logistical / clarity / consent). Never push harder. Find the type first.

**Consent Before Extraction:** Always ask before taking. Claude never acts without human confirmation.

**BWYH (Build While You Heal):** The ascension path. STB Command Center is the stabilization layer before full BWYH. Keep them connected but distinct.

---

## Tier Architecture

| Tier | Access | Price |
|------|--------|-------|
| Free | Today view + Evidence log (basic) | $0 |
| Paid | AI suggestions + pattern insights + Sprint board + Offer clarity | TBD |
| Operator | Full cohort view — Major + Spark Lab team only | Team plan |

---

## ICM Operating Rules for Claude Code

1. **Read this file first.** Then `CONTEXT.md`. Then the current stage's `CONTEXT.md`.
2. **Load only what the current stage needs.** Do not load all `_config/` files into every stage. Each stage `CONTEXT.md` specifies exactly which reference files to load (Layer 3 Inputs).
3. **Run `/graphify .` after each stage completes.** The knowledge graph updates. Use it for the next stage instead of re-reading doctrine files.
4. **Write outputs to `stages/0N_name/output/` only.** Never write directly to `src/` at the repo root — the PWA shell stage owns that.
5. **Every output is an edit surface.** Major reviews `output/` before the next stage runs. Do not auto-proceed to the next stage. Stop and confirm.
6. **Tools folder for mechanical work.** Data fetching, file moving, migrations — these go in `tools/` as local scripts, not embedded in stage AI work.
7. **One stage, one job.** If a stage feels too large, split it. Stage 03 builds Today + Evidence. Stage 04 builds Sprint + Offer. Never mix concerns.
8. **Do not build Stage 06 or 07 until Stage 05 ships.** Revenue-generating practitioner interface before operator view. Sequencing matters.

---

## Agent-Reach Integration

Agent-Reach provides weekly market signal intelligence. Run `tools/agent-reach-fetch.py` before starting a new build sprint. Output lands in `_config/signals/` as Layer 3 reference files.

Platforms monitored: Twitter (healers, coaches, founders), Reddit (r/coachingbusiness, r/solopreneur), YouTube (STB-adjacent content trends).

Keywords tracked: "burnout," "overloaded," "coaching offer," "systems for coaches," "breathwork business," "nervous system regulation."

---

## Graphify Integration

After each stage completes and Major approves the output:

```bash
/graphify .
```

This rebuilds the knowledge graph from all current repo files. In subsequent stage work, query the graph instead of re-reading doctrine files:

```bash
/graphify query "what is the One-Room Rule"
/graphify query "Supabase practitioners table schema"
/graphify path "EvidenceLog" "MomentumScore"
```

---

## Key People

| Person | Role |
|--------|------|
| Major Dream Williams | Founder, builder, architect. Primary operator of both views. |
| Flo (Floortje de Liefde) | First practitioner case study. Sprint 4. Breathwork + somatic presence. |
| Josephine | Yoga teacher, collaborator on retreat programming. Early STB test client. |

---

## What Claude Code Should Do After Reading This

1. Confirm: which stage is currently active?
2. Read `CONTEXT.md` (Layer 1) for workspace routing.
3. Read the active stage's `CONTEXT.md` (Layer 2) for exact inputs, process, outputs.
4. Load only the Layer 3 files specified in that stage's Inputs table.
5. Execute. Write to `output/`. Stop.
6. Report what was produced and what Major should review before proceeding.

**Never proceed to the next stage without explicit confirmation.**
