.pragma library

// Sanitized because widget Text elements may use AutoText, which would
// rich-text-parse crafted strings coming from the network.
function plainText(s) {
  return String(s == null ? "" : s).replace(/<[^>]*>/g, "")
}

function fmtCount(n) {
  n = Number(n) || 0
  if (n >= 1000000) return (n / 1000000).toFixed(1).replace(/\.0$/, "") + "M"
  if (n >= 10000) return Math.round(n / 1000) + "k"
  if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "k"
  return String(n)
}

// "2026-08-21" -> "Fri 21"
function dayLabel(iso) {
  var d = new Date(String(iso) + "T12:00:00")
  if (isNaN(d.getTime())) return String(iso)
  return Qt.formatDateTime(d, "ddd d")
}

function maxCount(rows) {
  var m = 0
  for (var i = 0; i < (rows || []).length; i++)
    m = Math.max(m, Number(rows[i].count) || 0)
  return m
}

function updatedLabel(iso) {
  var d = new Date(String(iso))
  if (isNaN(d.getTime())) return ""
  return Qt.formatDateTime(d, "HH:mm")
}

// Optional display-name override from the "siteLabels" setting.
function displayLabel(site, labelMap) {
  var label = String(site && site.label || "")
  if (labelMap && labelMap[label]) label = String(labelMap[label])
  return plainText(label)
}

function isSubsequence(q, s) {
  var j = 0
  for (var i = 0; i < s.length && j < q.length; i++)
    if (s[i] === q[j]) j++
  return j === q.length
}

// fzf-style page search over the full path list: prefix and substring
// matches on the path (or a substring match on the page title) rank above
// scattered subsequence matches; ties prefer shorter paths.
function fuzzyPaths(paths, query) {
  query = String(query || "").toLowerCase().trim()
  if (query === "") return []
  var out = []
  for (var i = 0; i < (paths || []).length; i++) {
    var p = paths[i]
    var path = String(p.path || "").toLowerCase()
    var title = String(p.title || "").toLowerCase()
    var idx = path.indexOf(query)
    var rank
    if (idx === 0) rank = 0
    else if (idx > 0) rank = 1
    else if (title.indexOf(query) >= 0) rank = 1
    else if (isSubsequence(query, path)) rank = 2
    else continue
    out.push({ id: p.id, name: p.path, rank: rank })
  }
  out.sort(function(a, b) {
    return a.rank - b.rank || a.name.length - b.name.length
  })
  return out.slice(0, 10)
}

// Bar pill hover label, always the weekly totals: "ssp.sh 13.9k · dedp 456"
function compactLabel(sites, labelMap) {
  var parts = []
  for (var i = 0; i < (sites || []).length; i++) {
    var s = sites[i]
    if (s.error || !s.ranges || !s.ranges["7"]) continue
    parts.push(displayLabel(s, labelMap) + " " + fmtCount(s.ranges["7"].total))
  }
  return parts.join(" · ")
}
