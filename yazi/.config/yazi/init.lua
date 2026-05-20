-- DuckDB plugin configuration
require("duckdb"):setup()

--adding cd'ed in directories to zoxied, so I can easily find them with `Z` inside yazi or zoxide
ps.sub("cd", function()
  local cwd = tostring(cx.active.current.cwd)
  ya.emit("shell", {
    "zoxide add -- " .. ya.quote(cwd) .. " >/dev/null 2>&1",
    orphan = true,
    confirm = true,
  })
end)
