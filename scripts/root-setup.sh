#!/usr/bin/env bash
# Root-level half of the setup: package installs/removals and the login screen.
# Run once with sudo, then re-run ../bootstrap.sh if you like. Idempotent.
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "run as root: sudo $0" >&2
  exit 1
fi

DROP_ALACRITTY=0
for arg in "$@"; do
  case "$arg" in
    --drop-alacritty) DROP_ALACRITTY=1 ;;
    -h|--help)
      echo "Usage: sudo $0 [--drop-alacritty]"
      exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

section() { printf '\n== %s\n' "$1"; }
log() { printf '   %s\n' "$1"; }

section "Removing abandoned theme packages"
# These content snaps were still connected to brave/slack/clickup/firefox/
# thunderbird while the desktop runs Yaru-dark, so those apps rendered in a
# different theme than everything else.
for s in gtk-theme-colloid icon-theme-papirus; do
  if snap list "$s" >/dev/null 2>&1; then
    snap remove --purge "$s" && log "removed snap $s"
  else
    log "snap $s already absent"
  fi
done

if dpkg -s papirus-icon-theme >/dev/null 2>&1; then
  apt-get purge -y papirus-icon-theme && log "purged papirus-icon-theme"
else
  log "papirus-icon-theme already absent"
fi

section "Installing packages from packages/apt.txt"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mapfile -t PACKAGES < <(grep -vE '^\s*(#|$)' "$REPO/packages/apt.txt")
apt-get update -qq
for p in "${PACKAGES[@]}"; do
  if dpkg -s "$p" >/dev/null 2>&1; then
    log "$p already installed"
  elif apt-get install -y "$p" >/dev/null; then
    log "installed $p"
  else
    log "FAILED to install $p"
  fi
done

if [ "$DROP_ALACRITTY" = 1 ] && dpkg -s alacritty >/dev/null 2>&1; then
  apt-get purge -y alacritty && log "purged alacritty"
fi

section "Login screen consistency"
install -d /etc/dconf/profile /etc/dconf/db/gdm.d
if [ ! -f /etc/dconf/profile/gdm ]; then
  cat > /etc/dconf/profile/gdm <<'EOF'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
  log "created /etc/dconf/profile/gdm"
fi
cat > /etc/dconf/db/gdm.d/10-appearance <<'EOF'
[org/gnome/desktop/interface]
gtk-theme='Yaru-dark'
icon-theme='Yaru-dark'
cursor-theme='Yaru'
cursor-size=24
color-scheme='prefer-dark'
font-name='Ubuntu Sans 11'
font-hinting='slight'
font-antialiasing='grayscale'
EOF
dconf update && log "greeter now matches the session theme, cursor and fonts"

section "Verification"
snap connections 2>/dev/null | awk '/gtk-3-themes|icon-themes/ {print "   " $2 " -> " $3}' | sort -u

printf '\nDone. Log out and back in.\n'
