---
name: Sacred Ethereal
colors:
  surface: '#131314'
  surface-dim: '#131314'
  surface-bright: '#39393a'
  surface-container-lowest: '#0e0e0f'
  surface-container-low: '#1c1b1c'
  surface-container: '#201f20'
  surface-container-high: '#2a2a2b'
  surface-container-highest: '#353436'
  on-surface: '#e5e2e3'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e5e2e3'
  inverse-on-surface: '#313031'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#c8c6c8'
  on-secondary: '#303032'
  secondary-container: '#474649'
  on-secondary-container: '#b7b4b7'
  tertiary: '#ceced0'
  on-tertiary: '#2f3132'
  tertiary-container: '#b2b3b5'
  on-tertiary-container: '#444547'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#e4e2e4'
  secondary-fixed-dim: '#c8c6c8'
  on-secondary-fixed: '#1b1b1d'
  on-secondary-fixed-variant: '#474649'
  tertiary-fixed: '#e2e2e4'
  tertiary-fixed-dim: '#c6c6c8'
  on-tertiary-fixed: '#1a1c1d'
  on-tertiary-fixed-variant: '#454749'
  background: '#131314'
  on-background: '#e5e2e3'
  surface-variant: '#353436'
typography:
  headline-lg:
    fontFamily: Libre Caslon Text
    fontSize: 48px
    fontWeight: '400'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Libre Caslon Text
    fontSize: 24px
    fontWeight: '400'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.1em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 10px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.15em
  headline-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  card-gap: 16px
---

## Brand & Style

This design system synthesizes the timeless authority of "Sacred Tradition" with the hyper-refined, fluid UI aesthetics of modern high-fidelity digital products. It is designed for an audience that values heritage but demands the performance and precision of a 60fps experience.

The visual style is **Ethereal Minimalism**. It moves away from heavy, static elements toward a layered, light-filled interface. The emotional response is one of "Digital Sanctuary"—calm, reverent, and technologically superior. It leverages subtle glassmorphism and deep, atmospheric depth to create a sense of infinite space within the UI, ensuring that traditional motifs feel like precision-engineered artifacts rather than historical relics.

## Colors

The palette is rooted in a "Deep Obsidian" environment, providing a high-contrast foundation for ritualistic accents.

- **Primary (Sacred Gold):** Used exclusively for high-priority actions, critical information, and delicate ornamentation. It should be applied with surgical precision—as 1px borders, glow effects, or micro-typography.
- **Secondary (Obsidian Glass):** Used for elevated surfaces, utilizing semi-transparency and backdrop blurs to create depth.
- **Tertiary (Mercury):** A cool-toned white for primary text, ensuring maximum legibility against dark surfaces.
- **Neutral (The Void):** The base background color, providing a pure, distraction-free canvas.

Color application focuses on restraint; avoid large blocks of gold. Instead, use it as a "light source" that illuminates the edges of components.

## Typography

The typographic strategy creates a "Historical Precision" look. Large, elegant serifs handle the storytelling and "Sacred" elements, while hyper-modern sans-serifs handle the "60fps" utility.

1.  **The Authority (Serif):** Libre Caslon Text is used for headlines. It should be typeset with generous leading and occasional italics for emphasis.
2.  **The Interface (Sans):** Geist is the primary body face, chosen for its monospaced-adjacent clarity and technical feel.
3.  **The Metadata (Label):** Hanken Grotesk is used for all UI labels, tags, and small utility text. It must always be tracked out (+10-15%) and usually presented in all-caps to evoke a premium, architectural feel.

## Layout & Spacing

The layout philosophy follows a **Fluid Cinematic Grid**. Content is housed in card-based containers that "float" over the obsidian base.

- **Grid:** A 12-column system for desktop with wide margins to create a focused, editorial center-cut.
- **Rhythm:** All spacing is based on a 4px baseline grid. Use larger gaps (64px+) between major sections to allow the design to "breathe."
- **Motion-Ready:** Components are designed with a "Container First" approach. Every element belongs to a logical group with consistent internal padding (24px or 32px), facilitating seamless layout transitions and hero-element expansions.

## Elevation & Depth

Hierarchy is established through **Atmospheric Layering** rather than traditional drop shadows.

- **Level 0 (Base):** Pure #0D0D0E.
- **Level 1 (Surfaces):** Dark grey (#1A1A1C) with 60% opacity and a 20px backdrop blur. Borders are 0.5px solid white at 10% opacity.
- **Level 2 (Active/Floating):** Same as Level 1 but with a 1px "Sacred Gold" top-border and a subtle, ultra-diffused outer glow (color-matched to gold at 5% opacity).
- **Glassmorphism:** Use for overlays and navigation bars. The blur effect should be high (30px+) to maintain legibility of the content beneath while preserving the sense of depth.

## Shapes

The shape language is "Soft Geometry." Standard UI elements use a 0.5rem (8px) radius to feel modern and tactile. 

- **Primary Cards:** 1rem (16px) for a soft, premium feel that frames content beautifully.
- **Interactive Elements:** Buttons use slightly more aggressive rounding (rounded-lg) to distinguish them from structural containers.
- **Precision Lines:** Separators and decorative accents must be 0.5px or 1px wide. Use "fading strokes" (linear gradients that go from 0% to 100% to 0% opacity) for a sophisticated, high-tech finish.

## Components

### Buttons
- **Primary:** High-gloss gold finish. A subtle linear gradient (Top: #D4AF37 to Bottom: #B69121) with a 1px inner highlight on the top edge. Text is Hanken Grotesk Bold, Black.
- **Ghost:** 0.5px Mercury border, 5% white fill on hover.

### Precision Inputs
- Fields should have no background, only a bottom border (1px). Upon focus, the border transitions to Gold with a 4px vertical "pulse" animation at the start of the line.

### Cards
- Always utilize the Obsidian Glass style. Cards should have no visible shadow; depth is conveyed via the contrast between the blurred background and the 0.5px border.

### Chips/Labels
- Small, pill-shaped elements with 1px borders. Use Hanken Grotesk at 10px. For "Active" states, the entire chip glows with a subtle Gold outer shadow.

### Micro-interactions
- Every interaction should feel "60fps." Hovering over a card should slightly increase the backdrop-blur intensity and scale the 0.5px border to 1px Gold.