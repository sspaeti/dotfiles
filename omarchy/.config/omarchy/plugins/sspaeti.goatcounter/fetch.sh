#!/usr/bin/env bash
# Fetch GoatCounter stats for all configured sites into one JSON blob.
#
# Credentials stay out of the dotfiles repo: sites are auto-discovered from
# GOATCOUNTER_URL / GOATCOUNTER_TOKEN plus any GOATCOUNTER_URL_<NAME> /
# GOATCOUNTER_TOKEN_<NAME> pairs in the secrets file. Only the GOATCOUNTER_*
# assignment lines are eval'd, never the whole file, and tokens are never
# printed.
#
# Usage: fetch.sh [--cached] [--alert-daily N|JSON] [--alert-hourly N|JSON]
#   --cached        print cache when younger than TTL, else refresh
#   --alert-daily   notify when a site passes N views today (or per-site map
#                   like '{"ssp.sh": 3000}'); 0 disables
#   --alert-hourly  same for views in the last 60 minutes
set -uo pipefail

SECRETS="${GOATCOUNTER_SECRETS:-$HOME/.dotfiles/zsh/.secrets}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/goatcounter"
CACHE="$STATE_DIR/stats.json"
TTL=900

cached=0 alert_daily=0 alert_hourly=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cached) cached=1; shift ;;
    --alert-daily) alert_daily=${2:-0}; shift 2 ;;
    --alert-hourly) alert_hourly=${2:-0}; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

if (( cached )) && [[ -f "$CACHE" ]]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
  if (( age < TTL )); then
    cat "$CACHE"
    exit 0
  fi
fi

if [[ -r "$SECRETS" ]]; then
  eval "$(grep -E '^[[:space:]]*(export[[:space:]]+)?GOATCOUNTER_[A-Z0-9_]+=' "$SECRETS")"
fi

# Date-only start/end is unreliable (start==end returns partial data), so
# always send full RFC3339 timestamps: local day boundaries converted to UTC.
day_start_utc() { date -u -d "$1 00:00:00" +%FT%TZ; }
day_end_utc()   { date -u -d "$1 23:59:59" +%FT%TZ; }

now=$(date -u +%FT%TZ)
today=$(date +%F)

