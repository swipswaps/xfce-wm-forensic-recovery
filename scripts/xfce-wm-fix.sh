#!/usr/bin/env bash
echo "=== XFCE WM safe fix ==="
if pgrep -x xfwm4 >/dev/null; then
  echo "xfwm4 running: $(pgrep -x xfwm4 | tr '\n' ' ')"
else
  setsid nohup xfwm4 --compositor=off >/tmp/xfwm4-fix.log 2>&1 < /dev/null &
  disown || true; sleep 2
  pgrep -x xfwm4 >/dev/null && echo "started" || { echo "failed"; tail -n 30 /tmp/xfwm4-fix.log; }
fi
xfconf-query -c xfwm4 -p /general/use_compositing -s false || echo "xfconf failed"
mkdir -p "$HOME/.config/environment.d"
printf 'GTK_CSD=0\n' > "$HOME/.config/environment.d/10-gtk-csd.conf"
grep -q 'GTK_CSD=0' "$HOME/.bashrc" || printf '\nexport GTK_CSD=0\n' >> "$HOME/.bashrc"
echo "log out / log in for environment.d to take effect"
