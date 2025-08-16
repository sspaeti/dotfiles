-- this settings are additional for wordprocessor config, optimized for markdown
-- overwriting default settings

vim.opt.listchars = { tab = "→  ", trail = "·", extends = "$" }

--markdown
vim.opt.syntax = "on" -- Enables syntax highlighing
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.conceallevel = 2 -- Markdown files behave like Obsidian, *italic*, **bold** and even [links](https...) are hidden. Amaziing!

-- vim.opt.textwidth = 80

vim.opt.wrap = true
vim.opt.linebreak = true       -- Break lines at word boundaries. Avoids cuting words at end of the line
vim.opt.breakindent = true     -- Preserve indentation of virtual lines
vim.opt.breakindentopt = "shift:1" -- Add extra indent for wrapped lines
vim.opt.showbreak = "↪ "       -- Show a symbol at the start of wrapped lines


-- Custom fold text function
vim.opt.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').' ']]
vim.opt.fillchars = { fold = " " }  -- Remove the default fold characters
vim.opt.foldcolumn = "0"           -- Hide the fold column

--Hide tab status
vim.opt.showtabline = 1

vim.opt.relativenumber = false


--enter text vertically to maximize focus on current line
vim.opt.scrolloff = 5 --default: 8


-- This removes the currly underline below a Markdown link, but keeps the color and icon effect
vim.defer_fn(function()
  -- Get current highlight attributes
  local current_hl = vim.api.nvim_get_hl(0, { name = "@string.special.url" })
  
  -- Create new highlight with same colors but no underline
  local new_hl = {
    fg = current_hl.fg,
    bg = current_hl.bg,
    sp = current_hl.sp,
    bold = current_hl.bold,
    italic = current_hl.italic,
    underline = false  -- Explicitly remove underline
  }
  
  -- Apply the modified highlight
  vim.api.nvim_set_hl(0, "@string.special.url", new_hl)
end, 100)


-- -- Auto-enable ZenMode on startup with a slight delay
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     vim.defer_fn(function()
--       vim.cmd("ZenMode")
--     end, 0.1) -- delay to ensure plugin is loaded
--   end
-- })
