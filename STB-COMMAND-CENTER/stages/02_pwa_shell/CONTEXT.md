# Stage 02 — React PWA Shell
**Layer 2 · Stage Contract · ~400 tokens**

---

## Inputs

| Layer | File | Purpose |
|-------|------|---------|
| L4 (working) | `stages/01_supabase_schema/output/SCHEMA_SUMMARY.md` | Table names + auth flow to wire |
| L3 (reference) | `_config/design-system/tokens.md` | Colors, fonts, spacing — exact values |
| L3 (reference) | `_config/design-system/ux-copy.md` | Copy patterns, sentence case rules |
| L3 (reference) | `_config/brand-voice/guidelines.md` | Major Dream voice for any copy |

Do not load doctrine files at this stage. Shell work does not need STB philosophy — only structure, routing, and design tokens.

---

## Process

Scaffold a production-ready Vite + React + TypeScript PWA. This is the skeleton every screen plugs into.

### 1. Project Setup

```bash
npm create vite@latest stb-command-center -- --template react-ts
cd stb-command-center
npm install
npm install -D tailwindcss postcss autoprefixer vite-plugin-pwa
npm install @supabase/supabase-js
npm install @tanstack/react-query
npm install react-router-dom
npm install @fontsource/cormorant-garamond @fontsource/dm-sans
```

### 2. Tailwind Config

Configure Tailwind with the exact design tokens from `_config/design-system/tokens.md`. Add custom colors as CSS variables and Tailwind extensions:

```js
// tailwind.config.js
colors: {
  bg: '#0d1f17',
  surface: '#122b1e',
  surface2: '#183524',
  gold: '#c9a84c',
  cream: '#f5f0e6',
  ember: '#c1622d',
}
```

### 3. File Structure

```
src/
├── main.tsx
├── App.tsx                      ← Router + QueryClientProvider + SupabaseProvider
├── lib/
│   ├── supabase.ts              ← createClient with env vars
│   └── queryClient.ts
├── contexts/
│   └── AuthContext.tsx          ← session, practitioner profile, tier
├── hooks/
│   ├── usePractitioner.ts       ← fetch + cache practitioner row
│   ├── useEvidenceLog.ts
│   ├── useDailyEntry.ts
│   └── useMomentumScore.ts
├── components/
│   ├── layout/
│   │   ├── TopBar.tsx           ← STB wordmark + tier badge + avatar
│   │   ├── BottomNav.tsx        ← Today / Evidence / Sprint / Offer tabs
│   │   └── Shell.tsx            ← TopBar + children + BottomNav
│   └── ui/
│       ├── GoldButton.tsx       ← Gold filled CTA button
│       ├── OutlineButton.tsx    ← Ghost/outline secondary button
│       ├── SectionLabel.tsx     ← "ONE FOCUS" uppercase gold label
│       └── AIPill.tsx           ← Claude suggestion pill (gold border, dark fill)
├── screens/
│   ├── Auth/
│   │   ├── MagicLinkScreen.tsx  ← Email input + "Send magic link"
│   │   └── AuthCallback.tsx     ← Handle Supabase redirect
│   ├── Onboarding/
│   │   └── OnboardingScreen.tsx ← 3-question flow → Sprint board
│   ├── Today/                   ← Stage 03 builds this
│   ├── Evidence/                ← Stage 03 builds this
│   ├── Sprint/                  ← Stage 04 builds this
│   └── Offer/                   ← Stage 04 builds this
└── types/
    └── index.ts                 ← Practitioner, DailyEntry, EvidenceLog, SprintTask, Offer, AISuggestion
```

### 4. Routing

```tsx
// App.tsx routes
/                    → redirect to /today if authed, /auth if not
/auth                → MagicLinkScreen
/auth/callback       → AuthCallback
/onboarding          → OnboardingScreen (if !practitioner.onboarding_complete)
/today               → Today screen (Stage 03)
/evidence            → Evidence log (Stage 03)
/sprint              → Sprint board (Stage 04)
/offer               → Offer clarity (Stage 04)
```

### 5. BottomNav Component

Four tabs. Active = gold icon + gold label. Inactive = muted cream.
Top border: `1px solid rgba(201,168,76,0.12)`.
Background: `rgba(13,31,23,0.96)` with `backdrop-filter: blur(8px)`.
Icons: use Tabler icons (`npm install @tabler/icons-react`).

```
Today      → IconHome
Evidence   → IconChartBar
Sprint     → IconListCheck
Offer      → IconDoorEnter
```

### 6. PWA Manifest

```json
{
  "name": "STB Command Center",
  "short_name": "STB",
  "description": "Stop the Bleed — practitioner command center",
  "theme_color": "#0d1f17",
  "background_color": "#0d1f17",
  "display": "standalone",
  "start_url": "/today",
  "icons": [{ "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }]
}
```

### 7. Environment Variables

```bash
# .env.local (do not commit)
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
VITE_ANTHROPIC_API_KEY=
```

### 8. Auth Flow

- On mount: check Supabase session
- If no session → `/auth`
- If session but no practitioner row → create practitioner row → `/onboarding`
- If session + practitioner + `onboarding_complete=false` → `/onboarding`
- If session + practitioner + `onboarding_complete=true` → `/today`

---

## Outputs

Write all output to `stages/02_pwa_shell/output/`:

```
output/
├── src/                         ← Full src/ directory tree as described above
│   ├── (all files listed in Process step 3)
├── package.json
├── vite.config.ts               ← includes PWA plugin config
├── tailwind.config.js
├── tsconfig.json
├── .env.example                 ← with blank values, safe to commit
├── public/
│   └── icon-512.png             ← placeholder SVG-based icon (STB gold on dark green)
└── SHELL_SUMMARY.md             ← what was built, what Stage 03 plugs into
```

`SHELL_SUMMARY.md` must list:
- All screen routes and their current state (placeholder vs built)
- All hooks and what they return
- What Stage 03 needs to do (which files to edit, which to create)
- Any architectural decisions made

---

## Verify

Before writing outputs:
- [ ] No screen is built yet — Today/Evidence/Sprint/Offer are empty placeholder `<div>` components
- [ ] Auth flow is complete (MagicLink + callback + redirect logic)
- [ ] BottomNav renders correctly with gold active state
- [ ] TopBar shows STB wordmark, tier badge, avatar
- [ ] TypeScript types match the Supabase schema from Stage 01 output
- [ ] `.env.example` has all required keys but no real values

---

## Stop Here

After writing all output files, stop.
Report: "Stage 02 complete. Review `stages/02_pwa_shell/output/` — particularly `SHELL_SUMMARY.md` — before proceeding to Stage 03."
