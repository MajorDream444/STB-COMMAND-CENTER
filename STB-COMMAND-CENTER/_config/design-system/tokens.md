# Design System Tokens
**Layer 3 · Reference · Stable across all runs**

---

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `--bg` | `#0d1f17` | Page background |
| `--surface` | `#122b1e` | Cards, momentum card |
| `--surface2` | `#183524` | Elevated surfaces |
| `--surface3` | `#1e3f2a` | Active states |
| `--gold` | `#c9a84c` | Primary accent: brand, CTAs, active nav, section labels |
| `--gold-15` | `rgba(201,168,76,0.15)` | Gold fills on dark bg |
| `--gold-08` | `rgba(201,168,76,0.08)` | Very subtle gold tint |
| `--gold-border` | `rgba(201,168,76,0.25)` | Card borders |
| `--cream` | `#f5f0e6` | Primary text |
| `--cream-70` | `rgba(245,240,230,0.7)` | Secondary text |
| `--cream-35` | `rgba(245,240,230,0.35)` | Muted text |
| `--cream-12` | `rgba(245,240,230,0.12)` | Subtle backgrounds |
| `--ember` | `#c1622d` | Warning, trip wire, pattern insight |
| `--ember-15` | `rgba(193,98,45,0.15)` | Ember tint backgrounds |
| `--teal` | `#5DCAA5` | Operations leak zone, success states |
| `--blue` | `#378ADD` | Visibility leak zone |
| `--purple` | `#7F77DD` | Delivery leak zone |
| `--sage` | `#8B9A85` | Mindset leak zone, inactive states |

---

## Typography

| Role | Font | Size | Weight | Notes |
|------|------|------|--------|-------|
| Display / greeting | Cormorant Garamond | 34px | 400 | "Good morning, Major" |
| Screen title | Cormorant Garamond | 28px | 400 | "Evidence log" |
| Momentum score | Cormorant Garamond | 72px | 400 | The big number |
| One Focus text | Cormorant Garamond | 22px | 400 | Editable field |
| Body / action text | DM Sans | 13–15px | 400 | Most copy |
| Section labels | DM Sans | 10px | 500 | "ONE FOCUS", letter-spacing 2.5px, uppercase |
| Muted/meta | DM Sans | 11–12px | 400 | Dates, notes |
| Tier badge | DM Sans | 9px | 500 | "PAID", letter-spacing 1.5px |

**Rule:** Never use font-weight 600 or 700. Max weight is 500 (medium). Heavier reads as wrong.

---

## Spacing

| Token | Value | Usage |
|-------|-------|-------|
| Page padding | 20px horizontal | Left/right margin on all screens |
| Card padding | 16–20px | Inside cards |
| Section gap | 20–24px | Between sections |
| Item gap | 6–8px | Within lists |
| Micro gap | 3–4px | Icon-to-text, label-to-value |

---

## Border Radius

| Context | Value |
|---------|-------|
| Cards | 12–14px |
| Buttons | 8–10px |
| Badges/pills | 20px (full pill) |
| Checkboxes | 50% (circles) |
| Dot strip dots | 50% (circles) |

---

## Motion

| Context | Duration | Easing |
|---------|----------|--------|
| Checkbox check | 200ms | ease-out |
| Score update | 300ms | ease-in-out |
| Progress bar fill | 500ms | ease-in-out |
| AI pill appear | 300ms | ease-out |
| Tab switch | 150ms | ease |

Never animate layout shifts. Only animate: opacity, transform, fill, color, width (progress bars).

---

## Component Patterns

### Momentum Card
```
bg: --surface
border: 1px solid rgba(201,168,76,0.12)
border-radius: 14px
padding: 20px 20px 18px
```
Score: Cormorant 72px gold  
Label: DM Sans 10px muted, letter-spacing 2.5px, uppercase  
Streak: DM Sans 13px, cream 65%  
Dot strip: 7 dots, 10px diameter, 8px gap

### Section Label
```
font: DM Sans 10px 500
letter-spacing: 2.5px
color: --gold
text-transform: uppercase
margin-bottom: 10px
```

### Checkbox (action)
```
width: 24px, height: 24px
border-radius: 50%
border: 1.5px solid rgba(201,168,76,0.5)
transition: all 200ms
```
Checked: `background: --gold; border-color: --gold`  
Check mark: `✓` in `#0d1f17`, 13px, font-weight 700

### AI Suggestion Pill
```
background: rgba(201,168,76,0.06)
border: 1px solid rgba(201,168,76,0.25)
border-radius: 12px
padding: 12px 14px
```
Icon: 20px box, `rgba(201,168,76,0.15)` bg, 6px radius  
Text: DM Sans 13px, cream 85%  
"Claude suggests:" — gold, font-weight 600  
Confirm button: gold filled, `#0d1f17` text, 700 weight  
Edit button: ghost, cream 60%

### Bottom Navigation
```
background: rgba(13,31,23,0.96)
backdrop-filter: blur(8px)
border-top: 1px solid rgba(201,168,76,0.12)
padding: 8px 0 16px (accounts for iOS home bar)
```
Active: gold icon + gold label  
Inactive: cream 30%  
Label: DM Sans 9px, letter-spacing 1px, uppercase

---

## Leak Zone Colors (all 6)

| Zone | Color | Hex |
|------|-------|-----|
| Offer clarity | Gold | `#c9a84c` |
| Operations | Teal | `#5DCAA5` |
| Visibility | Blue | `#378ADD` |
| Pricing confidence | Ember | `#c1622d` |
| Delivery | Purple | `#7F77DD` |
| Mindset | Sage | `#8B9A85` |

---

## Rules That Cannot Be Broken

1. **No shadows** — no `box-shadow` anywhere. Depth through color, not shadow.
2. **No gradients** — except the momentum score area can use a subtle radial if absolutely needed.
3. **Max 3 items visible** on Today screen before scroll — One-Room Rule.
4. **Gold fills only primary actions** — Confirm button is the only gold-filled button on any given screen.
5. **No emoji in UI** — icons from Tabler icons only.
6. **Never placeholder text that says "Enter..."** — placeholders should be examples: "I help coaches build their first stable offer."
