#!/usr/bin/env python3
"""Push the palette into Cursor's settings.json.

Merges only workbench.colorCustomizations and leaves every other setting alone.
Cursor saves settings atomically, which replaces a symlink with a regular file,
so the file is edited in place instead of being linked from this repo.
"""

import json
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
PALETTE = REPO / "palette" / "modus-vivendi-tinted.env"
SETTINGS = pathlib.Path.home() / ".config" / "Cursor" / "User" / "settings.json"


def load_palette(path):
    values = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def colors(p):
    return {
        "editor.background": p["BG_MAIN"],
        "editor.foreground": p["FG_MAIN"],
        "editorCursor.foreground": p["CURSOR"],
        "editor.selectionBackground": p["BG_REGION"],
        "editor.lineHighlightBackground": p["BG_HL_LINE"],
        "editorLineNumber.foreground": p["FG_DIM"],
        "editorLineNumber.activeForeground": p["FG_MAIN"],
        "editorWidget.background": p["BG_POPUP"],
        "editorWidget.border": p["BORDER"],
        "focusBorder": p["BORDER"],
        "sideBar.background": p["BG_DIM"],
        "sideBar.foreground": p["FG_MAIN"],
        "activityBar.background": p["BG_DIM"],
        "activityBar.foreground": p["FG_MAIN"],
        "statusBar.background": p["BG_DIM"],
        "statusBar.foreground": p["FG_MAIN"],
        "titleBar.activeBackground": p["BG_DIM"],
        "titleBar.activeForeground": p["FG_MAIN"],
        "panel.background": p["BG_MAIN"],
        "panel.border": p["BORDER"],
        "tab.activeBackground": p["BG_MAIN"],
        "tab.inactiveBackground": p["BG_DIM"],
        "tab.activeBorderTop": p["STATE_INFO"],
        "editorError.foreground": p["STATE_ERROR"],
        "editorWarning.foreground": p["STATE_WARNING"],
        "editorInfo.foreground": p["STATE_INFO"],
        # Same 16 slots as the standalone terminal, so the integrated one is
        # not a second color language.
        "terminal.background": p["BG_MAIN"],
        "terminal.foreground": p["FG_MAIN"],
        "terminalCursor.foreground": p["CURSOR"],
        "terminal.selectionBackground": p["BG_REGION"],
        "terminal.ansiBlack": p["TERM_BLACK"],
        "terminal.ansiRed": p["TERM_RED"],
        "terminal.ansiGreen": p["TERM_GREEN"],
        "terminal.ansiYellow": p["TERM_YELLOW"],
        "terminal.ansiBlue": p["TERM_BLUE"],
        "terminal.ansiMagenta": p["TERM_MAGENTA"],
        "terminal.ansiCyan": p["TERM_CYAN"],
        "terminal.ansiWhite": p["TERM_WHITE"],
        "terminal.ansiBrightBlack": p["TERM_BLACK_BRIGHT"],
        "terminal.ansiBrightRed": p["TERM_RED_BRIGHT"],
        "terminal.ansiBrightGreen": p["TERM_GREEN_BRIGHT"],
        "terminal.ansiBrightYellow": p["TERM_YELLOW_BRIGHT"],
        "terminal.ansiBrightBlue": p["TERM_BLUE_BRIGHT"],
        "terminal.ansiBrightMagenta": p["TERM_MAGENTA_BRIGHT"],
        "terminal.ansiBrightCyan": p["TERM_CYAN_BRIGHT"],
        "terminal.ansiBrightWhite": p["TERM_WHITE_BRIGHT"],
    }


def main():
    if not SETTINGS.exists():
        print(f"not found: {SETTINGS}", file=sys.stderr)
        return 1

    raw = SETTINGS.read_text()
    try:
        settings = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as err:
        print(f"{SETTINGS} is not plain JSON ({err}); merge by hand", file=sys.stderr)
        return 1

    wanted = colors(load_palette(PALETTE))
    existing = settings.get("workbench.colorCustomizations", {})
    if existing == wanted:
        print("Cursor colors already match the palette")
        return 0

    settings["workbench.colorCustomizations"] = wanted
    SETTINGS.write_text(json.dumps(settings, indent=4) + "\n")
    print(f"wrote {len(wanted)} color keys to {SETTINGS}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
