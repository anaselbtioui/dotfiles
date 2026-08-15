#!/usr/bin/env python3
"""Quiet live wallpaper: slow Modus breath on a radial canvas.

Stock Sway has no video wallpaper daemon in Ubuntu. This draws a BACKGROUND
layer at ~12 fps. Cycle ~22s. Amplitude tiny so acrylic bar stays readable.
"""
import math
import sys
import time

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell  # noqa: E402

# BG_MAIN #0d0e1c  →  slightly lifted toward BG_DIM, never a rainbow.
C0 = (13 / 255.0, 14 / 255.0, 28 / 255.0)
C1 = (22 / 255.0, 26 / 255.0, 42 / 255.0)
PERIOD = 22.0
FPS_MS = 90


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


class Canvas(Gtk.DrawingArea):
    def __init__(self):
        super().__init__()
        self.set_hexpand(True)
        self.set_vexpand(True)
        self.t0 = time.monotonic()
        self.connect("draw", self.on_draw)

    def on_draw(self, _widget, cr):
        w = self.get_allocated_width()
        h = self.get_allocated_height()
        if w <= 0 or h <= 0:
            return False
        phase = (time.monotonic() - self.t0) / PERIOD
        t = 0.5 + 0.5 * math.sin(2 * math.pi * phase)
        inner = mix(C0, C1, t)
        outer = mix(C0, C1, t * 0.25)
        cx, cy = w * 0.5, h * 0.38
        rad = max(w, h) * 0.85
        pat = cairo_radial(cr, cx, cy, 0, cx, cy, rad)
        pat.add_color_stop_rgb(0.0, *inner)
        pat.add_color_stop_rgb(1.0, *outer)
        cr.set_source(pat)
        cr.paint()
        return False


def cairo_radial(cr, x0, y0, r0, x1, y1, r1):
    import cairo

    return cairo.RadialGradient(x0, y0, r0, x1, y1, r1)


def tick(area):
    area.queue_draw()
    return True


def main():
    Gtk.init(sys.argv)
    win = Gtk.Window()
    win.set_title("quiet-live-bg")
    win.set_decorated(False)
    win.set_app_paintable(True)
    win.set_accept_focus(False)
    win.set_can_focus(False)

    screen = Gdk.Screen.get_default()
    visual = screen.get_rgba_visual() if screen is not None else None
    if visual is not None:
        win.set_visual(visual)

    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_namespace(win, "quiet-wallpaper")
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.BACKGROUND)
    GtkLayerShell.set_keyboard_mode(win, GtkLayerShell.KeyboardMode.NONE)
    GtkLayerShell.set_exclusive_zone(win, -1)
    for edge in (
        GtkLayerShell.Edge.TOP,
        GtkLayerShell.Edge.BOTTOM,
        GtkLayerShell.Edge.LEFT,
        GtkLayerShell.Edge.RIGHT,
    ):
        GtkLayerShell.set_anchor(win, edge, True)
        GtkLayerShell.set_margin(win, edge, 0)

    area = Canvas()
    win.add(area)
    GLib.timeout_add(FPS_MS, tick, area)
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
