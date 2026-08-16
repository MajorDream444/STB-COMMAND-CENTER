# Stage 04 — Sprint Board + Offer Clarity
**Layer 2 · Stage Contract · ~400 tokens**

---

## Inputs

| Layer | File | Purpose |
|-------|------|---------|
| L4 (working) | `stages/03_today_screen/output/SCREEN_SUMMARY.md` | Components to reuse |
| L4 (working) | `stages/03_today_screen/output/src/components/` | AIPill, SectionLabel, etc |
| L3 (reference) | `_config/design-system/tokens.md` | Design tokens |
| L3 (reference) | `_config/doctrine/STB-CORE-DOCTRINE.md` | The 6 leak zones — Sprint tasks reference these |
| L3 (reference) | `_config/doctrine/ONE-ROOM-RULE.md` | Max visible tasks rule |

---

## Process

### Screen 3 — Sprint Board (`src/screens/Sprint/SprintScreen.tsx`)

```
TopBar
│
├── Header
│   ├── "Sprint board" — Cormorant 28px
│   ├── "Day [N] of [7 or 14]" — muted
│   └── Sprint tag pill — "STOP THE BLEED" gold border
│
├── Progress bar
│   ├── Thin 3px bar, gold fill, cream-4% track
│   └── "[N] of [total] complete · [remaining] remaining" — muted 10px
│
├── Active tasks section (label: "ACTIVE")
│   └── Each task card (bg: surface, border: transparent → gold 15% on hover)
│       ├── Checkbox (circle, 20px, gold on check with ✓)
│       ├── Task name (cream 13px, strikethrough when done)
│       └── Leak zone tag (color-coded: offer=gold, ops=teal #5DCAA5, content=ember)
│
├── Trip wire button
│   ├── Ember border, ember text
│   ├── "⚠ Something hit a wall — run trip wire detector"
│   └── On tap → send to AI layer (Stage 05) with task context
│
└── Completed tasks section (collapsible, "COMPLETED" label)
    └── Same cards, 50% opacity, all checked

BottomNav
```

**Behaviour:**
- Tap checkbox → optimistic update → `sprint_tasks.done=true` → progress bar recalculates
- Max 5 active tasks visible before "show more" — One-Room Rule
- Leak zone colors: hard-coded per zone (not dynamic), matches doctrine's 6 zones:
  `offer_clarity` → gold, `operations` → teal, `visibility` → blue #378ADD, `pricing` → ember, `delivery` → purple #7F77DD, `mindset` → sage #8B9A85

### Screen 4 — Offer Clarity (`src/screens/Offer/OfferScreen.tsx`)

```
TopBar
│
├── Header: "Offer clarity"
│
├── One sentence card (bg: surface)
│   ├── Label: "ONE SENTENCE"
│   └── Editable textarea (Cormorant italic, cream)
│       placeholder: "I help [person] do [thing] so they can [result]…"
│
├── First doorway card
│   ├── Label: "FIRST DOORWAY" + status badge (Live=teal / Draft=ember)
│   ├── Offer name — Cormorant 20px
│   ├── Price — gold 15px
│   └── Leak zone tags (small pills, cream-4% bg)
│
├── Second doorway card (muted, 60% opacity if draft)
│   └── Same structure, status=Draft
│
├── AI offer architect pill (paid tier only)
│   ├── Gold border + suggestion text
│   └── "Apply edit" (gold filled) + "Keep mine" (ghost)
│
└── Leak zones addressed (progress bars)
    └── Each of the 6 zones with a gold fill bar showing % addressed

BottomNav
```

**Behaviour:**
- `one_sentence` debounce-saves to `practitioners.one_sentence` (500ms)
- `is_first_doorway` toggle — only one offer can be first doorway (enforced by partial unique index from Stage 01)
- Offer status toggle: Draft → Live → Paused (tap cycles)
- "Apply edit" → patches `practitioners.one_sentence` with AI suggestion → `ai_suggestions.confirmed=true`

---

## Outputs

```
output/
├── src/
│   ├── screens/
│   │   ├── Sprint/SprintScreen.tsx
│   │   └── Offer/OfferScreen.tsx
│   └── hooks/
│       ├── useSprintTasks.ts
│       └── useOffers.ts
└── SCREEN_SUMMARY.md
```

`SCREEN_SUMMARY.md` must include:
- Leak zone color map (all 6 zones, hex values)
- Trip wire button: what data it passes to Stage 05
- Offer status cycle: what each state means
- What Stage 05 needs (which screens show AI pills, what prompts they generate)

---

## Verify

- [ ] Max 5 active tasks before "show more" — One-Room Rule
- [ ] Trip wire button passes `{task_name, leak_zone, practitioner_id}` — Stage 05 needs this
- [ ] Offer `is_first_doorway` is mutually exclusive — test with 2 offers
- [ ] AI pills are tier-gated consistently with Stage 03 pattern

---

## Stop Here

Report: "Stage 04 complete. Review `stages/04_sprint_offer/output/SCREEN_SUMMARY.md`. 4 screens are now complete. Approve before Stage 05 (AI layer)."
