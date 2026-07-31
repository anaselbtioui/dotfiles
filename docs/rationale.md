# Why this configuration looks the way it does

One rule drives everything here: **reduce variation, do not add decoration.** A
desktop reads as cheap when the same button, the same label or the same window
edge is drawn three different ways by three different toolkits. Adding a theme
or an icon pack usually adds a fourth way.

Baseline this was built on: Ubuntu 26.04 LTS, GNOME Shell 50.1, Wayland, single
1920x1080 eDP panel, Intel Raptor Lake-P graphics.

## Priority order

The audit found the real problems in a different order than the usual "ricing"
checklists suggest. Highest impact first:

1. **Generic font families.** The GNOME UI used `Ubuntu Sans`, but `sans-serif`
   resolved to Noto Sans, `monospace` to DejaVu Sans Mono, and
   `document-font-name` was `Sans 11`. Browsers, Qt and Electron apps therefore
   rendered in different families than the shell. Fixed in
   `home/.config/fontconfig/fonts.conf` plus explicit gsettings values.
2. **Toolkit conformance.** Qt apps had no platform theme at all, so they drew
   light Fusion widgets on a dark desktop. Fixed with `qt6-gtk-platformtheme` /
   `qt5-gtk-platformtheme` and `QT_QPA_PLATFORMTHEME=gtk3`.
3. **Snap apps wired to an abandoned theme.** `brave`, `slack`, `clickup`,
   `firefox` and `thunderbird` were all connected to the `gtk-theme-colloid` and
   `icon-theme-papirus` content snaps while the session ran Yaru-dark. Removed.
4. **Native Wayland for Chromium and Electron.** No flags file existed, so those
   apps ran on Xwayland with their own cursor scaling and worse input handling.
5. **Terminal.** Alacritty was installed with no config at all, so it used
   generic monospace and its own palette.
6. Everything else (dock geometry, desktop icons, login screen) is cleanup.

## Decisions worth remembering

**Grayscale antialiasing, not subpixel.** GTK4 and GNOME 50 render grayscale
only; setting `rgba` would apply to browsers and Xwayland clients alone and make
text weight differ between windows. The value is set both in gsettings and in
`fonts.conf`, because Qt apps and flatpaks ignore xsettings. On a low-DPI 1080p
panel subpixel would be slightly crisper in isolation, and that is exactly the
trade accepted here: uniform beats locally sharper.

**`QT_QPA_PLATFORMTHEME=gtk3`, not `gnome`.** On Ubuntu the working
implementation is `libqgtk3` from `qt6-gtk-platformtheme`. `qgnomeplatform` is
effectively unmaintained for Qt6.

**No `QT_QPA_PLATFORMTHEME` inside flatpaks.** The runtimes carry no `libqgtk3`,
so the host value would only log a warning. VLC already ships
`org.kde.WaylandDecoration.QAdwaitaDecorations` for GNOME-matching decorations.
Flatpaks do get read-only access to host fonts, fontconfig and icons, which they
otherwise cannot see.

**Yaru icons, not Papirus, not MoreWaita (yet).** Papirus is a different design
language, not a more polished one, and it clashes with GNOME apps that ship
symbolic Adwaita-style icons. MoreWaita is the only defensible upgrade because
it extends the Adwaita style to third-party apps; revisit only if specific app
icons look foreign.

**No custom GTK theme.** `~/.themes/Colloid*` was deleted and libadwaita is left
stock. Accent color is set through GNOME's native `accent-color` key, which
achieves the color change with zero risk of breaking after an update.

**Alacritty stays configured but is not the target.** Ghostty is GTK4 +
libadwaita on Linux, so it matches GNOME natively and supports tabs. Until
Ghostty is installed, Alacritty carries the identical font and palette so the
two never look like different terminals. `sudo ./scripts/root-setup.sh
--drop-alacritty` removes it once Ghostty is verified.

**oh-my-zsh and `robbyrussell` kept.** The prompt is already single-line and
needs no glyph font. Measured startup is ~0.40 s, and eager `nvm` loading
accounts for ~0.01 s of that, so lazy-loading `nvm` would buy nothing. The cost
is oh-my-zsh itself; replacing it is a speed decision, not a visual one.

**`wack-lockscreen-clock` kept.** It is the only third-party shell extension and
therefore the only thing likely to break on a GNOME major upgrade, but it is
purely cosmetic and does not alter shell structure. If a GNOME upgrade breaks the
lock screen, disable this first.

## Deliberately not done

- **No ICC display profile.** Without a colorimeter, vendor profiles are often
  worse than none, and per-app color management on Wayland is still thin.
- **No fractional scaling work.** 1920x1080 at scale 1.0 has no scaling problem
  to solve. `xwayland-native-scaling` is already enabled in Mutter.
- **No extension pile.** No Blur My Shell; blur costs GPU time on an iGPU and
  breaks on shell upgrades.
- **No sound theme work.** Ubuntu barely uses system sounds, so the payoff is
  near zero next to typography and toolkit consistency.

## Provenance

`docs/original-chatgpt-conversation.md` is the conversation that started this.
Its diagnosis was sound and its closing principle is the rule quoted at the top,
but its checklist put display calibration and font/icon swapping first while
omitting toolkit conformance, browser integration and font fallback entirely.
This document is the corrected version.
