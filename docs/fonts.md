# Fonts

UI stays on Ubuntu Sans. The unique look lives in monospace: a private Iosevka
build named **Iosevka Quiet**.

## Why Iosevka, not another coding font

JetBrains Mono / Fira / Cascadia are the default stack of every rice. Iosevka is
parametric: you compile a build plan and get a face nobody else has. That is the
one uniqueness lever that adds zero visual noise — no blur, no RGB, no bar.

## Why not suckless for uniqueness

suckless (dwm/st) strips decoration, but uniqueness then means patching C forever
and staying on X11. Iosevka gives a unique face without abandoning Wayland or
maintaining a patch queue.

## Build plan

[`fonts/iosevka/private-build-plans.toml`](../fonts/iosevka/private-build-plans.toml)

- Family: `Iosevka Quiet`
- Spacing: `term` (terminal metrics, no ligatures)
- Serifs: sans
- Weights: Regular + Bold, upright + italic
- Width: normal (500)
- Character choices: double-storey `a`/`g`, serifed `i`/`l`, dotted zero, base
  `1`, quiet symbols. Names taken from Iosevka v34 `composite.ss*` so they stay
  valid across rebuilds.

TTF binaries are not committed (≈27 MB). Rebuild and install with:

```bash
./scripts/build-iosevka.sh
./bootstrap.sh
```

Source caches at `~/.cache/iosevka-src/Iosevka` (override with `IOSEVKA_SRC`).
Pin a release with `IOSEVKA_TAG=v34.8.0`.

## Where it is wired

| Surface | Setting |
| --- | --- |
| fontconfig `monospace` | prefers `Iosevka Quiet` |
| GNOME monospace | `Iosevka Quiet 12` |
| Ghostty / Alacritty | `font-family = Iosevka Quiet` |
| Cursor editor + integrated terminal | `editor.fontFamily` / `terminal.integrated.fontFamily`, ligatures off |

## Size note

Iosevka is slightly narrower than JetBrains Mono at the same point size, so the
terminal and editor use 12/13 instead of 11 to keep optical size comparable.
