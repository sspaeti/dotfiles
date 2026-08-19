-- Register the plugin used by the current Omarchy system theme so the
-- "Omarchy" pseudo-theme (see sessionThemes in sspaeti/lazy.lua) can apply
-- it without lazy-loading issues.
local omarchy = require("sspaeti.omarchy_theme")
if not omarchy.available() then
  return {}
end

-- current theme's plugin: eager, so the startup colorscheme works
local specs = omarchy.load()
for _, s in ipairs(specs) do
  s.lazy = false
  s.priority = 1000
end

-- Also register every stock omarchy theme plugin (lazy) so hot reload can
-- switch to any theme without an nvim restart. The list is maintained by
-- the omarchy-nvim package, so it stays in sync on omarchy updates.
local all_themes = "/etc/skel/.config/nvim/lua/plugins/all-themes.lua"
local ok, extra = pcall(dofile, all_themes)
if ok and type(extra) == "table" then
  vim.list_extend(specs, extra)
end

return specs
