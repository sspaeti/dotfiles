#!/bin/bash
# Pin / unpin packages against pacman upgrades by editing the IgnorePkg line in
# /etc/pacman.conf. `omarchy-update` runs plain `pacman -Syu`, which honors
# IgnorePkg, so a pinned package is skipped with a warning and pacman ABORTS
# (does not override) if some other package needs a newer version of it.
#
# Why: the Hyprland stack (hyprland, aquamarine, hyprtoolkit, hyprland-guiutils)
# and the kernel are frozen at a known state while the 5K-monitor Aquamarine
# crash and the amdgpu MES hang are open. See
# ~/.claude/projects/-home-sspaeti-git-omarchy/memory/ for the history.
#
# Usage:
#   pkg-pin.sh                      list pins: installed vs repo version
#   pkg-pin.sh pin   PKG [PKG...]   add to IgnorePkg
#   pkg-pin.sh unpin PKG [PKG...]   remove from IgnorePkg
#   pkg-pin.sh deps  PKG            who depends on PKG (these may block an update)
#
# Only the first active `IgnorePkg =` line under [options] is managed; commented
# ones (e.g. the linux-firmware-intel note) are left alone. Duplicates are
# collapsed on every write. Needs sudo for pin/unpin.
#
# Testing against a copy: PKG_PIN_CONF=/tmp/pacman.conf pkg-pin.sh pin foo

set -euo pipefail

CONF="${PKG_PIN_CONF:-/etc/pacman.conf}"

die() {
  echo "pkg-pin: $*" >&2
  exit 1
}

# Line number of the first active IgnorePkg line, empty if none.
ignore_lineno() {
  { grep -nE '^[[:space:]]*IgnorePkg[[:space:]]*=' "$CONF" || true; } | head -1 | cut -d: -f1
}

# Current pins, one per line, deduplicated, order preserved.
current_pins() {
  local ln
  ln=$(ignore_lineno)
  [[ -z $ln ]] && return 0
  sed -n "${ln}p" "$CONF" | sed -E 's/^[[:space:]]*IgnorePkg[[:space:]]*=[[:space:]]*//' | tr ' ' '\n' | awk 'NF && !seen[$0]++'
}

# Rewrite the IgnorePkg line from stdin (one pkg per line). Creates the line
# right after [options] if none exists; removes it when the list is empty.
write_pins() {
  local pins ln new
  pins=$(awk 'NF && !seen[$0]++' | tr '\n' ' ' | sed 's/ *$//')
  ln=$(ignore_lineno)
  local -a sudo=()
  [[ -w $CONF ]] || sudo=(sudo)

  if [[ -z $pins ]]; then
    [[ -n $ln ]] && "${sudo[@]}" sed -i "${ln}d" "$CONF"
    return 0
  fi

  new="IgnorePkg = $pins"
  if [[ -n $ln ]]; then
    "${sudo[@]}" sed -i "${ln}s|.*|${new}|" "$CONF"
  else
    local opt
    opt=$(grep -nE '^\[options\]' "$CONF" | head -1 | cut -d: -f1)
    [[ -n $opt ]] || die "no [options] section in $CONF"
    "${sudo[@]}" sed -i "${opt}a ${new}" "$CONF"
  fi
}

installed_version() { pacman -Q "$1" 2>/dev/null | awk '{print $2}'; }
repo_version() { pacman -Si "$1" 2>/dev/null | awk -F': *' '/^Version/{print $2; exit}'; }

cmd_list() {
  local pins
  pins=$(current_pins)
  if [[ -z $pins ]]; then
    echo "no pins in $CONF"
    return 0
  fi
  printf '%-28s %-22s %s\n' PACKAGE INSTALLED REPO
  local p inst repo mark
  while read -r p; do
    inst=$(installed_version "$p")
    repo=$(repo_version "$p")
    mark=""
    [[ -z $inst ]] && inst="(not installed)"
    [[ -z $repo ]] && repo="(not in repos)"
    [[ $inst != "$repo" && $inst != "(not installed)" && $repo != "(not in repos)" ]] && mark="  <- held back"
    printf '%-28s %-22s %s%s\n' "$p" "$inst" "$repo" "$mark"
  done <<<"$pins"
  echo
  echo "repo column is from the last 'pacman -Sy'; run 'checkupdates' for a fresh view."
}

cmd_pin() {
  [[ $# -gt 0 ]] || die "pin: give at least one package"
  local p
  for p in "$@"; do
    pacman -Q "$p" >/dev/null 2>&1 || echo "pkg-pin: warning: $p is not installed (pinning anyway)" >&2
  done
  { current_pins; printf '%s\n' "$@"; } | write_pins
  echo "pinned: $*"
  for p in "$@"; do
    local req
    req=$(pacman -Qi "$p" 2>/dev/null | awk -F': *' '/^Required By/{print $2}')
    [[ -n $req && $req != None ]] && echo "  note: $p is required by: $req (an update of those may now abort; pin them too or unpin $p)"
  done
  echo
  cmd_list
}

cmd_unpin() {
  [[ $# -gt 0 ]] || die "unpin: give at least one package"
  local pins p missing=()
  pins=$(current_pins)
  for p in "$@"; do
    grep -qx "$p" <<<"$pins" || missing+=("$p")
  done
  [[ ${#missing[@]} -gt 0 ]] && echo "pkg-pin: not pinned: ${missing[*]}" >&2
  grep -vxF -f <(printf '%s\n' "$@") <<<"$pins" | write_pins
  echo "unpinned: $*"
  echo
  cmd_list
}

cmd_deps() {
  [[ $# -eq 1 ]] || die "deps: give exactly one package"
  pacman -Qi "$1" >/dev/null 2>&1 || die "$1 is not installed"
  echo "packages that depend on $1 (an upgrade of these may require a newer $1):"
  pacman -Qi "$1" | awk -F': *' '/^Required By/{print "  " $2}'
}

[[ -r $CONF ]] || die "cannot read $CONF"

case "${1:-list}" in
list) cmd_list ;;
pin) shift; cmd_pin "$@" ;;
unpin) shift; cmd_unpin "$@" ;;
deps) shift; cmd_deps "$@" ;;
-h | --help | help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//' ;;
*) die "unknown command '$1' (list | pin | unpin | deps)" ;;
esac
