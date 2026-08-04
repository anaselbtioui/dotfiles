# dotfiles

Ubuntu 26.04 LTS / GNOME 50 / Wayland desktop configuration, built around one
rule: reduce variation between apps rather than add decoration on top of them.
No custom GTK theme, no icon packs, no extension pile.

Visual language is the **Quiet** design system — see
[docs/design-system.md](docs/design-system.md). Why each choice was made:
[docs/rationale.md](docs/rationale.md).

## Install

```bash
git clone <this repo> ~/_code/dotfiles
cd ~/_code/dotfiles

./bootstrap.sh              # user-level: symlinks, fonts, gsettings, flatpak, snap flags
sudo ./scripts/root-setup.sh   # packages, theme cleanup, login screen
```

Then log out and back in so `~/.config/environment.d` and the Qt platform theme
take effect.

Both scripts are idempotent. Re-run `./bootstrap.sh` after a snap refresh to
reinstall the Chromium flags file, since snaps move their config to a new
revision directory.

On a fresh install, `./bootstrap.sh --restore-dconf` also loads the full GNOME
settings snapshot. Skip that flag on a machine you have already customised: it
overwrites `/org/gnome/` wholesale.

### DE trials (closed)

Plasma and COSMIC were tried as second GDM sessions and rejected. Daily driver
stays **Ubuntu GNOME**. Purge / reinstall scripts remain if needed:

```bash
# COSMIC leftovers (PPA): sudo ./scripts/root-setup.sh --purge-cosmic
# Plasma: see docs/plasma-trial.md  (--plasma / --purge-plasma)
```

See [docs/cosmic-trial.md](docs/cosmic-trial.md) and
[docs/plasma-trial.md](docs/plasma-trial.md).

## Layout

| Path | Contents |
| --- | --- |
| `bootstrap.sh` | User-level setup, no root needed |
| `scripts/root-setup.sh` | Package installs/removals, GDM greeter settings |
| `scripts/dconf-snapshot.sh` | Refreshes `dconf/gnome.ini` from the live session |
| `scripts/check-contrast.py` | Verifies the palette's WCAG claims |
| `scripts/apply-cursor-palette.py` | Merges the palette into Cursor's settings |
| `scripts/bootstrap-plasma.sh` | Quiet Breeze Dark profile for the Plasma trial |
| `scripts/build-iosevka.sh` | Rebuild/install the custom Iosevka Quiet font |
| `palette/` | Modus env + Quiet CSS tokens |
| `home/` | Files symlinked into `$HOME`, mirroring their real paths |
| `snap-flags/` | Chromium flag files copied into snap config dirs |
| `packages/` | Curated apt, snap and flatpak lists |
| `dconf/gnome.ini` | GNOME settings snapshot |
| `docs/` | Design system, rationale, trial notes |

Existing files are moved aside as `<name>.pre-dotfiles.<timestamp>` before being
replaced with symlinks, so nothing is lost on first run.

## Key settings

- Design system: [Quiet](docs/design-system.md) — acrylic only on dock chrome and
  app overlays; solid Modus on editor/terminal body.
- Fonts: Ubuntu Sans for UI and documents, Noto Serif, Iosevka Quiet for
  monospace, Noto Color Emoji fallback, grayscale antialiasing with slight
  hinting, applied through both gsettings and fontconfig.
- Theme: stock Yaru-dark, libadwaita untouched, GNOME's native `slate` accent.
- Colors: one palette for terminal, editor and accent, derived from Modus
  vivendi-tinted and contrast-verified. See [docs/palette.md](docs/palette.md).
  CSS roles: [palette/quiet-tokens.css](palette/quiet-tokens.css).
- Monospace: custom **Iosevka Quiet** build (no ligatures). See
  [docs/fonts.md](docs/fonts.md). Rebuild with `./scripts/build-iosevka.sh`.
- Dock: `transparency-mode=FIXED`, icon size 48, autohide, no mounts/trash.
- Qt: `QT_QPA_PLATFORMTHEME=gtk3` under GNOME.
- Electron and Chromium: native Wayland via `ELECTRON_OZONE_PLATFORM_HINT=auto`
  and `snap-flags/brave-flags.conf`.
- Terminal: Ghostty with an Adwaita-dark palette; Alacritty matches it as a
  fallback until Ghostty is installed.
