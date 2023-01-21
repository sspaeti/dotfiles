require("sspaeti.lazy")
require("theme.kanagawa")
vim.cmd("source $HOME/.config/nvim/lua/old_config.vim")
require("sspaeti.set")
require("sspaeti.remap")

vim.opt.listchars = { eol = "↵", tab = "→  ", trail = "·", extends = "$" }
--lead = '·',
vim.opt.list = true

