#!/bin/bash
# Add amdgpu.dcdebugmask=0x400 (disable Panel Replay) to the kernel cmdline. No package changes.
# Run as: sudo bash ~/.config/hypr/sspaeti/gpu-checks/disable-panel-replay.sh
set -euo pipefail
F=/etc/default/limine
cp "$F" "$F.bak-$(date +%F)"
if grep -q 'dcdebugmask' "$F"; then echo "already set"; else
  sed -i '0,/^KERNEL_CMDLINE\[default\]+="\(.*\)"$/s//KERNEL_CMDLINE[default]+="\1 amdgpu.dcdebugmask=0x400"/' "$F"
fi
grep -n 'dcdebugmask' "$F" || { echo "ERROR: not added"; exit 1; }
limine-update
grep -c 'dcdebugmask=0x400' /boot/limine.conf
echo "DONE. Reboot, then: grep -o 'dcdebugmask=[^ ]*' /proc/cmdline ; SUPER+ALT+7 for Dell."
echo "Undo: restore $F.bak-* and run limine-update."
