#!/usr/bin/env bash
# One-shot bundle: diagnose + configsnap (if root) + tibet-snap -> .tar.gz
#   ./forensic-baseline.sh [outdir]
set +e

OUTDIR="${1:-$HOME/.local/state/xfce-forensics}"
STAMP=$(date +%Y%m%d-%H%M%S)
BUNDLE="$OUTDIR/bundle-$STAMP"
HERE=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$BUNDLE" || { echo "cannot create $BUNDLE"; exit 0; }

echo "bundle: $BUNDLE"
echo "scripts: $HERE"

echo "--- diagnose ---"
"$HERE/xfce-wm-diagnose.sh" > "$BUNDLE/diagnose.txt" 2>>"$BUNDLE/errors.log"

echo "--- configsnap ---"
if command -v configsnap >/dev/null && [ "$(id -u)" -eq 0 ]; then
  "$HERE/configsnap-baseline.sh" pre > "$BUNDLE/configsnap-pre.txt" 2>>"$BUNDLE/errors.log"
else
  {
    echo "configsnap skipped"
    echo "reason: $(command -v configsnap >/dev/null && echo 'not root' || echo 'not installed')"
    echo "install: sudo dnf install -y configsnap"
  } > "$BUNDLE/configsnap-pre.txt"
fi

echo "--- tibet-snap ---"
"$HERE/tibet-snap-baseline.sh" "bundle-$STAMP" > "$BUNDLE/tibet-snap.txt" 2>>"$BUNDLE/errors.log"

mkdir -p "$BUNDLE/scripts"
cp -a "$HERE"/. "$BUNDLE/scripts/" 2>>"$BUNDLE/errors.log"

echo "--- archive ---"
tar -C "$OUTDIR" -czf "$BUNDLE.tar.gz" "bundle-$STAMP"
echo "wrote: $BUNDLE.tar.gz"
echo "contents:"
tar -tzf "$BUNDLE.tar.gz" | head -n 40