# goatcounter.ssp.sh -> ssp.sh, dedp.goatcounter.com -> dedp
site_label() {
  local host=${1#*://}
  host=${host%%/*}
  host=${host#goatcounter.}
  host=${host%.goatcounter.com}
  printf '%s' "$host"
}

# Rate limit is ~4 req/s (429 with Retry-After, which --retry honors), so
# space the calls out and let curl retry transient failures.
api() { # url token path
  sleep 0.3
  curl -fsS -m 20 --retry 3 --retry-delay 2 \
    -H "Authorization: Bearer $2" "$1/api/v0/$3"
}

# Threshold may be a plain number or a per-site map keyed by label.
threshold_for() { # spec label
  jq -n --argjson t "$1" --arg l "$2" \
    '$t | if type == "number" then . else (.[$l] // 0) end' 2>/dev/null || echo 0
}

notify_once() { # marker-key summary body
  local marker="$STATE_DIR/alert-$1"
  [[ -f "$marker" ]] && return 0
  : >"$marker"
  command -v notify-send >/dev/null && notify-send -a GoatCounter "$2" "$3"
}

site_error() { # label url
  jq -n --arg label "$1" --arg url "$2" \
    '{label: $label, url: $url, error: "API request failed (check token, permissions, network)"}'
}

fetch_lists() { # url token start end -> json {toppages, toprefs, locations, systems, languages}
  local url=$1 token=$2 s=$3 e=$4
  local hits toprefs locations systems languages
  # The hits payload carries per-path hourly series — far too big to pass as
  # a jq argument — so strip it down to path+count immediately.
  hits=$(api "$url" "$token" "stats/hits?start=$s&end=$e&limit=10" \
    | jq -c '{hits: (.hits // [] | map({path, count}))}') &&
  toprefs=$(api "$url" "$token" "stats/toprefs?start=$s&end=$e") &&
  locations=$(api "$url" "$token" "stats/locations?start=$s&end=$e") &&
  systems=$(api "$url" "$token" "stats/systems?start=$s&end=$e") &&
  languages=$(api "$url" "$token" "stats/languages?start=$s&end=$e") || return 1
  jq -n --argjson hits "$hits" --argjson toprefs "$toprefs" \
    --argjson locations "$locations" --argjson systems "$systems" \
    --argjson languages "$languages" '
    def top: .stats // []
      | map({name: (if (.name // .id // "") == "" then "(direct)" else (.name // .id) end),
             count: .count})
      | sort_by(-.count) | .[0:8];
    {toppages: ($hits.hits // [] | map({name: .path, count: .count}) | sort_by(-.count) | .[0:10]),
     toprefs: ($toprefs | top), locations: ($locations | top),
     systems: ($systems | top), languages: ($languages | top)}'
}

fetch_site() { # label url token
  local label=$1 url=${2%/} token=$3

  # /stats/total has no per-day breakdown, so query each of the last 30 days;
  # the 7-day view is the tail of the same series.
  local days30="[]" i d t
  for i in $(seq 29 -1 0); do
    d=$(date -d "$i days ago" +%F)
    t=$(api "$url" "$token" "stats/total?start=$(day_start_utc "$d")&end=$(day_end_utc "$d")") \
      || { site_error "$label" "$url"; return; }
    days30=$(jq -n --argjson a "$days30" --arg day "$d" --argjson t "$t" \
      '$a + [{day: $day, count: ($t.total // 0)}]')
  done

  local lists7 lists30
  lists7=$(fetch_lists "$url" "$token" "$(day_start_utc "$(date -d '6 days ago' +%F)")" "$now") &&
  lists30=$(fetch_lists "$url" "$token" "$(day_start_utc "$(date -d '29 days ago' +%F)")" "$now") \
    || { site_error "$label" "$url"; return; }

  # ---- Viral alerts (dedup once per day / per hour via marker files).
  local thr views
  thr=$(threshold_for "$alert_daily" "$label")
  if (( thr > 0 )); then
    views=$(jq -r '.[-1].count' <<<"$days30")
    if (( views >= thr )); then
      notify_once "$label-day-$today" \
        "$label is going viral 🎉" "$views views today (threshold $thr)"
    fi
  fi
  thr=$(threshold_for "$alert_hourly" "$label")
  if (( thr > 0 )); then
    t=$(api "$url" "$token" "stats/total?start=$(date -u -d '60 minutes ago' +%FT%TZ)&end=$now") \
      && views=$(jq -r '.total // 0' <<<"$t") || views=0
    if (( views >= thr )); then
      notify_once "$label-hour-$(date +%FT%H)" \
        "$label is spiking 🚀" "$views views in the last hour (threshold $thr)"
    fi
  fi

  jq -n --arg label "$label" --arg url "$url" \
    --argjson days30 "$days30" --argjson lists7 "$lists7" --argjson lists30 "$lists30" '
    ($days30[-7:]) as $days7 |
    {label: $label, url: $url,
     ranges: {
       "7":  ({total: ($days7  | map(.count) | add // 0), days: $days7}  + $lists7),
       "30": ({total: ($days30 | map(.count) | add // 0), days: $days30} + $lists30)
     }}'
}

# ---- Auto-discover sites: base pair first, then every _<NAME> suffix pair.
suffixes=$(compgen -A variable | grep -E '^GOATCOUNTER_URL_[A-Z0-9_]+$' \
  | sed 's/^GOATCOUNTER_URL_//' | sort)

sites="[]"
add_site() { # url token
  [[ -z "${1:-}" || -z "${2:-}" ]] && return 0
  local s
  s=$(fetch_site "$(site_label "$1")" "$1" "$2")
  sites=$(jq -n --argjson a "$sites" --argjson s "$s" '$a + [$s]')
}

add_site "${GOATCOUNTER_URL:-}" "${GOATCOUNTER_TOKEN:-}"
for sfx in $suffixes; do
  url_var="GOATCOUNTER_URL_$sfx" token_var="GOATCOUNTER_TOKEN_$sfx"
  add_site "${!url_var:-}" "${!token_var:-}"
done

if [[ $(jq 'length' <<<"$sites") -eq 0 ]]; then
  out=$(jq -n --arg fetched "$(date -Is)" \
    '{fetched: $fetched, sites: [],
      error: "No GOATCOUNTER_URL / GOATCOUNTER_TOKEN found in secrets file"}')
else
  out=$(jq -n --argjson sites "$sites" --arg fetched "$(date -Is)" \
    '{fetched: $fetched, sites: $sites}')
fi

find "$STATE_DIR" -name 'alert-*' -mtime +2 -delete 2>/dev/null

tmp=$(mktemp "$STATE_DIR/.stats.XXXXXX")
printf '%s\n' "$out" >"$tmp"
chmod 600 "$tmp"
mv "$tmp" "$CACHE"
printf '%s\n' "$out"
