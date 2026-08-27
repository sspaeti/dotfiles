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

# ---- "--read <folder> <uid>": one message body via BODY.PEEK (never sets
#      \Seen). Bodies are immutable, so cache per message; stale body files
#      age out after two days.
if [[ -n "$read_folder" ]]; then
  [[ "$read_uid" =~ ^[0-9]+$ ]] || fail "bad uid"
  [[ "$read_folder" =~ ^[A-Za-z_]+$ ]] || fail "bad folder"
  BCACHE="$STATE_DIR/body-$read_folder-$read_uid.json"
  if [[ -f "$BCACHE" ]]; then
    cat "$BCACHE"
    exit 0
  fi
  out=$(timeout 60 neomd read --folder "$read_folder" --uid "$read_uid" 2>/dev/null \
    | head -c 1048576) || fail "neomd read failed"
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
    clamp_headers <"$CACHE" || fail "cached mail is not JSON"
    exit 0
  fi
fi

# head -c bounds how much of neomd's output this script (and the widget's
# stdout collector) will ever hold in memory. Oversized output trips pipefail
# (SIGPIPE) or the jq check, either way falling back to the stale cache.
out=$(timeout 90 neomd list --folders "$folders" --limit "$limit" 2>/dev/null \
  | head -c 4194304) \
  || { [[ -f "$CACHE" ]] && { clamp_headers <"$CACHE" && exit 0; }; fail "neomd list failed"; }
[[ -n "$out" ]] || fail "neomd list produced no output"
jq -e . >/dev/null 2>&1 <<<"$out" || fail "neomd list produced no JSON"

# On a transient IMAP failure keep the last good data (marked stale) rather
# than wiping the panel.
if [[ $(jq -r '.ok' <<<"$out") != "true" && -f "$CACHE" ]]; then
  clamp_headers '. + {stale: true}' <"$CACHE" || fail "cached mail is not JSON"
  exit 0
fi

out=$(clamp_headers <<<"$out") || fail "could not clamp neomd output"
out=$(jq -c --arg fetched "$(date -Is)" '. + {fetched: $fetched}' <<<"$out")

tmp=$(mktemp "$STATE_DIR/.mail.XXXXXX")
printf '%s\n' "$out" >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$CACHE"
printf '%s\n' "$out"
