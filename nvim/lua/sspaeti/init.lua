require("sspaeti.packer")
require("theme.kanagawa")
require("sspaeti.remap")
require("sspaeti.set")
vim.cmd("source $HOME/.config/nvim/lua/old_config.vim")

vim.opt.listchars = { eol = "↵", tab = "→  ", trail = "·", extends = "$" }
--lead = '·',
vim.opt.list = true

--packer not installed error: https://github.com/wbthomason/packer.nvim/issues/739#issuecomment-1019280631
vim.o.runtimepath = vim.fn.stdpath("data") .. "/site/pack/*/start/*," .. vim.o.runtimepath

