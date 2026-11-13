#!/usr/bin/env bash
# One-shot tibet-snap: create -> list -> verify -> rollback plan.
#   ./tibet-snap-baseline.sh baseline-$(date +%Y%m%d-%H%M%S)
#
# Env overrides:
#   TIBET_STORE  default: ~/.local/state/tibet-snap
#   TIBET_PATHS  default: "/etc/X11 /etc/xdg /etc/systemd /etc/fonts"
#
# Probes tibet-snap then tibet-wayback (upstream deprecates tibet-snap in
# favour of tibet-wayback).
set +e

NAME="${1:-baseline-$(date +%Y%m%d-%H%M%S)}"
STORE="${TIBET_STORE:-$HOME/.local/state/tibet-snap}"
PATHS="${TIBET_PATHS:-/etc/X11 /etc/xdg /etc/systemd /etc/fonts}"

TOOL=""
if command -v tibet-snap >/dev/null; then
  TOOL="tibet-snap"
elif command -v tibet-wayback >/dev/null; then
  TOOL="tibet-wayback"
fi

if [ -z "$TOOL" ]; then
  echo "tibet-snap / tibet-wayback not installed."
  echo "  python3 -m pip install --user tibet-snap"
  echo "  # deprecated upstream; successor:"
  echo "  python3 -m pip install --user tibet-wayback"
  exit 0
fi

mkdir -p "$STORE" || { echo "cannot create $STORE"; exit 0; }

echo "tool=$TOOL store=$STORE name=$NAME"
echo "paths: $PATHS"

# Run inside the store so the default on-disk layout stays self-contained.
# shellcheck disable=SC2086
( cd "$STORE" && "$TOOL" create "$NAME" $PATHS )

echo "--- list ---"
( cd "$STORE" && "$TOOL" list )

# Verify the newest id if the CLI can list it in a parseable way.
NEWEST=$( ( cd "$STORE" && "$TOOL" list ) 2>&1 | awk 'NF{id=$1} END{print id}' )
if [ -n "$NEWEST" ]; then
  echo "--- verify $NEWEST ---"
  ( cd "$STORE" && "$TOOL" verify "$NEWEST" )
fi

echo "--- rollback plan (Python API) ---"
python3 - "$STORE" <<'PY'
import sys
store = sys.argv[1]
try:
    from tibet_snap import SnapEngine
except Exception as exc:
    print("tibet_snap import failed:", exc)
    print("(rollback plans are only exposed via the Python API, not the CLI)")
    raise SystemExit(0)

try:
    engine = SnapEngine(store_dir=store)
    ids = engine.list_snapshots()
    if not ids:
        print("no snapshots")
        raise SystemExit(0)
    target = ids[-1]
    tid = getattr(target, "id", target)
    print("latest:", tid)
    plan = engine.rollback_plan(tid)
    if not plan:
        print("rollback plan empty")
    else:
        for action in plan:
            if isinstance(action, dict):
                print(" ", action.get("action", "?"), action.get("path", "?"))
            else:
                print(" ", action)
except Exception as exc:
    print("rollback plan unavailable:", exc)
PY

echo "done. store: $STORE"
