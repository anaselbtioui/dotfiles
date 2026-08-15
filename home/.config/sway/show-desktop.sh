#!/bin/sh
# Toggle empty "desktop" workspace. Second press returns to the last one.
# Windows Win+D analogue for Sway. No jq — python3 is already on this machine.
set -e
focused=$(python3 -c 'import json, subprocess; ws = json.loads(subprocess.check_output(["swaymsg", "-t", "get_workspaces"])); print(next(w["name"] for w in ws if w.get("focused")))')
if [ "$focused" = "desktop" ]; then
  swaymsg workspace back_and_forth
else
  swaymsg workspace desktop
fi
