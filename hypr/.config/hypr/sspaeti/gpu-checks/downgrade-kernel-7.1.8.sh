#!/usr/bin/env bash
# Downgrade `linux` to 7.1.8 and pin it. linux-omarchy 7.2.5 untouched, stays default boot entry.
# Run: sudo bash ~/.config/hypr/sspaeti/gpu-checks/downgrade-kernel-7.1.8.sh
# Undo: delete IgnorePkg line, then `pacman -Syu linux linux-headers`.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
C=/var/cache/pacman/pkg

echo "== 1/2 install linux 7.1.8 + headers"
pacman -U --noconfirm "$C"/linux-7.1.8.arch1-3-x86_64.pkg.tar.zst "$C"/linux-headers-7.1.8.arch1-3-x86_64.pkg.tar.zst

echo "== 2/2 pin"
grep -qE '^\s*IgnorePkg\s*=.*\blinux\b' /etc/pacman.conf || sed -i '/^\[options\]/a IgnorePkg = linux linux-headers' /etc/pacman.conf
grep -n "IgnorePkg" /etc/pacman.conf

echo "== verify"
pacman -Q linux linux-headers linux-omarchy
grep "Kernel version" /boot/limine.conf | head -2
echo "DONE. Reboot, pick 'linux' entry in boot menu. Check: uname -r"
