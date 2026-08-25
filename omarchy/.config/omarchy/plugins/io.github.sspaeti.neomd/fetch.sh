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
#   fetch.sh --config <path> ...
#       use another neomd config.toml (e.g. a demo account); the cache is
#       kept per config so demo data never mixes with the real mailbox
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

cached=0 folders="Inbox,ToScreen,Feed,PaperTrail" limit=15
read_folder="" read_uid="" config_path=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cached) cached=1; shift ;;
    --folders) folders=${2:-}; shift 2 ;;
    --limit) limit=${2:-15}; shift 2 ;;
    --read) read_folder=${2:-}; read_uid=${3:-}; shift 3 ;;
    --config) config_path=${2:-}; shift 2 ;;
    *) shift ;;
  esac
done

# Alternate config (demo account): pass it to every neomd call and keep a
# separate cache directory, named after the config's parent dir (e.g.
# "neomd-demo-hostpoint"), so demo data never mixes with the real mailbox.
NEOMD=(neomd)
cache_name="default"
if [[ -n "$config_path" ]]; then
  config_path="${config_path/#\~/$HOME}"
  [[ -r "$config_path" ]] || fail "config not readable: ${config_path//\"/}"
  NEOMD=(neomd -config "$config_path")
  cache_name=$(basename "$(dirname "$config_path")")
  [[ "$cache_name" =~ ^[A-Za-z0-9._-]+$ ]] || cache_name="alt"
fi

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/neomd/$cache_name"
CACHE="$STATE_DIR/mail.json"
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

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
  out=$(timeout 60 "${NEOMD[@]}" read --folder "$read_folder" --uid "$read_uid" 2>/dev/null) \
    || fail "neomd read timed out"
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
    cat "$CACHE"
    exit 0
  fi
fi

out=$(timeout 90 "${NEOMD[@]}" list --folders "$folders" --limit "$limit" 2>/dev/null) \
  || { [[ -f "$CACHE" ]] && { cat "$CACHE"; exit 0; }; fail "neomd list timed out"; }
[[ -n "$out" ]] || fail "neomd list produced no output"
jq -e . >/dev/null 2>&1 <<<"$out" || fail "neomd list produced no JSON"

# On a transient IMAP failure keep the last good data (marked stale) rather
# than wiping the panel.
if [[ $(jq -r '.ok' <<<"$out") != "true" && -f "$CACHE" ]]; then
  jq -c '. + {stale: true}' "$CACHE"
  exit 0
fi

out=$(jq -c --arg fetched "$(date -Is)" '. + {fetched: $fetched}' <<<"$out")

tmp=$(mktemp "$STATE_DIR/.mail.XXXXXX")
printf '%s\n' "$out" >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$CACHE"
printf '%s\n' "$out"
