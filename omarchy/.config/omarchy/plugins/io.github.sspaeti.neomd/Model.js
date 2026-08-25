.pragma library

// Sanitized because widget Text elements may use AutoText, which would
// rich-text-parse crafted strings coming from mail headers.
function plainText(s) {
  return String(s == null ? "" : s).replace(/<[^>]*>/g, "")
}

// Qt's MarkdownText goes through rich text, which FETCHES and renders remote
// ![](url) images — huge logos in the popup, and every spy pixel gets pinged.
// The TUI (glamour) renders images as text on purpose; match that here:
//   ![alt](url)  -> "🖼 alt"   (plain text, nothing is downloaded)
//   ![](url)     -> removed    (no alt = decoration or tracking pixel)
//   [![alt](img)](href) collapses to a normal [🖼 alt](href) link
// <img> tags that survive in the markdown are stripped the same way.
function sanitizeBody(md) {
  return String(md == null ? "" : md)
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, function(_, alt) {
      alt = alt.trim()
      return alt === "" ? "" : "🖼 " + alt
    })
    .replace(/<img\b[^>]*\balt="([^"]+)"[^>]*>/gi, "🖼 $1")
    .replace(/<img\b[^>]*>/gi, "")
    // Image-only links whose image was dropped leave "[](href)" — remove.
    .replace(/\[\s*\]\([^)]*\)/g, "")
}

// "Jane Doe <jane@example.com>" -> "Jane Doe"; bare address -> "jane"
function senderName(from) {
  var s = String(from || "")
  var i = s.indexOf("<")
  if (i > 0) {
    var name = s.slice(0, i).trim().replace(/^"|"$/g, "")
    if (name !== "") return name
  }
  var addr = senderAddr(s)
  var at = addr.indexOf("@")
  return at > 0 ? addr.slice(0, at) : addr
}

// "Jane Doe <jane@example.com>" -> "jane@example.com"
function senderAddr(from) {
  var s = String(from || "")
  var m = s.match(/<([^>]+)>/)
  return (m ? m[1] : s).trim()
}

// RFC3339 -> "8m" / "2h" / "3d" / "Aug 2"
function relTime(iso, now) {
  var d = new Date(String(iso))
  if (isNaN(d.getTime())) return ""
  now = now || new Date()
  var mins = Math.floor((now.getTime() - d.getTime()) / 60000)
  if (mins < 1) return "now"
  if (mins < 60) return mins + "m"
  var hours = Math.floor(mins / 60)
  if (hours < 24) return hours + "h"
  var days = Math.floor(hours / 24)
  if (days < 7) return days + "d"
  return Qt.formatDateTime(d, "MMM d")
}

function folderByName(data, name) {
  var list = data && data.folders ? data.folders : []
  for (var i = 0; i < list.length; i++)
    if (list[i].name === name) return list[i]
  return null
}

function unreadCount(folder) {
  var rows = folder && folder.emails ? folder.emails : []
  var n = 0
  for (var i = 0; i < rows.length; i++)
    if (rows[i].unread) n++
  return n
}

function updatedLabel(iso) {
  var d = new Date(String(iso))
  if (isNaN(d.getTime())) return ""
  return Qt.formatDateTime(d, "HH:mm")
}
