#!/bin/bash
# Rebuild backgrounds/ for every pics-* theme from manifest.txt (slug|mode|path relative to SRC).
# mode: link = symlink original, crop = auto-orient + centre-crop 16:10, orient = bake EXIF rotation.
# Then regenerate colors.toml/icons.theme with gen_colors.py.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
SRC="$HOME/Simon/Sync/Pics/Desktop"
T="$HOME/.config/omarchy/themes"
cut -d'|' -f1 "$HERE/manifest.txt" | sort -u | while read -r slug; do rm -rf "$T/pics-$slug/backgrounds"; mkdir -p "$T/pics-$slug/backgrounds"; done
while IFS='|' read -r slug mode rel; do
  d="$T/pics-$slug/backgrounds"; f="$SRC/$rel"; base=$(basename "$f")
  [[ -f $f ]] || { echo "MISSING: $rel"; continue; }
  case $mode in
    link)   ln -s "$f" "$d/$base" ;;
    crop)   magick "$f" -auto-orient -gravity center -crop 16:10 +repage -quality 92 "$d/${base%.*}-crop.jpg" ;;
    orient) magick "$f" -auto-orient -quality 92 "$d/${base%.*}.jpg" ;;
  esac
done < "$HERE/manifest.txt"
python3 "$HERE/gen_colors.py"
