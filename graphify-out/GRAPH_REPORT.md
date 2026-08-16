# Graph Report - STB-COMMAND-CENTER  (2026-08-16)

## Corpus Check
- 19 files · ~55,956 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 173 nodes · 227 edges · 14 communities (11 shown, 3 thin omitted)
- Extraction: 83% EXTRACTED · 16% INFERRED · 1% AMBIGUOUS · INFERRED: 37 edges (avg confidence: 0.85)
- Token cost: 219,282 input · 0 output

## Community Hubs (Navigation)
- Phase 1 Screen Architecture
- AI Layer and Deploy Stack
- ICM Context Architecture Theory
- Design Tokens and One-Room Rule
- Today and Evidence Screens
- Supabase Schema Objects
- UX Copy and Trip Wire
- Momentum Score and Review Gates
- Agent-Reach Signal Fetcher
- PWA Shell Navigation
- Typography and Section Labels
- PWA Manifest and Routing
- Supabase Migration Script

## God Nodes (most connected - your core abstractions)
1. `Interpretable Context Methodology (ICM)` - 11 edges
2. `Today Screen` - 10 edges
3. `One-Room Rule` - 9 edges
4. `Evidence Log Screen` - 9 edges
5. `Sprint Board Screen` - 9 edges
6. `practitioners` - 8 edges
7. `practitioners table` - 8 edges
8. `Offer Clarity Screen` - 8 edges
9. `Shared Chrome` - 8 edges
10. `Bottom Nav (mobile)` - 6 edges

## Surprising Connections (you probably didn't know these)
- `One-Room Rule` --semantically_similar_to--> `Layered Context Loading`  [INFERRED] [semantically similar]
  STB-COMMAND-CENTER/_config/doctrine/ONE-ROOM-RULE.md → Folder Structure and Architecture.pdf
- `Source of Truth Hierarchy` --semantically_similar_to--> `Stage Contract Inputs Table (Layer 2 control point)`  [INFERRED] [semantically similar]
  STB-COMMAND-CENTER/CLAUDE.md → Folder Structure and Architecture.pdf
- `Consent Before Extraction` --semantically_similar_to--> `Human Oversight and Interpretability`  [INFERRED] [semantically similar]
  STB-COMMAND-CENTER/CLAUDE.md → Folder Structure and Architecture.pdf
- `Evidence Over Vibes` --semantically_similar_to--> `Every Output Is an Edit Surface`  [INFERRED] [semantically similar]
  STB-COMMAND-CENTER/_config/doctrine/EVIDENCE-OVER-VIBES.md → Folder Structure and Architecture.pdf
- `Graphify Knowledge Graph Integration` --conceptually_related_to--> `Layered Context Loading`  [INFERRED]
  STB-COMMAND-CENTER/CLAUDE.md → Folder Structure and Architecture.pdf

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **ICM Five-Layer Context Stack as Realized in the STB Repo** — stb_command_center_claude_icm, stb_command_center_context_routing_rules, stb_command_center_context_stage_map, folder_structure_and_architecture_five_layer_context_hierarchy, folder_structure_and_architecture_layer_3_reference_material, folder_structure_and_architecture_layer_4_working_artifacts, stb_command_center_claude_code_handoff_five_layer_context_hierarchy [EXTRACTED 1.00]
- **The Six-Table Supabase Schema** — stb_command_center_stages_01_supabase_schema_context_practitioners_table, stb_command_center_stages_01_supabase_schema_context_daily_entries_table, stb_command_center_stages_01_supabase_schema_context_evidence_logs_table, stb_command_center_stages_01_supabase_schema_context_sprint_tasks_table, stb_command_center_stages_01_supabase_schema_context_offers_table, stb_command_center_stages_01_supabase_schema_context_ai_suggestions_table, stb_command_center_stages_01_supabase_schema_context_row_level_security [EXTRACTED 1.00]
- **Four AI Features Under the Confirm-Before-Act Flow** — stb_command_center_stages_05_claude_ai_layer_context_today_focus_suggestion, stb_command_center_stages_05_claude_ai_layer_context_evidence_pattern_insight, stb_command_center_stages_05_claude_ai_layer_context_trip_wire_detector, stb_command_center_stages_05_claude_ai_layer_context_check_in_draft, stb_command_center_stages_05_claude_ai_layer_context_claude_api_proxy, stb_command_center_stages_01_supabase_schema_context_ai_suggestions_table, stb_command_center_claude_consent_before_extraction [EXTRACTED 1.00]
- **Four-screen practitioner IA reachable from one nav** — stb_command_center_ia_today_screen, stb_command_center_ia_evidence_log_screen, stb_command_center_ia_sprint_board_screen, stb_command_center_ia_offer_clarity_screen, stb_command_center_ia_bottom_nav [EXTRACTED 1.00]
- **Paid Claude AI layer gated by tier badge** — stb_command_center_ia_ai_prompt_paid, stb_command_center_ia_pattern_insight_paid, stb_command_center_ia_offer_architect_paid, stb_command_center_ia_tier_badge, stb_command_center_ia_ai_assisted_human_confirmed [INFERRED 0.85]
- **Action → evidence → momentum score loop** — stb_command_center_ia_one_action, stb_command_center_ia_log_entry, stb_command_center_ia_momentum_score_calc, stb_command_center_ia_momentum_score, stb_command_center_ia_history_strip [EXTRACTED 1.00]

