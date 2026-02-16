#!/bin/bash
# Generates a categorized OPML from:
#   - urls file (for tag/category mapping)
#   - urls.opml (exported via `newsboat -e`, has proper titles)
#
# Usage: ./export-opml-with-categories.sh > feeds-categorized.opml
# Then import into Miniflux: Settings > Import > OPML file

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
URLS_FILE="$SCRIPT_DIR/urls"
OPML_FILE="$SCRIPT_DIR/urls.opml"

if [[ ! -f "$URLS_FILE" ]]; then
    echo "Error: $URLS_FILE not found (run 'make decrypt' first?)" >&2
    exit 1
fi
if [[ ! -f "$OPML_FILE" ]]; then
    echo "Error: $OPML_FILE not found (run 'newsboat -e > urls.opml' first)" >&2
    exit 1
fi

# Build URL -> tag mapping from urls file
declare -A url_tags
while IFS= read -r line; do
    # Skip empty lines, comments, query feeds, separators
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" =~ ^\"query: || "$line" == "---" ]] && continue

    # Extract URL (first non-whitespace token)
    url=$(echo "$line" | awk '{print $1}')
    [[ ! "$url" =~ ^https?:// ]] && continue

    # Extract tags: words after URL that aren't ! or quoted strings
    tags=()
    skip_url=true
    in_quote=false
    for word in $line; do
        if $skip_url; then skip_url=false; continue; fi
        # Skip ! (hidden marker)
        [[ "$word" == "!" ]] && continue
        # Skip quoted strings (titles like "~My Title")
        if [[ "$word" =~ ^\" ]]; then in_quote=true; fi
        if $in_quote; then
            [[ "$word" =~ \"$ ]] && in_quote=false
            continue
        fi
        tags+=("$word")
    done

    # Use first tag as category; default to "uncategorized"
    url_tags["$url"]="${tags[0]:-uncategorized}"
done < "$URLS_FILE"

# Parse OPML and group by category
declare -A category_entries
while IFS= read -r line; do
    # Extract xmlUrl
    if [[ "$line" =~ xmlUrl=\"([^\"]+)\" ]]; then
        xml_url="${BASH_REMATCH[1]}"
        # Skip separator entries
        [[ "$xml_url" == "---" ]] && continue

        category="${url_tags[$xml_url]:-uncategorized}"

        # Unescape &amp; in URL for lookup fallback
        if [[ "$category" == "uncategorized" && "$xml_url" =~ \&amp\; ]]; then
            plain_url="${xml_url//&amp;/&}"
            category="${url_tags[$plain_url]:-uncategorized}"
        fi

        category_entries["$category"]+="    $line"$'\n'
    fi
done < "$OPML_FILE"

# Output categorized OPML
cat << 'HEADER'
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>Newsboat Feeds (with categories)</title>
  </head>
  <body>
HEADER

for cat in $(echo "${!category_entries[@]}" | tr ' ' '\n' | sort); do
    echo "    <outline text=\"$cat\" title=\"$cat\">"
    echo -n "${category_entries[$cat]}"
    echo "    </outline>"
done

cat << 'FOOTER'
  </body>
</opml>
FOOTER
