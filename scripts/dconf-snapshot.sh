#!/usr/bin/env bash
# Capture the current GNOME settings into dconf/gnome.ini so a reinstall can be
# restored with `./bootstrap.sh --restore-dconf`.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/dconf/gnome.ini"

mkdir -p "$(dirname "$OUT")"
dconf dump /org/gnome/ > "$OUT"

printf 'wrote %s (%s lines)\n' "$OUT" "$(wc -l < "$OUT")"
