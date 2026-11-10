const test = require("node:test")
const assert = require("node:assert")
const M = require("./load.js")

const NOW = 1000000

function sess(id, state, extra) {
  return Object.assign({ id, project: "proj-" + id, title: "Title " + id, state, reason: "" }, extra || {})
}

function file(pid, sessions, extra) {
  const data = Object.assign({ version: 1, pid, updated: NOW - 5, level: 1, sessions }, extra || {})
  return { pid, alive: true, data }
}

function outs(sessionId, status, extra) {
  return Object.assign({ pid: 900, cwd: "/x/y/" + sessionId, kind: "interactive", startedAt: 1, sessionId, name: "N " + sessionId, status }, extra || {})
}

// Level for a file whose only content is `n` sessions per state.
function level(w, r, b) {
  const ss = []
  for (let i = 0; i < w; i++) ss.push(sess("w" + i, "waiting"))
  for (let i = 0; i < r; i++) ss.push(sess("r" + i, i % 2 ? "failed" : "done"))
  for (let i = 0; i < b; i++) ss.push(sess("b" + i, "busy"))
  const a = M.aggregate([file(1, ss, { level: 2 })], [], NOW)
  return [a.level, a.name, a.waiting, a.review, a.busy]
}

test("level for every combination of waiting/review/busy", () => {
  const names = ["", "ok", "running", "review", "input"]
  for (const w of [0, 2]) for (const r of [0, 2]) for (const b of [0, 2]) {
    const want = w > 0 ? 4 : r > 0 ? 3 : b > 0 ? 2 : 1
    assert.deepStrictEqual(level(w, r, b), [want, names[want], w, r, b], `w${w} r${r} b${b}`)
  }
})

test("empty input is green with no rows", () => {
  for (const a of [M.aggregate([], [], NOW), M.aggregate(null, undefined, NOW)]) {
    assert.strictEqual(a.level, 1)
    assert.strictEqual(a.name, "ok")
    assert.deepStrictEqual([a.waiting, a.review, a.busy, a.rows.length, a.groups.length], [0, 0, 0, 0, 0])
  }
})

test("outside sessions count: waiting and busy, idle ignored", () => {
  const a = M.aggregate([], [outs("a", "waiting"), outs("b", "busy"), outs("c", "idle"), outs("d", "busy")], NOW)
  assert.deepStrictEqual([a.level, a.waiting, a.review, a.busy, a.rows.length], [4, 1, 0, 2, 3])
})

test("outside entries with unknown shape or status are skipped", () => {
  const a = M.aggregate([], [null, 3, {}, { sessionId: 5, status: "busy" }, outs("a", "weird")], NOW)
  assert.strictEqual(a.rows.length, 0)
})

test("a session in a status file and in the outside list is counted once", () => {
  const f = file(1, [sess("s1", "waiting", { reason: "Bash" })], { level: 4 })
  const a = M.aggregate([f], [outs("s1", "waiting"), outs("s2", "busy")], NOW)
  assert.deepStrictEqual([a.waiting, a.busy, a.rows.length], [1, 1, 2])
  assert.strictEqual(a.rows.find((r) => r.id === "s1").reason, "Bash")
})

test("a session listed by two Neovims is counted once, the more urgent entry wins", () => {
  const a = M.aggregate([file(1, [sess("s", "done")], { level: 3 }), file(2, [sess("s", "parked")], { level: 1 })], [], NOW)
  assert.deepStrictEqual([a.review, a.rows.length], [1, 1])
  assert.strictEqual(a.rows[0].nvimPid, 1)
})

test("counts come from rows, not from the counters in the files", () => {
  // the counters of a Neovim also include sessions it does not own
  const f = file(1, [sess("a", "busy")], { level: 4, waiting: 5, review: 5, busy: 5 })
  const a = M.aggregate([f], [], NOW)
  assert.deepStrictEqual([a.level, a.waiting, a.review, a.busy], [2, 0, 0, 1])
})

test("states: done and failed are review, idle and parked produce no row", () => {
  const a = M.aggregate([file(1, [sess("a", "done"), sess("b", "failed"), sess("c", "idle"), sess("d", "parked"), sess("e", "x")], { level: 3 })], [], NOW)
  assert.deepStrictEqual(a.rows.map((r) => r.state).sort(), ["review", "review"])
})

test("staleness: older than 90 s is ignored while level > 1", () => {
  const busy = [sess("a", "busy")]
  assert.strictEqual(M.aggregate([file(1, busy, { level: 2, updated: NOW - 91 })], [], NOW).level, 1)
  assert.strictEqual(M.aggregate([file(1, busy, { level: 2, updated: NOW - 90 })], [], NOW).level, 2)
  assert.strictEqual(M.aggregate([file(1, busy, { level: 4, updated: NOW - 1000 })], [], NOW).level, 1)
})

test("staleness does not apply to level 1 files", () => {
  const f = file(1, [sess("a", "busy")], { level: 1, updated: NOW - 100000 })
  assert.strictEqual(M.aggregate([f], [], NOW).busy, 1)
})

