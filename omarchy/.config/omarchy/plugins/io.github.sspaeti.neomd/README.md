# omarchy-neomd-plugin

A calm mail widget for the [Omarchy](https://omarchy.org) bar, backed by
[neomd](https://neomd.ssp.sh) — the Neovim-flavored Markdown email client.

The design goal is the opposite of an inbox badge: the bar shows a **static
mail icon that never changes** — no unread counter, no color flip, nothing
that builds up while you work. Mail only exists when you click (or hit the
hotkey). Data is polled in the background so the panel opens instantly, but
whatever arrives, the pill stays silent.

## What you get

- **HEY-style tabs** — Inbox / ToScreen / Feed / PaperTrail, switched like
  pages with `H`/`L`, `1`–`4`, or a click. Unread counts appear on the tabs
  *inside* the panel only.
- **In-panel reader** — `l`/`Enter` (or a click) opens the selected mail's
  markdown body right in the popup for a quick glance; `j`/`k` scroll,
  `h`/`Esc` go back. **Strictly read-only**: bodies are fetched with
  BODY.PEEK, so nothing is ever marked read, moved, or classified from here —
  no state, no inconsistencies with the TUI.
- **Jump to the real client** — `o` or right-click the bar pill runs your
  jump script (tmux session with neomd by default).
- **Vim keys** — `j`/`k` move, `l`/`h` open/back, `H`/`L` tabs, `r`/`R`
  refresh, `Esc` close.

## Requirements

- `neomd` with the `list` and `read` subcommands (2026-08-25 or newer) on
  `PATH` (`~/.local/bin` is added automatically)
- `jq`

## Install

```sh
omarchy plugin add https://github.com/sspaeti/omarchy-neomd-plugin.git --enable
omarchy bar move io.github.sspaeti.neomd --section right
```

## Hotkey

IPC: `omarchy-shell shell toggle io.github.sspaeti.neomd` — bind it in
Hyprland, e.g.
`o.bind("SUPER + CTRL + ALT + M", "neomd Mail panel", "omarchy-shell shell toggle io.github.sspaeti.neomd")`.

## Settings

Configure on the widget entry in `~/.config/omarchy/shell.json`. Settings are
**inline keys next to `id`** (every key except `id` is a setting — there is no
nested `"settings"` object):

```json
{
  "id": "io.github.sspaeti.neomd",
  "icon": "󰇰",
  "folders": ["Inbox", "ToScreen", "Feed", "PaperTrail"],
  "defaultTab": "Inbox",
  "limit": 25,
  "refreshMinutes": 5,
  "jumpCommand": "~/.config/hypr/sspaeti/jump-to-email-tmux.sh"
}
```

- `icon` — bar glyph; try `󰇰`, `󰇮`, `󰛮`, or `` (markdown, for the
  markdown-first mail vibe)
- `folders` — which neomd folders become tabs (any of Inbox, ToScreen, Feed,
  PaperTrail, ScreenedOut, Archive, Waiting, Someday, Scheduled, Sent, Drafts)
- `defaultTab` — tab shown when the panel opens
- `refreshMinutes` — background poll cadence (the disk cache means an open
  is always instant)
- `jumpCommand` — what `o` / right-click runs to open the full client

## Mouse

| Action | Where | Effect |
|---|---|---|
| Left click | pill | toggle panel |
| Right click | pill | run `jumpCommand` (open neomd) |
| Middle click | pill | force refresh |
| Click | row | read the mail in the panel |
| Click | link in body | open in browser |

## How it works

`fetch.sh` wraps two headless, read-only neomd subcommands: `neomd list`
(header dump of the configured folders as one JSON object, polled in the
background and cached under `~/.local/state/omarchy/neomd/`) and
`neomd read` (one message body, fetched with BODY.PEEK and cached per
message — bodies never change). All IMAP config and credentials stay inside
neomd; nothing passes through this plugin, and nothing here can mutate your
mailbox.
