# STB Command Center — Claude Code Handoff
**Full session summary + step-by-step build instructions**
**Date:** August 16, 2026
**Operator:** Major Dream Williams
**GitHub:** https://github.com/MajorDream444/STB-COMMAND-CENTER

---

## WHAT WE BUILT THIS SESSION (Summary)

This session designed and architected the **STB Command Center** — a two-sided Progressive Web App for the Spark Lab ecosystem. Here is everything that was decided, designed, and built:

### The Product

A PWA (installable on phone) with two views:

**Practitioner view** — coaches, healers, and conscious founders going through the Stop the Bleed (STB) sprint use this every morning. It has four screens:
1. **Today** — One Focus, One Action, One Step. Momentum score (0–100). Claude AI suggestion pill.
2. **Evidence Log** — Binary proof tracking. Did it / didn't. No partial credit. 7-day dot strip. Pattern insights.
3. **Sprint Board** — Task checklist with leak zone tags, progress bar, trip wire flag button.
4. **Offer Clarity** — One-sentence offer, First Doorway card, Leak zone progress bars, AI offer architect.

**Operator view** (Phase 3, not built yet) — Major and Spark Lab team see all clients, momentum scores, trip wire alerts, check-in drafts.

**AI layer** — Claude (`claude-sonnet-4-6`) suggests next actions, detects resistance patterns, drafts check-ins. Humans confirm every suggestion. Nothing auto-executes.

### The Architecture

We adopted **Interpretable Context Methodology (ICM)** from a published paper — folder structure as agent orchestration. No framework. One Claude Code agent reads the right files at the right stage.

Five-layer context hierarchy:
- **Layer 0** — `CLAUDE.md` — global identity ("where am I?")
- **Layer 1** — `CONTEXT.md` — workspace routing ("where do I go?")
- **Layer 2** — `stages/0N/CONTEXT.md` — stage contract ("what do I do?")
- **Layer 3** — `_config/` — stable reference files: doctrine, design tokens, schema, brand voice
- **Layer 4** — `stages/0N/output/` — working artifacts, changes every run

### The Tool Stack

| Tool | Role |
|------|------|
| **Graphify** | Maps the entire repo into a queryable knowledge graph. Run `/graphify .` after each stage. |
| **Agent-Reach** | Weekly signal pull from Twitter/Reddit/YouTube. Zero API fees. Lands in `_config/signals/`. |
| **ICM** | Folder structure replaces agent framework. Stage folders = orchestration. |
| **Supabase** | PostgreSQL + magic link auth + RLS. 6 tables built and specified. |
| **Anthropic API** | `claude-sonnet-4-6` for AI features. Proxied through Vercel serverless function. |
| **Vercel** | Deploy. Every push to `main` auto-deploys. |
| **React + Vite + TypeScript + Tailwind** | Frontend stack. |

### The Design System

| Token | Value |
|-------|-------|
| Background | `#0d1f17` |
| Surface/cards | `#122b1e` |
| Gold accent | `#c9a84c` |
| Cream text | `#f5f0e6` |
| Ember/warning | `#c1622d` |
| Display font | Cormorant Garamond (serif) |
| Body font | DM Sans (sans-serif) |

Dark, cinematic, premium. Not a productivity app. One-Room Rule: max 3 items visible above the fold. Calm every time it opens.

### The Doctrine (Core STB Principles baked into the app)

- **One-Room Rule** — Client interface must always be peaceful. Backend complexity stays hidden.
- **Evidence Over Vibes** — Binary proof only. `did_it` is boolean, never a scale, never nullable.
- **Trip Wire System** — Resistance detection routes to operator, never pushes the practitioner harder.
- **Consent Before Extraction** — Claude never acts without human confirmation.

### What Was Already Built and Delivered

