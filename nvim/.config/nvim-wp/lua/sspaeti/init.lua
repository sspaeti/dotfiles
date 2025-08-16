require("sspaeti.custom")
require("sspaeti.lazy")
require("theme.kanagawa")
require("sspaeti.set")
-- markdown specific: run after set above as it should overwrite default settings
require("sspaeti.remap")
require("sspaeti.set_wp")

--remove in order to set in set_wp.lua
--vim.opt.listchars = { eol = "↵", tab = "→  ", trail = "·", extends = "$" }
--lead = '·',
vim.opt.list = true