test("clock skew: an updated far in the future counts as stale, a slightly future one as fresh", () => {
  const busy = [sess("a", "busy")]
  assert.strictEqual(M.aggregate([file(1, busy, { level: 2, updated: NOW + 30 })], [], NOW).level, 2)
  assert.strictEqual(M.aggregate([file(1, busy, { level: 2, updated: NOW + 5000 })], [], NOW).level, 1)
})

test("a level above 1 without a numeric updated is stale", () => {
  assert.strictEqual(M.aggregate([file(1, [sess("a", "busy")], { level: 2, updated: "now" })], [], NOW).level, 1)
})

test("dead pid files are ignored", () => {
  const f = file(1, [sess("a", "waiting")], { level: 4 })
  f.alive = false
  assert.strictEqual(M.aggregate([f], [], NOW).level, 1)
})

test("malformed file contents are ignored without throwing", () => {
  const bad = [
    { pid: 1, alive: true, data: null },
    { pid: 2, alive: true, data: "text" },
    { pid: 3, alive: true, data: [] },
    { pid: 4, alive: true, data: { version: 2, updated: NOW, level: 4, sessions: [sess("a", "waiting")] } },
    { pid: 5, alive: true, data: { version: 1, updated: NOW, level: "4", sessions: [] } },
    { pid: 6, alive: true, data: { version: 1, updated: NOW, level: 4, sessions: "nope" } },
    { pid: 7, alive: true, data: { version: 1, updated: NOW, level: 4, sessions: [null, 3, "x", { state: 5 }] } },
    null,
    undefined,
    7,
  ]
  const a = M.aggregate(bad, [], NOW)
  assert.deepStrictEqual([a.level, a.rows.length], [1, 0])
})

test("a session without id still counts, once per file position", () => {
  const f = file(1, [{ state: "waiting", project: "p", title: "t" }, { state: "waiting", project: "q", title: "u" }], { level: 4 })
  assert.strictEqual(M.aggregate([f], [], NOW).waiting, 2)
})

test("parseStatusLines: parses, skips half-written and garbage lines", () => {
  const good = JSON.stringify({ version: 1, pid: 11, updated: NOW, level: 2, sessions: [] })
  const text = [`11\t1\t${good}`, "12\t1\t{\"version\":1,\"pid\":", "13\t0\t{}", "garbage", "", "14\t1\t", "x\t1\t{}"].join("\n")
  const files = M.parseStatusLines(text)
  assert.deepStrictEqual(files.map((f) => [f.pid, f.alive, f.data === null]), [[11, true, false], [12, true, true], [13, false, false], [14, true, true]])
  assert.strictEqual(M.aggregate(files, [], NOW).level, 1)
  assert.deepStrictEqual(M.parseStatusLines(""), [])
  assert.deepStrictEqual(M.parseStatusLines(null), [])
})

test("parseOutside: array or null for anything else", () => {
  assert.deepStrictEqual(M.parseOutside("[]"), [])
  assert.strictEqual(M.parseOutside(""), null)
  assert.strictEqual(M.parseOutside("{\"a\":1}"), null)
  assert.strictEqual(M.parseOutside("[{\"pid\":"), null)
  assert.strictEqual(M.parseOutside(null), null)
  assert.strictEqual(M.parseOutside("[{\"sessionId\":\"a\"}]").length, 1)
})

test("row ordering: waiting, then review, then busy; stable inside a state", () => {
  const f1 = file(1, [sess("b1", "busy", { project: "zeta" }), sess("r1", "done", { project: "beta" }), sess("w1", "waiting", { project: "mid" })], { level: 4 })
  const f2 = file(2, [sess("w2", "waiting", { project: "alpha" }), sess("r2", "failed", { project: "alpha" })], { level: 4 })
  const a = M.aggregate([f1, f2], [outs("o1", "busy", { cwd: "/p/aaa" }), outs("o2", "waiting", { cwd: "/p/omega" })], NOW)
  assert.deepStrictEqual(a.rows.map((r) => r.id), ["w2", "w1", "o2", "r2", "r1", "o1", "b1"])
  assert.deepStrictEqual(a.rows.map((r) => r.flat), [0, 1, 2, 3, 4, 5, 6])
})

test("groups: one per Neovim, tmux last; rows keep their order inside a group", () => {
  const f1 = file(20, [sess("a", "busy")], { level: 2 })
  const f2 = file(10, [sess("b", "waiting"), sess("c", "done")], { level: 4 })
  const a = M.aggregate([f1, f2], [outs("t", "busy")], NOW)
  assert.deepStrictEqual(a.groups.map((g) => g.label), ["Neovim · proj-b, proj-c", "Neovim · proj-a", "tmux / other"])
  assert.deepStrictEqual(a.groups[0].rows.map((r) => r.id), ["b", "c"])
  assert.strictEqual(a.groups[2].rows[0].source, "tmux")
})

