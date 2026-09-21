#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/ping" <<'STUB'
#!/bin/sh
exit 0
STUB

cat >"$TMP_DIR/sleep" <<'STUB'
#!/bin/sh
exit 0
STUB

cat >"$TMP_DIR/ip" <<'STUB'
#!/bin/sh
if [ "$1" = "link" ] && [ "$2" = "show" ] && [ "$3" = "tun127" ]; then
  exit 0
fi
exit 1
STUB

cat >"$TMP_DIR/openconnect" <<'STUB'
#!/bin/sh
printf '%s\n' "$@" >"$OPENCONNECT_ARGS_FILE"
exit 0
STUB

chmod +x "$TMP_DIR/ping" "$TMP_DIR/sleep" "$TMP_DIR/ip" "$TMP_DIR/openconnect"

run_connect() {
  OPENCONNECT_ARGS_FILE="$1" \
  PATH="$TMP_DIR:$PATH" \
  ANYCONNECT_PASSWORD=password \
  ANYCONNECT_SERVER=vpn.example.com \
  ANYCONNECT_USER=user \
  ANYCONNECT_CERT="${2:-}" \
  sh "$ROOT_DIR/connect.sh" >/dev/null
}

assert_no_servercert_when_cert_is_empty() {
  args_file="$TMP_DIR/args-empty"

  run_connect "$args_file" ""

  if grep -qx -- "--servercert" "$args_file"; then
    echo "Expected no --servercert argument when ANYCONNECT_CERT is empty" >&2
    exit 1
  fi
}

assert_servercert_when_cert_is_set() {
  args_file="$TMP_DIR/args-set"

  run_connect "$args_file" "abc123"

  if ! grep -qx -- "--servercert" "$args_file"; then
    echo "Expected --servercert argument when ANYCONNECT_CERT is set" >&2
    exit 1
  fi

  if ! grep -qx -- "pin-sha256:abc123" "$args_file"; then
    echo "Expected pin-sha256 value when ANYCONNECT_CERT is set" >&2
    exit 1
  fi
}

assert_no_servercert_when_cert_is_empty
assert_servercert_when_cert_is_set
