function parseEmojis(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return Array.isArray(data) ? data : []
  } catch (e) {
    return []
  }
}

function normalizedQuery(query) {
  return String(query || "").trim().toLowerCase()
}

function keywordText(item) {
  return String((item && item.k) || "").toLowerCase()
}

function filterEmojis(emojis, query, limit) {
  var values = Array.isArray(emojis) ? emojis : []
  var needle = normalizedQuery(query)
  var max = limit === undefined || limit === null ? 1000 : Number(limit)
  if (isNaN(max)) max = 1000
  max = Math.max(0, max)
  if (max === 0) return []

  var out = []

  for (var i = 0; i < values.length; i++) {
    var item = values[i]
    if (!item || !item.e) continue
    if (!needle || keywordText(item).indexOf(needle) >= 0) {
      out.push(item)
      if (out.length >= max) break
    }
  }

  return out
}

// ---- Nerd Fonts tab ----
// The functions below (queryTokens, glyphFromHex, parseTsvLine,
// filterTsvRows) and the nerdfonts.tsv dataset are taken from
// "Emojis & Nerd Fonts for Omarchy" by farangkao, MIT licensed:
//   https://github.com/farangkao/omarchy-emojis-nerd
// See THIRD_PARTY_NOTICES.md in this directory.

function queryTokens(query) {
  var tokens = []
  var parts = normalizedQuery(query).split(" ")
  for (var i = 0; i < parts.length; i++) {
    if (parts[i]) tokens.push(parts[i])
  }
  return tokens
}

// Nerd Fonts spans the BMP and the astral planes (md icons live above
// U+F0000), so decode hex codepoints through surrogate pairs.
function glyphFromHex(hex) {
  var cp = parseInt(String(hex || ""), 16)
  if (!isFinite(cp) || cp <= 0 || cp > 0x10ffff) return ""
  if (cp <= 0xffff) return String.fromCharCode(cp)
  cp -= 0x10000
  return String.fromCharCode(0xd800 + (cp >> 10), 0xdc00 + (cp % 0x400))
}

// nerdfonts.tsv rows are: keywords <TAB> name <TAB> hex-codepoint.
function parseTsvLine(line) {
  var f = String(line || "").split("\t")
  if (f.length < 3) return null
  var glyph = glyphFromHex(f[2])
  return glyph ? { e: glyph, n: f[1], k: f[0].toLowerCase() } : null
}

// Rows arrive from a single-token grep prefilter; re-check the full
// token-AND here so "md home" only keeps rows containing both words.
function filterTsvRows(rows, tokens, limit) {
  var max = limit === undefined || limit === null ? 1000 : Number(limit)
  if (isNaN(max) || max < 0) max = 1000
  var out = []
  for (var i = 0; i < rows.length && out.length < max; i++) {
    var item = parseTsvLine(rows[i])
    if (!item) continue
    var matched = true
    for (var t = 0; t < tokens.length; t++) {
      if (item.k.indexOf(tokens[t]) < 0) { matched = false; break }
    }
    if (matched) out.push(item)
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    parseEmojis: parseEmojis,
    normalizedQuery: normalizedQuery,
    filterEmojis: filterEmojis,
    queryTokens: queryTokens,
    glyphFromHex: glyphFromHex,
    parseTsvLine: parseTsvLine,
    filterTsvRows: filterTsvRows
  }
}
