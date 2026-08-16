#!/bin/bash
set -uo pipefail

# Live file/folder finder with real previews -- the replacement for the old
# `omarchy-launch-walker -m files`.
#
# QUATTRO: walker and elephant are gone from Omarchy 4. walker 2.x was only a
# frontend; elephant was the backend daemon that served every provider, so every
# `walker --dmenu` call now returns nothing.
#
# The UI here is yazi, because it brings everything the alternatives lack:
#   - real previews: images (ffmpegthumbnailer/magick), PDFs (pdftoppm), and the
#     duckdb previewer already wired up in ~/.config/yazi/yazi.toml for
#     csv/tsv/json/parquet/xlsx/db
#   - native open semantics: Enter enters a directory or opens a file with its
#     default app, `O` opens the interactive "choose an opener" menu
#   - `f` filters the result list live, with the preview following along
#
# The Omarchy shell menu can't do any of that (it substring-filters a fixed list
# and has no preview pane), and fzf previews are text-only without chafa. The
# fzf variant is kept alongside as fuzzy-file-names-fzf.sh.
#
# Priming the search without yazi prompting for it:
#   yazi's `search` actor opens an input pre-filled with opt.subject, but
#   `search_do` runs the search straight away (yazi-actor/src/mgr/search.rs).
#   SearchOpt takes the subject as its FIRST POSITIONAL argument
#   (yazi-core/src/mgr/search.rs: `subject: a.take_first()`), so
#       ya emit-to <id> search_do "<term>" --via=fd
#   searches the instance's cwd with fd and no prompt.

# Two modes:
#   (no arg)  you know roughly what it's called -- prompt for a term, then let
#             fd find every match at once
#   browse    you don't -- go straight into yazi's built-in fzf plugin for live
#             fuzzy-as-you-type, then yazi reveals whatever you pick
#
# `z` is yazi's own binding for that fzf plugin (keymap-default.toml), but it
# refuses to run inside search results -- the plugin bails on
# `cwd.spec.is_virtual`, and a finished search is a `search://` URL. So browse
# mode fires the plugin while the cwd is still the real SEARCH_ROOT.

SSP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEARCH_ROOT="$HOME"
MODE="${1:-search}"

# The fzf plugin spawns a bare `Command("fzf")` with stdin INHERIT, so fzf falls
# back to its own walker -- which crawls every dotdir (6.2M entries here and
# still counting). FZF_DEFAULT_COMMAND replaces that with fd, which does the
# same job in ~50ms and honours these excludes. Keep this list in sync with the
# EXCLUDES array in fuzzy-file-names-fzf.sh.
FD_SOURCE="fd --type f --type d --exclude node_modules --exclude .git"
FD_SOURCE+=" --exclude target --exclude __pycache__ --exclude .venv --exclude 'Trash*'"

# The plugin passes no --preview of its own, so hand fzf one through the env.
FZF_OPTS="--layout=reverse --info=inline --preview '$SSP/fuzzy-file-preview-fzf.sh {}'"
FZF_OPTS+=" --preview-window=right,55%,border-left"

if [ "$MODE" = "browse" ]; then
    ACTION=(plugin fzf)
else
    QUERY=$(omarchy-menu-input "Search files & folders") || exit 0
    [ -n "$QUERY" ] || exit 0
    ACTION=(search_do "$QUERY" --via=fd)
fi

# `ya emit-to` addresses a yazi instance by its client id, so pick one up front.
CLIENT_ID=$((RANDOM + 20000))

# yazi is wrapped in a shell so the fzf env reaches it -- uwsm-app hands the
# terminal off to systemd, which does not carry arbitrary exported vars across.
# The app-id is what looknfeel.lua floats and sizes.
setsid omarchy-launch-tui --app-id=org.omarchy.finder bash -c "
    export FZF_DEFAULT_COMMAND=$(printf '%q' "$FD_SOURCE")
    export FZF_DEFAULT_OPTS=$(printf '%q' "$FZF_OPTS")
    exec yazi --client-id $CLIENT_ID $(printf '%q' "$SEARCH_ROOT")
" >/dev/null 2>&1 &

# `ya emit-to` exits 1 with "Connection refused" until the instance is listening,
# so poll rather than guess at a fixed sleep.
for _ in $(seq 1 100); do
    if ya emit-to "$CLIENT_ID" "${ACTION[@]}" 2>/dev/null; then
        exit 0
    fi
    sleep 0.1
done

notify-send "File Search" "yazi did not come up in time"
