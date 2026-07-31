#!/usr/bin/env bash
# Build Iosevka Quiet from fonts/iosevka/private-build-plans.toml and install
# into ~/.local/share/fonts/iosevka-quiet. Idempotent once source is cached.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="$REPO/fonts/iosevka/private-build-plans.toml"
SRC="${IOSEVKA_SRC:-$HOME/.cache/iosevka-src/Iosevka}"
DEST="$HOME/.local/share/fonts/iosevka-quiet"
TAG="${IOSEVKA_TAG:-v34.8.0}"

if [ ! -f "$PLAN" ]; then
  echo "missing build plan: $PLAN" >&2
  exit 1
fi

if [ ! -d "$SRC/.git" ]; then
  mkdir -p "$(dirname "$SRC")"
  git clone --depth 1 --branch "$TAG" https://github.com/be5invis/Iosevka.git "$SRC"
fi

cp "$PLAN" "$SRC/private-build-plans.toml"
(
  cd "$SRC"
  if [ ! -d node_modules ]; then
    npm install
  fi
  # Unhinted: Wayland/GTK use grayscale AA, and ttfautohint is optional.
  npm run build -- ttf-unhinted::IosevkaQuiet
)

mkdir -p "$DEST"
cp -f "$SRC"/dist/IosevkaQuiet/TTF-Unhinted/*.ttf "$DEST/"
fc-cache -f "$DEST"

echo "installed:"
fc-list "Iosevka Quiet" file style | sort
echo
echo "monospace resolves to: $(fc-match -f '%{family[0]}\n' monospace)"
echo "re-run ./bootstrap.sh to point GNOME/Ghostty/Cursor at it if needed"
