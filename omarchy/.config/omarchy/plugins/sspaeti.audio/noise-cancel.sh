#!/bin/bash
# Default-input switching for the sspaeti.audio panel.
#   noise-cancel.sh status|on|off|toggle      RNNoise filter on/off
#   noise-cancel.sh set <source-name>         make <source-name> the default input
#
# The filter is the PipeWire filter-chain in
# ~/.config/pipewire/pipewire.conf.d/99-input-denoising.conf; "on" means the
# default source is rnnoise_source, "off" means the raw mic it captures from.
#
# Active capture streams are moved to the new default like omarchy's own
# omarchy-audio-input-set-default does, EXCEPT the filter's own capture stream:
# moving that onto rnnoise_source would feed the filter its own output.

set -euo pipefail

FILTER="rnnoise_source"
FILTER_CAPTURE="capture.rnnoise_source"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d/99-input-denoising.conf"

sources() { pactl list sources short 2>/dev/null | awk '{ print $2 }'; }
have_source() { sources | grep -qx -- "$1"; }

raw_mic() {
  local target
  target=$(sed -n 's/.*target\.object *= *"\([^"]*\)".*/\1/p' "$CONF" 2>/dev/null | head -1)
  if [[ -n $target ]] && have_source "$target"; then
    echo "$target"
    return
  fi
  sources | grep -E '^alsa_input' | grep -v '\.monitor$' | head -1
}

set_default() {
  local name=$1
  [[ -n $name ]] || { echo "no input source available" >&2; exit 1; }
  have_source "$name" || { echo "input source not found: $name" >&2; exit 1; }
  pactl set-default-source "$name"

  # Move existing capture streams, skipping the filter's own capture stream.
  pactl list source-outputs 2>/dev/null | awk -v skip="$FILTER_CAPTURE" '
    /^Source Output #/ { id = substr($3, 2); node = "" }
    /node\.name = / { gsub(/"/, "", $3); node = $3 }
    /^$/ || /^Source Output #/ { if (id != "" && node != "" && node != skip) print id; if (/^$/) id = "" }
    END { if (id != "" && node != "" && node != skip) print id }
  ' | sort -u | while read -r out; do
    pactl move-source-output "$out" "$name" 2>/dev/null || true
  done
}

current=$(pactl get-default-source 2>/dev/null || true)

case "${1:-status}" in
  status) if [[ $current == "$FILTER" ]]; then echo on; else echo off; fi ;;
  on)
    have_source "$FILTER" || { echo "$FILTER not loaded (noise-suppression-for-voice installed? pipewire restarted?)" >&2; exit 1; }
    set_default "$FILTER" ;;
  off) set_default "$(raw_mic)" ;;
  toggle) if [[ $current == "$FILTER" ]]; then "$0" off; else "$0" on; fi ;;
  set) set_default "${2:-}" ;;
  *) echo "Usage: $(basename "$0") status|on|off|toggle|set <source-name>" >&2; exit 2 ;;
esac
