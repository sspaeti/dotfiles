#!/bin/bash
# Default-input switching for the sspaeti.audio panel.
#   noise-cancel.sh status          "on <mic>" | "off <mic>"  (mic = filter's capture target)
#   noise-cancel.sh target          name of the mic the filter currently captures from
#   noise-cancel.sh on [mic]        filter captures from <mic> (default: current default input), default input = filter
#   noise-cancel.sh off             default input = the mic the filter captures from
#   noise-cancel.sh toggle
#   noise-cancel.sh set <mic>       plain default-input switch (filter off)
#
# The filter is the PipeWire filter-chain in
# ~/.config/pipewire/pipewire.conf.d/99-input-denoising.conf. Its capture stream
# (capture.rnnoise_source) is retargeted through pw-metadata target.object, so
# any mic works.
#
# When switching the default input, active capture streams are moved along like
# omarchy's omarchy-audio-input-set-default does, EXCEPT the filter's own capture
# stream: moving that onto rnnoise_source would feed the filter its own output.

set -euo pipefail

FILTER="rnnoise_source"
FILTER_CAPTURE="capture.rnnoise_source"

sources() { pactl list sources short 2>/dev/null | awk '{ print $2 }'; }
have_source() { sources | grep -qx -- "$1"; }
is_mic() { [[ -n $1 && $1 != "$FILTER" && $1 != *.monitor ]]; }
source_name_by_index() { pactl list sources short 2>/dev/null | awk -v i="$1" '$1 == i { print $2 }'; }

# "<source-output-id> <source-index>" for the filter's capture stream, or nothing.
capture_stream() {
  pactl list source-outputs 2>/dev/null | awk -v want="$FILTER_CAPTURE" '
    /^Source Output #/ { id = substr($3, 2); src = ""; node = "" }
    /^\tSource: / { src = $2 }
    /node\.name = / { gsub(/"/, "", $3); node = $3 }
    node == want && src != "" && id != "" { print id, src; exit }
  '
}

current_target() {
  local cap; cap=$(capture_stream)
  [[ -n $cap ]] || return 0
  source_name_by_index "${cap#* }"
}

fallback_mic() { sources | grep -E '^alsa_input' | grep -v '\.monitor$' | head -1; }

# Move every capture stream except the filter's own onto $1.
move_streams() {
  local name=$1
  pactl list source-outputs 2>/dev/null | awk -v skip="$FILTER_CAPTURE" '
    /^Source Output #/ { if (id != "" && node != skip) print id; id = substr($3, 2); node = "" }
    /node\.name = / { gsub(/"/, "", $3); node = $3 }
    END { if (id != "" && node != skip) print id }
  ' | while read -r out; do
    pactl move-source-output "$out" "$name" 2>/dev/null || true
  done
}

set_default() {
  local name=$1
  [[ -n $name ]] || { echo "no input source available" >&2; exit 1; }
  have_source "$name" || { echo "input source not found: $name" >&2; exit 1; }
  pactl set-default-source "$name"
  move_streams "$name"
}

# Point the filter's capture stream at $1 by name. Not `pactl move-source-output`:
# moving a stream onto the *current default* stores target -1 ("follow default"),
# and the default is about to become the filter itself.
retarget_filter() {
  local mic=$1 cap
  cap=$(capture_stream)
  [[ -n $cap ]] || { echo "$FILTER_CAPTURE stream not found (noise-suppression-for-voice installed? pipewire restarted?)" >&2; exit 1; }
  pw-metadata "${cap%% *}" target.object "$mic" Spa:String >/dev/null
}

current=$(pactl get-default-source 2>/dev/null || true)

case "${1:-status}" in
  status)
    if [[ $current == "$FILTER" ]]; then echo "on $(current_target)"; else echo "off $(current_target)"; fi ;;
  target) current_target ;;
  on)
    have_source "$FILTER" || { echo "$FILTER not loaded (noise-suppression-for-voice installed? pipewire restarted?)" >&2; exit 1; }
    mic=${2:-}
    is_mic "$mic" || mic=$current
    is_mic "$mic" || mic=$(current_target)
    is_mic "$mic" || mic=$(fallback_mic)
    have_source "$mic" || { echo "mic not found: $mic" >&2; exit 1; }
    retarget_filter "$mic"
    set_default "$FILTER" ;;
  off)
    mic=$(current_target)
    is_mic "$mic" && have_source "$mic" || mic=$(fallback_mic)
    set_default "$mic" ;;
  toggle) if [[ $current == "$FILTER" ]]; then "$0" off; else "$0" on; fi ;;
  set) set_default "${2:-}" ;;
  *) echo "Usage: $(basename "$0") status|target|on [mic]|off|toggle|set <mic>" >&2; exit 2 ;;
esac
