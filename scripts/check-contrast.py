#!/usr/bin/env python3
"""Verify the palette still meets its contrast claims.

WCAG relative luminance and contrast ratio, per
https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
"""

import pathlib
import sys

PALETTE = pathlib.Path(__file__).resolve().parent.parent / "palette" / "modus-vivendi-tinted.env"

AAA_TEXT = 7.0
AA_TEXT = 4.5


def load(path):
    values = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def luminance(hex_color):
    r, g, b = (int(hex_color[i : i + 2], 16) / 255 for i in (1, 3, 5))
    channels = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in (r, g, b)]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def ratio(fg, bg):
    a, b = luminance(fg), luminance(bg)
    lighter, darker = max(a, b), min(a, b)
    return (lighter + 0.05) / (darker + 0.05)


def main():
    p = load(PALETTE)
    bg = p["BG_MAIN"]
    failures = 0

    print(f"background {bg}\n")

    # Modus claims AAA for primary text. fg-dim is de-emphasized by design and
    # only needs to clear AA.
    print("primary text (target AAA 7:1)")
    for key in ("FG_MAIN", "FG_ALT"):
        r = ratio(p[key], bg)
        ok = r >= AAA_TEXT
        failures += not ok
        print(f"  {key:<22} {p[key]}  {r:5.2f}:1  {'AAA' if ok else 'FAIL'}")

    print("\nde-emphasized text (target AA 4.5:1)")
    r = ratio(p["FG_DIM"], bg)
    ok = r >= AA_TEXT
    failures += not ok
    print(f"  {'FG_DIM':<22} {p['FG_DIM']}  {r:5.2f}:1  {'AA ' if ok else 'FAIL'}")

    # Slots 0 and 8 are deliberately dark greys. Programs use them as fill and
    # dim-decoration colors, not as body text on the main background, so a
    # contrast target would be meaningless.
    dark_slots = ("TERM_BLACK", "TERM_BLACK_BRIGHT")

    print("\nansi colors (target AA 4.5:1)")
    for key in sorted(k for k in p if k.startswith("TERM_") and k not in dark_slots):
        r = ratio(p[key], bg)
        ok = r >= AA_TEXT
        failures += not ok
        print(f"  {key:<22} {p[key]}  {r:5.2f}:1  {'AA ' if ok else 'FAIL'}")

    print("\nansi dark slots (informational, no target)")
    for key in dark_slots:
        print(f"  {key:<22} {p[key]}  {ratio(p[key], bg):5.2f}:1")

    print("\nsemantic states (target AA 4.5:1)")
    for key in sorted(k for k in p if k.startswith("STATE_")) + ["CURSOR"]:
        r = ratio(p[key], bg)
        ok = r >= AA_TEXT
        failures += not ok
        print(f"  {key:<22} {p[key]}  {r:5.2f}:1  {'AA ' if ok else 'FAIL'}")

    print("\nsurface separation (informational, no target)")
    for key in ("BG_DIM", "BG_INACTIVE", "BG_ACTIVE", "BG_REGION", "BG_POPUP", "BG_HL_LINE", "BORDER"):
        print(f"  {key:<22} {p[key]}  {ratio(p[key], bg):5.2f}:1")

    if failures:
        print(f"\n{failures} value(s) below target")
        return 1
    print("\nall targets met")
    return 0


if __name__ == "__main__":
    sys.exit(main())
