const test = require("node:test")
const assert = require("node:assert")
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")
const { spawnSync } = require("node:child_process")
const M = require("./load.js")

const SCRIPT = path.join(__dirname, "..", "collect.sh")

function run(dir) {
  const r = spawnSync("bash", [SCRIPT], { env: { PATH: process.env.PATH, AGENT_IDE_STATUS_DIR: dir }, encoding: "utf8" })
  assert.strictEqual(r.status, 0, r.stderr)
  return r.stdout
}

function tmp() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "agent-ide-test-"))
}

function status(pid, level, extra) {
  return JSON.stringify(Object.assign({ version: 1, pid, updated: Math.floor(Date.now() / 1000), level, sessions: [{ id: "s" + pid, project: "p", title: "t", state: "waiting", reason: "Bash" }] }, extra || {}))
}

test("missing directory: no output, exit 0", () => {
  assert.strictEqual(run(path.join(tmp(), "nope")), "")
})

test("empty directory: no output", () => {
  assert.strictEqual(run(tmp()), "")
})

test("alive, dead, junk and temp files", () => {
  const dir = tmp()
  const pidMax = Number(fs.readFileSync("/proc/sys/kernel/pid_max", "utf8").trim()) || 4194304
  const dead = pidMax + 12345 // above pid_max, so no process can have it
  fs.writeFileSync(path.join(dir, `status-${process.pid}.json`), status(process.pid, 4))
  fs.writeFileSync(path.join(dir, `status-${dead}.json`), status(dead, 4))
  fs.writeFileSync(path.join(dir, "status-abc.json"), "{}")
  fs.writeFileSync(path.join(dir, `status-${process.pid}.json.${process.pid}.tmp`), "{")
  fs.writeFileSync(path.join(dir, "other.json"), "{}")
  const files = M.parseStatusLines(run(dir))
  assert.deepStrictEqual(files.map((f) => [f.pid, f.alive]).sort(), [[process.pid, true], [dead, false]].sort())
  const a = M.aggregate(files, [], Math.floor(Date.now() / 1000))
  assert.deepStrictEqual([a.level, a.waiting, a.rows.length], [4, 1, 1])
})

test("a half-written file does not break the others", () => {
  const dir = tmp()
  fs.writeFileSync(path.join(dir, `status-${process.pid}.json`), '{"version":1,"pid":')
  fs.writeFileSync(path.join(dir, "status-1.json"), status(1, 2))
  const files = M.parseStatusLines(run(dir))
  const a = M.aggregate(files, [], Math.floor(Date.now() / 1000))
  assert.deepStrictEqual([a.level, a.rows.length], [4, 1]) // only the intact file (pid 1) counts
  assert.strictEqual(files.length, 2)
})

test("pretty-printed (multi-line) JSON is read as one record", () => {
  const dir = tmp()
  fs.writeFileSync(path.join(dir, `status-${process.pid}.json`), JSON.stringify(JSON.parse(status(process.pid, 4)), null, 2))
  const a = M.aggregate(M.parseStatusLines(run(dir)), [], Math.floor(Date.now() / 1000))
  assert.strictEqual(a.level, 4)
})
