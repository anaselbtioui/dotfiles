#!/usr/bin/env bash
# Root-level half of the setup: package installs/removals and the login screen.
# Run once with sudo, then re-run ../bootstrap.sh if you like. Idempotent.
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "run as root: sudo $0" >&2
  exit 1
fi

DROP_ALACRITTY=0
INSTALL_PLASMA=0
PURGE_PLASMA=0
INSTALL_COSMIC=0
PURGE_COSMIC=0
for arg in "$@"; do
  case "$arg" in
    --drop-alacritty) DROP_ALACRITTY=1 ;;
    --plasma) INSTALL_PLASMA=1 ;;
    --purge-plasma) PURGE_PLASMA=1 ;;
    --cosmic) INSTALL_COSMIC=1 ;;
    --purge-cosmic) PURGE_COSMIC=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: sudo ./scripts/root-setup.sh [flags]

  --drop-alacritty   Purge alacritty after Ghostty is the daily terminal.
  --plasma           Install Plasma 6 as a second GDM session (keeps gdm3).
  --purge-plasma     Remove the Plasma trial packages and autoremove.
  --cosmic           Install COSMIC via ppa:hepp3n/cosmic-epoch (keeps gdm3).
  --purge-cosmic     ppa-purge the COSMIC PPA and restore Ubuntu packages.
EOF
      exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

