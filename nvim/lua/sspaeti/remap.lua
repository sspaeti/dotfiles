--general
vim.keymap.set("n", "<leader>e", ":Explore<CR>")


-- s-shortcuts is for search -> without leader, directly with s
vim.keymap.set('n', 'sb', ':Buffers<CR>')
vim.keymap.set('n', 's/', ':History/<CR>')
vim.keymap.set('n', 's;', ':Commands<CR>')
vim.keymap.set('n', 'sa', ':Ag<CR>')
vim.keymap.set('n', 'sB', ':BLines<CR>')
vim.keymap.set('n', 'sb', ':Buffers<CR>')
vim.keymap.set('n', 'sc', ':Commits<CR>')
vim.keymap.set('n', 'sC', ':BCommits<CR>')
vim.keymap.set('n', 'sg', ':GFiles<CR>')
vim.keymap.set('n', 'sG', ':GFiles?<CR>')
vim.keymap.set('n', 'sr', ':History<CR>')
vim.keymap.set('n', 's:', ':History:<CR>')
vim.keymap.set('n', 's/', ':History/<CR>')
vim.keymap.set('n', 'sL', ':Lines<CR>')
vim.keymap.set('n', 'sM', ':Maps<CR>')
vim.keymap.set('n', 'st', ':NvimTreeToggle<CR>')
vim.keymap.set('n', 'se', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', 'sp', ':Files<CR>')
vim.keymap.set('n', 'sz', ':Helptags<CR>')
vim.keymap.set('n', 'sZ', ':Tags<CR>')
vim.keymap.set('n', 'su', ':UndotreeToggle<CR>')
vim.keymap.set('n', 'sS', ':Colors<CR>')
vim.keymap.set('n', 'sf', ':Rg<CR>')
vim.keymap.set('n', 'sT', ':BTags<CR>')
vim.keymap.set('n', 'sw', ':Windows<CR>')
vim.keymap.set('n', 'sy', ':Filetypes<CR>')
vim.keymap.set('n', 'sz', ':FZF<CR>')
	-- si and sm are mapped to harpoon
	-- vim.keymap.set(' sm :Marms<CR>
-- vim.keymap.set(' ss :Snippets<CR>

-- zoom vim split views
vim.cmd([[
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=
]])

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

--vim.keymap.set("n", "<Leader>lf", "vim.lsp.buf.format()<CR>")
vim.keymap.set("n", "<Leader>li", ":Mason<CR>")

-- closing buffers "https://stackoverflow.com/a/8585343/5246670
vim.keymap.set("n", "<C-w>q", ":bp<bar>sp<bar>bn<bar>bd<CR>")
vim.keymap.set("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>")

-- close all buffers execpt current one
-- nnoremap <leader>wa :%bd|e#<Return>

-- Close current window
vim.keymap.set("n", "<leader>x", "<C-w>c")

-- moving blocks with automatically indenting
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
--yank to the end of line
vim.keymap.set("n", "Y", "y$")

-- join lines without moving the cursor out of the way
vim.keymap.set("n", "J", "mzJ`z")

-- pasting without losing the pasted text
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Alternate way to save
vim.keymap.set("n", "<c>s", ":w<CR>")
vim.keymap.set("n", "<c>a", "gg<S-v>G")

-- Better tabbing
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- better scrolling and searching with centered always
vim.keymap.set("n", "<c-d>", "<C-d>zz")
vim.keymap.set("n", "<c-u>", "<C-u>zz")
vim.keymap.set("n", "<n>", "nzzzv")
vim.keymap.set("n", "<N>", "Nzzzv")

-- Use control-c instead of escape
vim.keymap.set("n", "c-c", "<Esc>")

--tab navigation
vim.keymap.set("n", "gt", ":bnext<CR>")
vim.keymap.set("n", "gT", ":bprevious<CR>")

--quickfix toggle_qf
local toggle_qf = function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd "cclose"
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd "copen"
  end
end

vim.keymap.set("n", "<Leader>cc", ":call toggle_qf()<CR>")
vim.keymap.set("n", "<Leader>co", ":copen<CR>")
vim.keymap.set("n", "<Leader>cc", ":cclose<CR>")

-- <TAB>: completion -> still needed?
-- inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
-- -- switching between tmux session from vim
-- vim.keymap.set("n", "<leader>ss", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--folding
vim.keymap.set("n", "<leader>z", "za")
vim.keymap.set("v", "<leader>z", "zf")
vim.keymap.set("n", "z2", ":set foldlevel=0<CR><Esc>")
vim.keymap.set('n', 'z2', ':set foldlevel=1<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z3', ':set foldlevel=2<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z4', ':set foldlevel=3<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z5', ':set foldlevel=4<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z6', ':set foldlevel=5<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z7', ':set foldlevel=6<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z8', ':set foldlevel=7<CR><Esc>', {silent = true})
vim.keymap.set("n", "z9", "zR")

-- Vimspector
-- vim.keymap.set("n", "<F5>", "<cmd>call vimspector#StepOver()<cr>")
-- vim.keymap.set("n", "<F8>", "<cmd>call vimspector#Reset()<cr>")
-- vim.keymap.set("n", "<F9>", "<cmd>call vimspector#Launch()<cr>")
-- vim.keymap.set("n", "<F10>", "<cmd>call vimspector#StepInto()<cr>")
-- vim.keymap.set("n", "<F11>", "<cmd>call vimspector#StepOver()<cr>")
-- vim.keymap.set("n", "<F12>", "<cmd>call vimspector#StepOut()<cr>")

vim.keymap.set("n", "<leader>Db", ":call vimspector#ToggleBreakpoint()<cr>")
vim.keymap.set("n", "<leader>Dw", ":call vimspector#AddWatch()<cr>")
vim.keymap.set("n", "<leader>De", ":call vimspector#Evaluate()<cr>")

