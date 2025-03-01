# this settings are additional for wordprocessor config, optimized for markdown

--markdown
vim.opt.syntax = "on" -- Enables syntax highlighing
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.conceallevel = 2 -- Markdown files behave like Obsidian, *italic*, **bold** and even [links](https...) are hidden. Amaziing!

vim.opt.wrap = true
vim.opt.linebreak = true       -- Break lines at word boundaries
vim.opt.breakindent = true     -- Preserve indentation of virtual lines
vim.opt.breakindentopt = "shift:2" -- Add extra indent for wrapped lines
vim.opt.showbreak = "↪ "       -- Show a symbol at the start of wrapped lines

