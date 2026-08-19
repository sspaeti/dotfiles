#!/bin/bash
# Switch Obsidian to a dedicated community theme when the Omarchy theme
# has a better native counterpart; anything else falls back to the
# auto-synced "Omarchy" theme.

THEME_SLUG="$1"

case "$THEME_SLUG" in
kanagawa) OBSIDIAN_THEME="Kanagawa" ;;
osaka-jade) OBSIDIAN_THEME="Osaka Jade" ;;
gruvbox) OBSIDIAN_THEME="Obsidian gruvbox" ;;
*) OBSIDIAN_THEME="Omarchy" ;;
esac

# The /bin/obsidian wrapper injects user-flags.conf flags before CLI args,
# which breaks Obsidian's CLI parsing — so call electron directly.
ELECTRON=$(awk '/^exec electron/ {print $2}' /bin/obsidian 2>/dev/null)
ELECTRON=${ELECTRON:-electron43}

# Obsidian running: switch live via its CLI (persists to appearance.json).
if pgrep -f '/usr/lib/obsidian/app.asar' >/dev/null; then
  "$ELECTRON" /usr/lib/obsidian/app.asar eval \
    code="app.customCss.setTheme('$OBSIDIAN_THEME')" >/dev/null 2>&1 && exit 0
fi

# Obsidian closed: write appearance.json for every vault directly.
jq -r '.vaults | values[].path' ~/.config/obsidian/obsidian.json 2>/dev/null | while read -r vault_path; do
  appearance="$vault_path/.obsidian/appearance.json"
  [[ -f $appearance ]] || continue
  tmp=$(mktemp)
  jq --arg t "$OBSIDIAN_THEME" '.cssTheme = $t' "$appearance" >"$tmp" && mv "$tmp" "$appearance"
done
