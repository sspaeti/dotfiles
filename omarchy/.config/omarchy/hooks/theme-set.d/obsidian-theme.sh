#!/bin/bash
# Switch Obsidian to a dedicated community theme when the Omarchy theme
# has a better native counterpart; anything else falls back to the
# auto-synced "Omarchy" theme. Also align Obsidian's base color scheme
# (dark "obsidian" / light "moonstone") with the Omarchy theme mode: the
# synced Omarchy theme.css only overrides some variables, so a dark theme on
# top of the light base scheme leaves form fields and buttons white.
#
# Written straight to each vault's appearance.json: Obsidian watches that
# file and applies changes live. The CLI `eval` route is not used because it
# ignores vault= and only ever hits the last-focused window.

THEME_SLUG="$1"

case "$THEME_SLUG" in
kanagawa) OBSIDIAN_THEME="Kanagawa" ;;
osaka-jade) OBSIDIAN_THEME="Osaka Jade" ;;
gruvbox) OBSIDIAN_THEME="Obsidian gruvbox" ;;
*) OBSIDIAN_THEME="Omarchy" ;;
esac

# colors.toml mode = "light" | "dark" (hook runs after current/theme is swapped)
if [[ $(omarchy-theme-color mode dark 2>/dev/null) == "light" ]]; then
  BASE_THEME="moonstone"
else
  BASE_THEME="obsidian"
fi

jq -r '.vaults | values[].path' ~/.config/obsidian/obsidian.json 2>/dev/null | while read -r vault_path; do
  appearance="$vault_path/.obsidian/appearance.json"
  [[ -f $appearance ]] || continue
  tmp=$(mktemp)
  jq --arg t "$OBSIDIAN_THEME" --arg b "$BASE_THEME" '.cssTheme = $t | .theme = $b' "$appearance" >"$tmp" && mv "$tmp" "$appearance"
done
