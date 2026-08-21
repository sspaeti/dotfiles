// Pure timezone/formatting logic for the timezones widget. All math works on
// UTC-offset minutes fetched from tzdata via `date`; no Date-local calls, so
// the same instant renders consistently for every configured zone.

// "+0200" / "-0930" → signed minutes east of UTC.
function parseUtcOffset(text) {
  var m = /^([+-])(\d{2}):?(\d{2})$/.exec(String(text || "").trim())
  if (!m) return null
  var minutes = parseInt(m[2], 10) * 60 + parseInt(m[3], 10)
  return m[1] === "-" ? -minutes : minutes
}

// Output of the offsets probe: one "<key> <±HHMM> <ABBR>" line per zone.
function parseOffsetLines(text) {
  var result = {}
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var parts = lines[i].trim().split(/\s+/)
    if (parts.length < 2) continue
    var offset = parseUtcOffset(parts[1])
    if (offset === null) continue
    result[parts[0]] = { offsetMin: offset, abbr: parts.length > 2 ? parts[2] : "" }
  }
  return result
}

// UTC ms of the home zone's most recent local midnight — column 0 of the grid.
function homeDayStartUtc(nowUtcMs, homeOffsetMin) {
  var dayMs = 24 * 3600000
  var localMs = nowUtcMs + homeOffsetMin * 60000
  return localMs - (((localMs % dayMs) + dayMs) % dayMs) - homeOffsetMin * 60000
}

// Local wall-clock fields of a UTC instant in a fixed-offset zone.
function localFields(utcMs, offsetMin) {
  var d = new Date(utcMs + offsetMin * 60000)
  return {
    hour: d.getUTCHours(),
    day: d.getUTCDate(),
    weekday: d.getUTCDay(),
    month: d.getUTCMonth(),
    minute: d.getUTCMinutes()
  }
}

var WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

// One grid cell: the zone-local hour at home-day column `col`.
function cell(col, dayStartUtcMs, offsetMin) {
  var f = localFields(dayStartUtcMs + col * 3600000, offsetMin)
  return {
    hour: f.hour,
    isMidnight: f.hour === 0,
    dayLabel: WEEKDAYS[f.weekday] + " " + f.day,
    tint: tintFor(f.hour)
  }
}

// Visual band for a cell: business hours pop, waking hours mid, night dark.
function tintFor(hour) {
  if (hour >= 8 && hour < 18) return "work"
  if (hour >= 6 && hour < 23) return "day"
  return "night"
}

// Configurable strings (icon, labels, abbreviations) are rendered by Text
// elements whose default AutoText format detects rich text — strip the
// characters that could smuggle markup (e.g. <img src=...>) into the
// long-lived shell process.
function plainText(value) {
  return String(value === null || value === undefined ? "" : value).replace(/[<>&]/g, "")
}

function pad2(n) {
  return (n < 10 ? "0" : "") + n
}

// "07:12" for a zone right now.
function timeLabel(nowUtcMs, offsetMin) {
  var f = localFields(nowUtcMs, offsetMin)
  return pad2(f.hour) + ":" + pad2(f.minute)
}

// "Thu 21 Aug" style date for the row header.
var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
function dateLabel(nowUtcMs, offsetMin) {
  var f = localFields(nowUtcMs, offsetMin)
  return WEEKDAYS[f.weekday] + " " + f.day + " " + MONTHS[f.month]
}

// Offset relative to home: "+6h", "−9h", "+5:30", "" for home itself.
function diffLabel(offsetMin, homeOffsetMin) {
  var diff = offsetMin - homeOffsetMin
  if (diff === 0) return ""
  var sign = diff < 0 ? "−" : "+"
  var abs = Math.abs(diff)
  var h = Math.floor(abs / 60)
  var m = abs % 60
  return sign + (m === 0 ? h + "h" : h + ":" + pad2(m))
}

// Fractional column position of "now" for the vertical indicator, in [0, 24).
function nowColumn(nowUtcMs, dayStartUtcMs) {
  return (nowUtcMs - dayStartUtcMs) / 3600000
}

// Compact bar label shown on hover: "NY 07:12 · SF 04:12 · CDO 19:12".
function compactLabel(zones, nowUtcMs) {
  var parts = []
  for (var i = 0; i < zones.length; i++) {
    var z = zones[i]
    if (z.home || z.offsetMin === undefined || z.offsetMin === null) continue
    parts.push(plainText(z.shortLabel) + " " + timeLabel(nowUtcMs, z.offsetMin))
  }
  return parts.join(" · ")
}

// Fallback when the widget entry in shell.json carries no "zones" array —
// the real configuration belongs there. The home row (zone: "") tracks the
// system timezone, so travel updates it.
function defaultZones() {
  return [
    { label: "Home", shortLabel: "HOME", zone: "", home: true },
    { label: "East Coast", shortLabel: "NY", zone: "America/New_York" },
    { label: "West Coast", shortLabel: "SF", zone: "America/Los_Angeles" }
  ]
}

if (typeof module !== "undefined") {
  module.exports = {
    parseUtcOffset: parseUtcOffset,
    parseOffsetLines: parseOffsetLines,
    homeDayStartUtc: homeDayStartUtc,
    localFields: localFields,
    cell: cell,
    tintFor: tintFor,
    timeLabel: timeLabel,
    dateLabel: dateLabel,
    diffLabel: diffLabel,
    nowColumn: nowColumn,
    compactLabel: compactLabel,
    plainText: plainText,
    defaultZones: defaultZones
  }
}
