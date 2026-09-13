#!/usr/bin/env bash
# Data source for the omarchy neomd bar widget.
#
# Everything goes through the neomd binary, which owns the IMAP config and
# keyring — no credential of any kind passes through this script.
#
#   fetch.sh [--cached] [--folders A,B,..] [--limit N]
#       print {"ok":true,"account":..,"folders":[..],"fetched":..}
#   fetch.sh --read <folder> <uid>
#       print one message body (BODY.PEEK — never marks it read)
#
# Output is always a single JSON object. Failures print {"ok":false,...} and
# exit 0: a widget that gets no JSON has nothing to show but a crash.
set -uo pipefail
umask 077

TTL=240

# Size bounds. LIST_MAX/BODY_MAX apply to neomd's live output AND to the
# on-disk caches — every byte this script emits passes one of them.
LIST_MAX=4194304   # 4 MB
BODY_MAX=1048576   # 1 MB

# Quickshell child processes are started by uwsm and do not necessarily
# inherit the login shell's PATH, so add the usual install dirs back.
for candidate in "$HOME/.local/bin" "$HOME/go/bin"; do
  case ":$PATH:" in
    *":$candidate:"*) ;;
    *) [ -d "$candidate" ] && PATH="$PATH:$candidate" ;;
  esac
done
export PATH

fail() { # message
  printf '{"ok":false,"error":"%s"}\n' "$1"
  exit 0
}

command -v neomd >/dev/null || fail "neomd not found in PATH"
command -v jq >/dev/null || fail "jq not found in PATH"

cached=0 folders="Inbox,ToScreen,Feed,PaperTrail" limit=25
read_folder="" read_uid=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cached) cached=1; shift ;;
    --folders) folders=${2:-}; shift 2 ;;
    --limit) limit=${2:-25}; shift 2 ;;
    --read) read_folder=${2:-}; read_uid=${3:-}; shift 3 ;;
    *) shift ;;
  esac
done

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/neomd"
CACHE="$STATE_DIR/mail.json"
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

# ---- Sender-controlled header cap, enforced here rather than trusted from
# the producer. From/Subject come straight off the wire, and the widget holds
# them in memory, writes them to the cache and hands them to QML Text items.
# neomd >= v0.9.1 already truncates both at 500 bytes, but this script must
# hold on its own against any older or differently-built neomd on PATH — the
# widget's bound cannot depend on which version happens to be installed. Every
# code path below that prints list data pipes through clamp_headers, so
# "fetch.sh never emits an unbounded header" is a property of this file alone.
# The cap is in characters; jq slices codepoints, so a multibyte rune is
# never split in half by the cut.
HEADER_MAX=500
CLAMP_JQ='
  def clip: if type == "string" and (length > $n) then .[0:$n] + "…" else . end;
  def clipmail:
    if type == "object"
    then (if has("from") then .from |= clip else . end
          | if has("subject") then .subject |= clip else . end)
    else . end;
  if (.folders | type) == "array"
  then .folders |= map(
         if type == "object" and (.emails | type) == "array"
         then .emails |= map(clipmail) else . end)
  else . end
'

# clamp_headers [extra-jq] : JSON on stdin -> clamped JSON on stdout.
# Exits nonzero (printing nothing) on unparseable input, so a corrupt cache
# surfaces as an error instead of being emitted unclamped.
clamp_headers() {
  jq -c --argjson n "$HEADER_MAX" "$CLAMP_JQ${1:+ | $1}" 2>/dev/null
}

# ---- read_cache <file> <max-bytes> : print at most max-bytes of file.
#
# The cache lives in a 0700 dir, but the widget must not be wedged or blown up
# by whatever happens to sit at that pathname — a leftover from another tool, a
# botched restore, or a swapped-in special file. `[[ -f ]]` is not enough: it
# follows symlinks (a link to a huge file passes the test), and even for FIFOs,
# which it does reject, the answer is stale by the time the file is opened.
#
# dd does the open itself with O_NOFOLLOW (a symlink at the path fails outright
# rather than redirecting the read) and O_NONBLOCK (a FIFO returns EOF instead
# of hanging the helper, and with it the QML StdioCollector waiting on stdout).
# head then bounds what an oversized file or an endless device node can push
# into memory. Requires GNU dd for the iflags; this is an Arch/Omarchy plugin.
read_cache() {
  dd if="$1" iflag=nofollow,nonblock status=none 2>/dev/null | head -c "$2"
}

