#!/usr/bin/env bash
# Render docker-compose.template.yml with the password from ~/.config/windows/credentials
# and install it as the root-owned live compose omarchy-windows-vm uses.
# Usage: ./apply-compose.sh [--diff]   (--diff only shows what would change)
set -euo pipefail

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TEMPLATE="$DIR/docker-compose.template.yml"
CREDENTIALS="$HOME/.config/windows/credentials"
LIVE=/var/lib/omarchy/windows/docker-compose.yml

[[ -f $CREDENTIALS ]] || { echo "missing $CREDENTIALS" >&2; exit 1; }
password=$(sed -n 's/^PASSWORD=//p' "$CREDENTIALS" | head -n1)
[[ -n $password ]] || { echo "no PASSWORD in $CREDENTIALS" >&2; exit 1; }

# Same escaping omarchy-windows-vm applies: YAML double-quoted scalar first
# (\ and "), then docker compose interpolation ($ -> $$).
esc=${password//\\/\\\\}
esc=${esc//\"/\\\"}
esc=${esc//\$/\$\$}

rendered=$(mktemp)
trap 'rm -f "$rendered"' EXIT
awk -v pw="$esc" '{ gsub(/__PASSWORD__/, pw); print }' "$TEMPLATE" >"$rendered"

if [[ ${1:-} == --diff ]]; then
  sudo diff -u "$LIVE" "$rendered" && echo "live compose already matches template"
  exit 0
fi

sudo install -o root -g docker -m 0640 "$rendered" "$LIVE"
echo "installed $LIVE"
echo "restart the VM to pick it up: omarchy-windows-vm stop && omarchy-windows-vm launch"
