#!/bin/sh

# Wait for network connectivity
echo "Waiting for network..."
while ! ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; do
  sleep 1
done
echo "Network is up, starting VPN..."

# Start OpenConnect in background
echo "$ANYCONNECT_PASSWORD" | openconnect \
  "$ANYCONNECT_SERVER" --user="$ANYCONNECT_USER" -i tun127 -b --servercert pin-sha256:${ANYCONNECT_CERT}

# Wait for tun127 interface to appear
echo "Waiting for tun127 interface..."
while ! ip link show tun127 >/dev/null 2>&1; do
  sleep 1
done
echo "tun127 is ready"

# Keep container running and forward signals to openconnect
echo 