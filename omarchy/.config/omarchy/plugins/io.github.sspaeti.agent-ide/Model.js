.pragma library

// Pure logic of the Agent-IDE bar indicator: no Quickshell imports, tested with plain node
// (test/*.test.js). Inputs are already-read data, so nothing here touches the disk or the clock.

var STALE_SECONDS = 90
var MAX_ROWS = 20
var NAMES = ["", "ok", "running", "review", "input"]
var FALLBACK_COLORS = { green: "#9ece6a", yellow: "#e0af68", orange: "#ff9e64", violet: "#a277ff" }
var STATE_RANK = { waiting: 0, review: 1, busy: 2 }

// Text from other programs ends up in Text elements: strip tags and control characters.
function plainText(s) {
  return String(s == null ? "" : s)
    .replace(/<[^>]*>/g, "")
    .replace(/[\u0000-\u001f\u007f-\u009f]+/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 200)
}

function isObject(v) {
  return v !== null && typeof v === "object" && !Array.isArray(v)
}

// collect.sh prints one line per status file: "<pid>\t<alive 0|1>\t<json on one line>".
// A file whose JSON does not parse (half-written, garbage) keeps its line with data = null.
function parseStatusLines(text) {
  var out = []
  var lines = String(text == null ? "" : text).split("\n")
  for (var i = 0; i < lines.length; i++) {
    var m = /^(\d+)\t([01])\t(.*)$/.exec(lines[i])
    if (!m) continue
    var data = null
    try {
      data = JSON.parse(m[3])
    } catch (e) {
      data = null
    }
    out.push({ pid: Number(m[1]), alive: m[2] === "1", data: data })
  }
  return out
}

// `claude agents --json` output: an array, or null when the text is not usable (so the caller can keep older data).
function parseOutside(text) {
  try {
    var v = JSON.parse(String(text == null ? "" : text))
    return Array.isArray(v) ? v : null
  } catch (e) {
    return null
  }
}

function fileUsable(f, now) {
  if (!isObject(f) || !f.alive || !isObject(f.data)) return false
  var d = f.data
  if (d.version !== 1 || typeof d.level !== "number" || d.level < 1 || d.level > 4) return false
  if (!Array.isArray(d.sessions)) return false
  if (d.level > 1) {
    // A Neovim that crashed (or hung) leaves its last words behind; a heartbeat keeps live ones fresh.
    // A timestamp far in the future (clock jump) cannot be trusted either.
    if (typeof d.updated !== "number" || Math.abs(now - d.updated) > STALE_SECONDS) return false
  }
  return true
}

function rowState(state) {
  if (state === "waiting") return "waiting"
  if (state === "done" || state === "failed") return "review"
  if (state === "busy") return "busy"
  return null // idle, parked, anything unknown: nothing to show
}

function basename(p) {
  var parts = String(p == null ? "" : p).split("/").filter(function (x) { return x !== "" })
  return parts.length ? parts[parts.length - 1] : ""
}

function posPid(v) {
  return typeof v === "number" && isFinite(v) && v > 0 && Math.floor(v) === v ? v : 0
}

// files: [{ pid, alive, data }] (see parseStatusLines); outside: array from `claude agents --json`.
// Counts are derived from the de-duplicated rows. The counters inside the status files are not summed: a Neovim
// also counts the sessions it does not own (status.lua adds the live map), so adding them up and then adding the
// outside list would count the same tmux session once per Neovim.
function aggregate(files, outside, now) {
  var usable = []
  var list = Array.isArray(files) ? files : []
  for (var i = 0; i < list.length; i++) if (fileUsable(list[i], now)) usable.push(list[i])

  var outsideById = {}
  var outsideList = Array.isArray(outside) ? outside : []
  for (var o = 0; o < outsideList.length; o++) {
    var e = outsideList[o]
    if (isObject(e) && typeof e.sessionId === "string" && e.sessionId !== "") outsideById[e.sessionId] = e
  }

  var seenIds = {}
  var best = {} // id -> candidate
  for (var u = 0; u < usable.length; u++) {
    var f = usable[u]
    for (var k = 0; k < f.data.sessions.length; k++) {
      var s = f.data.sessions[k]
      if (!isObject(s)) continue
      var hasId = typeof s.id === "string" && s.id !== ""
      var key = hasId ? s.id : f.pid + "#" + k
      if (hasId) seenIds[s.id] = true
      var state = rowState(s.state)
      var rank = state === null ? 9 : STATE_RANK[state]
      var cand = { key: key, state: state, rank: rank, updated: typeof f.data.updated === "number" ? f.data.updated : 0, file: f, s: s, hasId: hasId }
      var cur = best[key]
      if (!cur || cand.rank < cur.rank || (cand.rank === cur.rank && cand.updated > cur.updated)) best[key] = cand
    }
  }

  var rows = []
  for (var key2 in best) {
    var c = best[key2]
    if (c.state === null) continue
    var out = c.hasId ? outsideById[c.s.id] : null
    var jump = []
    if (out && posPid(out.pid)) jump.push(out.pid)
    if (posPid(c.file.pid)) jump.push(c.file.pid)
    rows.push({
      id: c.hasId ? c.s.id : key2,
      state: c.state,
      project: plainText(c.s.project),
      title: plainText(c.s.title),
      reason: c.state === "waiting" ? plainText(c.s.reason) : "",
      source: "nvim",
      nvimPid: c.file.pid,
      jumpPids: jump,
    })
  }
  for (var id in outsideById) {
    if (seenIds[id]) continue
    var oe = outsideById[id]
    var st = oe.status === "waiting" ? "waiting" : oe.status === "busy" ? "busy" : null
    if (st === null) continue
    rows.push({
      id: id,
      state: st,
      project: plainText(basename(oe.cwd)),
      title: plainText(oe.name),
      reason: "",
      source: "tmux",
      nvimPid: 0,
      jumpPids: posPid(oe.pid) ? [oe.pid] : [],
    })
  }

  var waiting = 0, review = 0, busy = 0
  for (var r = 0; r < rows.length; r++) {
    if (rows[r].state === "waiting") waiting++
    else if (rows[r].state === "review") review++
    else busy++
  }
  var level = waiting > 0 ? 4 : review > 0 ? 3 : busy > 0 ? 2 : 1

  rows.sort(function (a, b) {
    return STATE_RANK[a.state] - STATE_RANK[b.state]
      || cmp(a.project, b.project) || cmp(a.title, b.title) || cmp(a.id, b.id)
  })
  if (rows.length > MAX_ROWS) rows = rows.slice(0, MAX_ROWS)
  for (var n = 0; n < rows.length; n++) rows[n].flat = n

  return { level: level, name: NAMES[level], waiting: waiting, review: review, busy: busy, rows: rows, groups: groupRows(rows) }
}

