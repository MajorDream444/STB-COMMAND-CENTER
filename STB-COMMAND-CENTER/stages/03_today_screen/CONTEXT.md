# Stage 03 — Today Screen + Evidence Log
**Layer 2 · Stage Contract · ~450 tokens**

---

## Inputs

| Layer | File | Purpose |
|-------|------|---------|
| L4 (working) | `stages/02_pwa_shell/output/SHELL_SUMMARY.md` | What hooks exist, what to plug into |
| L4 (working) | `stages/02_pwa_shell/output/src/hooks/` | Existing hook signatures |
| L3 (reference) | `_config/design-system/tokens.md` | Colors, fonts, exact values |
| L3 (reference) | `_config/design-system/components.md` | Momentum card, dot strip, AI pill specs |
| L3 (reference) | `_config/doctrine/EVIDENCE-OVER-VIBES.md` | Why binary — do not compromise this |
| L3 (reference) | `_config/doctrine/ONE-ROOM-RULE.md` | Why the room must stay small |

---

## Process

Build two complete, production-ready screens. These are the screens a practitioner opens every morning.

### Screen 1 — Today (`src/screens/Today/TodayScreen.tsx`)

Visual reference: the Claude Design mockup approved in the design session.

**Structure (top to bottom):**

```
TopBar (from Shell — already built)
│
├── Greeting section
│   ├── "Good morning, [name]" — Cormorant Garamond 34px, cream
│   └── Date — DM Sans 13px, muted cream
│
├── Momentum card (full width, bg: #122b1e, border: gold 8% opacity)
│   ├── Score number — Cormorant Garamond 72px, gold
│   ├── "MOMENTUM SCORE" — DM Sans 10px, letter-spacing 2.5px, muted
│   ├── "[N]-day streak" — DM Sans 13px, cream 65%
│   └── 7-dot strip — done=gold filled, missed=cream 15%, today=gold outline
│
├── ONE FOCUS section
│   ├── Label: "ONE FOCUS" — gold, 10px, letter-spacing 2.5px
│   └── Editable textarea — Cormorant Garamond 22px, cream, no border
│       placeholder: "What matters most today?"
│
├── ONE ACTION section
│   ├── Label: "ONE ACTION"
│   ├── Checkbox row — 24px circle, gold border → gold fill on check
│   ├── Action text — cream 18px, strikes through on check
│   └── ONE STEP sub-row — tiny "ONE STEP" label + muted text
│
└── AI Suggestion pill (paid tier only)
    ├── Gold border, #gold3 background
    ├── Star icon (4-point, 11px, gold fill)
    ├── "Claude suggests: [text] ↗"
    └── Confirm button (gold filled) + Edit button (ghost)

BottomNav (from Shell — already built)
```

**Behaviour:**
- Load today's `daily_entries` row on mount (or create if none)
- Debounce-save `one_focus` and `one_action` text as user types (500ms)
- Checking the checkbox → sets `action_done=true` → calls `useMomentumScore` to refresh score
- Confirm on AI pill → sets `ai_suggestions.confirmed=true` → applies suggestion to `one_focus`
- Edit on AI pill → focuses the `one_focus` textarea

### Screen 2 — Evidence Log (`src/screens/Evidence/EvidenceScreen.tsx`)

**Structure:**

```
TopBar
│
├── Header
│   ├── "Evidence log" — Cormorant Garamond 28px
│   └── "Reps, not vibes. Binary proof only." — DM Sans 12px, muted
│
├── Log Today button (full width, gold filled)
│   ├── Shows "Log today — did you do it?" if not logged
│   └── After tap: shows ✓ "Logged" with score update
│   └── Two options inline: "Did it ✓" | "Didn't ✗" — both are valid
│
├── 7-day strip (same dot pattern as Today card)
│
├── Score row (3 metric cards side by side)
│   ├── Momentum score (live)
│   ├── Streak days
│   └── This week (N/7)
│
├── Log history (scrollable)
│   ├── Each entry: colored dot (gold=done, muted=missed) + action text + date
│   ├── Strikethrough on done entries
│   └── Optional note in italic muted text
│
└── AI pattern insight pill (paid tier only)
    ├── Ember border + background tint
    ├── "CLAUDE PATTERN INSIGHT" label
    └── Insight text based on last 14 days of logs

BottomNav
```

**Behaviour:**
- Log button tap → inline choice: "Did it" / "Didn't" — no modal, inline confirmation
- Both choices create an `evidence_logs` row with `did_it=true/false`
- Momentum score recalculates immediately via `calculate_momentum_score` RPC call
- History loads last 14 entries, newest first
- Pattern insight shows only if `tier = 'paid'` — gate clearly, no teaser

### Shared Components to Create

```
src/components/
├── MomentumCard.tsx             ← reusable between Today and Evidence
├── DotStrip.tsx                 ← 7-day dot strip, takes history array
├── SectionLabel.tsx             ← "ONE FOCUS" style label (already listed in Stage 02 but build here)
└── AIPill.tsx                   ← suggestion pill (already listed but implement here)
```

---

## Outputs

Write all output to `stages/03_today_screen/output/`:

```
output/
├── src/
│   ├── screens/
│   │   ├── Today/TodayScreen.tsx
│   │   └── Evidence/EvidenceScreen.tsx
│   ├── components/
│   │   ├── MomentumCard.tsx
│   │   ├── DotStrip.tsx
│   │   ├── SectionLabel.tsx
│   │   └── AIPill.tsx
│   └── hooks/
│       ├── useDailyEntry.ts     ← update/extend if needed
│       └── useEvidenceLog.ts    ← update/extend if needed
└── SCREEN_SUMMARY.md
```

`SCREEN_SUMMARY.md` must include:
- Screenshot description of each screen (what renders on first open)
- All Supabase queries made by each screen
- Tier gates: what free users see vs paid users see
- What Stage 04 needs to wire into (hooks, components it can reuse)

---

## Verify

- [ ] `did_it` in evidence log is strictly `true` or `false` — no null, no scale
- [ ] AI suggestions are gated: `{practitioner.tier === 'paid' && <AIPill />}`
- [ ] Confirm button calls `useMutation` to set `confirmed=true` — never auto-confirms
- [ ] Today screen shows max 3 active items (focus, action, step) — One-Room Rule
- [ ] Score updates immediately after logging — no page refresh needed
- [ ] Momentum card is the same component used in both screens

---

## Stop Here

After writing all output files, stop.
Report: "Stage 03 complete. Open `stages/03_today_screen/output/SCREEN_SUMMARY.md` and review both screens before Stage 04."
