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


--lazy stuff
require("lazy").setup({ { import = "sspaeti.plugins" }, { import = "sspaeti.plugins.lsp" } }, {
  install = {
    colorscheme = { "vim" },
  },
  checker = {
    enabled = false,
    notify = false,
  },
  --autoreload notification
  change_detection = {
    notify = false,
  },
})
