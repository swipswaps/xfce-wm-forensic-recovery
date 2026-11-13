#!/usr/bin/env bash
# Snapshot + drift check + log. Safe from cron.
LOG_DIR="${HOME}/.local/state/xfce-forensics"
mkdir -p "$LOG_DIR"
OUT="$LOG_DIR/monitor-$(date +%Y%m%d-%H%M%S).log"
{
  date -Is
  echo "--- xfwm4 ---"
  pgrep -x xfwm4 || echo "MISSING"
  echo "--- compositing ---"
  xfconf-query -c xfwm4 -p /general/use_compositing || echo unknown
  echo "--- RENDER (correct extension name) ---"
  xdpyinfo | grep -iqw RENDER && echo present || echo ABSENT
  echo "--- statedrift ---"
  command -v statedrift >/dev/null && statedrift watch --once --json || echo "statedrift not installed"
  echo "--- configsnap ---"
  command -v configsnap >/dev/null && sudo -n configsnap --phase post || echo "configsnap not installed / sudo -n unavailable"
  echo "--- tibet-snap ---"
  command -v tibet-snap >/dev/null && tibet-snap list || echo "tibet-snap not installed"
} >>"$OUT" 2>&1
echo "$OUT"
