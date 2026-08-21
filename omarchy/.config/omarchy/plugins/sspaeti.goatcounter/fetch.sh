#!/usr/bin/env bash
# Fetch GoatCounter stats for all configured sites into one JSON blob.
#
# Credentials stay out of the dotfiles repo: sites are auto-discovered from
# GOATCOUNTER_URL / GOATCOUNTER_TOKEN plus any GOATCOUNTER_URL_<NAME> /
# GOATCOUNTER_TOKEN_<NAME> pairs in the secrets file. The GOATCOUNTER_*
# assignment lines are parsed literally (never eval'd — no shell syntax in
# values is ever executed), and tokens are never printed.
#
# Usage: fetch.sh [--cached] [--alert-daily N|JSON] [--alert-hourly N|JSON]
#   --cached        print cache when younger than TTL, else refresh
#   --alert-daily   notify when a site passes N views today (or per-site map
#                   like '{"ssp.sh": 3000}'); 0 disables
#   --alert-hourly  same for views in the last 60 minutes
#   --paths <label>            print the site's page list (≤1000, 6h cache)
#   --counts <label> <1|7|30> <id,..>  print view counts for those page ids
set -uo pipefail

SECRETS="${GOATCOUNTER_SECRETS:-$HOME/.dotfiles/zsh/.secrets}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/goatcounter"
CACHE="$STATE_DIR/stats.json"
TTL=900

cached=0 alert_daily=0 alert_hourly=0
paths_label="" counts_label="" counts_range="" counts_ids=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cached) cached=1; shift ;;
    --alert-daily) alert_daily=${2:-0}; shift 2 ;;
    --alert-hourly) alert_hourly=${2:-0}; shift 2 ;;
    --paths) paths_label=${2:-}; shift 2 ;;
    --counts) counts_label=${2:-}; counts_range=${3:-30}; counts_ids=${4:-}; shift 4 ;;
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

