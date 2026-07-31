#!/usr/bin/env bash
# User-level setup. Idempotent: safe to re-run after any system update.
# Root-level steps live in scripts/root-setup.sh.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$REPO/home"
RESTORE_DCONF=0

for arg in "$@"; do
  case "$arg" in
    --restore-dconf) RESTORE_DCONF=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: ./bootstrap.sh [--restore-dconf]

  --restore-dconf   Also load dconf/gnome.ini over the current session.
                    Only use on a fresh install; it overwrites GNOME settings.
EOF
      exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

section() { printf '\n== %s\n' "$1"; }
log() { printf '   %s\n' "$1"; }

section "Linking config files"
while IFS= read -r -d '' src; do
  rel="${src#"$HOME_SRC"/}"
  dest="$HOME/$rel"
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$src" ]; then
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup="$dest.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log "backed up existing $rel"
  fi
  ln -sfn "$src" "$dest"
  log "linked $rel"
done < <(find "$HOME_SRC" -type f -print0)

section "Typography"
gsettings set org.gnome.desktop.interface font-name 'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
fc-cache -f >/dev/null
log "sans-serif -> $(fc-match -f '%{family[0]}\n' sans-serif)"
log "serif      -> $(fc-match -f '%{family[0]}\n' serif)"
log "monospace  -> $(fc-match -f '%{family[0]}\n' monospace)"
log "emoji      -> $(fc-match -f '%{family[0]}\n' emoji)"

section "Appearance"
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# slate is the least saturated accent GNOME offers, so it marks focus and state
# without competing with content. GNOME only accepts its own enum, not a hex, so
# this is the closest available match to the palette. Switch to 'blue' for the
# palette's own accent hue.
gsettings set org.gnome.desktop.interface accent-color 'slate'
gsettings set org.gnome.desktop.interface enable-animations true

section "Desktop surface"
if gsettings list-schemas | grep -qx org.gnome.shell.extensions.ding; then
  gsettings set org.gnome.shell.extensions.ding show-home false
  gsettings set org.gnome.shell.extensions.ding show-trash false
  gsettings set org.gnome.shell.extensions.ding show-volumes false
fi

if gsettings list-schemas | grep -qx org.gnome.shell.extensions.dash-to-dock; then
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
  gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
  gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
  gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
  gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
  gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
  # Yaru's own dock styling, not a custom theme on top of it.
  gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
  gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DEFAULT'
fi

section "Flatpak integration"
if command -v flatpak >/dev/null; then
  # Flatpaks do not see host fontconfig or icon themes unless granted.
  # QT_QPA_PLATFORMTHEME is unset inside the sandbox on purpose: flatpak
  # runtimes ship their own Qt integration (VLC uses
  # org.kde.WaylandDecoration.QAdwaitaDecorations) and carry no libqgtk3, so the
  # host value would only produce a warning.
  flatpak override --user \
    --filesystem=xdg-config/fontconfig:ro \
    --filesystem="$HOME/.local/share/fonts:ro" \
    --filesystem=/usr/share/fonts:ro \
    --filesystem=/usr/share/icons:ro \
    --unset-env=QT_QPA_PLATFORMTHEME
  log "host fonts and icons exposed to flatpaks"
fi

section "Palette"
python3 "$REPO/scripts/check-contrast.py" | tail -1
python3 "$REPO/scripts/apply-cursor-palette.py" || log "Cursor settings need a manual merge"

section "Chromium snap Wayland flags"
# Chromium reads <name>-flags.conf from its own XDG_CONFIG_HOME, which for a
# snap is ~/snap/<name>/current/.config. Copied rather than linked because the
# path moves to a new revision on every refresh.
for app in brave; do
  target_dir="$HOME/snap/$app/current/.config"
  src="$REPO/snap-flags/$app-flags.conf"
  if [ -d "$target_dir" ] && [ -f "$src" ]; then
    install -m 0644 "$src" "$target_dir/$app-flags.conf"
    log "$app-flags.conf installed"
  fi
done

if [ "$RESTORE_DCONF" = 1 ]; then
  section "Restoring dconf snapshot"
  dconf load /org/gnome/ < "$REPO/dconf/gnome.ini"
  log "loaded dconf/gnome.ini"
fi

printf '\nDone. Log out and back in for environment.d and Qt changes to apply.\n'
