--general
local map = vim.api.nvim_set_keymap
vim.keymap.set("n", "<leader>e", ":Explore<CR>") --netrw file explorer

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

-- Split window
vim.keymap.set("n", "ss", ":split<Return>")
vim.keymap.set("n", "sv", ":vsplit<Return>")

--Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

--search and replace
vim.keymap.set("n", "S", ":%s//g<Left><Left>")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

--null-ls formatting, diagnostic and linting configs
vim.keymap.set("n", "<leader>lf", ":lua vim.lsp.buf.format()<CR>") --netrw file explorer

-- moving blocks with automatically indenting
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- join lines without moving the cursor out of the way
vim.keymap.set("n", "J", "mzJ`z")

-- pasting without losing the pasted text
vim.keymap.set("x", "<leader>p", [["_dP]])

-- -- switching between tmux session from vim
-- vim.keymap.set("n", "<leader>ss", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Vimspector
vim.keymap.set("n", "<F5>", "<cmd>call vimspector#StepOver()<cr>")
vim.keymap.set("n", "<F8>", "<cmd>call vimspector#Reset()<cr>")
vim.keymap.set("n", "<F9>", "<cmd>call vimspector#Launch()<cr>")
vim.keymap.set("n", "<F10>", "<cmd>call vimspector#StepInto()<cr>")
vim.keymap.set("n", "<F11>", "<cmd>call vimspector#StepOver()<cr>")
vim.keymap.set("n", "<F12>", "<cmd>call vimspector#StepOut()<cr>")

vim.keymap.set("n", "<leader>Db", ":call vimspector#ToggleBreakpoint()<cr>")
vim.keymap.set("n", "<leader>Dw", ":call vimspector#AddWatch()<cr>")
vim.keymap.set("n", "<leader>De", ":call vimspector#Evaluate()<cr>")