# ---- cache_json [extra-jq] : print the clamped list cache, or exit nonzero
# without printing anything. Bounded read, then the same header clamp every
# other path goes through.
cache_json() {
  local raw
  raw=$(read_cache "$CACHE" "$LIST_MAX")
  [[ -n "$raw" ]] || return 1
  clamp_headers "${1:-}" <<<"$raw"
}

# ---- "--read <folder> <uid>": one message body via BODY.PEEK (never sets
#      \Seen). Bodies are immutable, so cache per message; stale body files
#      age out after two days.
if [[ -n "$read_folder" ]]; then
  [[ "$read_uid" =~ ^[0-9]+$ ]] || fail "bad uid"
  [[ "$read_folder" =~ ^[A-Za-z_]+$ ]] || fail "bad folder"
  BCACHE="$STATE_DIR/body-$read_folder-$read_uid.json"
  # A cache hit is only taken if it survives the bounded read AND still parses
  # as JSON; anything else falls through to a fresh fetch rather than handing
  # the panel a truncated or foreign body.
  if [[ -f "$BCACHE" ]]; then
    cached_body=$(read_cache "$BCACHE" "$BODY_MAX")
    if [[ -n "$cached_body" ]] && jq -e . >/dev/null 2>&1 <<<"$cached_body"; then
      printf '%s\n' "$cached_body"
      exit 0
    fi
  fi
  out=$(timeout 60 neomd read --folder "$read_folder" --uid "$read_uid" 2>/dev/null \
    | head -c "$BODY_MAX") || fail "neomd read failed"
  [[ -n "$out" ]] || fail "neomd read produced no output"
  jq -e . >/dev/null 2>&1 <<<"$out" || fail "neomd read produced no JSON"
  if [[ $(jq -r '.ok' <<<"$out") == "true" ]]; then
    tmp=$(mktemp "$STATE_DIR/.body.XXXXXX")
    printf '%s\n' "$out" >"$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$BCACHE"
  fi
  find "$STATE_DIR" -name 'body-*' -mtime +2 -delete 2>/dev/null
  printf '%s\n' "$out"
  exit 0
fi

if (( cached )) && [[ -f "$CACHE" ]]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
  if (( age < TTL )); then
    cache_json || fail "cached mail is unusable"
    exit 0
  fi
fi

# head -c bounds how much of neomd's output this script (and the widget's
# stdout collector) will ever hold in memory. Oversized output trips pipefail
# (SIGPIPE) or the jq check, either way falling back to the stale cache.
out=$(timeout 90 neomd list --folders "$folders" --limit "$limit" 2>/dev/null \
  | head -c "$LIST_MAX") \
  || { [[ -f "$CACHE" ]] && { cache_json && exit 0; }; fail "neomd list failed"; }
[[ -n "$out" ]] || fail "neomd list produced no output"
jq -e . >/dev/null 2>&1 <<<"$out" || fail "neomd list produced no JSON"

# On a transient IMAP failure keep the last good data (marked stale) rather
# than wiping the panel.
if [[ $(jq -r '.ok' <<<"$out") != "true" && -f "$CACHE" ]]; then
  cache_json '. + {stale: true}' || fail "cached mail is unusable"
  exit 0
fi

out=$(clamp_headers <<<"$out") || fail "could not clamp neomd output"
out=$(jq -c --arg fetched "$(date -Is)" '. + {fetched: $fetched}' <<<"$out")

tmp=$(mktemp "$STATE_DIR/.mail.XXXXXX")
printf '%s\n' "$out" >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$CACHE"
printf '%s\n' "$out"
