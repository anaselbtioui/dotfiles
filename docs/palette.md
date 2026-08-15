# Palette

One palette drives every surface: `palette/modus-vivendi-tinted.env`. Values are
copied verbatim from `modus-themes-vivendi-tinted-palette` in
[protesilaos/modus-themes](https://github.com/protesilaos/modus-themes), part of
GNU Emacs. Quiet role names and CSS variables:
[`palette/quiet-tokens.css`](../palette/quiet-tokens.css) and
[design-system.md](design-system.md).

## Why this one

It is one of the few palettes with published reasoning rather than taste. Its
design rules, in the author's own words:

- Every foreground/background pair meets WCAG AAA, a minimum 7:1 relative
  luminance ratio. "There shall never be a compromise on this principle."
- Deliberate avoidance of the "rainbow effect": color is used "as few colours as
  deemed necessary," and clustering intense colors is treated as a defect.
- Red is excluded from ordinary syntax because it "calls too much attention to
  itself," reserved instead for genuine errors. Same logic for yellow and green.
- Not every color hits exactly 7:1, on purpose: uniform contrast "would make
  them all look about the same... dull and monotonous." The variation in
  luminance is what guides the eye.

The `-tinted` variant is chosen over plain `modus-vivendi` for one reason: plain
vivendi uses `#000000` as its background. Pure black on an emissive panel causes
halation around bright text and maximizes contrast fatigue. The tinted variant
uses `#0d0e1c`, described upstream as a night sky.

## Measured

Run `scripts/check-contrast.py` after any edit. It computes WCAG relative
luminance directly, so the claims here are verified rather than assumed.

Current results against the `#0d0e1c` background:

- `FG_MAIN` `#ffffff` at 19.15:1 and `FG_ALT` `#c6daff` at 13.56:1, both AAA.
- `FG_DIM` `#989898` at 6.64:1, clears AA. De-emphasized by design, so AAA is
  not claimed for it.
- All 14 non-black ANSI slots land between 6.41:1 and 19.15:1, all clearing AA.
  The lowest is red, which is intentional: it is the only color meant to alarm.
- ANSI slots 0 and 8 (`#000000`, `#595959`) are dark greys used as fills and dim
  decoration, never as body text, so no target applies.

## Where it is applied

| Surface | Mechanism |
| --- | --- |
| Ghostty | `home/.config/ghostty/config`, 16 slots plus background, cursor, selection |
| Alacritty | `home/.config/alacritty/alacritty.toml`, identical values |
| Cursor editor and its integrated terminal | `scripts/apply-cursor-palette.py`, merged into `workbench.colorCustomizations` |
| GNOME accent | `slate`, set by `bootstrap.sh` |
| Sway (trial) | `home/.config/sway/config` canvas and client colors |
| Waybar / mako / swaylock | matching surface, overlay, border, and semantic states |

Cursor's settings are edited in place rather than symlinked, because Cursor saves
atomically and would replace a symlink with a regular file. The script merges
only `workbench.colorCustomizations` and preserves everything else.

## Deviations from upstream, and why

**Cursor color.** Modus maps the cursor to `magenta-intense` `#ff66ff`. That
suits Emacs, where the cursor is one thin glyph. A terminal block cursor fills an
entire cell, so this uses `magenta-cooler` `#b6a0ff` instead: same hue family,
lower intensity, still 8.63:1.

**GNOME accent.** GNOME accepts only its own enum (`blue`, `teal`, `green`,
`yellow`, `orange`, `red`, `pink`, `purple`, `slate`, `brown`), not a hex value.
`slate` is the least saturated option, so the accent signals focus and state
without competing. Ubuntu's default `orange` is high-chroma and brand-driven.
Switch to `blue` if you prefer the palette's own accent hue.

## Known gap

`window.autoDetectColorScheme` is `true` in Cursor, so it follows the system
light/dark preference, while these customizations are dark-only. GNOME is pinned
to `prefer-dark`, so the two agree today. If you ever switch to light, scope the
customizations per theme with the `[Theme Name]` key syntax instead.

## Rules this palette exists to enforce

No wallpaper-derived theming. No per-app color schemes. One accent, used only for
focus and state. Color carries meaning or it does not appear: red for errors,
yellow for warnings, green for success, blue for information.
