--general
vim.g.mapleader = " "
local map = vim.api.nvim_set_keymap
vim.keymap.set('n', "<leader>e", ":Explore<CR>") --netrw file explorer

vim.keymap.set('i', "jk", "<Esc>")
vim.keymap.set('i', "kj", "<Esc>")

-- Split window
vim.keymap.set('n', "ss", ":split<Return>")
vim.keymap.set('n', "sv", ":vsplit<Return>")

--Move window
vim.keymap.set('n', "sh", "<C-w>h")
vim.keymap.set('n', "sk", "<C-w>k")
vim.keymap.set('n', "sj", "<C-w>j")
vim.keymap.set('n', "sl", "<C-w>l")

--search and replace
vim.keymap.set('n', "S", ":%s//g<Left><Left>")

-- Vimspector
vim.keymap.set('n', "<F5>", "<cmd>call vimspector#StepOver()<cr>")
vim.keymap.set('n', "<F8>", "<cmd>call vimspector#Reset()<cr>")
vim.keymap.set('n', "<F9>", "<cmd>call vimspector#Launch()<cr>")
vim.keymap.set('n', "<F10>", "<cmd>call vimspector#StepInto()<cr>")
vim.keymap.set('n', "<F11>", "<cmd>call vimspector#StepOver()<cr>")
vim.keymap.set('n', "<F12>", "<cmd>call vimspector#StepOut()<cr>")

vim.keymap.set('n', "<leader>Db", ":call vimspector#ToggleBreakpoint()<cr>")
vim.keymap.set('n', "<leader>Dw", ":call vimspector#AddWatch()<cr>")
vim.keymap.set('n', "<leader>De", ":call vimspector#Evaluate()<cr>")
