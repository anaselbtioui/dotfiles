# Sway second-session trial

**Status: open.** Sway as a second GDM session next to Ubuntu GNOME. Daily
driver stays **Ubuntu** until this trial sticks or is rejected. Plasma and
COSMIC stay closed.

Quiet-colored i3-on-Wayland. Upstream keybindings, Modus palette, no rice.
See the survey notes in chat: Sway is the Quiet-compatible programmer path;
Omarchy/Hyprland is a different design system.

## Risk

Packages come from the Ubuntu 26.04 archive (`universe`). They do not replace
Mesa or GDM. GNOME is untouched. Worst case you cannot tile: log out and pick
**Ubuntu** at GDM.

## Install

```bash
cd ~/_code/dotfiles
sudo ./scripts/root-setup.sh --sway
./bootstrap.sh
```

If apt asks for a display manager, keep **gdm3**. Verify:

```bash
cat /etc/X11/default-display-manager
# expect: /usr/sbin/gdm3
ls /usr/share/wayland-sessions/
# expect: ubuntu.desktop and sway.desktop
```

## Switch sessions

1. Log out (do not shut down).
2. At the GDM gear / session menu, choose **Sway**.
3. Log in. Ghostty, Cursor, Brave, and fonts keep working — they are
   session-agnostic. `environment.d` still sets `QT_QPA_PLATFORMTHEME=gtk3`.

Back to GNOME: log out → choose **Ubuntu**.

## Quiet rules (this trial)

- Upstream Sway keybindings (`Mod4`, hjkl, `$mod+Return` = Ghostty)
- Slow live canvas (`quiet-live-bg.py`, Modus breath). No video daemon in Ubuntu archive.
- Floating Quiet Waybar: acrylic tint+noise (stock Sway cannot live-blur layers)
- mako for notifications (overlay surface only)
- fuzzel as PowerToys Run (Super+Alt+Space); Super+r is the same launcher
- cliphist + fuzzel for Super+v clipboard history
- Yaru cursor and Ubuntu Sans chrome; Iosevka Quiet stays in Ghostty/Cursor
- French AZERTY (`xkb_layout fr`); workspace row is `&é"'(-è_çà`
- Windows muscle: Alt+F4, Super+e files, Super+r / Super+Alt+Space run, Super+d desktop, Super+v clipboard, Super+l lock, Super+Shift+s snip
- No Hyprland, no Quickshell, no waybar rice

## Keys to remember

| Key | Action |
| --- | --- |
| Super+Return | Ghostty |
| Super+Alt+Space | app launcher (fuzzel, PowerToys Run analogue) |
| Super+r | same launcher (Windows Run) |
| Super+e | Files (Nautilus) |
| Super+d | toggle empty desktop workspace |
| Super+v | clipboard history (cliphist + fuzzel) |
| Super+l | lock |
| Alt+F4 / Super+Shift+q | close window |
| Alt+Tab | next window (this workspace) |
| Super+Ctrl+Left/Right | prev/next workspace (Windows desktops) |
| Super+h/j/k / arrows | move focus (`l` is lock) |
| Super+Shift+r | resize mode |
| Super+Shift+v | split vertical |
| Super+t | layout toggle split |
| Super+Shift+c | reload Sway + Waybar style |
| Super+Shift+e | exit Sway (back to GDM) |
| Super+Shift+s | region screenshot → clipboard |
| Shift+Print | full-screen screenshot → clipboard |
| Super+& … Super+à | workspaces 1–10 (AZERTY number row) |
| Super+² | scratchpad |

## Packages

Listed in [`packages/sway.txt`](../packages/sway.txt). Avoid extra bars,
launchers, or blur helpers.

## If the i3 grid feels like Tetris

That is the planned next fork: **niri**, same GDM pattern, still not Omarchy.
Do not overlay Hyprland on 26.04; upstream calls the Ubuntu package outdated.

## Remove the trial

```bash
sudo ./scripts/root-setup.sh --purge-sway
```

GNOME settings and the rest of this repo are untouched. After purge, GDM only
shows **Ubuntu** again. The Quiet Sway configs remain in this repo (symlinks);
they are idle without the packages.