The ICM seed folder (`STB-COMMAND-CENTER-seed.zip`) was generated containing:
- `CLAUDE.md` — Layer 0 identity file (full tech stack, doctrine summaries, ICM rules, Graphify/Agent-Reach integration)
- `CONTEXT.md` — Layer 1 routing (stage map, shared resources, review gates)
- `stages/01_supabase_schema/CONTEXT.md` — Stage contract with exact table specs
- `stages/02_pwa_shell/CONTEXT.md` — React + Vite + Tailwind + Supabase setup
- `stages/03_today_screen/CONTEXT.md` — Today + Evidence screens, full component specs
- `stages/04_sprint_offer/CONTEXT.md` — Sprint board + Offer clarity screens
- `stages/05_claude_ai_layer/CONTEXT.md` — Anthropic API integration, 4 AI features
- `_config/design-system/tokens.md` — Every color, font, spacing, component pattern
- `_config/design-system/ux-copy.md` — Every screen's copy, error messages, empty states, banned words
- `_config/supabase/schema.sql` — Complete schema: 6 tables, momentum score function, triggers, indexes
- `_config/supabase/rls_policies.sql` — Row Level Security for all 6 tables
- `_config/doctrine/ONE-ROOM-RULE.md` — Doctrine reference
- `_config/doctrine/EVIDENCE-OVER-VIBES.md` — Doctrine reference
- `tools/agent-reach-fetch.py` — Weekly signal intelligence script
- `tools/supabase-migrate.sh` — Migration runner

The seed zip also creates the full empty folder structure for all 7 stages plus `graphify-out/` and `99_archive/`.

---

## WHAT YOU NEED BEFORE STARTING

### Credentials to gather