# Parse GOATCOUNTER_* assignments WITHOUT eval: eval would execute shell
# syntax in the value (command substitutions, chained commands) on every
# background refresh. Values are taken literally — one level of surrounding
# quotes is stripped, an unquoted value ends at the first whitespace, and no
# expansion of any kind is performed.
if [[ -r "$SECRETS" ]]; then
  while IFS= read -r _line; do
    [[ "$_line" =~ ^[[:space:]]*(export[[:space:]]+)?(GOATCOUNTER_[A-Z0-9_]+)=(.*)$ ]] || continue
    _name="${BASH_REMATCH[2]}"
    _val="${BASH_REMATCH[3]}"
    if [[ "$_val" =~ ^\"([^\"]*)\" ]]; then
      _val="${BASH_REMATCH[1]}"
    elif [[ "$_val" =~ ^\'([^\']*)\' ]]; then
      _val="${BASH_REMATCH[1]}"
    else
      _val="${_val%%[[:space:]]*}"
    fi
    printf -v "$_name" '%s' "$_val"
  done <"$SECRETS"
  unset _line _name _val
fi

# Date-only start/end is unreliable (start==end returns partial data), so
# always send full RFC3339 timestamps. GoatCounter IGNORES the timezone
# suffix and interprets the clock time in the SITE's timezone (verified:
# ...T10:00:00Z and ...T10:00:00+02:00 return identical data), so send LOCAL
# wall-clock times with a nominal Z — correct as long as the site timezone
# matches this machine's.
day_start_utc() { date -d "$1 00:00:00" +%FT%TZ; }
day_end_utc()   { date -d "$1 23:59:59" +%FT%TZ; }

now=$(date +%FT%TZ)
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
# space the calls out and let curl retry transient failures. --retry-max-time
# caps the whole retry loop: hosted goatcounter.com sends long Retry-After
# values that would otherwise stall a call for many minutes. The token goes
# in via a stdin config file, never argv, so it is invisible in `ps`.
api() { # url token path
  sleep 0.15
  curl -fsS -m 20 --retry 3 --retry-delay 2 --retry-max-time 45 \
    -K - "$1/api/v0/$3" <<<"header = \"Authorization: Bearer $2\""
}

resolve_site() { # label -> sets s_url/s_token, fails if unknown
  s_url="" s_token=""
  if [[ "$(site_label "${GOATCOUNTER_URL:-}")" == "$1" ]]; then
    s_url="${GOATCOUNTER_URL:-}" s_token="${GOATCOUNTER_TOKEN:-}"
  else
    local sfx u_var t_var
    for sfx in $(compgen -A variable | grep -E '^GOATCOUNTER_URL_[A-Z0-9_]+$' | sed 's/^GOATCOUNTER_URL_//'); do
      u_var="GOATCOUNTER_URL_$sfx" t_var="GOATCOUNTER_TOKEN_$sfx"
      if [[ "$(site_label "${!u_var:-}")" == "$1" ]]; then
        s_url="${!u_var:-}" s_token="${!t_var:-}"
        break
      fi
    done
  fi
  [[ -n "$s_url" && -n "$s_token" ]]
}

range_start() { # 1|7|30 -> range start timestamp
  case "$1" in
    1) day_start_utc "$today" ;;
    7) day_start_utc "$(date -d '6 days ago' +%F)" ;;
    *) day_start_utc "$(date -d '29 days ago' +%F)" ;;
  esac
}

# ---- "--paths <label>": print the site's path list (up to 1000 pages) as
#      {paths: [{id, path, title}]} and exit. The list is small (~150 bytes
#      per path) and cached on disk for 6 hours; the panel's "/" search
#      fuzzy-matches against it locally.
if [[ -n "$paths_label" ]]; then
  resolve_site "$paths_label" || { jq -n '{error: "unknown site"}'; exit 0; }
  PCACHE="$STATE_DIR/paths-$paths_label.json"
  if [[ -f "$PCACHE" ]] && (( $(date +%s) - $(stat -c %Y "$PCACHE") < 21600 )); then
    cat "$PCACHE"
    exit 0
  fi
  all="[]" after=0 truncated=false
  for _page in 1 2 3 4 5; do
    r=$(api "${s_url%/}" "$s_token" "paths?Limit=200&After=$after") \
      || { jq -n '{error: "API request failed"}'; exit 0; }
    n=$(jq '.paths | length' <<<"$r")
    (( n == 0 )) && break
    all=$(jq -n --argjson a "$all" --argjson r "$r" \
      '$a + ($r.paths | map({id, path, title}))')
    after=$(jq '.paths[-1].id' <<<"$r")
    if [[ $(jq '.more' <<<"$r") != "true" ]]; then
      truncated=false
      break
    fi
    truncated=true
  done
  out=$(jq -n --argjson p "$all" --argjson t "$truncated" '{paths: $p, truncated: $t}')
  tmp=$(mktemp "$STATE_DIR/.paths.XXXXXX")
  printf '%s\n' "$out" >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$PCACHE"
  printf '%s\n' "$out"
  exit 0
fi

# ---- "--counts <label> <range> <ids>": print view counts for specific page
#      ids in one range as {counts: [{name, count}]} and exit. Small (~15 KB)
#      because include_paths narrows the hits payload to the matched pages.
if [[ -n "$counts_label" ]]; then
  resolve_site "$counts_label" || { jq -n '{error: "unknown site"}'; exit 0; }
  [[ "$counts_ids" =~ ^[0-9]+(,[0-9]+)*$ ]] || { jq -n '{error: "bad ids"}'; exit 0; }
  h=$(api "${s_url%/}" "$s_token" \
    "stats/hits?start=$(range_start "$counts_range")&end=$now&limit=100&include_paths=$counts_ids") \
    || { jq -n '{error: "API request failed"}'; exit 0; }
  jq '{counts: (.hits // [] | map({name: .path, count: .count}))}' <<<"$h"
  exit 0
fi

# Threshold may be a plain number or a per-site map keyed by label.
threshold_for() { # spec label
  jq -n --argjson t "$1" --arg l "$2" \
    '$t | if type == "number" then . else (.[$l] // 0) end' 2>/dev/null || echo 0
}

notify_once() { # marker-key summary body [click-url]
  local marker="$STATE_DIR/alert-$1"
  [[ -f "$marker" ]] && return 0
  : >"$marker"
  command -v notify-send >/dev/null || return 0
  if [[ -n "${4:-}" ]]; then
    # -A blocks until the notification is clicked or dismissed, so wait in a
    # detached subshell and open the stats page on click.
    (
      resp=$(notify-send -a GoatCounter -A default=Open "$2" "$3")
      [[ "$resp" == "default" ]] && omarchy-launch-browser "$4"
    ) >/dev/null 2>&1 &
  else
    notify-send -a GoatCounter "$2" "$3"
  fi
}

site_error() { # label url
  # On a transient API failure keep the site's last good data (marked stale,
  # original fetch time preserved) rather than wiping the panel for the site.
  local cached=""
  [[ -f "$CACHE" ]] && cached=$(jq -c --arg l "$1" \
    '(.fetched // "") as $gf
     | [.sites[]? | select(.label == $l and .ranges != null)][0] // empty
     | . + {stale: true} | .fetched = (.fetched // $gf)' \
    "$CACHE" 2>/dev/null)
  if [[ -n "$cached" && "$cached" != "null" ]]; then
    printf '%s' "$cached"
    return
  fi
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

  # Incremental refresh: past days and past hours never change, so reuse them
  # from the previous cache. A cached period is final only when the cache was
  # written AFTER it ended, so gate on the cache's fetched timestamp.
  local cache_date="" cache_hour=-1 cached_days30="[]" cached_hours="[]"
  if [[ -f "$CACHE" ]]; then
    # Gate on the SITE's own fetch time (a stale-preserved site carries older
    # data than the file's timestamp), minus a 2.5-hour finality buffer:
    # GoatCounter's stats aggregates trail live traffic by up to ~2 hours
    # (verified: an hour read 25 shortly after it ended, 47 half an hour
    # later), so a period is trusted only once it was cached comfortably
    # after it ended — until then it keeps being refetched.
    local site_fetched fe
    site_fetched=$(jq -r --arg l "$label" \
      '([.sites[]? | select(.label == $l)][0].fetched) // .fetched // ""' "$CACHE" 2>/dev/null)
    fe=$(date -d "$site_fetched" +%s 2>/dev/null || echo 0)
    if (( fe > 9000 )); then
      fe=$((fe - 9000))
      cache_date=$(date -d "@$fe" +%F)
      cache_hour=$((10#$(date -d "@$fe" +%H)))
    fi
    cached_days30=$(jq -c --arg l "$label" \
      '[.sites[]? | select(.label == $l)][0].ranges["30"].days // []' "$CACHE" 2>/dev/null) \
      || cached_days30="[]"
    cached_hours=$(jq -c --arg l "$label" \
      '[.sites[]? | select(.label == $l)][0].ranges["1"].days // []' "$CACHE" 2>/dev/null) \
      || cached_hours="[]"
  fi

  # /stats/total has no per-day breakdown, so query each of the last 30 days;
  # the 7-day view is the tail of the same series.
  local days30="[]" i d t c
  for i in $(seq 29 -1 0); do
    d=$(date -d "$i days ago" +%F)
    if [[ -n "$cache_date" && "$d" < "$cache_date" ]]; then
      c=$(jq -r --arg d "$d" 'map(select(.day == $d)) | .[0].count // "MISS"' <<<"$cached_days30")
      if [[ "$c" =~ ^[0-9]+$ ]]; then
        days30=$(jq -n --argjson a "$days30" --arg day "$d" --argjson c "$c" \
          '$a + [{day: $day, count: $c}]')
        continue
      fi
    fi
    t=$(api "$url" "$token" "stats/total?start=$(day_start_utc "$d")&end=$(day_end_utc "$d")") \
      || { site_error "$label" "$url"; return; }
    days30=$(jq -n --argjson a "$days30" --arg day "$d" --argjson t "$t" \
      '$a + [{day: $day, count: ($t.total // 0)}]')
  done

  # Today as hourly bars: one total call per elapsed hour, cached hours reused.
  local hours="[]" h H hs he hl
  H=$(date +%-H)
  for ((h = 0; h <= H; h++)); do
    hl=$(printf '%02d:00' "$h")
    if [[ "$cache_date" == "$today" ]] && (( h < cache_hour )); then
      c=$(jq -r --arg d "$hl" 'map(select(.day == $d)) | .[0].count // "MISS"' <<<"$cached_hours")
      if [[ "$c" =~ ^[0-9]+$ ]]; then
        hours=$(jq -n --argjson a "$hours" --arg day "$hl" --argjson c "$c" \
          '$a + [{day: $day, count: $c}]')
        continue
      fi
    fi
    hs=$(date -d "$today $h:00:00" +%FT%TZ)
    he=$(date -d "$today $h:59:59" +%FT%TZ)
    t=$(api "$url" "$token" "stats/total?start=$hs&end=$he") \
      || { site_error "$label" "$url"; return; }
    hours=$(jq -n --argjson a "$hours" --arg day "$hl" --argjson t "$t" \
      '$a + [{day: $day, count: ($t.total // 0)}]')
  done

  local lists1 lists7 lists30
  lists1=$(fetch_lists "$url" "$token" "$(day_start_utc "$today")" "$now") &&
  lists7=$(fetch_lists "$url" "$token" "$(day_start_utc "$(date -d '6 days ago' +%F)")" "$now") &&
  lists30=$(fetch_lists "$url" "$token" "$(day_start_utc "$(date -d '29 days ago' +%F)")" "$now") \
    || { site_error "$label" "$url"; return; }

  # ---- Viral alerts: fire when a SINGLE PAGE passes the threshold in the
  #      window, not the site total (dedup per day / per hour via markers).
  check_page_alert() { # window-start marker-key window-label emoji-title thr
    local ws=$1 marker=$2 wlabel=$3 title=$4 thr=$5 viral n body vpath
    t=$(api "$url" "$token" "stats/hits?start=$ws&end=$now&limit=10") || return 0
    viral=$(jq -c --argjson thr "$thr" \
      '[.hits // [] | .[] | select(.count >= $thr)] | sort_by(-.count)' <<<"$t")
    n=$(jq 'length' <<<"$viral")
    (( n == 0 )) && return 0
    body=$(jq -r --arg w "$wlabel" '.[0] | "\(.path) — \(.count) views \($w)"' <<<"$viral")
    (( n > 1 )) && body="$body (+$((n - 1)) more pages)"
    vpath=$(jq -r '.[0].path' <<<"$viral")
    notify_once "$marker" "$title" "$body (threshold $thr)" "$url/?filter=$vpath"
  }

  local thr
  thr=$(threshold_for "$alert_daily" "$label")
  if (( thr > 0 )); then
    check_page_alert "$(day_start_utc "$today")" "$label-day-$today" \
      "today" "$label page is going viral 🎉" "$thr"
  fi
  thr=$(threshold_for "$alert_hourly" "$label")
  if (( thr > 0 )); then
    check_page_alert "$(date -d '60 minutes ago' +%FT%TZ)" "$label-hour-$(date +%FT%H)" \
      "in the last hour" "$label page is spiking 🚀" "$thr"
  fi

  jq -n --arg label "$label" --arg url "$url" --arg fetched "$(date -Is)" \
    --argjson hours "$hours" --argjson days30 "$days30" \
    --argjson lists1 "$lists1" --argjson lists7 "$lists7" --argjson lists30 "$lists30" '
    ($days30[-7:]) as $days7 |
    {label: $label, url: $url, fetched: $fetched,
     ranges: {
       "1":  ({total: ($hours  | map(.count) | add // 0), days: $hours}  + $lists1),
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
