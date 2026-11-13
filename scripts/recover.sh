#!/usr/bin/env bash
# List snapshots, compare/verify, and print a Python rollback plan.
command -v tibet-snap >/dev/null || { echo "tibet-snap not installed"; exit 0; }
tibet-snap list
echo "---"
if [ -n "${1:-}" ] && [ -n "${2:-}" ]; then
  tibet-snap compare "$1" "$2"
  tibet-snap verify "$2"
else
  echo "usage: $0 <snapshot-id-a> <snapshot-id-b>"
fi
echo "--- rollback plan (Python API) ---"
python3 - <<'PY'
try:
    from tibet_snap import SnapEngine
    engine = SnapEngine(store_dir=".tibet-snap")
    ids = engine.list_snapshots()
    if not ids:
        print("no snapshots")
    else:
        for action in engine.rollback_plan(ids[-1].id):
            print(action["action"], action["path"])
except Exception as exc:
    print("rollback plan unavailable:", exc)
PY