1. **Supabase** — Create a new project at [supabase.com](https://supabase.com)
   - Get: `Project URL` and `anon/public key`
   - Also get: `service_role key` (for the Vercel serverless function)

2. **Anthropic API key** — You already have this. Keep it ready for Stage 05.

3. **Vercel** — Go to [vercel.com/new](https://vercel.com/new)
   - Import `MajorDream444/STB-COMMAND-CENTER` from GitHub
   - Framework: **Vite**
   - Add these environment variables (even if blank now):
     ```
     VITE_SUPABASE_URL=
     VITE_SUPABASE_ANON_KEY=
     VITE_ANTHROPIC_API_KEY=
     SUPABASE_SERVICE_ROLE_KEY=
     ```

4. **GitHub repo** — `MajorDream444/STB-COMMAND-CENTER` is already created.

---

## STEP-BY-STEP INSTRUCTIONS FOR CLAUDE CODE

### STEP 0 — Push the seed to GitHub

This is done outside Claude Code. On your local machine:

```bash
# Clone the empty repo
git clone https://github.com/MajorDream444/STB-COMMAND-CENTER.git
cd STB-COMMAND-CENTER

# Unzip the seed file into this folder
# (the seed zip was delivered in our Claude.ai session)
# All files go directly into STB-COMMAND-CENTER/

# Push everything
git add .
git commit -m "ICM seed: CLAUDE.md, CONTEXT.md, 5 stage contracts, _config, tools"
git push origin main
```

### STEP 1 — Install tools in Claude Code

Once Claude Code is open and pointed at the `STB-COMMAND-CENTER` repo, run these commands:

```bash
# Install Graphify (knowledge graph for the repo)
uv tool install graphifyy
# OR if uv not available:
pip install graphifyy --break-system-packages

# Register Graphify with Claude Code
graphify install

# Build the knowledge graph from all repo files
/graphify .
# This creates graphify-out/graph.html and graphify-out/GRAPH_REPORT.md

# Install Agent-Reach (market signal intelligence)
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto
agent-reach doctor
```

### STEP 2 — Install Supabase CLI

```bash
# Install Supabase CLI
brew install supabase/tap/supabase
# OR on Linux:
curl -fsSL https://raw.githubusercontent.com/supabase/cli/main/scripts/install.sh | sh

# Login to Supabase
supabase login

# Initialize in the project
supabase init
```

### STEP 3 — Apply the database schema

The schema is already written and waiting at `_config/supabase/schema.sql`.

```bash
# Option A — Apply directly via Supabase dashboard
# Go to: supabase.com → your project → SQL Editor
# Copy and paste _config/supabase/schema.sql → Run
# Then copy and paste _config/supabase/rls_policies.sql → Run

# Option B — Use the migration tool
bash tools/supabase-migrate.sh
```

After applying, verify in your Supabase dashboard:
- 6 tables exist: `practitioners`, `daily_entries`, `evidence_logs`, `sprint_tasks`, `offers`, `ai_suggestions`
- The `calculate_momentum_score` function exists under Database → Functions
- RLS is enabled on all 6 tables

### STEP 4 — Paste this prompt into Claude Code to start the build

```
You are Claude Code operating on the STB Command Center repo.

Read these files in order before doing anything:
1. CLAUDE.md (Layer 0 — global identity)
2. CONTEXT.md (Layer 1 — workspace routing)
3. stages/02_pwa_shell/CONTEXT.md (Layer 2 — Stage 02 contract)

The Supabase schema (Stage 01) is already applied to the database.
Skip Stage 01. Start at Stage 02.

Before writing any code, run:
/graphify .

Then execute Stage 02 only:
- Scaffold the React + TypeScript + Vite PWA
- Install all dependencies listed in the Stage 02 CONTEXT.md
- Build the file structure exactly as specified
- Wire Supabase auth (magic link, no password)
- Build TopBar, BottomNav, Shell layout, routing
- Create placeholder screens for Today, Evidence, Sprint, Offer
- Write all output to stages/02_pwa_shell/output/
- Write SHELL_SUMMARY.md explaining what was built and what Stage 03 plugs into

Stop when Stage 02 is complete. Do not proceed to Stage 03 until I confirm.

Environment variables needed (add to .env.local):
VITE_SUPABASE_URL=[your Supabase project URL]
VITE_SUPABASE_ANON_KEY=[your Supabase anon key]
VITE_ANTHROPIC_API_KEY=[your Anthropic API key]
```

### STEP 5 — Review Stage 02 output

When Claude Code stops, open `stages/02_pwa_shell/output/SHELL_SUMMARY.md`.

Check:
- [ ] Auth flow works (magic link → callback → redirect)
- [ ] Bottom nav shows 4 tabs with gold active state
- [ ] All 4 screen routes exist (even if just placeholder `<div>`)
- [ ] TypeScript types match the Supabase schema
- [ ] `.env.example` exists with blank keys

If looks good → say: **"Approved. Proceed to Stage 03."**

### STEP 6 — Stage 03 prompt

```
Stage 02 is approved. Read stages/03_today_screen/CONTEXT.md.

Execute Stage 03:
- Build TodayScreen.tsx (full implementation per the spec)
- Build EvidenceScreen.tsx (full implementation per the spec)  
- Build shared components: MomentumCard, DotStrip, SectionLabel, AIPill
- Wire to Supabase: daily_entries and evidence_logs tables
- Gate AI features behind tier check: {practitioner.tier === 'paid'}
- Write to stages/03_today_screen/output/

Load _config/design-system/tokens.md and _config/design-system/ux-copy.md 
as your design reference. Query the knowledge graph for anything doctrine-related:
/graphify query "One-Room Rule"
/graphify query "Evidence Over Vibes"

Stop when Stage 03 is complete. Report what was built.
```

### STEP 7 — Stage 04 prompt (after 03 approved)

```
Stage 03 is approved. Read stages/04_sprint_offer/CONTEXT.md.

Execute Stage 04:
- Build SprintScreen.tsx with task checkboxes, progress bar, leak zone tags
- Build OfferScreen.tsx with one-sentence field, doorway cards, leak zone bars
- Build useSprintTasks and useOffers hooks
- Wire trip wire button to pass {task_name, leak_zone, practitioner_id}
- Write to stages/04_sprint_offer/output/

Reference: /graphify query "leak zones"
Reference: _config/design-system/tokens.md for leak zone colors

Stop when Stage 04 is complete.
```

### STEP 8 — Stage 05 prompt (after 04 approved)

```
Stage 04 is approved. Read stages/05_claude_ai_layer/CONTEXT.md.

Execute Stage 05 — the AI integration:
- Create src/lib/claude.ts
- Create api/claude.ts (Vercel serverless function — API key stays server-side)
- Build 4 hooks: useTodaySuggestion, usePatternInsight, useTripWireDetector
- Create _config/doctrine/AI-PROMPT-TEMPLATES.md with all 4 prompt templates
- Model: claude-sonnet-4-6, max_tokens: 300, temperature: 0.3
- Pattern insight: only triggers at 14+ evidence log entries, never before
- Every suggestion stored in ai_suggestions table before displaying
- confirmed defaults false — Confirm button required, never auto-confirm

Load _config/doctrine/TRIP-WIRE-SYSTEM.md fully for the trip wire feature.
Load _config/brand-voice/guidelines.md for check-in draft voice.

Write to stages/05_claude_ai_layer/output/
Write AI_LAYER_SUMMARY.md

When Stage 05 is complete — this is Phase 1 complete. Report what was built.
```

### STEP 9 — Deploy to Vercel

After Stage 05 is approved:

```bash
# Add all env vars to Vercel dashboard first
# Then deploy from Claude Code:
vercel --prod

# OR push to main and let auto-deploy handle it:
git add .
git commit -m "Phase 1 complete: 4 screens + AI layer"
git push origin main
```

Your Vercel URL will be something like `stb-command-center.vercel.app`.

Update the Supabase auth redirect URL:
- Supabase dashboard → Authentication → URL Configuration
- Site URL: `https://stb-command-center.vercel.app`
- Redirect URLs: `https://stb-command-center.vercel.app/auth/callback`

---

## OPERATING IN VERCEL

### Environment Variables (set these in Vercel dashboard)

Go to: vercel.com → stb-command-center → Settings → Environment Variables

```
VITE_SUPABASE_URL          = https://[your-project-id].supabase.co
VITE_SUPABASE_ANON_KEY     = [your anon/public key from Supabase]
SUPABASE_SERVICE_ROLE_KEY  = [your service role key — NEVER expose client-side]
VITE_ANTHROPIC_API_KEY     = [your Anthropic key — passed to serverless function only]
```

**Important:** `SUPABASE_SERVICE_ROLE_KEY` and `VITE_ANTHROPIC_API_KEY` must only be used in the Vercel serverless function (`api/claude.ts`), never in client-side code.

### Auto-Deploy Setup

Every push to `main` on GitHub auto-deploys to production. To disable this temporarily:
- Vercel dashboard → stb-command-center → Settings → Git → uncheck "Auto Deploy"

### Preview Deployments

Every branch push creates a preview URL automatically. Use this for testing Stage outputs before merging to main.

### Checking Logs

```bash
# In Claude Code:
vercel logs stb-command-center --prod

# Or in Vercel dashboard:
# Deployments → click any deployment → Runtime Logs
```

### Custom Domain (when ready)

Vercel dashboard → stb-command-center → Settings → Domains → Add domain.

---

## OPERATING IN SUPABASE

### Finding your keys

Supabase dashboard → your project → Settings → API:
- `URL` → `VITE_SUPABASE_URL`
- `anon public` → `VITE_SUPABASE_ANON_KEY`
- `service_role` → `SUPABASE_SERVICE_ROLE_KEY` (keep secret)

### Checking the database

Supabase dashboard → Table Editor → you should see 6 tables after schema is applied.

### Checking auth

Supabase dashboard → Authentication → Users — practitioners who sign in appear here.

### Running the momentum score manually (for testing)

In Supabase SQL Editor:
```sql
SELECT calculate_momentum_score('[practitioner-uuid-here]');
```

### Checking RLS is working

In Supabase SQL Editor:
```sql
-- Should return policies for all 6 tables
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;
```

### Viewing evidence logs

```sql
SELECT
  e.date,
  e.did_it,
  e.momentum_score,
  e.note,
  p.name
FROM evidence_logs e
JOIN practitioners p ON p.id = e.practitioner_id
ORDER BY e.created_at DESC
LIMIT 20;
```

---

## GRAPHIFY COMMANDS (use throughout the build)

```bash
# Build/rebuild knowledge graph
/graphify .

# Query the graph instead of re-reading doctrine files
/graphify query "One-Room Rule"
/graphify query "Supabase practitioners table"
/graphify query "momentum score calculation"
/graphify query "leak zones"
/graphify query "trip wire types"
/graphify query "AI suggestion pill"

# Find connections between concepts
/graphify path "EvidenceLog" "MomentumScore"
/graphify path "TodayScreen" "Supabase"

# See key concepts and communities
cat graphify-out/GRAPH_REPORT.md
```

Run `/graphify .` after every stage completes. The graph updates automatically.

---

## AGENT-REACH COMMANDS (weekly signal intelligence)

```bash
# Run the signal fetch (do this weekly before a content or build sprint)
python3 tools/agent-reach-fetch.py

# Output lands in _config/signals/LATEST-SIGNAL-SUMMARY.md
# Load that file as Layer 3 context when generating AI suggestions

# Check agent-reach is configured correctly
agent-reach doctor

# See what platforms are active
agent-reach configure list
```

---

## REVIEW GATE PROTOCOL (critical — do not skip)

After every stage completes:

1. Read `stages/0N_name/output/[SUMMARY].md`
2. Check the verify checklist in the stage's `CONTEXT.md`
3. If approved: say **"Approved. Proceed to Stage N+1."**
4. If changes needed: edit the output files directly, then say **"Updated. Proceed to Stage N+1."**
5. Never let Claude Code auto-proceed. Always confirm.

This is the ICM architecture working as designed.

---

## BUILD PHASE MAP

| Phase | Stages | Goal | Status |
|-------|--------|------|--------|
| Phase 1 | 01–05 | Practitioner PWA ships to a real practitioner | **Build now** |
| Phase 2 | (none) | Get practitioner feedback, iterate | After Phase 1 ships |
| Phase 3 | 06 | Operator view: cohort dashboard, momentum board, trip wire inbox | After Phase 1 has a real user |
| Phase 4 | 07 | Tiers + Stripe payments, feature gating | After operator view is live |

**Do not build Stage 06 or 07 until Phase 1 ships to a real practitioner.**
Flo (Floortje de Liefde — breathwork practitioner) is the planned first test user.

---

## KEY REPOS AND TOOLS REFERENCED THIS SESSION

| Tool | URL |
|------|-----|
| STB Command Center repo | https://github.com/MajorDream444/STB-COMMAND-CENTER |
| SPARK-LAB-STB doctrine repo | https://github.com/MajorDream444/SPARK-LAB-STB |
| ICM paper (folder structure as agent architecture) | https://arxiv.org/abs/2603.16021 |
| ICM GitHub implementation | https://github.com/RinDig/Interpretable-Context-Methodology-ICM- |
| Graphify (knowledge graph) | https://github.com/Graphify-Labs/graphify |
| Agent-Reach (internet signal intel) | https://github.com/Panniantong/Agent-Reach |
| Impeccable (design craft skill) | https://github.com/pbakaus/impeccable |
| Supabase | https://supabase.com |
| Vercel | https://vercel.com |

---

## OPENING PROMPT FOR CLAUDE CODE

Copy and paste this as your very first message when you open Claude Code on this repo:

```
You are Claude Code operating on the STB Command Center — a two-sided 
PWA for the Spark Lab ecosystem. This repo uses Interpretable Context 
Methodology (ICM): folder structure replaces agent frameworks.

Start by reading these files in order:
1. CLAUDE.md
2. CONTEXT.md

Then run: /graphify .

Then tell me:
- What stage are we starting on?
- What files does that stage need from Layer 3?
- What is the first output you will produce?

Wait for my confirmation before executing anything.
```

---

*Systems create freedom. Build once. Scale forever.*
*— Major Dream Williams, Founder. Builder. Architect.*
