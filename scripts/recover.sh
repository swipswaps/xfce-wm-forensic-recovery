#!/usr/bin/env bash
command -v tibet-snap >/dev/null || { echo "tibet-snap not installed"; exit 0; }
tibet-snap list; echo "---"
if [ -n "${1:-}" ] && [ -n "${2:-}" ]; then
  tibet-snap compare "$1" "$2"; tibet-snap verify "$2"
else
  echo "usage: $0 <a> <b>"
fi
echo "--- rollback plan (Python API) ---"
python3 - <<'PY'
try:
    from tibet_snap import SnapEngine
    e = SnapEngine(store_dir=".tibet-snap")
    ids = e.list_snapshots()
    if not ids: print("no snapshots")
    else:
        for a in e.rollback_plan(ids[-1].id): print(a)
except Exception as ex:
    print("rollback plan unavailable:", ex)
PY
