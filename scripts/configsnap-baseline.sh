#!/usr/bin/env bash
# One-shot configsnap: pre | post | report.
#   sudo ./configsnap-baseline.sh pre
#   ... change something ...
#   sudo ./configsnap-baseline.sh post
#   sudo ./configsnap-baseline.sh report <tag>
#
# Env overrides:
#   CONFIGSNAP_TAG   default: timestamp
#   CONFIGSNAP_BASE  default: /var/log/configsnap
#   CONFIGSNAP_ARCHIVE=1 -> pass -a (tar the output)
set +e

PHASE="${1:-pre}"
TAG="${CONFIGSNAP_TAG:-$(date +%Y%m%d-%H%M%S)}"
BASE="${CONFIGSNAP_BASE:-/var/log/configsnap}"
ARCHIVE_FLAG=""
[ "${CONFIGSNAP_ARCHIVE:-0}" = "1" ] && ARCHIVE_FLAG="-a"

if ! command -v configsnap >/dev/null; then
  echo "configsnap not installed."
  echo "  sudo dnf install -y configsnap"
  echo "  # upstream: https://github.com/rackerlabs/configsnap"
  echo "  # Fedora:   https://packages.fedoraproject.org/pkgs/configsnap/configsnap/"
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "configsnap must run as root (it reads /proc, package DB, services)."
  echo "re-run with: sudo $0 $PHASE"
  exit 0
fi

mkdir -p "$BASE" || { echo "cannot create $BASE"; exit 0; }

case "$PHASE" in
  pre|baseline)
    echo "configsnap pre: tag=$TAG base=$BASE"
    configsnap -t "$TAG" -p pre -d "$BASE" -v $ARCHIVE_FLAG
    echo "saved under: $BASE/$TAG/"
    echo "tag for later: $TAG"
    ;;
  post|after)
    echo "configsnap post: tag=$TAG base=$BASE"
    configsnap -t "$TAG" -p post -d "$BASE" -v $ARCHIVE_FLAG
    echo "diff written under: $BASE/$TAG/"
    echo "tag: $TAG"
    ;;
  report|diff|compare)
    PRE_TAG="${2:-}"
    if [ -z "$PRE_TAG" ]; then
      PRE_TAG=$(ls -1 "$BASE" 2>&1 | head -n 1)
    fi
    if [ -z "$PRE_TAG" ]; then
      echo "no tags under $BASE yet; run: sudo $0 pre"
      exit 0
    fi
    echo "configsnap compare-only: tag=$PRE_TAG"
    configsnap -C --pre=pre -p post -t "$PRE_TAG" -d "$BASE" -v $ARCHIVE_FLAG
    ;;
  *)
    echo "usage: $0 {pre|post|report} [tag]"
    exit 0
    ;;
esac

echo "done."