test("rows: project from the file, from cwd for outside, title fallback, jump pids", () => {
  const f = file(7, [sess("s", "waiting", { project: "mine", title: "", reason: "Edit" })], { level: 4 })
  const a = M.aggregate([f], [outs("s", "waiting", { pid: 555 }), outs("t", "busy", { pid: 556, cwd: "/a/b/theproj/", name: "" })], NOW)
  const s = a.rows.find((r) => r.id === "s")
  assert.deepStrictEqual([s.project, s.reason, s.source, s.jumpPids], ["mine", "Edit", "nvim", [555, 7]])
  const t = a.rows.find((r) => r.id === "t")
  assert.deepStrictEqual([t.project, t.title, t.source, t.jumpPids], ["theproj", "", "tmux", [556]])
})

test("text is stripped of tags and control characters", () => {
  const a = M.aggregate([file(1, [sess("s", "busy", { title: "<b>hi</b>\u0007 there\n", project: "p<i>" })], { level: 2 })], [], NOW)
  assert.deepStrictEqual([a.rows[0].title, a.rows[0].project], ["hi there", "p"])
})

test("rows are capped", () => {
  const ss = []
  for (let i = 0; i < 500; i++) ss.push(sess("s" + i, "busy"))
  const a = M.aggregate([file(1, ss, { level: 2 })], [], NOW)
  assert.strictEqual(a.busy, 500)
  assert.ok(a.rows.length <= M.MAX_ROWS)
})

test("badge: what the bar shows next to the dot", () => {
  const mk = (w, r, b) => M.aggregate([file(1, [].concat(
    Array.from({ length: w }, (_, i) => sess("w" + i, "waiting")),
    Array.from({ length: r }, (_, i) => sess("r" + i, "done")),
    Array.from({ length: b }, (_, i) => sess("b" + i, "busy"))), { level: 4 })], [], NOW)
  assert.strictEqual(M.badge(mk(0, 0, 0)), "")
  assert.strictEqual(M.badge(mk(0, 0, 3)), "")
  assert.strictEqual(M.badge(mk(0, 2, 3)), "2")
  assert.strictEqual(M.badge(mk(4, 2, 3)), "4")
})

test("tooltip summarises counts", () => {
  const a = M.aggregate([file(1, [sess("a", "waiting"), sess("b", "done"), sess("c", "busy")], { level: 4 })], [], NOW)
  assert.strictEqual(M.tooltip(a), "1 waiting for input · 1 to review · 1 running")
  assert.strictEqual(M.tooltip(M.aggregate([], [], NOW)), "All agents idle")
})

test("parseThemeColors: palette keys with fallbacks", () => {
  const c = M.parseThemeColors('green = "#a4cf7c"\nyellow = "#f7c96a"\nmagenta = "#d98bc4"\n# orange = "#000000"\n')
  assert.deepStrictEqual(c, { green: "#a4cf7c", yellow: "#f7c96a", orange: "#ff9e64", violet: "#d98bc4" })
  assert.deepStrictEqual(M.parseThemeColors(""), M.FALLBACK_COLORS)
  assert.deepStrictEqual(M.parseThemeColors('green = "not a color"'), M.FALLBACK_COLORS)
  assert.deepStrictEqual(M.parseThemeColors(null), M.FALLBACK_COLORS)
  assert.deepStrictEqual(M.parseThemeColors('violet = "#112233"').violet, "#112233")
})

test("colorFor maps levels", () => {
  const c = { green: "g", yellow: "y", orange: "o", violet: "v" }
  assert.deepStrictEqual([1, 2, 3, 4, 9].map((l) => M.colorFor(l, c)), ["g", "y", "o", "v", "g"])
})

test("aggregate does not depend on time while nothing is stale", () => {
  const f = file(1, [sess("a", "waiting"), sess("b", "busy")], { level: 4, updated: NOW })
  const o = [outs("t", "busy")]
  assert.deepStrictEqual(M.aggregate([f], o, NOW), M.aggregate([f], o, NOW + 60))
  assert.deepStrictEqual(M.aggregate([f], o, NOW), M.aggregate([f], o, NOW - 60))
})

test("groupLabel: one or two projects by name, more by count", () => {
  const r = (...p) => p.map((x) => ({ project: x }))
  assert.strictEqual(M.groupLabel(r("b", "a", "b")), "Neovim · a, b")
  assert.strictEqual(M.groupLabel(r("only")), "Neovim · only")
  assert.strictEqual(M.groupLabel(r("a", "b", "c")), "Neovim · 3 projects")
  assert.strictEqual(M.groupLabel(r("", "")), "Neovim")
  assert.strictEqual(M.groupLabel([]), "Neovim")
})

test("selectedIndex follows the id, else the nearest valid index", () => {
  const rows = [{ id: "a" }, { id: "b" }, { id: "c" }]
  assert.strictEqual(M.selectedIndex(rows, "c", 0), 2)
  assert.strictEqual(M.selectedIndex(rows, "gone", 1), 1)
  assert.strictEqual(M.selectedIndex(rows, "gone", 9), 2)
  assert.strictEqual(M.selectedIndex(rows, "gone", -3), 0)
  assert.strictEqual(M.selectedIndex([], "a", 4), 0)
  assert.strictEqual(M.selectedIndex(null, "a", 4), 0)
})
