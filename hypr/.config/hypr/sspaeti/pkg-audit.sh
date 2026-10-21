#!/bin/bash
# Find packages you installed yourself and probably don't use, then remove them
# interactively. Companion to pkg-pin.sh.
#
# Scope: explicitly installed packages that are NOT in Omarchy's base list
# (/usr/share/omarchy/install/omarchy-base.packages), i.e. the stuff you added.
# Packages pulled in as dependencies are not listed here; `orphans` covers the
# ones nothing (or only an optional dependency) still needs.
#
# "Last used" is estimated from three signals, newest wins:
#   h  shell history   ~/.zsh_history: a command line started with one of the
#                      package's /usr/bin names (sudo/env prefixes skipped)
#   r  binary run      atime of its executables in /usr/bin and /opt, only if
#                      newer than the file's mtime (relatime: updated at most
#                      once a day; equal to mtime = not run since install/upgrade)
#                      r? = 30+ packages read within the same 10 minutes = a
#                      backup/indexer/rebuild-detector, ignored for LAST
#   c  config touched  mtime of ~/.config|~/.cache|~/.local/share|~/.local/state
#                      entries named like the package, its stem or a binary
#                      (case-insensitive; substring match for names of 5+ chars)
#   s  service running a systemd unit shipped by the package is active (LAST=running)
#
# KIND column: app = has a .desktop entry, cli = has /usr/bin binaries,
# sys = kernel/firmware/ucode/dkms/keyring/fonts/shell plugins/base (no usage
# signal possible, listed last, think twice), lib = something else depends on it
# (hidden by default, cannot be removed alone; --all shows them).
#
# Usage:
#   pkg-audit.sh [list] [--all] table, stalest first, biggest first within a day
#   pkg-audit.sh review [--all] fzf multi-select (Tab) -> sudo pacman -Rns
#   pkg-audit.sh aur [--bin]    AUR packages built from source (slow in yay);
#                               --bin also asks AUR whether a -bin variant exists
#   pkg-audit.sh orphans        deps nothing needs anymore + optional-only deps
#   pkg-audit.sh big [N]        N largest installed packages (default 25)

set -uo pipefail

BASE=/usr/share/omarchy/install/omarchy-base.packages
HIST="${HISTFILE:-$HOME/.zsh_history}"
TMP=$(mktemp -d -t pkg-audit-XXXXXX)
trap 'rm -rf "$TMP"' EXIT

die() {
  echo "pkg-audit: $*" >&2
  exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || die "missing $1 (pacman -S $2)"; }
need expac expac

mine() {
  local base=$TMP/base
  if [[ -r $BASE ]]; then
    grep -vE '^#|^$' "$BASE" | awk '{print $1}' | sort -u >"$base"
  else
    : >"$base"
  fi
  comm -23 <(pacman -Qeq | sort) "$base"
}

