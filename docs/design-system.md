# Quiet design system

Canon for this machine and for apps you control. Daily driver stays
**Ubuntu GNOME**. Sway is an optional second GDM session (open trial) —
[sway-trial.md](sway-trial.md) — not a replacement DE. Core color is
[`palette/modus-vivendi-tinted.env`](../palette/modus-vivendi-tinted.env).
Machine-readable CSS: [`palette/quiet-tokens.css`](../palette/quiet-tokens.css).

Acrylic / texture from Fluent is in. Wallpaper-driven Material You color is out.

## Principles

1. **Restraint** — one accent; content over chrome; whitespace over ornament.
2. **Texture where chrome is** — Fluent acrylic on overlays and light shell
   translucency; never on the editing surface.
3. **GNOME chrome stays GNOME** — header bars, symbolic icons, adaptive layout;
   do not restyle libadwaita widgets.
4. **Color only when it means something** — semantic states only; no decorative
   rainbow.

## Steal matrix

| Source | Steal | Reject |
| --- | --- | --- |
| **Apple HIG** | One accent; content over chrome; whitespace; motion only for orientation; type hierarchy | SF Pro swap; heavy translucency-as-identity; skeuomorph |
| **Fluent 2** | Semantic surface roles; state layers (hover/press/disabled as opacity); **acrylic / mica texture** on chrome layers; focus ring as first-class | Reveal sparkles; multi-accent packs; opaque Fluent purple brand |
| **Material 3** | Role names (`surface`, `primary`, `error`); touch target ≥40px; elevation as tone shift | Dynamic color from wallpaper |
| **GNOME HIG / Libadwaita** | Header bars; symbolic icons; adaptive layout; do not restyle widgets | Custom GTK themes that break after updates |
| **make-interfaces-feel-better** | Concentric radius; shadows over hard borders; interruptible motion; press `scale(0.96)`; tabular nums; `text-wrap: balance/pretty` | `transition: all`; bounce springs |

## Color roles

Fluent-style names map onto Modus keys:

```text
bg/canvas     → BG_MAIN      (#0d0e1c)
bg/surface    → BG_DIM       (#1d2235)
bg/overlay    → BG_POPUP     (#14162c)  (+ acrylic recipe for app chrome)
bg/selection  → BG_REGION    (#555a66)
fg/primary    → FG_MAIN      (#ffffff)
fg/secondary  → FG_DIM       (#989898)
fg/accent     → FG_ALT / STATE_INFO
fg/danger     → STATE_ERROR
stroke        → BORDER       (#61647a)
```

GNOME system accent stays `slate` (native accent API). Do not invent a second
brand purple.

State layers (Fluent): hover / press / disabled are opacity or translucent white
over the surface — see `--quiet-state-*` in `quiet-tokens.css`. Do not mint new
hues for hover.

## Type

| Role | Face | Size |
| --- | --- | --- |
| UI | Ubuntu Sans | 11 |
| Mono | Iosevka Quiet | 12 |
| Documents | Ubuntu Sans / Noto Serif | system |

App headings: `text-wrap: balance`. Prefer tabular nums for columns of figures.
See [fonts.md](fonts.md).

## Motion

- GNOME animations: on.
- Duration: short (~180ms in app CSS).
- Easing: `cubic-bezier(0.2, 0, 0, 1)` — orientation, not bounce.
- Interactive press: `scale(0.96)` where it helps; interruptible transitions.
- Avoid `transition: all`.

## Density / targets

- Hit areas ≥ 40×40 CSS px (Material 3 floor).
- Dock icon size 48 (bootstrap).
- Concentric radius: outer ≈ inner + padding when nesting controls.

## Acrylic — honest Linux map

Windows Acrylic = blur + noise + tint over the desktop. GNOME / libadwaita
cannot do system-wide Mica without fighting the toolkit.

**Apply acrylic only here:**

1. **Shell chrome (light touch)** — Ubuntu dock `transparency-mode=FIXED` with
   moderate opacity (not `DEFAULT`). One wallpaper with soft grain so
   translucency reads as texture, not muddy glass. No Blur My Shell unless a
   single extension is later proven stable. Default: dock + wallpaper only
   (iGPU-friendly).
2. **Terminal** — Ghostty background stays Modus `BG_MAIN`. Optional slight
   opacity only if contrast still clears AA after check; otherwise keep opaque.
   Legibility > glass.
3. **Apps you control (CSS / React)** — Fluent-like panel recipe below. Tokens
   in `palette/quiet-tokens.css` (`.quiet-acrylic`).
4. **Cursor workbench** — solid Modus surfaces. Editor must stay AAA. No fake
   acrylic on code.

### Acrylic recipe (app chrome)

```css
.quiet-acrylic {
  background: rgba(20, 22, 44, 0.82); /* BG_POPUP tint */
  backdrop-filter: blur(20px) saturate(1.2);
  -webkit-backdrop-filter: blur(20px) saturate(1.2);
  /* + noise SVG overlay at ~3–5% opacity (see quiet-tokens.css) */
}
```

Tint may use `BG_DIM` / `BG_POPUP` at **0.72–0.85** alpha. Prefer surface tint
for sidebars, overlay tint for floating panels.

**Do not use acrylic on:** body text blocks, code editors, terminal cell
backgrounds, small labels, dense data tables. Solid `bg/canvas` or `bg/surface`
there.

### Wallpaper rule

Low-noise, muted, supports acrylic read. No anime, no RGB gradients, no busy
photos that turn dock translucency into mud. Sway trial: slow Modus breath
(`quiet-live-bg.py`), not a video/mpvpaper rice.

## Desktop wiring (this repo)

- Dock: `transparency-mode=FIXED`, size 48, autohide, no mounts/trash — see
  `bootstrap.sh`.
- Accent: `slate`.
- Toolkit: stock Yaru-dark / libadwaita; Qt via `gtk3` under GNOME.

## Explicitly not stealing / not building

- Hyprland, Omarchy, or a custom DE
- System-wide Blur My Shell as default
- Material You / wallust palette generation
- Restyling libadwaita widgets
- Acrylic on Cursor editor canvas
- Plasma / COSMIC as daily drivers (tried; rejected — purge scripts remain)
- Sway as daily driver until the second-session trial sticks or is rejected

## Provenance

| Steal | Cite |
| --- | --- |
| Restraint, hierarchy, motion for orientation | Apple Human Interface Guidelines |
| Surface roles, state layers, acrylic | Microsoft Fluent 2 |
| Role names, 40px targets, tone-as-elevation | Material Design 3 |
| Header bars, symbolic icons, adaptive layout | GNOME HIG / Libadwaita |
| Concentric radius, press scale, no bounce, text-wrap | make-interfaces-feel-better skill |
| Palette doctrine (AAA, few hues) | Prot’s Modus themes (vivendi-tinted) |

Plasma and COSMIC shopping is closed. Sway is the remaining compositor
trial. See [rationale.md](rationale.md) and [sway-trial.md](sway-trial.md).
