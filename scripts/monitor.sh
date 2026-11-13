#!/usr/bin/env bash
D="${HOME}/.local/state/xfce-forensics"; mkdir -p "$D"
OUT="$D/monitor-$(date +%Y%m%d-%H%M%S).log"
{
  date -Is
  pgrep -x xfwm4 || echo "xfwm4 MISSING"
  xfconf-query -c xfwm4 -p /general/use_compositing || echo unknown
  xdpyinfo | grep -iqw RENDER && echo "RENDER present" || echo "RENDER ABSENT"
  command -v statedrift >/dev/null && statedrift watch --once --json || echo "statedrift n/a"
  command -v configsnap >/dev/null && sudo -n configsnap --phase post || echo "configsnap n/a"
} >>"$OUT" 2>&1
echo "$OUT"
