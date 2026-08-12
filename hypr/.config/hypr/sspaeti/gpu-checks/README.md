# gpu-checks

Tooling for a recurring AMD GPU crash on this laptop. Started Nov 2025, still open as of Aug 2026.

Full crash-by-crash history lives in `~/.local/share/omarchy/troubleshoot.md`. This file covers
what the scripts do, why they were written the way they were, and what to change when the
situation moves.

## The problem

| | |
|---|---|
| GPU | AMD Radeon 890M (integrated), `gfx1150` / RDNA 3.5, PCI `0000:65:00.0` |
| Failing block | MES — Micro Engine Scheduler (`mes_v11_0_0`) |
| Symptom | display + input freeze for seconds, then Hyprland dies, sometimes full lockup |

The failure is always the same shape. From the Aug 12 2026 crash:

```
ring gfx_0.0.0 timeout, signaled seq=88962, emitted seq=88964
 Process vesktop pid 38100 thread vesktop:cs0 pid 38130
Starting gfx_0.0.0 ring reset
MES failed to respond to msg=RESET
reset via MES failed and try pipe reset -110
The CPFW hasn't support pipe reset yet.
Ring gfx_0.0.0 reset failed
MES failed to respond to msg=REMOVE_QUEUE
[drm] device wedged
```

Hyprland then aborts in `CHyprOpenGLImpl::begin()` — its EGL context died with the GPU and it
cannot rebuild one. That abort is a consequence, never the cause.

**Trigger is a Chromium-family app wherever the log names a process**: Brave is explicitly
identified in 6 of the 9 entries in `troubleshoot.md`, vesktop (Discord) in the Aug 12 crash. Of
the rest, Jan 21 was a degraded GPU after a failed hibernate resume, Jan 22 was a VPE warning
rather than a crash, and Mar 20 has no triggering process recorded.

The failing messages are `RESET` and `REMOVE_QUEUE` — GPU *queue lifecycle*, not sustained load.
That is why `gpu-stress` churns short-lived contexts instead of running one long render.

## Two things that look like other bugs but aren't

**Hyprland "loses your config" after a crash.** It does not. Since Hyprland 0.56, `start-hyprland`
restarts the compositor with `--safe-mode` after an unclean exit. Safe mode reads
`$instancePath/recoverycfg.lua` — a per-instance path under `/run/user/1000/hypr/<sig>/` that does
not exist, so Hyprland autogenerates a blank config. You get a bare desktop. Source:
`src/config/supplementary/jeremy/Jeremy.cpp`, `getMainConfigPath()`. Your files in
`~/.config/hypr/` are untouched. Log tell:

```
[cfg] Config is either explicit or special.
[cfg] Config is lua, loading lua mgr
WARN: No config file found; attempting to generate.
```

versus a healthy start:

```
[cfg] Regular config at /home/sspaeti/.config/hypr/hyprland.conf
```

Log out and back in to leave safe mode.

**Suspend/hibernate is no longer the cause.** It was, in Jan 2026 — a failed hibernate resume left
the GPU degraded and it died ~1h later. Fixed by adding `resume=` / `resume_offset=` to the kernel
cmdline. Crashes since then have happened on boots with no suspend at all.

## Kernel cmdline

Set in `/etc/default/limine`, applied via `sudo limine-mkinitcpio`:

```
resume=/dev/mapper/root resume_offset=128838606
amdgpu.gpu_recovery=1 amdgpu.noretry=0
amdgpu.ip_block_mask=0xfffff7ff   # disables VPE, works around a 6.18 suspend bug
amdgpu.cwsr_enable=0              # MES workaround; helped for a while, no longer sufficient
```

Verify with `cat /proc/cmdline`. None of these prevent the current failure — they are kept because
each fixed a real, separate problem along the way.

## Scripts

| Script | When it runs | What it does |
|---|---|---|
| `gpu-health-check` | manual (`gpu-check`) | scans the current boot's kernel log for amdgpu failures. Exit 0 = clean |
| `gpu-session-check` | login, via `autostart.conf` | sleeps 20s, then runs the health check and the stack check. Notifies only on a problem |
| `gpu-stack-changed` | manual / from session check | compares the installed GPU package set against the last acked one |
| `gpu-stress` | manual, after an update | churns concurrent short-lived `vkcube` contexts, diffs the kernel log |
| `kernel-rollback` | manual, when a kernel goes bad | downgrades `linux` + `linux-headers` from pacman cache, rebuilds the UKI |

