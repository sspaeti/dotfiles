# Windows VM (omarchy-windows-vm)

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
