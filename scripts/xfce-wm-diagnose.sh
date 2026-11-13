#!/usr/bin/env bash
# Read-only diagnostics. Makes no changes.
echo "=== XFCE WM diagnostics ==="; date
echo "--- processes ---"
pgrep -a xfwm4 || echo "xfwm4: NOT RUNNING"
pgrep -a xfce4-session || echo "xfce4-session: NOT RUNNING"
pgrep -a xfsettingsd || echo "xfsettingsd: NOT RUNNING"
echo "--- compositor ---"
xfconf-query -c xfwm4 -p /general/use_compositing || echo unknown
echo "--- X11 extensions (RENDER is the correct name) ---"
xdpyinfo | grep -iE 'RENDER|Composite|DAMAGE' || echo "absent or xdpyinfo unavailable"
echo "--- graphics ---"
lspci -nnk | grep -A3 -E 'VGA|3D' | head -n 8 || echo "lspci unavailable"
echo "--- Alt-Tab binding ---"
xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Tab' || echo unknown
