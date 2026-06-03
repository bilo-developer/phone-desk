---
name: Obsidian Flux
colors:
  surface: '#131314'
  surface-dim: '#131314'
  surface-bright: '#3a393a'
  surface-container-lowest: '#0e0e0f'
  surface-container-low: '#1c1b1c'
  surface-container: '#201f20'
  surface-container-high: '#2a2a2b'
  surface-container-highest: '#353436'
  on-surface: '#e5e2e3'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#e5e2e3'
  inverse-on-surface: '#313031'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#ecb2ff'
  on-secondary: '#520071'
  secondary-container: '#cf5cff'
  on-secondary-container: '#480063'
  tertiary: '#dbffd7'
  on-tertiary: '#003911'
  tertiary-container: '#00fa64'
  on-tertiary-container: '#006e27'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#f8d8ff'
  secondary-fixed-dim: '#ecb2ff'
  on-secondary-fixed: '#320047'
  on-secondary-fixed-variant: '#74009f'
  tertiary-fixed: '#6bff83'
  tertiary-fixed-dim: '#00e55b'
  on-tertiary-fixed: '#002107'
  on-tertiary-fixed-variant: '#00531b'
  background: '#131314'
  on-background: '#e5e2e3'
  surface-variant: '#353436'
typography:
  display-lg:
    fontFamily: Geist
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-sm:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.2'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '400'
    lineHeight: '1'
  headline-md-mobile:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.2'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  tile-gap: 12px
  container-padding: 24px
  margin-sm: 16px
  margin-md: 32px
  margin-lg: 48px
---

## Brand & Style

The design system is engineered for high-performance control interfaces, prioritizing low-latency visual feedback and high-tech aesthetics. The brand personality is precise, immersive, and authoritative, catering to streamers, developers, and power users who require a command-center experience. 

The style is a fusion of **Modern Corporate** structure and **Cyberpunk-influenced Glassmorphism**. It utilizes deep obsidian surfaces to minimize eye strain in low-light environments, contrasted by "living" neon accents that signify active states and data flow. The emotional response is one of total control and professional-grade reliability.

## Colors

The palette is built on a "Void" foundation to ensure maximum contrast for functional elements.

- **Primary (Neon Blue):** Used for primary actions, active connections, and focus states.
- **Secondary (Cyber Purple):** Reserved for secondary toggles, media controls, and aesthetic flourishes.
- **Tertiary (Flux Green):** Specifically for "Live" indicators, successful triggers, and system health.
- **Neutral:** A range of deep grays (`#0A0A0B` to `#1F1F23`) used for surfaces and containers to create a sense of physical depth without traditional lighting.
- **Status Colors:** Use a high-vibrancy Red (`#FF004D`) strictly for critical errors or recording states.

## Typography

This design system employs a tiered typographic approach. **Geist** provides a sharp, technical look for headings. **Inter** handles high-density information and settings with maximum legibility. **JetBrains Mono** is used for functional labels, button IDs, and telemetry data, reinforcing the "engineered" feel of the controller.

All text on interactive tiles should be centered. Use `label-caps` for categorical headers and `label-sm` for secondary metadata on buttons.

## Layout & Spacing

The layout follows a **Fixed Grid** model optimized for ergonomic interaction. 

- **The Grid:** A customizable N x M grid of control tiles. On desktop, tiles maintain a 1:1 aspect ratio.
- **Gaps:** A consistent `tile-gap` of 12px ensures clear separation for touch and mouse precision.
- **Safe Areas:** 24px internal padding for all main controller containers.
- **Responsive Behavior:** 
  - **Desktop:** Center-aligned grid with sidebar for deck switching.
  - **Tablet:** Full-screen grid, 6-column width.
  - **Mobile:** 3-column width; tiles scale to fill screen width with `margin-sm`.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layering** and **Luminescent Glows** rather than traditional shadows.

1.  **Base (Level 0):** Pure black `#000000` for the background.
2.  **Surface (Level 1):** `#0A0A0B` for the main deck container with a 1px solid border of `#1F1F23`.
3.  **Tile (Level 2):** `#161618` with a subtle linear gradient (top-down, 5% opacity white to 0%).
4.  **Active State:** When a tile is toggled, it gains a **Glowing Border**. This is a 2px solid stroke of the `primary_color` with a `box-shadow` of 0px 0px 12px rgba(0, 240, 255, 0.4).
5.  **Interactive Depth:** On press/touch, tiles should translate 1px downward and decrease in brightness by 10% to simulate physical travel.

## Shapes

The design system uses **Soft** geometry. Interactive tiles and input fields utilize a 0.25rem radius to maintain a professional, sharp appearance while avoiding the harshness of 0px corners. Larger containers like the main deck housing use `rounded-lg` (0.5rem) to create a subtle frame around the inner grid.

## Components

### Control Tiles
The core component. Each tile features a centered icon and a bottom-aligned `label-sm`. 
- **Inactive:** Dark gray background, muted gray icon.
- **Active:** Glowing border, icon tinted with the primary or secondary color.
- **Momentary:** Flash the primary color border upon trigger for 150ms.

### Status Chips
Small, pill-shaped indicators located at the top-right of tiles. Use these for bitrates, viewer counts, or "REC" indicators. They should have a semi-transparent background (20% opacity of the accent color) and a high-vibrancy text color.

### Sliders (Faders)
Used for volume and brightness. Use a thick track with a high-contrast fill. The "thumb" should be a vertical bar rather than a circle to mimic professional audio mixers.

### Input Fields
Dark backgrounds with no fill, only a 1px bottom border. Upon focus, the border transitions to the primary neon color with a subtle glow.

### Lists
For deck navigation, use a clean list with a `primary_color` vertical indicator on the left side of the active item.