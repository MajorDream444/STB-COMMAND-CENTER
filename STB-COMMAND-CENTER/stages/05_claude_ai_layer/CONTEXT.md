# Stage 05 — Claude AI Layer
**Layer 2 · Stage Contract · ~400 tokens**

---

## Inputs

| Layer | File | Purpose |
|-------|------|---------|
| L4 (working) | `stages/04_sprint_offer/output/SCREEN_SUMMARY.md` | Which screens need AI, what data is passed |
| L3 (reference) | `_config/doctrine/TRIP-WIRE-SYSTEM.md` | Trip wire types + correct responses |
| L3 (reference) | `_config/doctrine/EVIDENCE-OVER-VIBES.md` | Pattern insight logic |
| L3 (reference) | `_config/signals/` | Latest Agent-Reach signal drop (if available) |
| L3 (reference) | `_config/brand-voice/guidelines.md` | Claude must write in Major Dream's voice |

---

## Process

Wire four AI features. All use `claude-sonnet-4-6`. All require human confirmation before any action.

**Core rule:** Claude never acts. Claude suggests. The practitioner or operator confirms.

### Feature 1 — Today Focus Suggestion

Triggered when: practitioner opens Today screen and has no `one_focus` set yet.

Input to Claude:
- Last 3 `daily_entries` (focus + done status)
- Last 7 `evidence_logs` (did_it + note)
- Current `sprint_tasks` (active, undone)
- Practitioner's `one_sentence` offer

Prompt template in `_config/doctrine/` (create `AI-PROMPT-TEMPLATES.md`):
```
You are the STB Command Center AI for [name], a [description from one_sentence].

Based on their recent sprint tasks and evidence, suggest ONE focus for today.
Format: a single sentence, plain language, action-oriented.
Maximum 15 words. No motivational filler. Just the next concrete thing.

Recent evidence: [last 7 logs]
Active sprint tasks: [undone tasks]
```

Output: stored in `ai_suggestions` with `type='next_action'`.
Display: AIPill on Today screen. Gold border. "Claude suggests: [text] ↗"

### Feature 2 — Evidence Pattern Insight

Triggered when: practitioner views Evidence screen and has 14+ days of logs.

Input to Claude:
- Last 14 `evidence_logs` with notes
- `sprint_tasks` leak zone distribution

Prompt: surface one specific, non-obvious pattern. No generic advice.
Example output: "You complete offer-facing tasks 3× faster than systems tasks. Consider scheduling systems work before 10am."

Output: `ai_suggestions` with `type='pattern_insight'`. Ember pill on Evidence screen.

### Feature 3 — Trip Wire Detector

Triggered when: practitioner taps "Something hit a wall" on Sprint screen.

Input to Claude:
- Task name + leak zone
- Last 3 evidence log entries
- Practitioner's `one_sentence` + `bleed_zone`

Load `_config/doctrine/TRIP-WIRE-SYSTEM.md` fully for this call.

Prompt: identify the trip wire type (somatic / identity / relational / logistical / clarity / consent) and return:
1. The type
2. The correct immediate response (from doctrine)
3. The smallest next action

Output: operator sees this in their trip wire inbox (Stage 06). Practitioner sees a calm, human message — not a diagnosis.

### Feature 4 — Check-In Draft (operator only)

Triggered when: operator requests a check-in for a practitioner.

Input to Claude:
- Full practitioner profile
- Last 14 days evidence log
- Current sprint status
- Any trip wire flags

Prompt: write a warm, human check-in message in Major Dream's voice (load brand voice guidelines).
Output: `ai_suggestions` with `type='check_in_draft'`. Operator edits and sends.

### API Integration

```typescript
// src/lib/claude.ts
export async function getClaude(prompt: string, systemPrompt: string) {
  const response = await fetch('/api/claude', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt, systemPrompt })
  });
  return response.json();
}
```

Create a Vercel serverless function `api/claude.ts` that proxies to Anthropic — keeps the API key server-side.

Model: `claude-sonnet-4-6`
Max tokens: 300 (suggestions are short by design)
Temperature: 0.3 (consistent, not creative)

---

## Outputs

```
output/
├── src/
│   ├── lib/claude.ts
│   └── hooks/
│       ├── useTodaySuggestion.ts
│       ├── usePatternInsight.ts
│       └── useTripWireDetector.ts
├── api/
│   └── claude.ts                ← Vercel serverless function
├── _config/
│   └── doctrine/AI-PROMPT-TEMPLATES.md   ← all 4 prompt templates
└── AI_LAYER_SUMMARY.md
```

`AI_LAYER_SUMMARY.md` must include:
- Average token cost per feature call (estimated)
- Which features are free-tier vs paid-tier
- Trip wire types supported and their response patterns
- What Stage 06 (operator view) plugs into

---

## Verify

- [ ] API key never appears in client-side code — proxied through Vercel function
- [ ] Every suggestion stored in `ai_suggestions` before displaying — no ephemeral suggestions
- [ ] `confirmed` defaults false — Confirm button required for every suggestion
- [ ] Trip wire detector loads full TRIP-WIRE-SYSTEM.md — do not summarize it
- [ ] Pattern insight only triggers at 14+ log entries — no fake insights from thin data
- [ ] Check-in draft is operator-only — `{practitioner.tier === 'operator'}` gate

---

## Stop Here

Report: "Stage 05 complete. All four AI features are wired. Review `AI_LAYER_SUMMARY.md` — this is the Phase 1 completion checkpoint. Approve to ship to Vercel."
