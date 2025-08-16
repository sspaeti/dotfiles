--general
--
vim.keymap.set("n", "<leader>e", ":Explore<CR>")
-- vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })

-- s-shortcuts is for search -> without leader, directly with s
vim.keymap.set('n', 'sb', ':Buffers<CR>')
vim.keymap.set('n', 's/', ':History/<CR>')
vim.keymap.set('n', 's;', ':Commands<CR>')
vim.keymap.set('n', 'sa', ':Ag<CR>')
vim.keymap.set('n', 'sB', ':BLines<CR>')
vim.keymap.set('n', 'sb', ':Buffers<CR>')
vim.keymap.set('n', 'sc', ':Commits<CR>')
-- vim.keymap.set('n', 'sC', ':BCommits<CR>') --> changed to lsp symbol/class name search (see lsp.lua)
vim.keymap.set('n', 'sg', ':GFiles<CR>')
vim.keymap.set('n', 'sG', ':GFiles?<CR>')
vim.keymap.set('n', 'sr', ':History<CR>')
vim.keymap.set('n', 's:', ':History:<CR>')
vim.keymap.set('n', 's/', ':History/<CR>')
vim.keymap.set('n', 'sL', ':Lines<CR>')
vim.keymap.set('n', 'sn', ':enew<CR>')
vim.keymap.set('n', 'sM', ':Maps<CR>')
vim.keymap.set('n', 'st', ':Neotree position=float toggle=true reveal<CR>')
vim.keymap.set('n', 'se', ':Neotree position=right toggle=true reveal<CR>')
-- this will include hidden files and work on none git directories. Also fuzzy search works better than telecope
vim.keymap.set('n', '<c-p>', ':Files<CR>') --> sp is in telecope.lua
vim.keymap.set('n', 'sz', ':Helptags<CR>')
vim.keymap.set('n', 'sZ', ':Tags<CR>')
vim.keymap.set('n', 'su', ':UndotreeToggle<CR>')
vim.keymap.set('n', 'sS', ':Colors<CR>')
vim.keymap.set('n', 'sF', ':Rg<CR>')
vim.keymap.set('n', 'sf', ':Telescope live_grep<CR>') --search for typing string
vim.keymap.set('n', 'sw', ':Telescope grep_string<CR>') --search for word/string under cursor