function cmp(a, b) {
  return a < b ? -1 : a > b ? 1 : 0
}

// One group per Neovim (by pid), the sessions that run outside Neovim last.
function groupRows(rows) {
  var byPid = {}
  var pids = []
  var tmux = []
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i]
    if (row.source === "tmux") {
      tmux.push(row)
      continue
    }
    if (!byPid[row.nvimPid]) {
      byPid[row.nvimPid] = []
      pids.push(row.nvimPid)
    }
    byPid[row.nvimPid].push(row)
  }
  pids.sort(function (a, b) { return a - b })
  var groups = pids.map(function (p) { return { label: groupLabel(byPid[p]), rows: byPid[p] } })
  if (tmux.length) groups.push({ label: "tmux / other", rows: tmux })
  return groups
}

// "Neovim · proj" / "Neovim · a, b" for one or two distinct projects, else "Neovim · n projects".
function groupLabel(rows) {
  var seen = {}
  var names = []
  for (var i = 0; i < rows.length; i++) {
    var p = rows[i].project
    if (p !== "" && !seen[p]) {
      seen[p] = true
      names.push(p)
    }
  }
  names.sort()
  if (names.length === 0) return "Neovim"
  if (names.length <= 2) return "Neovim · " + names.join(", ")
  return "Neovim · " + names.length + " projects"
}

// Index of the selected row after the rows changed: follow the session id; if it is gone, the nearest valid index.
function selectedIndex(rows, id, prevIndex) {
  var list = Array.isArray(rows) ? rows : []
  if (list.length === 0) return 0
  for (var i = 0; i < list.length; i++) if (list[i].id === id) return i
  var p = typeof prevIndex === "number" ? prevIndex : 0
  return Math.max(0, Math.min(p, list.length - 1))
}

// Text next to the dot: the waiting count at level 4, the review count at level 3, nothing otherwise.
function badge(agg) {
  if (!agg) return ""
  if (agg.level === 4) return String(agg.waiting)
  if (agg.level === 3) return String(agg.review)
  return ""
}

function tooltip(agg) {
  var parts = []
  if (agg && agg.waiting > 0) parts.push(agg.waiting + " waiting for input")
  if (agg && agg.review > 0) parts.push(agg.review + " to review")
  if (agg && agg.busy > 0) parts.push(agg.busy + " running")
  return parts.length ? parts.join(" · ") : "All agents idle"
}

// colors.toml of the active Omarchy theme: green, yellow, orange, magenta (used as violet; a `violet` key wins).
function parseThemeColors(text) {
  var out = { green: FALLBACK_COLORS.green, yellow: FALLBACK_COLORS.yellow, orange: FALLBACK_COLORS.orange, violet: FALLBACK_COLORS.violet }
  var found = {}
  var lines = String(text == null ? "" : text).split("\n")
  for (var i = 0; i < lines.length; i++) {
    var m = /^\s*(green|yellow|orange|magenta|violet)\s*=\s*["'](#[0-9a-fA-F]{6})["']/.exec(lines[i])
    if (m) found[m[1]] = m[2]
  }
  if (found.green) out.green = found.green
  if (found.yellow) out.yellow = found.yellow
  if (found.orange) out.orange = found.orange
  if (found.magenta) out.violet = found.magenta
  if (found.violet) out.violet = found.violet
  return out
}

function colorFor(level, colors) {
  return level === 4 ? colors.violet : level === 3 ? colors.orange : level === 2 ? colors.yellow : colors.green
}

if (typeof module !== "undefined") {
  module.exports = {
    STALE_SECONDS: STALE_SECONDS,
    MAX_ROWS: MAX_ROWS,
    FALLBACK_COLORS: FALLBACK_COLORS,
    parseStatusLines: parseStatusLines,
    parseOutside: parseOutside,
    aggregate: aggregate,
    badge: badge,
    groupLabel: groupLabel,
    selectedIndex: selectedIndex,
    tooltip: tooltip,
    parseThemeColors: parseThemeColors,
    colorFor: colorFor,
    plainText: plainText,
  }
}
