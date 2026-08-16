# STB Command Center

**Stop the Bleed — Practitioner Command Center**  
*Founder. Builder. Architect. — Major Dream Williams*

---

A two-sided Progressive Web App for the Spark Lab ecosystem. Practitioners use it every morning to stay focused. Operators use it to manage the cohort without clutter.

---

## Architecture

This repo uses **Interpretable Context Methodology (ICM)** — folder structure as agent orchestration. No framework. No server. One Claude Code agent reads the right files at the right stage.

Read [`CLAUDE.md`](./CLAUDE.md) before running anything.

## Stack

- **React 18 + TypeScript + Vite** — PWA, installable on phone
- **Supabase** — PostgreSQL + magic link auth + RLS
- **Anthropic API** — `claude-sonnet-4-6` for AI suggestions
- **Agent-Reach** — weekly market signal intelligence
- **Graphify** — queryable knowledge graph of this repo
- **Vercel** — deploy

## Build Stages

| Stage | Status |
|-------|--------|
| 01 · Supabase schema | Ready to start |
| 02 · PWA shell | Waiting |
| 03 · Today + Evidence | Waiting |
| 04 · Sprint + Offer | Waiting |
| 05 · Claude AI layer | Waiting |
| 06 · Operator view | Phase 3 |
| 07 · Tiers + Stripe | Phase 4 |

## First Run

```bash
# 1. Install Graphify and map the repo
graphify install
/graphify .

# 2. Install Agent-Reach for signal intel
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto

# 3. Open Claude Code
# Read CLAUDE.md → read CONTEXT.md → read stages/01_supabase_schema/CONTEXT.md
# Execute Stage 01. Stop. Review output. Confirm.
```

## Doctrine

Full STB doctrine lives in [`_config/doctrine/`](./_config/doctrine/).  
Design tokens: [`_config/design-system/tokens.md`](./_config/design-system/tokens.md)  
Supabase schema: [`_config/supabase/schema.sql`](./_config/supabase/schema.sql)

---

*Systems create freedom. Build once. Scale forever.*
