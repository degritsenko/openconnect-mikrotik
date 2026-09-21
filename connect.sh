#!/bin/sh

# Wait for network connectivity
echo "Waiting for network..."
while ! ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; do
  sleep 1
done
echo "Network is up, starting VPN..."

# Start OpenConnect in background
if [ -n "${ANYCONNECT_CERT:-}" ]; then
  echo "$ANYCONNECT_PASSWORD" | openconnect \
    "$ANYCONNECT_SERVER" --user="$ANYCONNECT_USER" -i tun127 --servercert "pin-sha256:${ANYCONNECT_CERT}" &
else
  echo "$ANYCONNECT_PASSWORD" | openconnect \
    "$ANYCONNECT_SERVER" --user="$ANYCONNECT_USER" -i tun127 &
fi
vpn_pid=$!

trap 'kill "$vpn_pid" 2>/dev/null; wait "$vpn_pid" 2>/dev/null; exit 0' INT TERM

# Wait for tun127 interface to appear
echo "Waiting for tun127 interface..."
while ! ip link show tun127 >/dev/null 2>&1; do
  if ! kill -0 "$vpn_pid" 2>/dev/null; then
    wait "$vpn_pid"
    exit $?
  fi
  sleep 1
done
echo "tun127 is ready"

# Keep container running and forward signals to openconnect
echo "VPN is active. Container is running."
wait "$vpn_pid"