# One pass over shell history: first command word -> newest timestamp.
build_hist_index() {
  [[ -r $HIST ]] || return 0
  # zsh extended format ": TS:0;CMD", plain lines otherwise (no timestamp).
  awk '
    { line=$0; ts=0
      if (match(line, /^: [0-9]+:[0-9]+;/)) { ts=substr(line,3,index(line,":")-3)+0; line=substr(line,RLENGTH+1) }
      n=split(line, w, /[ \t|;&]+/)
      for (i=1;i<=n;i++) { c=w[i]; if (c=="" || c=="sudo" || c=="env" || c=="command" || c=="nohup" || c ~ /^[A-Za-z_][A-Za-z0-9_]*=/) continue; break }
      sub(/^.*\//, "", c)
      if (c!="" && ts>seen[c]) seen[c]=ts }
    END { for (c in seen) print c "\t" seen[c] }' "$HIST" >"$TMP/hist" 2>/dev/null
}

hist_ts() { # binary name -> ts or 0
  [[ -s $TMP/hist ]] || { echo 0; return; }
  awk -F'\t' -v b="$1" '$1==b{print $2; exit}' "$TMP/hist" | grep . || echo 0
}

# Executables owned by the package (limited, enough for "was it run").
pkg_bins() {
  pacman -Qlq "$1" 2>/dev/null | grep -E '^/usr/bin/[^/]+$|^/opt/[^/]+/[^/]+$' | head -15
}

run_ts() { # max atime over bins, only where atime > mtime+60 (else 0)
  local f a m best=0
  for f in "$@"; do
    [[ -x $f && ! -d $f ]] || continue
    a=$(stat -c %X "$f" 2>/dev/null || echo 0)
    m=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    ((a > m + 60 && a > best)) && best=$a
  done
  echo "$best"
}

# Cached, lowercased listing of the state dirs: "<mtime>\t<lowername>\t<path>"
state_index() {
  [[ -s $TMP/state ]] && return 0
  local d
  for d in "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" "$HOME/.local/state"; do
    [[ -d $d ]] || continue
    find "$d" -mindepth 1 -maxdepth 1 -printf '%T@\t%f\t%p\n' 2>/dev/null |
      awk -F'\t' -v OFS='\t' '{print int($1), tolower($2), $3}'
  done >"$TMP/state"
}

cfg_ts() { # max mtime of state dirs named like pkg / its stems / its bins
  state_index
  local best=0 n t
  for n in "$@"; do
    n=${n,,}
    [[ ${#n} -ge 3 ]] || continue
    # exact name always; substring only for names of 5+ chars (brave -> bravesoftware)
    t=$(awk -F'\t' -v n="$n" 'BEGIN{sub_ok=length(n)>=5} ($2==n || (sub_ok && index($2,n)>0)) && $1>m {m=$1} END{print m+0}' "$TMP/state")
    ((t > best)) && best=$t
  done
  echo "$best"
}

svc_active() { # 1 if any systemd unit shipped by the package is active (system or user)
  local u
  while read -r u; do
    u=${u##*/}
    systemctl is-active --quiet "$u" 2>/dev/null && { echo 1; return; }
    systemctl --user is-active --quiet "$u" 2>/dev/null && { echo 1; return; }
  done < <(pacman -Qlq "$1" 2>/dev/null | grep -E '/systemd/(system|user)/[^/]+\.(service|socket|timer)$' | head -10)
  echo 0
}

kind_of() { # pkg -> app|cli|sys|lib
  local p=$1
  case $p in
    base | base-devel | linux | linux-* | *-ucode | *firmware* | *-dkms* | *-keyring | ttf-* | otf-* | noto-* | zsh-* | lib32-* | vulkan-* | mesa | gst-* | pipewire*) echo sys; return ;;
  esac
  local req
  req=$(pacman -Qi "$p" | awk -F': *' '/^Required By/{print $2}')
  [[ $req != None ]] && { echo lib; return; }
  pacman -Qlq "$p" 2>/dev/null | grep -qE '/usr/share/applications/.*\.desktop$' && { echo app; return; }
  echo cli
}

# Raw rows: h TAB r TAB c TAB rawsize TAB installed TAB pkg TAB kind TAB desc TAB svc_active
scan_raw() {
  build_hist_index
  local all=${1:-0}
  local p bins names h r c t raw inst desc kind stem sv
  while read -r p; do
    kind=$(kind_of "$p")
    [[ $kind == lib && $all == 0 ]] && continue
    mapfile -t bins < <(pkg_bins "$p")
    stem=${p%-bin}; stem=${stem%-git}; stem=${stem%-desktop}
    names=("$p" "$stem" "${stem%%-*}")
    for b in "${bins[@]}"; do names+=("${b##*/}"); done
    h=0
    for b in "${bins[@]}"; do
      t=$(hist_ts "${b##*/}")
      ((t > h)) && h=$t
    done
    r=$(run_ts "${bins[@]}")
    c=$(cfg_ts "${names[@]}")
    sv=$(svc_active "$p")
    raw=$(expac -H M '%m' "$p" | awk '{print $1}')
    inst=$(expac --timefmt=%Y-%m-%d '%l' "$p")
    desc=$(expac '%d' "$p" | cut -c1-46)
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$h" "$r" "$c" "$raw" "$inst" "$p" "$kind" "$desc" "$sv"
  done < <(mine)
}

# Second pass: a backup/indexer/rebuild-detector reads every binary within a
# few minutes. If 30+ scanned packages share the same 10-minute atime bucket,
# mark that signal "r?" and don't count it as use. Real use is spread out.
# Emits: sortkey LAST SIG SIZE INSTALLED PKG KIND DESC rawsize (tab-separated).
finish_rows() {
  awk -F'\t' -v OFS='\t' '
    function day(t) { return strftime("%Y-%m-%d", t) }
    function bucket(t) { return int(t/600) }
    { rows[NR]=$0; if ($2>0) n[bucket($2)]++ }
    END {
      for (i=1;i<=NR;i++) {
        split(rows[i], f, "\t"); h=f[1]+0; r=f[2]+0; c=f[3]+0
        sig=""; last=0
        if (h>0) { sig=sig "h"; if (h>last) last=h }
        if (r>0) { if (n[bucket(r)]>=30) sig=sig "r?"; else { sig=sig "r"; if (r>last) last=r } }
        if (c>0) { sig=sig "c"; if (c>last) last=c }
        if (f[9]+0==1) { sig=sig "s"; last=systime() }
        if (sig=="") sig="-"
        key=last; if (f[7]=="sys") key=9999999999
        lastd=(last>0) ? day(last) : "never"
        if (f[9]+0==1) lastd="running"
        sz=(f[4]<10) ? sprintf("%.1fM", f[4]) : sprintf("%.0fM", f[4])
        print key, lastd, sig, sz, f[5], f[6], f[7], f[8], f[4]
      } }'
}

scan() { scan_raw "${1:-0}" | finish_rows | sort -t$'\t' -k1,1n -k9,9rn; }

ROW='{printf "%-11s %-4s %-7s %-11s %-28s %-4s %s\n", $2,$3,$4,$5,$6,$7,$8}'

cmd_list() {
  local all=0
  [[ ${1:-} == --all ]] && all=1
  local n
  n=$(mine | wc -l)
  echo "your explicit packages not in Omarchy base: $n   signals: h=shell history r=binary atime c=config dir s=service running   (lib hidden unless --all)"
  printf '%-11s %-4s %-7s %-11s %-28s %-4s %s\n' LAST SIG SIZE INSTALLED PACKAGE KIND DESCRIPTION
  scan "$all" | awk -F'\t' "$ROW"
}

cmd_review() {
  need fzf fzf
  local all=0
  [[ ${1:-} == --all ]] && all=1
  local sel
  sel=$(scan "$all" | awk -F'\t' "$ROW" |
    fzf -m --header 'TAB = mark, ENTER = remove marked (pacman -Rns), ESC = abort' \
      --preview 'pacman -Qi {5}' --preview-window=right:55% |
    awk '{print $5}')
  [[ -n $sel ]] || { echo "nothing selected"; return 0; }
  echo "removing: $(tr '\n' ' ' <<<"$sel")"
  # shellcheck disable=SC2086
  sudo pacman -Rns $sel
}

# Toolchain a source-built AUR package compiles with, read from the cached PKGBUILD.
build_tool() {
  local pb=$HOME/.cache/yay/$1/PKGBUILD t=""
  [[ -f $pb ]] || { echo "?"; return; }
  grep -qE 'cargo (build|fetch|install)' "$pb" && t="cargo"
  grep -qE '\bgo build\b|makedepends=.*\bgo\b' "$pb" && t="${t:+$t,}go"
  grep -qE 'cmake|meson|ninja|\bmake\b' "$pb" && t="${t:+$t,}cmake/make"
  grep -qE 'npm |pnpm |yarn |electron' "$pb" && t="${t:+$t,}node"
  grep -qE 'python -m build|setup\.py' "$pb" && t="${t:+$t,}python"
  grep -qE 'dkms' "$pb" && t="${t:+$t,}dkms"
  echo "${t:-data}"
}

cmd_aur() {
  local check=0
  [[ ${1:-} == --bin ]] && check=1
  echo "AUR packages built from source (yay rebuilds these on every version bump; cargo/go/node/electron ones are the slow updates):"
  printf '%-28s %-7s %-14s %-20s %s\n' PACKAGE SIZE BUILDS_WITH "REQUIRED BY" NOTE
  local p size req note tool
  while read -r p; do
    size=$(expac -H M '%m' "$p" | awk '{printf "%.0fM", $1}')
    req=$(pacman -Qi "$p" | awk -F': *' '/^Required By/{print $2}' | cut -c1-20)
    tool=$(build_tool "$p")
    note=""
    [[ $tool == *dkms* ]] && note="rebuilds on every kernel update"
    [[ $p == *-git ]] && note="${note:+$note; }-git: rebuilds on every upstream commit"
    if ((check)) && command -v yay >/dev/null; then
      if timeout 15 yay -Si "${p%-git}-bin" >/dev/null 2>&1; then note="${p%-git}-bin exists: yay -S ${p%-git}-bin"; fi
    fi
    printf '%-28s %-7s %-14s %-20s %s\n' "$p" "$size" "$tool" "$req" "$note"
  done < <(pacman -Qmq | grep -vE -- '-bin$')
  echo
  echo "yay build cache: $(du -sh "$HOME/.cache/yay" 2>/dev/null | cut -f1)   (clear: yay -Sc)"
  ((check)) || echo "add --bin to ask AUR which ones have a prebuilt -bin variant (network, ~1s each)"
}

cmd_orphans() {
  local o opt
  o=$(pacman -Qdtq 2>/dev/null || true)
  opt=$(comm -13 <(echo "$o" | sort) <(pacman -Qdttq 2>/dev/null | sort))
  if [[ -z $o ]]; then
    echo "no orphans"
  else
    echo "orphans (installed as dependency, nothing needs them):"
    echo "$o" | sed 's/^/  /'
    echo "  remove: sudo pacman -Rns \$(pacman -Qdtq)"
  fi
  echo
  if [[ -n $opt ]]; then
    echo "optional-only deps (installed as dependency, only an optional dependency of something; remove by name):"
    local p
    while read -r p; do
      printf '  %-28s %-8s optional for: %s\n' "$p" "$(expac -H M '%m' "$p" | awk '{printf "%.0fM", $1}')" "$(pacman -Qi "$p" | awk -F': *' '/^Optional For/{print $2}' | cut -c1-50)"
    done <<<"$opt"
    echo "  remove: sudo pacman -Rns PKG"
  fi
}

cmd_big() {
  local n=${1:-25}
  expac -H M '%m\t%n\t%d' | sort -rn | head -n "$n" | awk -F'\t' '{printf "%8.0f MiB  %-28s %s\n", $1, $2, substr($3,1,50)}'
}

case "${1:-list}" in
list) shift; cmd_list "$@" ;;
--all) cmd_list --all ;;
review) shift; cmd_review "$@" ;;
aur) shift; cmd_aur "$@" ;;
orphans) cmd_orphans ;;
big) shift; cmd_big "$@" ;;
-h | --help | help) sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//' ;;
*) die "unknown command '$1' (list | review | aur | orphans | big)" ;;
esac
