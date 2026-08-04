#!/usr/bin/env bash
# Quiet Plasma profile for the second-session trial. Idempotent.
# Safe to run from GNOME before the first Plasma login, or inside Plasma.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

section() { printf '\n== %s\n' "$1"; }
log() { printf '   %s\n' "$1"; }

# Prefer kwriteconfig6; fall back to writing keys if the tool is missing
# (e.g. script run before Plasma packages are installed).
kw() {
  local file="$1" group="$2" key="$3" type="$4" value="$5"
  if command -v kwriteconfig6 >/dev/null; then
    kwriteconfig6 --file "$file" --group "$group" --key "$key" --type "$type" "$value"
  else
    local conf="$HOME/.config/$file"
    mkdir -p "$(dirname "$conf")"
    # Minimal fallback: append is wrong for updates; require kwriteconfig6 for real use.
    log "kwriteconfig6 missing; skipped $file [$group] $key (install Plasma first)"
    return 0
  fi
}

section "Plasma toolkit override"
install -d "$HOME/.config/plasma-workspace/env"
install -m 0644 "$REPO/plasma/env/90-plasma-toolkit.sh" \
  "$HOME/.config/plasma-workspace/env/90-plasma-toolkit.sh"
log "QT_QPA_PLATFORMTHEME=plasma for Plasma session only"

section "Look and Feel"
kw kdeglobals General ColorScheme string BreezeDark
kw kdeglobals KDE LookAndFeelPackage string org.kde.breezedark.desktop
kw kdeglobals Icons Theme string breeze-dark
# Breeze for GTK apps launched under Plasma (breeze-gtk-theme package).
kw kdeglobals KDE widgetStyle string Breeze
log "Breeze Dark + breeze-dark icons"

section "Fonts"
# Qt font.toString() form used by Plasma 6; weight 50 = Normal.
kw kdeglobals General font string "Ubuntu Sans,11,-1,5,50,0,0,0,0,0"
kw kdeglobals General menuFont string "Ubuntu Sans,11,-1,5,50,0,0,0,0,0"
kw kdeglobals General toolBarFont string "Ubuntu Sans,10,-1,5,50,0,0,0,0,0"
kw kdeglobals General smallestReadableFont string "Ubuntu Sans,10,-1,5,50,0,0,0,0,0"
kw kdeglobals General fixed string "Iosevka Quiet,12,-1,5,50,0,0,0,0,0"
log "Ubuntu Sans UI, Iosevka Quiet 12 monospace"

section "KWin: no decoration theater"
kw kwinrc Compositing Enabled bool true
# Empty plugin list = no blur, magic lamp, wobbly windows, etc.
kw kwinrc Plugins blurEnabled bool false
kw kwinrc Plugins contrastEnabled bool false
kw kwinrc Plugins cubecoverEnabled bool false
kw kwinrc Plugins cubeslideEnabled bool false
kw kwinrc Plugins desktopgridEnabled bool false
kw kwinrc Plugins diminactiveEnabled bool false
kw kwinrc Plugins fallapartEnabled bool false
kw kwinrc Plugins glidedEnabled bool false
kw kwinrc Plugins invertEnabled bool false
kw kwinrc Plugins lookingglassEnabled bool false
kw kwinrc Plugins magiclampEnabled bool false
kw kwinrc Plugins magnifierEnabled bool false
kw kwinrc Plugins mouseclickEnabled bool false
kw kwinrc Plugins mousemarkEnabled bool false
kw kwinrc Plugins overviewEnabled bool false
kw kwinrc Plugins presentwindowsEnabled bool false
kw kwinrc Plugins scaleinEnabled bool false
kw kwinrc Plugins sheetEnabled bool false
kw kwinrc Plugins slidebackEnabled bool false
kw kwinrc Plugins slidingpopupsEnabled bool false
kw kwinrc Plugins thumbnailasideEnabled bool false
kw kwinrc Plugins thumbgridEnabled bool false
kw kwinrc Plugins trackmouseEnabled bool false
kw kwinrc Plugins windowgeometryEnabled bool false
kw kwinrc Plugins wobblywindowsEnabled bool false
kw kwinrc Plugins zoomEnabled bool false
# Instant window animations (factor 0 = off in Plasma 6).
kw kwinrc General AnimationDurationFactor double 0
kw kwinrc Windows BorderlessMaximizedWindows bool true
log "effects off, animation factor 0, borderless maximized"

section "Desktop surface"
kw dolphinrc General ShowFullPathInTitlebar bool true
kw dolphinrc General FilterBar bool false
log "prefer Dolphin in Plasma; keep Nautilus for the GNOME session"
log "rule: one panel, no widget zoo, empty desktop"

section "Toolkit env check"
env_file="$HOME/.config/plasma-workspace/env/90-plasma-toolkit.sh"
if [ -L "$env_file" ] || [ -f "$env_file" ]; then
  log "plasma toolkit override present: $env_file"
else
  log "WARNING: missing $env_file — re-run ./bootstrap.sh"
fi

if command -v kwriteconfig6 >/dev/null; then
  printf '\nDone. Log out → GDM → Plasma (Wayland).\n'
  printf 'Inside Plasma: System Settings → Colors should show Breeze Dark.\n'
  printf 'Rule: one panel, no widget zoo. Dolphin for files, Ghostty for terminal.\n'
else
  printf '\nPlasma packages not installed yet. Run:\n'
  printf '  sudo ./scripts/root-setup.sh --plasma\n'
  printf 'then re-run this script.\n'
fi
