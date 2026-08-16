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

SEARCH_ROOT="$HOME"

QUERY=$(omarchy-menu-input "Search files & folders") || exit 0
[ -n "$QUERY" ] || exit 0

# `ya emit-to` addresses a yazi instance by its client id, so pick one up front.
CLIENT_ID=$((RANDOM + 20000))

# The app-id is what looknfeel.lua floats and sizes.
setsid omarchy-launch-tui --app-id=org.omarchy.finder \
    yazi --client-id "$CLIENT_ID" "$SEARCH_ROOT" >/dev/null 2>&1 &

# `ya emit-to` exits 1 with "Connection refused" until the instance is listening,
# so poll rather than guess at a fixed sleep.
for _ in $(seq 1 100); do
    if ya emit-to "$CLIENT_ID" search_do "$QUERY" --via=fd 2>/dev/null; then
        exit 0
    fi
    sleep 0.1
done

notify-send "File Search" "yazi did not come up in time -- searching for '$QUERY' manually (press s)"
