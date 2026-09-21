#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if ! grep -Fq 'CMD ["/root/connect.sh"]' "$ROOT_DIR/Dockerfile"; then
  echo "Expected Dockerfile to run /root/connect.sh directly" >&2
  exit 1
fi

if grep -Fq '&& sh && tail -f /dev/null' "$ROOT_DIR/Dockerfile"; then
  echo "Dockerfile should not start an interactive shell and tail to keep the container alive" >&2
  exit 1
fi