vim.keymap.set('n', 'sT', ':BTags<CR>')
vim.keymap.set('n', 'sd', ':Windows<CR>')
vim.keymap.set('n', 'sy', ':Filetypes<CR>')
vim.keymap.set('n', 'sz', ':FZF<CR>')
	-- si and sm are mapped to harpoon
	-- vim.keymap.set(' sm :Marms<CR>
-- vim.keymap.set(' ss :Snippets<CR>

-- zoom vim split views
vim.api.nvim_set_keymap('n', 'Zz', '<C-w>_| <C-w>|', {noremap = true})
vim.api.nvim_set_keymap('n', 'Zo', '<C-w>=', {noremap = true})

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
vim.keymap.set("n", "S", ":%s//g<Left><Left>") --used for lazy.
vim.keymap.set("n", "<leader>s", ":%s//g<Left><Left>")
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

--ciq (change in quotes) 
vim.keymap.set("n", "ciq", "ci\"")
--cib (change in brackets)
vim.keymap.set("n", "cib", "ci(")

--improve cmd line completion (: mode or wildmenu) - allow c-j and c-n to accept completion (tab)
-- Map Ctrl+n to wildmenu completion in command mode
vim.keymap.set('c', '<C-n>', '<C-z>', { noremap = true })
vim.keymap.set('c', '<C-j>', '<C-z>', { noremap = true })
vim.keymap.set('c', '<C-p>', '<S-Tab>', { noremap = true })
vim.keymap.set('c', '<C-k>', '<S-Tab>', { noremap = true })

-- Optional: Enhance command-line completion behavior
vim.opt.wildmode = "longest:full,full"
vim.opt.wildmenu = true

--remove commands
--
--remove empty line
-- vim.keymap.set("n", "<leader>rl", ":%s/^$\n*//g")
vim.api.nvim_set_keymap('n', '<leader>rl', ':%s/^$\\n*//<CR>', { noremap = true, silent = true })


--vim.keymap.set("n", "<Leader>lf", "vim.lsp.buf.format()<CR>")
vim.keymap.set("n", "<Leader>li", ":Mason<CR>")
vim.keymap.set("n", "<Leader>ll", ":Lazy<CR>")

-- closing buffers "https://stackoverflow.com/a/8585343/5246670
vim.keymap.set("n", "<C-w>q", ":bp<bar>sp<bar>bn<bar>bd<CR>")
--vim.keymap.set("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>")
----close buffers except current
vim.keymap.set("n", "<leader>q", "<cmd>%bd|e#|bd#<cr>|'<cr>", { desc = "Delete surrounding buffers" })
-- Close current window
vim.keymap.set("n", "<leader>x", "<C-w>c")

--color themes
vim.keymap.set("n", "<leader>ts", ":Telescope colorscheme<CR>")

--GIT: Start
--
-- LazyGit
vim.api.nvim_set_keymap('n', '<leader>gg', ':LazyGit<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', {noremap = true, silent = true})
--Blamer
vim.api.nvim_set_keymap('n', '<leader>gb', ':BlamerToggle<CR>', {noremap = true, silent = true})
--Diffview.nvim
vim.api.nvim_set_keymap('n', '<leader>go', ':DiffviewOpen<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gc', ':DiffviewClose<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gh', ':DiffviewFileHistory<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gf', ':DiffviewFileHistory %<CR>', {noremap = true, silent = true})

--Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
--Browse to GitHub page
vim.api.nvim_set_keymap('n', '<leader>gw', ':GBrowse<CR>', {noremap = true, silent = false})
--END: git


--databaes
vim.keymap.set("n", "<leader>dd", ":DBUIToggle<CR>")

-- close all buffers execpt current one
-- nnoremap <leader>wa :%bd|e#<Return>


--Markdown
-- Writing / Markdown (see also markdown.lua)
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>")

-- Set shortcut to switch between showing markdown formatting level (conceallevel)
vim.api.nvim_set_keymap('n', '<leader>m0', ':set conceallevel=0<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m1', ':set conceallevel=1<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m2', ':set conceallevel=2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>m3', ':set conceallevel=3<CR>', { noremap = true, silent = true })

-- Function to toggle conceallevel
function ToggleConceallevel()
    if vim.wo.conceallevel == 0 then
        vim.wo.conceallevel = 2
    else
        vim.wo.conceallevel = 0
    end
end

-- Shortcut to toggle conceallevel
vim.api.nvim_set_keymap('n', '<leader>mt', ':lua ToggleConceallevel()<CR>', { noremap = true, silent = true })


-- Zenmode
vim.keymap.set("n", "<leader>z", ":ZenMode<CR>")

--! the plugin markdown.nvim has all the mappings, but they are used with `gs{motion}{style}`, where `{style}` 
--  is the key corresponding to the style to toggle (by default "i", "b", "s", or "c")
-- Bold text (works on word in normal mode, or selection in visual mode)
vim.api.nvim_set_keymap('n', '<leader>b', 'ciw**<C-r>"**<Esc>', {desc = "Bold Word", noremap = true})
vim.api.nvim_set_keymap('v', '<leader>b', 'c**<C-r>"**<Esc>', {desc = "Bold Selection", noremap = true})

-- Italic text
vim.api.nvim_set_keymap('n', '<leader>i', 'ciw*<C-r>"*<Esc>', {desc = "Italic Word", noremap = true})
vim.api.nvim_set_keymap('v', '<leader>i', 'c*<C-r>"*<Esc>', {desc = "Italic Selection", noremap = true})

-- Links
vim.api.nvim_set_keymap('n', '<leader>l', 'ciw[<C-r>"]()<Esc>T)i', {desc = "Link Word", noremap = true})
vim.api.nvim_set_keymap('v', '<leader>l', 'c[<C-r>"]()<Esc>T)i', {desc = "Link Selection", noremap = true})
--End: Markdown

-- Spell checker
vim.keymap.set("n", "<leader>so", "<c-o>:set spell<cr>")
vim.keymap.set("n", "<leader>so", ":set spell<cr>")
vim.keymap.set("n", "<leader>sc", "<c-o>:set nospell<cr>")
vim.keymap.set("n", "<leader>sc", ":set nospell<cr>")

--Aerial
vim.keymap.set("n", "<leader>o", ":AerialToggle<CR>", { noremap = true, silent = true })
--preview


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

-- ! do not set tab, it will also change ctrl+i due to keyboard inputs are handled. Ctrl+i is used for jumping back in history
-- vim.keymap.set("n", "<Tab>", ":bnext<CR>")
-- vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

--macro recordings
vim.keymap.set("n", "Q", "@qj") --apply macro on q and jump a line done, so you do not need to add line donw at the end
vim.keymap.set("x", "Q", ":norm @q<CR>") --applyies saved macro on q on selected lines


-- Quickfix toggle function
local toggle_qf = function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists then
    vim.cmd "cclose"
  else
    if not vim.tbl_isempty(vim.fn.getqflist()) then
      vim.cmd "copen"
    end
  end
end

vim.keymap.set("n", "<Leader>cc", toggle_qf)
vim.keymap.set("n", "<Leader>co", ":copen<CR>")
vim.keymap.set("n", "<Leader>cq", ":cclose<CR>")
vim.keymap.set("n", "<Leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<Leader>cp", ":cprevious<CR>")
vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprevious<CR>")
vim.keymap.set("n", "<Leader>wc", ":%s///gn<CR>") --first search a term with /

--<TAB>: completion -> still needed?
--inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
-- switching between tmux session from vim
--vim.keymap.set("n", "<leader>ss", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--folding
-- vim.keymap.set("n", "z1", "za")
-- vim.keymap.set("v", "z1", "zf")
-- vim.keymap.set("n", "z2", ":set foldlevel=0<CR><Esc>")
vim.keymap.set('n', 'z1', ':set foldlevel=1<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z2', ':set foldlevel=2<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z3', ':set foldlevel=3<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z4', ':set foldlevel=4<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z5', ':set foldlevel=5<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z6', ':set foldlevel=6<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z7', ':set foldlevel=7<CR><Esc>', {silent = true})
vim.keymap.set('n', 'z8', ':set foldlevel=8<CR><Esc>', {silent = true})
vim.keymap.set("n", "z9", "zR")

-- netwr explorer
vim.g.netrw_banner = 0 -- disable annoying banner
vim.g.netrw_browser_split = 4 -- open in previous window
vim.g.netrw_altv = 1 -- open splits to the right


--
--below: converted from old_configs.vim (with ChatGPT - caughtion if something does not work)
--2023-07-18
-- find in a specific repo
-- I'm not converting this command because Lua doesn't handle vim commands yet as of my knowledge cut-off in September 2021
vim.cmd[[
    command! -bang -nargs=* Rg2
      \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}, <bang>0)
]]
--
-- fzf: ctrl f for find files
-- vim.keymap.set('n', '<c-P>', ':Files<CR>')
vim.keymap.set('n', '<leader>fw', ":call fzf#vim#files('.', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<cr>")
vim.keymap.set('n', '<silent> <Leader>fr', ':Rg<CR>')
vim.keymap.set('n', '<silent> <Leader>fb', ':Buffers<CR>')
vim.keymap.set('n', '<silent> <Leader>f/', ':BLines<CR>')
vim.keymap.set('n', '<silent> <Leader>fm', ':Marks<CR>')
vim.keymap.set('n', '<silent> <Leader>fc', ':Commits<CR>')
vim.keymap.set('n', '<silent> <Leader>fH', ':Helptags<CR>')
vim.keymap.set('n', '<silent> <Leader>fg', ':Rg2 search folder')

-- Resize window ABSOLUTE (doing it the same direction wheter in right or left split)
vim.keymap.set('n', '<C-w>l', function() if vim.fn.winnr() == vim.fn.winnr('$') then vim.cmd('vertical resize -10') else vim.cmd('vertical resize +10') end end)
vim.keymap.set('n', '<C-w>h', function() if vim.fn.winnr() == 1 then vim.cmd('vertical resize -10') else vim.cmd('vertical resize +10') end end)

-- resize window RELATIVE (Haven't found a absoulte way)
vim.keymap.set('n', '<C-w>k', ':resize -10<CR>')
vim.keymap.set('n', '<C-w>j', ':resize +10<CR>')

-- Open current directory
vim.keymap.set('n', 'te', ':tabedit')
vim.keymap.set('n', '<leader>tn', ':tabnew<Return>')
-- vim.keymap.set('n', '<S-Tab>', ':tabprev<Return>')

-- undo break points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', '[', '[<c-g>u')
vim.keymap.set('i', '(', '(<c-g>u')

-- word count
vim.keymap.set('n', '<leader>cw', 'g<c-g><CR>', {desc="count words"})

-- jumplist mutations
-- These mappings are not directly convertible to Lua since they involve an expression.
-- Until Neovim's Lua API provides a method to create expression-based mappings, you'll have to use vim.cmd
-- vim.cmd[[
--     nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
--     nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'
--     nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
--     nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
-- ]]

--TODO:count on each keypress above seems to be slow, let's try this for a while:
vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap = true, silent = true})

--
--
-- vim.cmd[[
--   nnoremap <expr> k v:count > 5 ? 'k' : 'gk'
--   nnoremap <expr> j v:count > 5 ? 'j' : 'gj'
-- ]]

--copy path of current file into clipboard
vim.keymap.set('n', '<leader>y', ':let @+=expand("%:p")<CR>')

--! jumping forth and back: Needed, if I remove, c-o and c-i are not working anylonger
-- vim.keymap.set("n", "<leader>O", "<C-o>", { noremap = true })
-- vim.keymap.set("n", "<leader>I", "<C-i>", { noremap = true })
-- -- needed for c-o and c-i to work in Kitty (?):
-- vim.api.nvim_set_keymap('n', '<C-i>', '\x1b[105;5u', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-o>', '\x1b[111;5u', { noremap = true })

-- vim.api.nvim_set_keymap('n', '<C-o>', '<C-S-O>', { noremap = true, silent = true })
-- test with `:verbose map <C-o>`
--
--

vim.api.nvim_set_keymap('n', '<C-o>', '<C-O>', { noremap = true })


-- Debug key codes
-- vim.api.nvim_set_keymap('n', '<C-o>', ':lua print("C-o pressed")<CR><C-o>', {silent = false})
-- vim.api.nvim_set_keymap('n', '<C-i>', ':lua print("C-i pressed")<CR><C-i>', {sjilent = false})


-- needed for c-o and c-i to work in Kitty (?):
-- vim.api.nvim_set_keymap('n', '<C-i>', '\x1b[105;5u', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-o>', '\x1b[111;5u', { noremap = true })
-- potentially add to kitty:
-- map ctrl+i send_text all \x1b[105;5u
