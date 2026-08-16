#!/bin/bash
set -uo pipefail

# Live fuzzy file/folder finder with preview -- the replacement for the old
# `omarchy-launch-walker -m files`.
#
# QUATTRO: walker and elephant are gone from Omarchy 4. walker 2.x was only a
# frontend; elephant was the backend daemon that served every provider (dmenu
# included), so every `walker --dmenu` call now returns nothing.
#
# The Omarchy shell menu (omarchy-menu-select) is the stock dmenu replacement,
# but it filters a FIXED list by substring (Menu.qml rebuildDmenuDisplay uses
# indexOf) and has no preview pane. Since we want fuzzy-as-you-type over the
# whole home *and* a preview, this runs fzf in a terminal instead.
#
# `fd` walks the home in ~50ms for ~65k entries, so there is no index to keep
# warm and results are never stale.
#
# Launched via:
#   omarchy-launch-tui --app-id=org.omarchy.finder .../fuzzy-file-names.sh
# The app-id is what looknfeel.lua floats and sizes.

SSP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Roots to search. Narrow this if the whole home ever gets too noisy.
SEARCH_ROOTS=("$HOME")

# Hidden files stay out (elephant's files provider defaulted the same way) --
# that also drops ~/.config, ~/.local and the Filen trash dirs from the results.
EXCLUDES=(
    --exclude node_modules
    --exclude .git
    --exclude target
    --exclude __pycache__
    --exclude .venv
    --exclude 'Trash*'
)

OUT=$(
    fd --type f --type d "${EXCLUDES[@]}" . "${SEARCH_ROOTS[@]}" 2>/dev/null |
        fzf --prompt='  ' \
            --info=inline \
            --border=rounded \
            --height=100% \
            --layout=reverse \
            --preview="$SSP/fuzzy-file-preview.sh {}" \
            --preview-window='right,55%,border-left,~0' \
            --bind='ctrl-/:toggle-preview' \
            --bind='ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
            --header=$'enter open · ctrl-e editor · ctrl-o files · ctrl-t yazi · ctrl-y copy path' \
            --expect=ctrl-e,ctrl-o,ctrl-t,ctrl-y
)

# --expect prints the pressed key on line 1 (empty for plain Enter) and the
# selection on line 2. An empty selection means Escape.
KEY=$(printf '%s' "$OUT" | sed -n 1p)
SELECTED=$(printf '%s' "$OUT" | sed -n 2p)
[ -n "$SELECTED" ] || exit 0
[ -e "$SELECTED" ] || exit 0

if [ -d "$SELECTED" ]; then
    DIR_PATH="$SELECTED"
else
    DIR_PATH=$(dirname "$SELECTED")
fi

# GUI apps must outlive this terminal, hence setsid + uwsm-app.
launch() { setsid uwsm-app -- "$@" >/dev/null 2>&1 & }

case "$KEY" in
ctrl-y)
    printf '%s\n' "$SELECTED" | wl-copy
    notify-send "Path Copied" "$SELECTED"
    ;;
ctrl-o)
    launch nautilus "$DIR_PATH"
    ;;
ctrl-t)
    setsid omarchy-launch-tui --app-id=org.omarchy.yazi yazi "$DIR_PATH" >/dev/null 2>&1 &
    ;;
ctrl-e)
    setsid omarchy-launch-tui --app-id=org.omarchy.nvim nvim "$SELECTED" >/dev/null 2>&1 &
    ;;
*)
    # Plain Enter: a directory opens in Files, a file opens in its default app.
    if [ -d "$SELECTED" ]; then
        launch nautilus "$SELECTED"
    else
        launch xdg-open "$SELECTED"
    fi
    ;;
esac
