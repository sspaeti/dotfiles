#!/usr/bin/env bash
# CPU package temperature for the omarchy bar (Waybar-style JSON on stdout).
#
# hwmon indices are not stable across boots, so the sensor is looked up by
# name rather than by the hwmonN path a given boot happened to hand out.
set -euo pipefail

CRITICAL=${CPU_TEMP_CRITICAL:-80}

hwmon_by_name() {
  local dir
  for dir in /sys/class/hwmon/hwmon*; do
    [[ -r "$dir/name" ]] || continue
    [[ "$(<"$dir/name")" == "$1" ]] || continue
    echo "$dir"
    return 0
  done
  return 1
}

# k10temp = AMD, coretemp = Intel, acpitz = generic fallback.
dir=""
for name in k10temp coretemp acpitz acpitz_0; do
  if dir=$(hwmon_by_name "$name"); then break; fi
  dir=""
done
[[ -n "$dir" && -r "$dir/temp1_input" ]] || exit 0

celsius=$(($(<"$dir/temp1_input") / 1000))
label=$(cat "$dir/temp1_label" 2>/dev/null || basename "$dir")

class=""
[[ $celsius -ge $CRITICAL ]] && class="active"

printf '{"text":"%s°C","tooltip":"CPU temperature: %s°C (%s)","class":"%s"}\n' \
  "$celsius" "$celsius" "$label" "$class"
