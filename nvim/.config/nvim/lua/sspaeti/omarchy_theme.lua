-- Omarchy system-theme integration: follow the theme set via `omarchy theme set`
-- inside neovim, with hot reload when the system theme changes.
--
-- How Omarchy does it (see omarchy-nvim package, /etc/skel/.config/nvim/):
--   * Every omarchy theme ships a lazy.nvim spec at
--     ~/.local/state/omarchy/current/theme/neovim.lua containing the theme
--     plugin (Omarchy 4: bjarneo/aether.nvim with per-theme opts.colors) plus
--     a { "LazyVim/LazyVim", opts = { colorscheme = ... } } entry.
--   * Their config symlinks lua/plugins/theme.lua to that file and relies on
--     lazy.nvim change_detection + a LazyReload autocmd to re-apply it.
--
-- We don't run LazyVim, so instead we dofile() the same spec, drop the
-- LazyVim entry, and watch ~/.local/state/omarchy/current with fs_event —
-- the colorscheme updates the moment the theme is switched, no refocus needed.

local M = {}

local state_dir = vim.fn.expand("~/.local/state/omarchy/current")
M.theme_file = state_dir .. "/theme/neovim.lua"

function M.available()
  return (vim.uv or vim.loop).fs_stat(M.theme_file) ~= nil
end

-- Returns (plugin specs without the LazyVim entry, colorscheme name)
function M.load()
  local ok, spec = pcall(dofile, M.theme_file)
  if not ok or type(spec) ~= "table" then
    return {}, nil
  end
  local plugins, colorscheme = {}, nil
  for _, s in ipairs(spec) do
    if type(s) == "table" and s[1] == "LazyVim/LazyVim" then
      colorscheme = s.opts and s.opts.colorscheme
    else
      table.insert(plugins, s)
    end
  end
  return plugins, colorscheme
end

local function module_name(s)
  return s.name or s[1]:match("([^/]+)$"):gsub("%.nvim$", "")
end

-- Apply the current omarchy theme: clear old highlights, re-run the theme
-- plugin's setup() with the new colors, set the colorscheme.
function M.apply()
  local plugins, colorscheme = M.load()
  if not colorscheme then
    vim.notify("omarchy_theme: could not read " .. M.theme_file, vim.log.levels.WARN)
    return
  end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark" -- light themes set this back themselves

  -- put the theme plugin on the rtp if it isn't yet: all stock omarchy theme
  -- plugins are registered lazy=true via plugins/omarchy.lua, and lazy can
  -- resolve which of them provides this colorscheme
  pcall(function()
    require("lazy.core.loader").colorscheme(colorscheme)
  end)

  for _, s in ipairs(plugins) do
    local mod = module_name(s)
    -- purge cached modules so setup() re-applies the new theme's colors
    -- (all Omarchy 4 stock themes share aether.nvim, only opts differ)
    for loaded in pairs(package.loaded) do
      if loaded == mod or loaded:find("^" .. vim.pesc(mod) .. "%.") then
        package.loaded[loaded] = nil
      end
    end
    if s.opts then
      pcall(function()
        require(mod).setup(s.opts)
      end)
    end
  end

  if not pcall(vim.cmd.colorscheme, colorscheme) then
    -- theme plugin not installed (e.g. custom/newly installed omarchy theme):
    -- fall back, restart nvim once so lazy installs it
    pcall(vim.cmd.colorscheme, "kanagawa")
    vim.notify(
      "omarchy_theme: colorscheme '" .. colorscheme .. "' not available, fell back to kanagawa — restart nvim to install it",
      vim.log.levels.WARN
    )
  end
  vim.cmd("redraw!")
end

local watcher

-- Apply now and hot-reload whenever `omarchy theme set` swaps the
-- ~/.local/state/omarchy/current/theme directory.
function M.enable()
  if not M.available() then
    vim.notify("omarchy_theme: no omarchy theme found, keeping current colorscheme", vim.log.levels.WARN)
    return
  end
  M.apply()

  if watcher then
    return
  end
  local uv = vim.uv or vim.loop
  local debounce = uv.new_timer()
  watcher = uv.new_fs_event()
  watcher:start(state_dir, {}, function(_, filename)
    -- ignore background cycling etc.; only react to the theme dir swap
    if filename and not filename:match("^theme") then
      return
    end
    -- the swap fires several events and files land just after the directory
    -- move; restart the timer on each event to settle before re-applying
    debounce:stop()
    debounce:start(300, 0, vim.schedule_wrap(M.apply))
  end)
end

return M
