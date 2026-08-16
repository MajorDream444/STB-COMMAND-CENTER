# STB Command Center — Workspace Context
**Layer 1 · Workspace Routing · ~300 tokens**

---

## Current Build Phase

**Phase 1 — Practitioner Shell** (active)

Stages 01–05. Ship a working PWA that a practitioner can install on their phone and open every morning. Evidence of product–practitioner fit before building the operator view.

**Do not start Phase 2 (Stage 06, operator view) until Phase 1 ships to a real practitioner.**

---

## Stage Map

| Stage | Name | Status | Job |
|-------|------|--------|-----|
| `01_supabase_schema` | Database + auth | **START HERE** | Create all 6 tables, magic link auth, RLS policies |
| `02_pwa_shell` | React PWA shell | Waiting for 01 | Vite + React + Tailwind, routing, bottom nav, PWA manifest |
| `03_today_screen` | Today + Evidence | Waiting for 02 | Today view, Evidence log, momentum score, 7-day dot strip |
| `04_sprint_offer` | Sprint + Offer | Waiting for 03 | Sprint board with task checkboxes, Offer clarity screen |
| `05_claude_ai_layer` | AI integration | Waiting for 04 | Anthropic API, suggestion pills, trip wire detection, pattern insights |
| `06_operator_view` | Cohort dashboard | Phase 3 | Client roster, momentum board, trip wire inbox — build after Phase 1 ships |
| `07_tiers_stripe` | Payments | Phase 4 | Stripe, feature gating, free/paid/operator tiers |

---

## Shared Resources (available to all stages)

| Resource | Location | What it contains |
|----------|----------|-----------------|
| Doctrine | `_config/doctrine/` | STB-CORE-DOCTRINE, ONE-ROOM-RULE, EVIDENCE-OVER-VIBES, TRIP-WIRE-SYSTEM, STABILITY-SEEKER-ARCHETYPE |
| Design system | `_config/design-system/` | tokens.md, components.md, ux-copy.md |
| Brand voice | `_config/brand-voice/guidelines.md` | Major Dream voice, tone, copy patterns |
| Supabase schema | `_config/supabase/schema.sql` | Canonical table definitions — source of truth |
| Signal intel | `_config/signals/` | Weekly Agent-Reach drops (Twitter/Reddit/YouTube) |
| Knowledge graph | `graphify-out/GRAPH_REPORT.md` | Graphify summary — query instead of re-reading files |

---

## Routing Rules

**"Build the Today screen"** → Stage 03. Load design tokens + ux-copy (L3). Output goes to `stages/03_today_screen/output/`.

**"Set up the database"** → Stage 01. Load `_config/supabase/schema.sql` (L3). Output is migration files in `stages/01_supabase_schema/output/`.

**"Wire up Claude AI suggestions"** → Stage 05. Load Anthropic API spec + doctrine (L3). Requires Stage 04 output in context.

**"Build the operator view"** → Stage 06. Blocked until Stage 05 ships. Do not start early.

**"What is the One-Room Rule?"** → Run `/graphify query "One-Room Rule"` rather than loading the full doctrine file.

**"Something hit a wall / trip wire"** → Load `_config/doctrine/TRIP-WIRE-SYSTEM.md` and run the detector. Do not proceed with the build task until the trip wire is resolved.

---

## Review Gates

After every stage `output/` is written, Claude Code stops.
Major reviews the output.
Only proceed when Major confirms: **"this looks good, continue to Stage N+1."**

This is not optional. It is the architecture.
