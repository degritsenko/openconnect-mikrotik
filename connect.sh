#!/bin/sh

while ! ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; do
  sleep 1
done

if [ -n "${ANYCONNECT_CERT:-}" ]; then
  echo "$ANYCONNECT_PASSWORD" | openconnect \
    "$ANYCONNECT_SERVER" --user="$ANYCONNECT_USER" -i tun127 --servercert "pin-sha256:${ANYCONNECT_CERT}" &
else
  echo "$ANYCONNECT_PASSWORD" | openconnect \
    "$ANYCONNECT_SERVER" --user="$ANYCONNECT_USER" -i tun127 &
fi
vpn_pid=$!

trap 'kill "$vpn_pid" 2>/dev/null; wait "$vpn_pid" 2>/dev/null; exit 0' INT TERM

while ! ip link show tun127 >/dev/null 2>&1; do
  if ! kill -0 "$vpn_pid" 2>/dev/null; then
    wait "$vpn_pid"
    exit $?
  fi
  sleep 1
done

wait "$vpn_pid"
