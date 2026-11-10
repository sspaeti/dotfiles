// Loads ../Model.js for node. The file starts with QML's `.pragma library` line, which is not JavaScript.
const fs = require("node:fs")
const path = require("node:path")


const src = fs.readFileSync(path.join(__dirname, "..", "Model.js"), "utf8").replace(/^\.pragma library\s*$/m, "")
const mod = { exports: {} }
new Function("module", src)(mod)
module.exports = mod.exports
