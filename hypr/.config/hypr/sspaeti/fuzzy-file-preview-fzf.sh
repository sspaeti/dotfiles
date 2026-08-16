#!/bin/bash
# Preview pane renderer for fuzzy-file-names.sh (called by fzf --preview).
# Takes one path. fzf exports FZF_PREVIEW_COLUMNS / FZF_PREVIEW_LINES.

set -uo pipefail

TARGET="${1:-}"
[ -e "$TARGET" ] || { echo "gone: $TARGET"; exit 0; }

COLS="${FZF_PREVIEW_COLUMNS:-80}"
LINES_="${FZF_PREVIEW_LINES:-40}"

if [ -d "$TARGET" ]; then
    if command -v eza >/dev/null; then
        eza --long --header --group-directories-first --color=always \
            --time-style=long-iso --no-user "$TARGET" | head -n "$LINES_"
    else
        ls -lAh --color=always "$TARGET" | head -n "$LINES_"
    fi
    exit 0
fi

MIME=$(file --brief --mime-type "$TARGET" 2>/dev/null || echo "")

case "$MIME" in
image/*)
    # chafa renders in any terminal; kitten icat needs the kitty graphics
    # protocol, which ghostty and kitty both speak.
    if command -v chafa >/dev/null; then
        chafa --size="${COLS}x$((LINES_ - 6))" "$TARGET"
    elif command -v kitten >/dev/null; then
        kitten icat --clear --transfer-mode=stream --stdin=no \
            --place="${COLS}x$((LINES_ - 6))@0x0" "$TARGET" 2>/dev/null ||
            echo "(no inline image support)"
    fi
    echo
    exiftool -s -ImageSize -FileSize -FileModifyDate -Model "$TARGET" 2>/dev/null
    ;;
application/pdf)
    exiftool -s -Title -PageCount -FileSize -FileModifyDate "$TARGET" 2>/dev/null
    echo "---"
    pdftotext -l 3 -nopgbrk "$TARGET" - 2>/dev/null | head -n $((LINES_ - 8))
    ;;
video/* | audio/*)
    exiftool -s -Duration -ImageSize -FileSize -FileModifyDate "$TARGET" 2>/dev/null
    ;;
text/* | application/json | application/xml | application/javascript | inode/x-empty)
    if command -v bat >/dev/null; then
        bat --style=numbers --color=always --paging=never \
            --line-range=":$((LINES_ * 2))" "$TARGET" 2>/dev/null
    else
        head -n "$((LINES_ * 2))" "$TARGET"
    fi
    ;;
*)
    file --brief "$TARGET"
    echo "---"
    exiftool -s -FileSize -FileModifyDate "$TARGET" 2>/dev/null
    ;;
esac
