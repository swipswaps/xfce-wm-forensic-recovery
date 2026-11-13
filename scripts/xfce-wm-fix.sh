#!/usr/bin/env bash
# Safe, reversible fix. Never kills xfwm4. Never exits the terminal.
echo "=== XFCE WM safe fix ==="
if pgrep -x xfwm4 >/dev/null; then
  echo "xfwm4 already running: $(pgrep -x xfwm4 | tr '\n' ' ')"
else
  echo "starting xfwm4 --compositor=off"
  setsid nohup xfwm4 --compositor=off >/tmp/xfwm4-fix.log 2>&1 < /dev/null &
  disown || true
  sleep 2
  if pgrep -x xfwm4 >/dev/null; then
    echo "xfwm4 started: $(pgrep -x xfwm4 | tr '\n' ' ')"
  else
    echo "xfwm4 did not stay running; log tail:"
    tail -n 30 /tmp/xfwm4-fix.log || true
  fi
fi
echo "persisting use_compositing=false"
if xfconf-query -c xfwm4 -p /general/use_compositing >/dev/null 2>&1; then
  xfconf-query -c xfwm4 -p /general/use_compositing -s false || echo "xfconf-query failed"
else
  xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false || echo "xfconf-query create failed"
fi
echo "GTK_CSD=0 for future GTK apps"
mkdir -p "$HOME/.config/environment.d"
printf 'GTK_CSD=0\n' > "$HOME/.config/environment.d/10-gtk-csd.conf"
grep -q 'GTK_CSD=0' "$HOME/.bashrc" || printf '\nexport GTK_CSD=0\n' >> "$HOME/.bashrc"
echo "done. log out / log in for environment.d to take effect."
