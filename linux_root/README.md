
files here are not created or symlinked with Stow. These are in the folder root e.g. `/etc/systemd/logind.conf.d/lid.conf`, that's why we just keep them here as a reference.

## etc/udev/rules.d/99-xhci-no-runtime-pm.rules

Workaround for the AMD 151f xHCI controller (`0000:67:00.0`, USB4 complex) refusing
D3hot — kernel retried suspend every ~1.2s, spamming the journal and burning CPU
wakeups/battery. Started 2026-08-22, got worse until it fired from a fresh boot.
Reported to TUXEDO support. Related symptoms: external display dead on the usual
USB-C port, Aug 25 2026 freeze (the first one with zero amdgpu errors).

Install:

```sh
sudo cp etc/udev/rules.d/99-xhci-no-runtime-pm.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger -c add /sys/bus/pci/devices/0000:67:00.0   # apply now without reboot
```

Consequence: none functionally — all USB ports work, devices still autosuspend
individually. Only the controller itself stays in D0 (tiny idle-power cost, less
than the retry loop it replaces).

### Is it fixed yet? (run after kernel/BIOS updates)

Run `xhci-check --test-fix` (in `hypr/.config/hypr/sspaeti/gpu-checks/`). It
temporarily re-enables runtime PM, watches the journal for 60s, and reports:

- errors return → still broken, workaround re-applied, keep the rule
- clean + controller reaches `suspended` → bug fixed upstream, remove the rule:

```sh
sudo rm /etc/udev/rules.d/99-xhci-no-runtime-pm.rules
sudo udevadm control --reload
echo auto | sudo tee /sys/bus/pci/devices/0000:67:00.0/power/control
```
