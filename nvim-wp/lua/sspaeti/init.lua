require("sspaeti.custom")
require("sspaeti.lazy")
require("theme.kanagawa")
require("sspaeti.set")
-- markdown specific: run after set above as it should overwrite default settings
require("sspaeti.set_wp")
require("sspaeti.remap")

vim.opt.listchars = { eol = "↵", tab = "→  ", trail = "·", extends = "$" }
--lead = '·',
vim.opt.list = true

