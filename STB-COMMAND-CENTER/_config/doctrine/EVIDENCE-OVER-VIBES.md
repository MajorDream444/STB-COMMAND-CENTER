# Evidence Over Vibes
**STB Core Doctrine · Layer 3 Reference**

---

## The Principle

Don't chase feelings. Track reps. Evidence compounds.

The Stability Seeker — the overwhelmed gifted practitioner — has typically been running on vibes for years. They feel confident some days, terrified others. They interpret a good client conversation as proof the business is working, a quiet week as proof it isn't.

This is not data. It is emotional weather.

The STB Command Center does not ask how you feel. It asks what you did.

---

## Applied to the Evidence Log

The `did_it` field in `evidence_logs` is strictly boolean. True or false. Not a scale of 1–5. Not "how well did you do it." Not nullable.

You did it or you didn't. Both are valid data points.

**Why binary:**
- Scales invite self-assessment, which reintroduces vibes
- Binary forces clarity: what exactly was the task? (If you're unsure whether you "did it," the task definition was unclear — that's the problem to solve)
- Evidence needs to be countable. 5 out of 7 is a real number. "Mostly 3–4 out of 5" is noise.

---

## The Momentum Score

The momentum score (0–100) is computed, not felt. It is:
- Weighted: last 7 days = 70%, prior 7 days = 30%
- Streak-boosted: consecutive days add +2 each (max +20)
- Never manually adjusted

A practitioner cannot set their own momentum score. They can only affect it by logging.

---

## The Discomfort → Observation → Data → Clarity Sequence

When a practitioner wants to quit something — a strategy, an offer, a niche — the doctrine says:

1. **Discomfort** — notice it. Don't act on it.
2. **Observation** — what specifically is uncomfortable? Name it.
3. **Data** — what does the evidence log actually show? How many days have you tried this? What happened?
4. **Clarity** — from that data, make the decision.

The problem is making a permanent decision from a temporary emotion. The evidence log exists to interrupt that pattern.

**In the app:** The "Claude pattern insight" feature on the Evidence screen uses this sequence. It waits for 14 days of data before generating a pattern — never from thin data.

---

## Pattern Insight Rules (for Claude AI layer)

When generating pattern insights:
- Surface specific, non-obvious patterns only. Not "you're doing great."
- Use actual data: "You complete offer-facing tasks 3× faster than systems tasks."
- Suggest a systemic change, not a motivational nudge: "Consider scheduling systems work before 10am."
- Never offer a pattern with fewer than 14 days of logs. Return nothing instead.
- One insight at a time. Never stack multiple.

---

## What This Rule Prevents

- Coaching based on feelings ("I feel like my offer isn't working")
- Premature pivots from fear rather than data
- Practitioners quitting things that are actually working
- The operator making decisions about a client based on vibes

---

## Copy Implications

Evidence log subtitle: "Reps, not vibes. Binary proof only."
Log button (after missed day): "Logged — no streak broken, just data"
Empty log state: "Start logging to see patterns here. Seven days builds the first picture."

Never use: "How are you feeling?" or "Rate your session."
