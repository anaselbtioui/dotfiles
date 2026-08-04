# COSMIC second-session trial

**Status: rejected.** Tried as a second GDM session; did not stick. Daily driver
stays Ubuntu GNOME under the Quiet design system — see
[design-system.md](design-system.md). DE shopping is closed.

Kept below for purge/reinstall commands only.

System76 **COSMIC** was evaluated as a second GDM login session next to Ubuntu
GNOME.

## Risk

Install uses the unofficial PPA [`ppa:hepp3n/cosmic-epoch`](https://launchpad.net/~hepp3n/+archive/ubuntu/cosmic-epoch)
(Ubuntu 26.04 / resolute only). It can replace **Mesa**, **Wayland/XWayland**,
**LLVM**, and **Rust** packages from the Ubuntu archive. This laptop has an
Intel iGPU; that usually works, but a bad Mesa swap can break GNOME too.

**Escape hatch (restores archive packages):**

```bash
sudo ./scripts/root-setup.sh --purge-cosmic
# then: ./bootstrap.sh   # clears stale DCONF_PROFILE if still set
# reboot if graphics feel wrong after purge, or if gsettings stays broken
```

`ppa-purge` is the supported rollback. Do not only `apt remove cosmic-session`
if the PPA upgraded Mesa. A lingering `DCONF_PROFILE=.../cosmic` in the user
systemd environment also blocks GNOME settings writes until cleared (bootstrap
does this) or you log out fully.

## Install

```bash
cd ~/_code/dotfiles
sudo ./scripts/root-setup.sh --cosmic
```

If apt asks for a display manager, keep **gdm3**. Never choose `cosmic-greeter`
as default while you still want easy GNOME logins. Verify:

```bash
cat /etc/X11/default-display-manager
# expect: /usr/sbin/gdm3
ls /usr/share/wayland-sessions/
# expect: ubuntu.desktop and a COSMIC session file
```

Package notes live in [`packages/cosmic.txt`](../packages/cosmic.txt). The
install path is the meta package `cosmic-session`.

## Switch sessions (read this — Plasma lesson)

Logging out and back in **keeps Ubuntu** unless you change the session.

1. Use the top-right menu → **Log Out** (not lock, not reboot required).
2. At the GDM **password** screen (not the blurred lock screen), look
   **bottom-right** for the **gear** icon.
3. Click the gear → choose **COSMIC** (not Ubuntu).
4. Enter password.

No gear? Click the user / password field first so the session menu appears.

After login, confirm you are not still on GNOME:

```bash
echo "$XDG_CURRENT_DESKTOP"
# want something COSMIC-related, not ubuntu:GNOME
```

Back to GNOME: log out → gear → **Ubuntu**.

## What to judge

- Tiling / window management vs GNOME overview
- Settings app completeness
- **cosmic-files** vs Nautilus; **cosmic-term** vs Ghostty
- Stability for a full work day (Cursor, Brave, Android tooling)
- Whether the iced UI feels calmer than Plasma did

Do **not** spend the week ricing COSMIC. Defaults are the product under test.
Ghostty, Iosevka Quiet, Modus, and Cursor stay available; they are
session-agnostic.

## Remove

```bash
sudo ./scripts/root-setup.sh --purge-cosmic
```

That runs `ppa-purge ppa:hepp3n/cosmic-epoch` and keeps gdm3. Reboot if display
stack packages were reverted.
