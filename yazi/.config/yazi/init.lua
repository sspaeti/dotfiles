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

  -- NEOMD:
  -- When yazi was launched as a file picker (--chooser-file, used by neomd's
  -- <leader>a attach flow), wipe any leftover selection on every cd. The trap:
  -- yazi binds <Space> to `toggle` selection. A single stray <Space> press in
  -- the picker leaves a stale selection on whatever was under the cursor in
  -- the launch directory (e.g. `aur` in a repo root), and that selection
  -- survives a cd. When you later press <Enter> on the file you actually want
  -- in ~/Downloads, yazi's `open` writes the *selected* file(s) (not the
  -- hovered one) to the chooser file — see yazi-actor/src/mgr/open.rs:23-31.
  --
  -- Use `escape --select` (not `toggle_all --state=off`): the latter only
  -- touches files in the current tab directory, but the selected URL points
  -- at a file in the *previous* directory, so the stale entry survives.
  -- `escape_select` calls `tab.selected.clear()` which wipes everything
  -- (see yazi-actor/src/mgr/escape.rs, EscapeSelect).
  if rt.args.chooser_file then
    ya.emit("escape", { select = true })
  end
end)
