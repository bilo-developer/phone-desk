---
name: Atmospheric Glass
colors:
  surface: '#111318'
  surface-dim: '#111318'
  surface-bright: '#37393f'
  surface-container-lowest: '#0c0e13'
  surface-container-low: '#1a1b21'
  surface-container: '#1e2025'
  surface-container-high: '#282a2f'
  surface-container-highest: '#33353a'
  on-surface: '#e2e2e9'
  on-surface-variant: '#c1c6d7'
  inverse-surface: '#e2e2e9'
  inverse-on-surface: '#2e3036'
  outline: '#8c909f'
  outline-variant: '#424753'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e69'
  primary-container: '#4b8eff'
  on-primary-container: '#00285c'
  inverse-primary: '#005bc1'
  secondary: '#e8b3ff'
  on-secondary: '#510074'
  secondary-container: '#7d01b1'
  on-secondary-container: '#e5a9ff'
  tertiary: '#ffb695'
  on-tertiary: '#571e00'
  tertiary-container: '#ef6719'
  on-tertiary-container: '#4c1a00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004494'
  secondary-fixed: '#f6d9ff'
  secondary-fixed-dim: '#e8b3ff'
  on-secondary-fixed: '#310048'
  on-secondary-fixed-variant: '#7200a3'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb695'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#7c2e00'
  background: '#111318'
  on-background: '#e2e2e9'
  surface-variant: '#33353a'
  glass-surface: rgba(28, 30, 35, 0.6)
  input-glass: rgba(255, 255, 255, 0.05)
  outline-glow: rgba(255, 255, 255, 0.1)
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  stack-gap: 16px
  grid-gutter: 12px
  container-padding: 20px
  touch-target: 44px
---

## Brand & Style

The brand identity is centered around a futuristic, tech-forward aesthetic that balances utility with high-end visual polish. It targets tech-savvy users who appreciate a "developer-tool" feel that doesn't sacrifice elegance. 

The design style is **Glassmorphism**, characterized by deep backdrop blurs, translucent surfaces, and vibrant atmospheric background orbs. The interface feels lightweight and ethereal, as if elements are floating in a multidimensional digital space. The emotional response is one of precision, security, and modern sophistication.

## Colors

The palette is anchored in a deep monochromatic dark mode, utilizing a primary "Electric Blue" for actions and brand moments. Secondary "Deep Purple" and tertiary "Burnt Orange" are used primarily for atmospheric background gradients and subtle status indicators.

The interface relies heavily on alpha-blended neutrals to achieve its glass effect. Surface colors are rarely solid; they are composed of dark, translucent greys that allow the background orbs to bleed through. Text uses high-contrast off-whites for readability and muted blue-greys for secondary information.

## Typography

The system uses **Inter** exclusively to maintain a clean, systematic, and utilitarian feel. Hierarchy is established through significant weight shifts (700 for headlines vs. 400 for body) rather than excessive size variations. 

For mobile devices, the largest headlines are scaled down slightly to ensure they don't break across too many lines. Tracking (letter spacing) is tightened for large headlines to increase impact and loosened for small labels to improve legibility on dark backgrounds.

## Layout & Spacing

The layout philosophy uses a **Contextual Fluid Grid** centered on the screen for transactional flows. While the main content container has a maximum width (448px), it scales fluidly on smaller devices with fixed 20px side margins.

The spacing rhythm is based on a 4px baseline unit. Elements within a card are separated by a standard 16px "stack gap," while larger logical sections use 32px or 40px offsets to create a clear visual hierarchy. Touch targets are strictly maintained at a minimum of 44px to ensure accessibility.

## Elevation & Depth

Hierarchy is communicated through **Glassmorphism and Backdrop Blurs** rather than traditional drop shadows. 

1.  **Base Layer:** Dark background with 30% blur orbs in primary and secondary colors.
2.  **Surface Layer:** Semi-transparent panels (`rgba(28, 30, 35, 0.6)`) with a 40px backdrop blur and 1px white border at 10% opacity.
3.  **Interactive Layer:** Input fields use a lighter glass effect (`rgba(255, 255, 255, 0.05)`) with a 20px blur.
4.  **Action Layer:** Primary buttons use a linear gradient and a 20% opacity glow shadow matching the primary color to indicate prominence.

## Shapes

The shape language is consistently "Rounded" to soften the technical nature of the UI. Main containers use a generous `3xl` (24px) corner radius to create an organic, pebble-like feel. Interactive elements like buttons and input fields follow a `xl` (12px) radius, providing a comfortable and modern touch experience. Icons are enclosed in circular or rounded-square containers to match this philosophy.

## Components

### Buttons
Primary buttons utilize a vertical linear gradient from `#4b8eff` to `#005bc1`. They feature a subtle scale-down effect (0.95) on press. Secondary buttons are text-only with icon pairings, utilizing the `on-surface-variant` color and transitioning to primary blue on hover.

### Input Fields
Inputs use a "Floating Label" pattern. The container is a `input-glass` surface. On focus, the border transitions to the primary color, and the label scales to 85% and shifts upward, resting on a semi-opaque background to remain legible over the input's content.

### Glass Panels
Large containers (cards) must implement `backdrop-filter: blur(40px)`. They should always have a 1px border at 10% white opacity to define the edge against the background orbs.

### Atmospheric Orbs
Background decorative elements are large radial gradients with a 3XL blur filter, set to `mix-blend-mode: screen` or `lighten` to interact dynamically with the surface glass.