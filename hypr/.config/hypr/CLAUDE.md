# Agent Notes — Omarchy Code Duplication Registry

This config forks/wraps Omarchy code in several places. Omarchy updates change the
upstream copies (`/usr/share/omarchy/`), but our copies stay frozen. **Whenever you
work in this repo — and especially after any `omarchy update` — check the
duplications below for upstream drift and re-apply our intentional deltas onto the
new upstream code.**

Rules:

- Never edit `/usr/share/omarchy/` — re-sync means: copy new upstream, re-apply our delta.
- When you create a NEW wrapper, intercept, or plugin clone of Omarchy code, **add it to this registry**.
- A drift check that finds changes: show the user the upstream diff before re-syncing.

## 1. Forked scripts (high drift risk — full copies of Omarchy logic)

These duplicate upstream logic, so upstream fixes do NOT reach us automatically.

| Local (in `sspaeti/`) | Upstream | Intentional delta |
|---|---|---|
| `omarchy-system-lock-wrapper.sh` | `$(which omarchy-system-lock)` | Skips `1password --lock` (no fingerprint reader; master password every unlock unacceptable). Header documents the diff command. |
| `omarchy-system-menu` | System section of `$(which omarchy-menu)` | tmux-aware shutdown/restart handling. |
| `omarchy-system-menu-intercept` | System handling of `$(which omarchy-menu)` (uses `omarchy-state` like upstream) | Intercepts to add tmux-aware shutdown/restart. |
| `omarchy-menu` | Dispatcher over `$(which omarchy-menu)` | Routes "system" to our `omarchy-system-menu`, passes everything else through. |

Check: `diff <(cat "$(which <upstream>)") ~/.config/hypr/sspaeti/<local>` — anything beyond the documented delta = upstream drift.

## 2. Cloned shell plugins (high drift risk — frozen forks)

Live in `~/.config/omarchy/plugins/` (the **omarchy** stow package of this dotfiles
repo, not hypr). Created with `omarchy plugin clone`; the stock plugin is disabled in
`shell.json` (`disabledPlugins`), so upstream plugin fixes do NOT load anymore.

| Clone | Upstream source | Intentional delta |
|---|---|---|
| `sspaeti.idle` | `/usr/share/omarchy/shell/plugins/services/idle/` | `Service.qml` lockSystem() runs `~/.config/hypr/sspaeti/omarchy-system-lock-wrapper.sh` instead of `omarchy-system-lock` (skip 1Password lock on idle lock). |
| `sspaeti.clipboard` | `/usr/share/omarchy/shell/plugins/clipboard/` | Deployed from fork repo `~/git/omarchy/omarchy-clipboard-plugin` (`make deploy`) — OCR + copy-only workflow. **Do not edit in place; edit the repo and redeploy.** |
| `sspaeti.emojis` | `/usr/share/omarchy/shell/plugins/emojis/` | Copy-only: `wl-copy`, no `wtype` auto-paste. Custom `emojis.json`. |
| `sspaeti.clock` | `/usr/share/omarchy/shell/plugins/panels/clock/` | Custom `BarWidget.qml` (clock format). |
| `sspaeti.weather` | `/usr/share/omarchy/shell/plugins/panels/weather/` | Custom `BarWidget.qml`. |
| `sspaeti.workspaces` | `/usr/share/omarchy/shell/plugins/bar/widgets/Workspaces.qml` | Custom `Workspaces.qml` rendering. |

Check (per plugin): `diff -ru --exclude=manifest.json <upstream-dir> ~/.config/omarchy/plugins/<clone>/`
(`manifest.json` always differs: id/clonedFrom rewrite. For `sspaeti.workspaces`, diff `Workspaces.qml` against the single upstream file.)

After editing a clone: hot-reloads on save; if not, `omarchy restart shell`.

## 3. Thin wrappers (low drift risk — call the stock command, add pre/post steps)

Break only if the upstream CLI, flags, or paths change. Sanity-check after updates;
no line-by-line diff needed.

- `sspaeti/omarchy-capture-screenshot-wrapper.sh` → calls `omarchy-capture-screenshot`, then opens annotation editor
- `sspaeti/omarchy-capture-screenrecording-kdenlive` → wraps `omarchy-capture-screenrecording` for Kdenlive-friendly output
- `sspaeti/omarchy-menu-wrapper` → calls `omarchy-menu`, restores personal background after theme switch
- `sspaeti/omarchy-update-sspaeti` → wraps `omarchy-update` with `mise deactivate`/`activate`
- `sspaeti/omasnap-capture.sh` → wraps `omasnap` (external fork, see below), sets monthly Printscreen save dir

## 4. External fork repos (separate git repos, own upstream tracking)

- `~/git/omarchy/omarchy-clipboard-plugin` — fork of the Omarchy clipboard plugin; deploys to `sspaeti.clipboard` via `make deploy`
- `~/git/omarchy/omasnap` — omasnap fork (branches: `feat`=PR work, `local`/`personal`=installed version)

Sync these with `git fetch upstream` + rebase in their own repos, not here.

## Drift-check procedure (occasional / after `omarchy update`)

1. Run the diff commands from sections 1 and 2.
2. Expected: only the intentional deltas listed above. Anything else = upstream changed.
3. On drift: show the user what upstream changed, then re-apply our delta onto the new upstream copy (don't keep the stale base).
4. Section 3 wrappers: verify the wrapped commands still exist and flags still work.
