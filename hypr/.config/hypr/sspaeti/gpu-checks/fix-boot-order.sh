#!/usr/bin/env bash
# Make the stock arch `linux` kernel the default limine entry (before linux-omarchy).
# Run: sudo bash ~/.config/hypr/sspaeti/gpu-checks/fix-boot-order.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
F=/etc/default/limine
cp "$F" "$F.bak.$(date +%s)"
LINE='BOOT_ORDER="linux, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"'
python3 - "$F" "$LINE" <<'PY'
import sys,re
f,line=sys.argv[1],sys.argv[2]
s=open(f).read()
s,n=re.subn(r'^BOOT_ORDER=.*$', line, s, flags=re.M)
assert n==1, f"expected 1 BOOT_ORDER line, found {n}"
open(f,'w').write(s)
PY
echo "== $F"; grep -n '^BOOT_ORDER=' "$F"
echo "== limine-update"; limine-update
echo "== result"; grep -n 'default_entry' /boot/limine.conf; grep -A2 '^  //linux' /boot/limine.conf | grep -E '//linux|Kernel version'
