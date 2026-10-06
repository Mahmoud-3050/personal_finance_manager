# Design — Personal finance manager

A locked design system for this app. Every screen reads this file before
emitting UI. Do not regenerate per screen — extend this file when the system
needs to grow.

## Genre

modern-minimal

## Macrostructure family

App screens share one shape. There are no marketing pages.

- App pages: Workbench. A balance or status figure leads. Everything under it is a hairline row. Sections separate by gap, not by cards or shadows.

## Theme

Navy and slate surfaces, emerald for balances and income, coral for expenses.

- `--color-paper`   #0B1220 deep navy
- `--color-paper-2` #141C2B slate card
- `--color-ink`     #F7F8FA off-white
- `--color-ink-2`   #B7C0CC light grey
- `--color-rule`    #243044
- `--color-accent`  #3DDC97 emerald
- `--color-expense` #FF8A80 coral
- `--color-focus`   #3DDC97

## Typography

- Display: Space Grotesk, weight 600, style normal. Tight tracking. Tabular figures on every amount.
- Body: Inter, weight 400
- Mono: Inter, weight 500, for short labels. No second family.
- Display tracking: -0.03em on balances
- Type scale anchor: the home balance is 40px at the 393px design width

## Spacing

4-point scale, applied in Flutter through `screen_util` (`.w`, `.h`, `.sp`, `.r`). Named steps live in `tokens.css`.

## Motion

- Easings: cubic-bezier(0.16, 1, 0.3, 1) named `--ease-out`
- Reveal pattern: fade only, 220ms, on route changes
- Reduced-motion fallback: the platform’s reduce-motion setting. No extra spatial motion.

## Microinteractions stance

- Silent success. A saved record leaves the form. No celebratory toast.
- Hover does not exist on touch. Focus ring is cobalt and appears immediately.
- Pressed controls move 0px. No shadow lift.

## CTA voice

- Primary CTA: ink fill, pill shape, label in the paper color. One per screen.
- Secondary CTA: hairline outline, pill shape, ink label, transparent fill.

## Per-page allowances

- App pages must not use illustration, mock chrome, or gradient fills.
- Income green and expense red are allowed on amounts only.

## What pages MUST share

- Inter for labels and body. Space Grotesk for balances and the one large status line.
- Ink pills for the primary action.
- Cobalt only on the selected tab and the focus ring.
- Hairline rows instead of shadowed cards.
- The same tab bar on Home, Accounts, Transactions, and Reports.

## What pages MAY differ on

- Which figure leads (total on Home, net on Reports, schedule on Backup).
- Whether the screen is a list, a form, or a status page.

## Navigation

Previous nav: none (a wrap of outlined shortcuts on Home). This build: an edge-aligned tab bar, because the book has four top-level destinations and the phone already supplies the chrome. Categories and Backup stay one push away from Home. Forms cover the tab bar.

## Exports

### tokens.css

See `tokens.css` at the project root. Flutter maps those roles in `lib/config/themes/colors_palettes.dart`.

### Tailwind v4 `@theme`

```css
@theme {
  --color-paper: #f8fafd;
  --color-ink: #192029;
  --color-accent: #0065cd;
  --font-display: "Space Grotesk", sans-serif;
  --font-body: "Inter", sans-serif;
  --spacing-md: 1.5rem;
  --text-md: 1.125rem;
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
}
```

### DTCG `tokens.json`

```json
{
  "color": {
    "paper": { "$value": "oklch(98.5% 0.004 250)", "$type": "color" },
    "ink": { "$value": "oklch(24% 0.02 258)", "$type": "color" },
    "accent": { "$value": "oklch(52% 0.18 256)", "$type": "color" }
  },
  "font": {
    "display": { "$value": "Space Grotesk", "$type": "fontFamily" },
    "body": { "$value": "Inter", "$type": "fontFamily" }
  },
  "space": {
    "md": { "$value": "1.5rem", "$type": "dimension" }
  }
}
```

### shadcn/ui CSS variables

```css
:root {
  --background: 98.5% 0.004 250;
  --foreground: 24% 0.02 258;
  --primary: 52% 0.18 256;
  --primary-foreground: 98.5% 0.004 250;
  --muted: 90% 0.008 250;
  --muted-foreground: 40% 0.02 257;
  --border: 90% 0.008 250;
  --input: 90% 0.008 250;
  --ring: 52% 0.18 256;
  --radius: 8px;
}
```
