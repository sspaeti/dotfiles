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
#
# The term prompt with search history:
#   The stock `omarchy-menu-input` popup cannot be pre-filled and has no key
#   handling for history -- Menu.qml's openDmenu() resets filterText to "" and
#   the payload has no initial-text field. Adding that would mean cloning the
#   whole omarchy.menu plugin (frozen fork of every Omarchy menu), so the prompt
#   runs as fzf INSIDE the finder terminal instead, before yazi takes over:
#     Up/Down  walk the previous searches (newest first), copying each into the
#              query line like a shell history (Up = last search)
#     Enter    search for whatever is on the query line (history pick or typed)
#     Ctrl+Z   skip the term and drop into browse mode (yazi fzf plugin)
#     Esc      cancel, closes the window
#   fzf runs with --disabled so typing never filters the history away; the
#   blank first row is the "nothing recalled yet" position, like an empty
#   readline before the first Up.
#   History: $XDG_STATE_HOME/fuzzy-file-names/history, newest last, deduped,
#   capped at HISTORY_MAX entries.
#
# Invocation layout:
#   fuzzy-file-names.sh [search|browse]   from the keybinding: opens the floating
#                                         terminal and re-runs itself inside with
#   fuzzy-file-names.sh --inner <mode>    prompt -> history -> ya emit-to -> yazi

SSP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEARCH_ROOT="$HOME"
HISTORY_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/fuzzy-file-names/history"
HISTORY_MAX=50

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

BROWSE_SENTINEL=$'\x1fbrowse'

prompt_for_term() {
    # Prints the chosen term, or BROWSE_SENTINEL on Ctrl+Z. Exit 1 on cancel.
    local history=""
    [ -s "$HISTORY_FILE" ] && history=$(tac "$HISTORY_FILE")
    # A blank leading row, then newest-first history. Default (bottom-up) layout:
    # the list sits above the prompt, so Up walks away from it into the past.
    { echo; [ -z "$history" ] || printf '%s\n' "$history"; } |
        FZF_DEFAULT_OPTS= fzf --disabled --no-info --no-sort \
            --prompt 'Search files & folders > ' \
            --header 'Up/Down: previous searches   Enter: search   Ctrl+Z: fuzzy browse   Esc: cancel' \
            --bind 'up:up+replace-query,down:down+replace-query' \
            --bind 'enter:print-query' \
            --bind "ctrl-z:become(printf '\\x1fbrowse\\n')"
}

remember_term() {
    local term="$1" tmp
    mkdir -p "$(dirname "$HISTORY_FILE")"
    tmp=$(mktemp) || return
    { [ -f "$HISTORY_FILE" ] && grep -Fxv -- "$term" "$HISTORY_FILE"; printf '%s\n' "$term"; } |
        tail -n "$HISTORY_MAX" > "$tmp" && mv "$tmp" "$HISTORY_FILE"
}

inner() {
    local mode="$1" action query
    if [ "$mode" = "browse" ]; then
        action=(plugin fzf)
    else
        query=$(prompt_for_term) || exit 0
        if [ "$query" = "$BROWSE_SENTINEL" ]; then
            action=(plugin fzf)
        else
            query="${query#"${query%%[![:space:]]*}"}"   # trim leading
            query="${query%"${query##*[![:space:]]}"}"   # trim trailing
            [ -n "$query" ] || exit 0
            remember_term "$query"
            action=(search_do "$query" --via=fd)
        fi
    fi

    # `ya emit-to` addresses a yazi instance by its client id, so pick one up
    # front. It exits 1 with "Connection refused" until the instance is
    # listening, so poll in the background while yazi comes up in this terminal.
    local client_id=$((RANDOM + 20000))
    (
        for _ in $(seq 1 100); do
            ya emit-to "$client_id" "${action[@]}" 2>/dev/null && exit 0
            sleep 0.1
        done
        notify-send "File Search" "yazi did not come up in time"
    ) >/dev/null 2>&1 &

    export FZF_DEFAULT_COMMAND="$FD_SOURCE"
    export FZF_DEFAULT_OPTS="$FZF_OPTS"
    exec yazi --client-id "$client_id" "$SEARCH_ROOT"
}

if [ "${1:-}" = "--inner" ]; then
    inner "${2:-search}"
fi

MODE="${1:-search}"

# The app-id is what looknfeel.lua floats and sizes. The script re-enters itself
# inside the terminal (--inner), so exported env reaches yazi -- uwsm-app hands
# the terminal off to systemd, which does not carry arbitrary vars across.
exec setsid omarchy-launch-tui --app-id=org.omarchy.finder "$SSP/fuzzy-file-names.sh" --inner "$MODE" >/dev/null 2>&1
