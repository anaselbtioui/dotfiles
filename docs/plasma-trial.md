# Plasma second-session trial

**Status: rejected.** Tried as a second GDM session; did not stick. COSMIC was
also tried and rejected. Daily driver stays Ubuntu GNOME — see
[design-system.md](design-system.md). DE shopping is closed.

KDE Plasma 6 as a **second GDM login session** next to Ubuntu GNOME. Kept below
for purge/reinstall commands only.

## Install

```bash
cd ~/_code/dotfiles
sudo ./scripts/root-setup.sh --plasma
./bootstrap.sh
./scripts/bootstrap-plasma.sh
```

If apt asks for a display manager, keep **gdm3**. The script preseeds that choice;
verify with:

```bash
cat /etc/X11/default-display-manager
# expect: /usr/sbin/gdm3
```

## Switch sessions

1. Log out (do not shut down).
2. At the GDM gear / session menu, choose **Plasma (Wayland)**.
3. Log in. Ghostty, Cursor, Brave, and fonts keep working — they are
   session-agnostic.

Back to GNOME: log out → choose **Ubuntu**.

## Quiet rules (this trial)

- Breeze Dark look-and-feel, breeze-dark icons
- KWin effects off, animation duration factor `0`
- Borderless maximized windows
- One panel, no widget zoo
- **Dolphin** for files in Plasma; Nautilus stays for GNOME
- Monospace: Iosevka Quiet (same build as GNOME)
- No Latte Dock, no store themes, no blur packs

## Qt platform theme split

| Session | `QT_QPA_PLATFORMTHEME` | Where |
| --- | --- | --- |
| Ubuntu GNOME | `gtk3` | `~/.config/environment.d/90-toolkits.conf` |
| Plasma | `plasma` | `~/.config/plasma-workspace/env/90-plasma-toolkit.sh` |

Plasma sources `plasma-workspace/env/*.sh` at session start, so it overrides the
global gtk3 value without breaking GNOME.

## Packages

Listed in [`packages/plasma.txt`](../packages/plasma.txt):

- `kde-plasma-desktop` (meta, installed with `--no-install-recommends`)
- `kwin-wayland`, `plasma-session-wayland`
- `plasma-nm`, `plasma-pa`, `powerdevil`, `kscreen`
- `breeze-gtk-theme`, `kde-config-gtk-style`
- `xdg-desktop-portal-kde`

Avoid `kubuntu-desktop` and `kde-full`.

## Remove the trial

```bash
sudo ./scripts/root-setup.sh --purge-plasma
rm -rf ~/.config/plasma* ~/.config/kwinrc ~/.config/kdeglobals ~/.config/dolphinrc ~/.local/share/kscreen
```

GNOME settings and the rest of this repo are untouched. After purge, GDM only
shows **Ubuntu** again.