## Communities (14 total, 3 thin omitted)

### Community 0 - "Phase 1 Screen Architecture"
Cohesion: 0.10
Nodes (27): Active Tasks (3–5 max), Auth Gate (Supabase magic link), Bottom Nav (mobile), Completed Section (collapsed), Doorway Status (draft / live / needs work), First Doorway (active offer), Leak Zone Tag, Leak Zones Linked to Offer (+19 more)

### Community 1 - "AI Layer and Deploy Stack"
Cohesion: 0.09
Nodes (23): Human Oversight and Interpretability, AI Suggestion Pill Component Pattern, Claude AI Layer, Anthropic API (claude-sonnet-4-6), Build Phase Map (Phases 1-4), Vercel Deployment and Env Var Split, Consent Before Extraction, Flo (Floortje de Liefde) (+15 more)

### Community 2 - "ICM Context Architecture Theory"
Cohesion: 0.10
Nodes (22): Configure the Factory, Not the Product, Context Engineering, David McDermott, Five-Layer Context Hierarchy, Interpretable Context Methodology (ICM), Jake Van Clief, Layer 3 — Reference Material (the factory), Layer 4 — Working Artifacts (the product) (+14 more)

### Community 3 - "Design Tokens and One-Room Rule"
Cohesion: 0.12
Nodes (20): Color Palette Tokens, Leak Zone Color Map (6 zones), Momentum Card Component Pattern, Rules That Cannot Be Broken, Error Message Structure (What happened -> what to do), One-Room Rule, The Operator Exception, The 7am Test Question (+12 more)

### Community 4 - "Today and Evidence Screens"
Cohesion: 0.16
Nodes (18): AI-Assisted, Human-Confirmed, AI Prompt (paid) — Claude suggests today's focus, ai_suggestions (Supabase table), daily_entries (Supabase table), Evidence Log Screen, evidence_logs (Supabase table), Evidence Over Vibes, History Strip (7-day dots) (+10 more)

### Community 5 - "Supabase Schema Objects"
Cohesion: 0.19
Nodes (15): auth, auth.users, ai_suggestions, daily_entries, daily_entries_updated_at, evidence_log_momentum, evidence_logs, offers (+7 more)

### Community 6 - "UX Copy and Trip Wire"
Cohesion: 0.15
Nodes (17): Banned Words List, The Five Copy Rules (Clear, Concise, Consistent, Useful, Human), UX Copy Voice — Calm, Direct, Human, Discomfort -> Observation -> Data -> Clarity Sequence, Pattern Insight Rules, Stability Seeker Archetype, Trip Wire System, ai_suggestions table (+9 more)

### Community 7 - "Momentum Score and Review Gates"
Cohesion: 0.31
Nodes (9): Every Output Is an Edit Surface, Empty State Structure, Evidence Over Vibes, Momentum Score (0-100), Review Gate Protocol, Review Gate, calculate_momentum_score (Postgres function), evidence_logs table (+1 more)

### Community 8 - "Agent-Reach Signal Fetcher"
Cohesion: 0.22
Nodes (8): fetch_reddit_signals(), fetch_twitter_signals(), Fetch Twitter/X signal threads for STB keywords., Fetch Reddit signal threads from coaching/solopreneur subs., Write signals to Layer 3 reference file., Write human-readable summary for Claude Code to load as L3 reference., write_signal_file(), write_signal_summary()

### Community 9 - "PWA Shell Navigation"
Cohesion: 0.50
Nodes (4): Bottom Navigation Component Pattern, BottomNav, Shell Layout, TopBar

## Ambiguous Edges - Review These
- `Graphify Knowledge Graph Integration` → `Agent-Reach Signal Intelligence`  [AMBIGUOUS]
  STB-COMMAND-CENTER/CLAUDE.md · relation: conceptually_related_to
- `Flo (Floortje de Liefde)` → `Josephine`  [AMBIGUOUS]
  STB-COMMAND-CENTER/CLAUDE.md · relation: conceptually_related_to

## Knowledge Gaps
- **34 isolated node(s):** `supabase-migrate.sh script`, `BWYH (Build While You Heal)`, `Major Dream Williams`, `Supabase (PostgreSQL + Magic Link Auth)`, `Typography Scale (Cormorant Garamond + DM Sans)` (+29 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Graphify Knowledge Graph Integration` and `Agent-Reach Signal Intelligence`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Flo (Floortje de Liefde)` and `Josephine`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `Interpretable Context Methodology (ICM)` connect `ICM Context Architecture Theory` to `Momentum Score and Review Gates`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `One-Room Rule` connect `Design Tokens and One-Room Rule` to `ICM Context Architecture Theory`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `Layered Context Loading` connect `ICM Context Architecture Theory` to `Design Tokens and One-Room Rule`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `One-Room Rule` (e.g. with `Layered Context Loading` and `daily_entries table`) actually correct?**
  _`One-Room Rule` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `supabase-migrate.sh script`, `BWYH (Build While You Heal)`, `Major Dream Williams` to the rest of the system?**
  _34 weakly-connected nodes found - possible documentation gaps or missing edges._