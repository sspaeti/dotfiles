# Windows VM (omarchy-windows-vm)

## Where everything lives (Omarchy 4.5)

| What | Path | Notes |
|---|---|---|
| Live compose (active) | `/var/lib/omarchy/windows/docker-compose.yml` | root:docker 0640, read with `sudo cat`. Installed from the template below via `apply-compose.sh` |
| My source of truth | `~/.config/windows/docker-compose.template.yml` | This folder, in dotfiles (`windows-vm/.config/windows/`) |
| VM disk (Windows install) | `~/.windows` (`data.img`, ~23G) | Bind-mounted by omarchy to `/var/lib/omarchy/windows/mounts/users/1000/storage` → `/storage` in the container |
| Shared folder | `~/Windows` | Bind-mounted to `/var/lib/omarchy/windows/mounts/users/1000/shared` → `/shared` |
| Sync folders | `~/Simon/Sync/{1 Areas,2 Project,3 Resources}` | → `/data/...` in the container (my extra volumes) |
| RDP login | `~/.config/windows/credentials` | `USERNAME=sspaeti`, git-ignored |
| Launcher script | `/usr/bin/omarchy-windows-vm` | Part of the `omarchy` package |
| Web console | http://127.0.0.1:8006 | Works without RDP or guest network |

The live compose can't be a symlink into dotfiles: omarchy only accepts a
root-owned file under `/var/lib` (it guards against swapping the compose to get
root). That's why the template plus `apply-compose.sh` exist.

Check the container with `sudo docker ps` (my user is not in the `docker` group,
so every VM action goes through a polkit prompt).

### No password prompt for start/stop

`polkit/49-omarchy-windows-vm.rules` lets `pkexec omarchy-windows-vm __priv
up|up_wait|down|status` run without a prompt (my user, local active session only).
`write_compose` and `remove` still prompt. Install once:

```sh
sudo install -m 0644 -o root -g root ~/.config/windows/polkit/49-omarchy-windows-vm.rules /etc/polkit-1/rules.d/
```

### Networking speed

The template adds `/dev/vhost-net` (not in omarchy's generated compose), so the
NAT tap NIC runs through kernel vhost instead of QEMU userspace. If the VM is
slow, check which network mode it's using:
`sudo docker logs omarchy-windows 2>&1 | grep -iE 'falling back|passt|slirp|user-mode'`.
Any hit there means NAT failed and it fell back to user-mode networking (slow).

Root cause found 2026-11-23: the container uses `iptables-legacy`, but the host
(nftables) doesn't load `ip_tables`/`iptable_nat` by default, so NAT setup fails
with "can't initialize iptables table `nat'". Fix, persistent across reboots:

```sh
printf 'ip_tables\niptable_nat\n' | sudo tee /etc/modules-load.d/omarchy-windows-vm.conf
sudo modprobe -a ip_tables iptable_nat
```

After a kernel update, re-check if the warning comes back (modules must exist
for the running kernel: `modinfo -n iptable_nat`).

Removed 2026-11-23: `docker-compose-omarchy.yml` and `docker-compose-sspaeti.yml`
(pre-Sep-2026 layout). `~/Documents/VMs/windows` is an old, unused VM disk from
Aug 2025 (user `docker`).

Omarchy generates the live compose as root at `/var/lib/omarchy/windows/docker-compose.yml`
(0640 root:docker, so only visible via sudo). On upgrade it migrated my old
`~/.config/windows/docker-compose.yml` there and deleted it, keeping only
RAM/CPU/disk/user/password. 

## Why this setup? Just for keeping my extra volumnes
Extra volumes are dropped, hence this setup.

## Files

- `docker-compose.template.yml` – my source of truth (Sync volumes, TZ). Different
  filename on purpose: the legacy name gets migrated and deleted again.
- `apply-compose.sh` – renders the password from `credentials` and installs the
  template as the live compose. `--diff` only shows what would change.
- `credentials`, `krb5.conf` – written by omarchy. `credentials` is git-ignored.

## Keep omarchy and my setup in sync

After every omarchy upgrade:

```sh
~/.config/windows/apply-compose.sh --diff
```

- No diff, or only my volumes on the `+` side: nothing to do.
- Upstream lines on the `-` side (new env var, port, argument): port them into
  `docker-compose.template.yml` first, then apply.
- Volumes missing on the `-` side: omarchy regenerated the file
  (`omarchy-windows-vm install` or a migration), just apply.

```sh
~/.config/windows/apply-compose.sh
omarchy-windows-vm stop && omarchy-windows-vm launch
```

Never change the `/storage` and `/shared` lines. omarchy verifies them against
its root-owned bind anchors and refuses to start otherwise.
