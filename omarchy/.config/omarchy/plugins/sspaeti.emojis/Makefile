# sspaeti.emojis — Nerd Fonts dataset maintenance.
# Source: https://github.com/ryanoasis/nerd-fonts (glyphnames.json, MIT).
# Picker code adapted from https://github.com/farangkao/omarchy-emojis-nerd (MIT).

.PHONY: update check test

## Regenerate nerdfonts.tsv from the newest Nerd Fonts release (applies on next search, no restart)
update:
	./update-nerdfonts.py

## Compare the installed dataset with the newest release, write nothing
check:
	./update-nerdfonts.py --check

## Sanity-check nerdfonts.tsv and the search helpers
test:
	@LC_ALL=C awk -F'\t' 'NF != 3 || $$3 !~ /^[0-9a-f]+$$/ { print "malformed row " NR; exit 1 }' nerdfonts.tsv
	@LC_ALL=C grep -qP '[^\x00-\x7f]' nerdfonts.tsv && { echo "nerdfonts.tsv must be pure ASCII"; exit 1; } || true
	@grep -qP '\tnf-md-home\t' nerdfonts.tsv || { echo "nf-md-home row missing"; exit 1; }
	@node -e 'const S=require("./EmojiSearch.js");const a=require("assert");a.strictEqual(S.parseTsvLine("home md-home nf-md-home\tnf-md-home\tf02dc").n,"nf-md-home");a.strictEqual(S.filterTsvRows(["x\ty\tea60","bad"],["x"],10).length,1);a.strictEqual(S.glyphFromHex("f0a02"),String.fromCodePoint(0xf0a02))'
	@echo "ok: $$(wc -l < nerdfonts.tsv) glyphs, version $$(cat NERDFONTS_VERSION 2>/dev/null || echo unknown)"