section() { printf '\n== %s\n' "$1"; }
log() { printf '   %s\n' "$1"; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

install_from_list() {
  local list="$1"
  local apt_flags="${2:-}"
  mapfile -t PACKAGES < <(grep -vE '^\s*(#|$)' "$list")
  for p in "${PACKAGES[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      log "$p already installed"
    elif apt-get install -y $apt_flags "$p"; then
      log "installed $p"
    else
      log "FAILED to install $p"
    fi
  done
}

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
apt-get update -qq
install_from_list "$REPO/packages/apt.txt"

if [ "$DROP_ALACRITTY" = 1 ] && dpkg -s alacritty >/dev/null 2>&1; then
  apt-get purge -y alacritty && log "purged alacritty"
fi

if [ "$INSTALL_PLASMA" = 1 ]; then
  section "Plasma second session (keep gdm3)"
  # Stop apt/sddm from stealing the display manager during recommends resolution.
  echo 'gdm3 shared/default-x-display-manager select gdm3' | debconf-set-selections
  echo 'sddm shared/default-x-display-manager select gdm3' | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends kde-plasma-desktop
  log "kde-plasma-desktop installed (no recommends)"
  # Usable extras that --no-install-recommends would otherwise skip.
  mapfile -t PLASMA_EXTRAS < <(grep -vE '^\s*(#|$|kde-plasma-desktop)' "$REPO/packages/plasma.txt")
  for p in "${PLASMA_EXTRAS[@]}"; do
    if dpkg -s "$p" >/dev/null 2>&1; then
      log "$p already installed"
    elif DEBIAN_FRONTEND=noninteractive apt-get install -y "$p"; then
      log "installed $p"
    else
      log "FAILED to install $p"
    fi
  done

  if [ -f /usr/share/wayland-sessions/plasma.desktop ] || [ -f /usr/share/wayland-sessions/plasmax11.desktop ] || ls /usr/share/wayland-sessions/*plasma* >/dev/null 2>&1; then
    log "Plasma Wayland session desktop file present:"
    ls /usr/share/wayland-sessions/*plasma* 2>/dev/null | sed 's/^/   /'
  else
    log "WARNING: no Plasma entry under /usr/share/wayland-sessions/"
  fi

  dm="$(cat /etc/X11/default-display-manager 2>/dev/null || true)"
  if echo "$dm" | grep -q gdm; then
    log "default display manager: $dm"
  else
    log "WARNING: default DM is '$dm' — expected gdm3. Fix with: sudo dpkg-reconfigure gdm3"
  fi
fi

if [ "$PURGE_PLASMA" = 1 ]; then
  section "Purging Plasma trial"
  mapfile -t PLASMA_PKGS < <(grep -vE '^\s*(#|$)' "$REPO/packages/plasma.txt")
  # Also pull common deps that the meta package left behind if listed as installed.
  EXTRA_PURGE=(plasma-desktop plasma-workspace plasma-workspace-wayland kde-baseapps)
  DEBIAN_FRONTEND=noninteractive apt-get purge -y "${PLASMA_PKGS[@]}" "${EXTRA_PURGE[@]}" 2>/dev/null || \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y "${PLASMA_PKGS[@]}"
  apt-get autoremove --purge -y
  echo 'gdm3 shared/default-x-display-manager select gdm3' | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure gdm3 >/dev/null 2>&1 || true
  if [ -e /usr/share/wayland-sessions/plasma.desktop ]; then
    log "WARNING: plasma.desktop still present"
  else
    log "Plasma session removed from GDM"
  fi
  dm="$(cat /etc/X11/default-display-manager 2>/dev/null || true)"
  log "default display manager: $dm"
fi

if [ "$INSTALL_COSMIC" = 1 ]; then
  section "COSMIC second session (keep gdm3)"
  # Unofficial PPA; may replace Mesa/Wayland. Rollback: --purge-cosmic.
  echo 'gdm3 shared/default-x-display-manager select gdm3' | debconf-set-selections
  echo 'cosmic-greeter shared/default-x-display-manager select gdm3' | debconf-set-selections
  if ls /etc/apt/sources.list.d/*hepp3n*cosmic* >/dev/null 2>&1 || \
     grep -rq hepp3n/cosmic-epoch /etc/apt/sources.list.d/ 2>/dev/null; then
    log "ppa:hepp3n/cosmic-epoch already configured"
  else
    add-apt-repository -y ppa:hepp3n/cosmic-epoch
    log "added ppa:hepp3n/cosmic-epoch"
  fi
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y cosmic-session
  log "cosmic-session installed"

  if ls /usr/share/wayland-sessions/*[Cc]osmic* >/dev/null 2>&1 || \
     ls /usr/share/wayland-sessions/cosmic*.desktop >/dev/null 2>&1; then
    log "COSMIC Wayland session desktop file present:"
    ls /usr/share/wayland-sessions/*[Cc]osmic* /usr/share/wayland-sessions/cosmic*.desktop 2>/dev/null | sort -u | sed 's/^/   /'
  else
    log "WARNING: no COSMIC entry under /usr/share/wayland-sessions/"
    ls /usr/share/wayland-sessions/ 2>/dev/null | sed 's/^/   /'
  fi

  dm="$(cat /etc/X11/default-display-manager 2>/dev/null || true)"
  if echo "$dm" | grep -q gdm; then
    log "default display manager: $dm"
  else
    log "WARNING: default DM is '$dm' — expected gdm3. Fix with: sudo dpkg-reconfigure gdm3"
  fi
fi

if [ "$PURGE_COSMIC" = 1 ]; then
  section "Purging COSMIC trial (ppa-purge)"
  echo 'gdm3 shared/default-x-display-manager select gdm3' | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure gdm3 >/dev/null 2>&1 || true
  apt-get install -y ppa-purge
  # Restores Ubuntu archive versions of anything the PPA replaced (Mesa, etc.).
  if ppa-purge -y ppa:hepp3n/cosmic-epoch; then
    log "ppa-purge completed"
  else
    log "ppa-purge reported errors — removing leftover PPA sources by hand"
  fi
  # ppa-purge can miss Deb822 .sources files on resolute; clear leftovers.
  rm -fv /etc/apt/sources.list.d/hepp3n-ubuntu-cosmic-epoch-*.sources \
    /etc/apt/sources.list.d/hepp3n-ubuntu-cosmic-epoch-*.list 2>/dev/null || true
  apt-get update -qq || true
  if ls /usr/share/wayland-sessions/*[Cc]osmic* >/dev/null 2>&1; then
    log "WARNING: COSMIC session file still present"
  else
    log "COSMIC session removed from GDM"
  fi
  dm="$(cat /etc/X11/default-display-manager 2>/dev/null || true)"
  log "default display manager: $dm"
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

if [ "$INSTALL_COSMIC" = 1 ]; then
  printf '\nCOSMIC ready. Logout alone keeps Ubuntu — you must pick the session:\n'
  printf '  1. Log out (not lock)\n'
  printf '  2. GDM password screen → gear (bottom-right)\n'
  printf '  3. Choose COSMIC → enter password\n'
  printf 'Verify after login:  echo \$XDG_CURRENT_DESKTOP\n'
  printf 'Hate it:  sudo ./scripts/root-setup.sh --purge-cosmic\n'
elif [ "$PURGE_COSMIC" = 1 ]; then
  printf '\nCOSMIC PPA purged. Reboot if Mesa/Wayland were swapped.\n'
  printf 'GDM should only show Ubuntu.\n'
  printf 'Then run ./bootstrap.sh as your user (clears stale DCONF_PROFILE).\n'
elif [ "$INSTALL_PLASMA" = 1 ]; then
  printf '\nPlasma ready. Log out, pick Plasma (Wayland) at GDM, then run:\n'
  printf '  ./scripts/bootstrap-plasma.sh\n'
elif [ "$PURGE_PLASMA" = 1 ]; then
  printf '\nPlasma purged. Stay on Ubuntu at GDM. Optional home cleanup:\n'
  printf '  rm -rf ~/.config/plasma* ~/.config/kwinrc ~/.config/kdeglobals ~/.config/dolphinrc ~/.local/share/kscreen\n'
else
  printf '\nDone. Log out and back in.\n'
fi
