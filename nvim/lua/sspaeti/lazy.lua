--lazy stuff
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " " -- make sure to set `mapleader` before lazy so your mappings are correct


-- define colorscheme based on session name
local sessionThemes = {
    ["work"]        = "gruvbox-material",
    ["dotfiles"]    = "vague", 
    ["de-projects"] = "kanagawa-paper",
    ["DEDP"]        = "rose-pine",
    ["default"]     = "kanagawa",  --required: default theme
}


--lazy stuff
require("lazy").setup({ { import = "sspaeti.plugins" }, { import = "sspaeti.plugins.lsp" } }, {
  install = {
    colorscheme = { sessionThemes["default"] },
  },
  checker = {
    enabled = false, --shoots 10's of lookups to github for checking if new update...
    notify = false,
  },
  --autoreload notification
  change_detection = {
    notify = false,
  },
})

-- Set color scheme based on tmux session name dynamically. See `sessionThemes` above
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        SetThemeBasedOnTmuxSession(sessionThemes)
    end
})
