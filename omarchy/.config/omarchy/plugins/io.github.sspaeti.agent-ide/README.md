# Agent-IDE status (Omarchy bar plugin)

One coloured dot on the Omarchy bar that answers "does any of my AI coding agents need me?". It never pops up
and never takes focus. It reads what [Agent-IDE.nvim](../../README.md) publishes plus the Claude sessions that
run outside Neovim (tmux panes), and shows the most urgent state of all of them.

| Level | Colour | Meaning | Next to the dot | Theme key (`colors.toml`) | Fallback |
|---|---|---|---|---|---|
| 1 | green | all good, nothing running | nothing | `green` | `#9ece6a` |
| 2 | yellow | all good, some agents are running | nothing (count is in the tooltip) | `yellow` | `#e0af68` |
| 3 | orange | an agent finished or failed, its result waits for you | review count | `orange` | `#ff9e64` |
| 4 | violet | an agent needs input (permission ask, prompt) | waiting count | `magenta` (or `violet`) | `#a277ff` |

Level 4 wins over 3, 3 over 2, 2 over 1. Hover for the summary ("1 waiting for input · 2 to review · 3 running").

## Panel

Left click opens it. Rows are sorted by urgency (waiting with the tool name as reason, then review, then
running), then by project, and grouped by source: one block per Neovim (labelled `Neovim · <project>`, `Neovim · <a>, <b>` or `Neovim · <n> projects`), then `tmux / other`.
Each row shows project, session title and state. `j`/`k` move, `Enter` or a click focuses the tmux pane of that
session (same steps as the Neovim plugin: `ps -o tty=`, `tmux list-panes -a`, `tmux switch-client`), `r`
refreshes, `Esc` closes. Jumping only changes tmux's selection (window, pane, client); it does not raise or focus the terminal window in Hyprland. Middle click on the dot refreshes. The panel shows at most 20 rows.

## Install

```sh
ln -s "$PWD/omarchy/io.github.sspaeti.agent-ide" ~/.config/omarchy/plugins/io.github.sspaeti.agent-ide
```

(run from the repository root; a copy works too, but then updates need copying again). Omarchy hot-reloads plugin
code on save. Then put the widget on the bar (Omarchy bar settings, category "AI") or run
`omarchy plugin enable io.github.sspaeti.agent-ide --section right`. If it does not show up: `omarchy-shell shell rescanPlugins`.

## How it gets its data

- `collect.sh`, every 2 s: reads `$XDG_RUNTIME_DIR/agent-ide/status-<pid>.json` (one file per Neovim, written
  by `lua/agent-ide/status.lua`). A file counts only if its pid is alive and, while its level is above 1, its
  `updated` is at most 90 s old (Neovim rewrites it every 30 s while something is going on). Half-written or
  malformed files are skipped.
- `outside.sh`, every 10 s: `claude agents --json` (4 s timeout). Sessions with the same id as one in a status
  file are counted once. If the call fails the last answer is kept for three polls, then this source is empty.
- `Model.js` combines both (pure JavaScript, tested with `make test-omarchy`). The counts are derived from the
  de-duplicated session rows, not from the counters in the status files, because those counters already include
  sessions a Neovim does not own and would count a tmux session once per Neovim.
- Theme colours come from `~/.local/state/omarchy/current/theme/colors.toml`, re-read every 30 s.

Both commands run asynchronously and never overlap themselves, so the bar cannot block. The plugin only reads;
it never starts, stops or signals a Claude session. Nothing is written to disk.

## Tests

```sh
make test-omarchy      # node --test, no dependencies
```

`qmllint` on this machine is the old syntax-only checker: it cannot resolve the `qs.*` modules, and it rejects
the `function open(): void` annotations that Omarchy's own panels use as well. `Panel.qml` passes it; `BarWidget.qml`
passes once those annotations are ignored. The QML is otherwise unverified until loaded by the shell.

## Troubleshooting

- **Brief green dot after suspend/resume**: the status files look stale (older than 90 s) until each Neovim writes its next heartbeat, up to 30 s later, so the dot can be green for a moment although agents are working.
- **Green dot, nothing else**: no status files, or Neovim is not running the plugin. Check
  `ls $XDG_RUNTIME_DIR/agent-ide/` and that `require('agent-ide.status').setup()` ran. An empty or missing directory is
  "all good" on purpose.
- **Dot stays green while a Neovim agent works**: the file is older than 90 s (Neovim hung) or its pid is not
  alive (check with `bash collect.sh`: the second column is `1` for alive).
- **tmux sessions are not counted**: `claude` is not on the PATH of the shell. `bash outside.sh` should print a JSON
  array; `outside.sh` adds `~/.local/bin` to the PATH. Without `claude` that source is simply empty.
- **Clicking a row does nothing**: the session is not on a tmux pane (for example it is a Neovim chat
  session without a terminal), or tmux is not running. `bash jump.sh <pid>` exits 1 when no pane matches.
- **Wrong colours**: the theme has no such keys; the fallbacks are used.
- Debug: `AGENT_IDE_STATUS_DIR=/some/dir bash collect.sh` reads another directory.
