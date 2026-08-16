# UX Copy Guidelines — STB Command Center
**Layer 3 · Reference · from /design:ux-copy skill**

---

## Voice

**Core character:** Calm. Direct. Human. Never motivational. Never clinical.

This is a practitioner's quiet morning interface, not a productivity app that cheers them on. The copy should feel like a wise colleague who knows exactly what you're dealing with — not a coach, not a bot.

---

## The Five Rules

1. **Clear** — say exactly what you mean. No jargon. "Log today" not "Submit evidence entry."
2. **Concise** — fewest words that carry full meaning. If it can be shorter, make it shorter.
3. **Consistent** — same word for the same thing everywhere. "Action" not "task" sometimes and "action" others.
4. **Useful** — every word helps the practitioner do the thing. No decoration.
5. **Human** — write like a helpful person, not software.

---

## Specific Screen Copy

### Today Screen

| Element | Copy |
|---------|------|
| Greeting | "Good morning, [name]" (morning) / "Good afternoon, [name]" / "Good evening, [name]" |
| Date | "Sunday, August 16" — no year |
| Momentum label | "MOMENTUM SCORE" (all caps, small) |
| Streak | "12-day streak" |
| Focus placeholder | "What matters most today?" |
| Action placeholder | "The one thing you'll actually do." |
| Step placeholder | "The smallest possible start." |
| Log button (unlogged) | "Log today — did you do it?" |
| Log button (logged done) | "Logged ✓ — momentum score updated" |
| Log button (logged missed) | "Logged — no streak broken, just data" |
| AI suggestion prefix | "Claude suggests:" |
| AI confirm button | "Confirm" |
| AI edit button | "Edit" |
| Confirmed toast | "Confirmed — focus locked in" |

### Evidence Log Screen

| Element | Copy |
|---------|------|
| Screen title | "Evidence log" |
| Subtitle | "Reps, not vibes. Binary proof only." |
| Log button | "Log today — did you do it?" |
| After tap option A | "Did it ✓" |
| After tap option B | "Didn't ✗" |
| Section label | "7-DAY RECORD" |
| Score card labels | "Momentum score" / "Day streak" / "This week" |
| History section | "RECENT LOG" |
| AI insight label | "CLAUDE PATTERN INSIGHT" |
| No data state | "Start logging to see patterns here. Seven days builds the first picture." |

### Sprint Board Screen

| Element | Copy |
|---------|------|
| Screen title | "Sprint board" |
| Progress | "[N] of [total] complete · [remaining] remaining" |
| Active section | "ACTIVE" |
| Completed section | "COMPLETED" |
| Trip wire button | "Something hit a wall" |
| Empty sprint state | "No sprint active. Your operator will set one up." |

### Offer Clarity Screen

| Element | Copy |
|---------|------|
| Screen title | "Offer clarity" |
| One sentence label | "ONE SENTENCE" |
| Sentence placeholder | "I help [person] do [thing] so they can [result]…" |
| First doorway label | "FIRST DOORWAY" |
| Status: live | "Live" |
| Status: draft | "Draft" |
| Status: paused | "Paused" |
| Leak zones label | "LEAK ZONES ADDRESSED" |
| AI architect label | "OFFER ARCHITECT — CLAUDE SUGGESTS" |
| Apply button | "Apply edit" |
| Keep button | "Keep mine" |

### Onboarding Screen

| Element | Copy |
|---------|------|
| Eyebrow | "WELCOME TO STB COMMAND CENTER" |
| Headline | "The room is small. The path is clear." |
| Subtitle | "Three questions. Two minutes. Then you have a sprint, a focus, and a first doorway — nothing else." |
| Q1 label | "What do you do?" |
| Q1 hint | "One sentence. Who you help, and what they get." |
| Q2 label | "Where is the bleed?" |
| Q2 hint | "The one thing costing you clients right now." |
| Q3 label | "What does stable look like?" |
| Q3 hint | "One sentence on what you're working toward." |
| CTA step 1 | "Start with question 1" |
| CTA step 2 | "Continue to question 2" |
| CTA step 3 | "Open the room →" |
| Completion note | "Your first sprint is ready. Claude has mapped your bleed zone to a first doorway." |
| Footer note | "No fluff. No 47-step setup wizard. The room opens in under two minutes." |

### Auth Screen

| Element | Copy |
|---------|------|
| Title | "Enter the room" |
| Subtitle | "We'll send a link to your email. No password needed." |
| Email placeholder | "your@email.com" |
| Submit button | "Send me a link" |
| Sent state | "Link sent. Check your email." |
| Resend | "Send again" |

---

## Error Messages

Structure: What happened → what to do. Never apologise. Never vague.

| Context | Copy |
|---------|------|
| Email not found | "No account with that email. Check the spelling or contact your operator." |
| Magic link expired | "That link has expired. Request a new one." |
| Save failed | "Couldn't save. Check your connection and try again." |
| AI suggestion failed | "Couldn't load a suggestion right now. Try again in a moment." |
| No sprint assigned | "No active sprint. Your operator will assign one." |

---

## Empty States

Structure: What this is → why it's empty → what to do.

| Context | Copy |
|---------|------|
| No focus set | "What matters most today?" (placeholder handles this) |
| No evidence logs | "Start logging to see patterns here. Seven days builds the first picture." |
| No sprint tasks | "No active sprint. Your operator will set one up, or tap to create your own." |
| No offer | "No offer yet. Your operator will help you build the first doorway." |
| No AI suggestion | "No suggestion yet. Claude will offer one after your first log." |

---

## Words That Are Banned

| Never use | Use instead |
|-----------|------------|
| "Submit" | The action name (e.g. "Log", "Confirm", "Save") |
| "Successfully" | Just confirm with the action: "Logged ✓" |
| "Please" | Just the instruction |
| "leverage", "unlock", "empower" | Describe what it actually does |
| "simply" / "just" / "easy" | Cut it — it condescends |
| "dashboard" | "command center" or just the screen name |
| "data" (talking to practitioners) | "evidence" or "proof" |
| "AI" (in the UI) | "Claude" |

---

## Tone by Context

| Moment | Tone | Example |
|--------|------|---------|
| First open of the day | Calm, grounding | "Good morning, [name]" — nothing else needed |
| Checking the action box | Quiet acknowledgement | "Logged ✓" — no fanfare |
| Missed day | Matter-of-fact | "Logged — no streak broken, just data" |
| Trip wire / resistance | Gentle, non-alarmist | "Something hit a wall. Let's look at it." |
| AI confirmation | Assured | "Confirmed — focus locked in" |
| Error | Direct, helpful | "Couldn't save. Check your connection." |