Aliases are in `zsh/.dotfiles/zsh/aliases.shrc`.

### Normal cycle after a system update

```sh
gpu-stress 180          # provoke it now, while you're watching. CAN hang the session
gpu-stack-changed --ack # if it survived, record this package set as proven
```

From then on, any `-Syu` touching `linux`, `mesa`, `vulkan-radeon`, `linux-firmware-amdgpu` or
`hyprland` produces a login notification saying the stack is unproven.

### When a kernel turns out to be bad

```sh
kernel-rollback --list          # what's in the pacman cache
kernel-rollback --pin           # revert to the known-good version, rebuild UKI, pin it
# reboot
gpu-check
```

## Honest limits

A pre-flight test cannot predict an MES hang. Measured against the recorded crash history:

| Event | Detectable at boot? |
|---|---|
| Jan 21 / Jan 22 2026 | **yes** — `IB test failed (-110)`, `VPE queue reset failed` at init, crash ~1h later |
| Nov 10, Dec 4, Feb 9, Feb 15, Mar 17, Mar 20, Apr 8, Aug 12 | no — clean GPU init, died later under real load |

Two of ten recorded events were visible before the fact. So `gpu-health-check` catches one failure
mode out of two, and `gpu-stress` is a weak proxy for
Chromium's actual GPU behaviour. A `gpu-stress` pass means "no obvious regression", nothing
stronger. Treat a **fail** as conclusive and a **pass** as weak evidence.

A live journal watcher was considered and deliberately not built — the warning window is
inconsistent (6 minutes before the fatal crash on Feb 15, 5 seconds on Aug 12) and a permanently
running follower was not wanted.

## Maintenance

Things that will need editing, and the signal that it's time:

- **`DEFAULT_TARGET` in `kernel-rollback`** — currently `7.0.10.arch1-1`, the last version with
  zero MES failures across three weeks of uptime (boots -9..-2, Jul 22 – Aug 12 2026). Bump it once
  a newer kernel has survived a comparable stretch.
- **Log patterns** — `gpu-health-check` and `gpu-stress` grep literal amdgpu strings. These change
  between kernel versions. After a major kernel bump, re-verify both directions against a known
  crash boot:
  ```sh
  journalctl -b <clean-boot> -k | grep -cE "<pattern>"   # want 0
  journalctl -b <crash-boot> -k | grep -cE "<pattern>"   # want >0
  ```
  This matters. The original `gpu-health-check` grepped bare `MES`, which also matched two benign
  init lines (`MES: vmid_mask_mmhub ...`, `MES: gfx_hqd_mask ...`) present on *every* boot — so it
  warned "crash imminent, reboot NOW" 100% of the time and was trained-out noise. Fixed Aug 2026.
- **`PKGS` in `gpu-stack-changed`** — add anything new that sits between the app and the GPU.
- **Hyprland safe-mode path** — `recoverycfg.lua` and the `[cfg]` log strings are 0.56 internals
  and may move. Recheck `getMainConfigPath()` in the Hyprland source after a major bump.

## Known unrelated breakage

`linux-headers` can drift from `linux` if you downgrade by hand with `pacman -U linux` alone —
always do both, which is what `kernel-rollback` is for.

DKMS is separately broken: `tuxedo-drivers` and `tuxedo-yt6801-dkms-git` are built only for
`6.18.13-arch1-1` and report "Built modules are missing in the kernel modules folder". They are
inert on current kernels. `kernel-rollback` reports this and prints the `dkms autoinstall -k`
command but will not run it for you.

## Upstream

- [amd-gfx: MES hang on gfx1150 / Strix](https://lists.freedesktop.org/archives/amd-gfx/2025-December/136016.html)
- [ROCm #5724 — MES firmware 0x83 GPU hang](https://github.com/ROCm/ROCm/issues/5724)
- [Framework: critical amdgpu bugs in 6.18.x / 6.19.x](https://community.frame.work/t/attn-critical-bugs-in-amdgpu-driver-included-with-kernel-6-18-x-6-19-x/79221)
- [omarchy #4259 — hibernate crash, includes my fix](https://github.com/basecamp/omarchy/issues/4259#issuecomment-4010179550)
