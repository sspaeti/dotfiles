-- setup must be called before loading
vim.cmd("colorscheme kanagawa") --#kanagawa

-- vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.completeopt = { "menu" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option("updatetime", 300)

-- set undofile to keep undo history unlimited (even if buffer is closed)
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"
vim.opt.undofile = true
vim.opt.swapfile = false --instead have unlimited undo's
vim.opt.backup = false --instead have unlimited undo's
vim.opt.clipboard = "unnamedplus" --" Copy paste between vim and everything else -> inserts all into system clipboard

vim.opt.relativenumber = true
vim.opt.number = true

-- vim.opt.numberwidth = 2  -- Minimal number of columns to use for the line number

--set `filetype` in lua
vim.cmd("filetype plugin indent on")

vim.opt.ruler = true -- show the cursor position all the time
vim.opt.showcmd = true -- display incomplete commands
vim.opt.laststatus = 3 -- 3: Only show global status line in acitve window 2: Always display the status line

--fold settings
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 5
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

-- search related
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true

vim.opt.updatetime = 200 -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.

--language settings
-- vim.opt.spelllang = "en_us,de_ch"

-- Ignore files
vim.opt.wildignore = "*.pyc,*_build/*,**/coverage/*,**/.git/*,**/__pycache__/*"

vim.opt.syntax = "on" -- Enables syntax highlighing
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.conceallevel = 0 -- So that I can see `` in markdown files
vim.opt.tabstop = 2 -- Insert 2 spaces for a tab
vim.opt.shiftwidth = 2 -- Change the number of space characters inserted for indentation
vim.opt.softtabstop = 2 --Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>

--wrap lines for markdown only
vim.opt.wrap = false -- Display long lines as just one line
vim.cmd("autocmd FileType markdown setlocal wrap")

vim.opt.expandtab = true -- Converts tabs to spaces
vim.opt.smarttab = true -- Makes tabbing smarter will realize you have 2 vs 4
vim.opt.smartindent = true -- Makes indenting smart
vim.opt.autoindent = true -- Good auto indent
vim.opt.splitbelow = true -- Horizontal splits will automatically be below
vim.opt.splitright = true -- Vertical splits will automatically be to the right
-- vim.opt.t_Co=256                            -- Support 256 colors
vim.opt.termguicolors = true -- True color support
vim.opt.cmdheight = 2 -- More space for displaying messages
vim.opt.pumheight = 10 -- Makes popup menu smaller
vim.opt.hidden = true -- Required to keep multiple buffers open multiple buffers
vim.opt.timeoutlen = 500 -- By default timeoutlen is 1000 ms

vim.opt.scrolloff = 8

vim.opt.encoding = "utf8"

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
vim.opt.signcolumn = "yes"
vim.cmd([[
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])



-- MISC
--> autocmd and buff

-- Highlight what I yanked
vim.cmd("autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=500 }")

--set filetype bash when file ending wih .shrc
vim.cmd('autocmd BufNewFile,BufRead *.shrc,.secrets,.secrets_airbyte set filetype=bash')

-- auto create a folder if we save a file in a non existing folder
vim.cmd([[
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END
]])


vim.cmd([[
" Python: auto format on save with Black
autocmd BufWritePre *.py execute ':Black'
" set virtual env -> still needed with lsp? 
let g:python3_host_prog = expand($HOME."/.venvs/nvim/bin/python3")
" format JSON
:command! Formatj :%!jq .
:command! Unformatj :%!jq -c .
]])


-- vim.cmd([[
-- debug mode with -i
-- "FileType settings {{{
-- augroup mb_filetype
-- 	autocmd!
-- 	autocmd FileType brainfuck xmap <buffern R "xygv*;%s;;<c-r>x;g<left><left>
-- 	autocmd FileType yaml nnoremap <buffer> <CR> :AnsibleDoc<CR>
-- 	autocmd FileType python iabbrev <buffer> im import
-- 	autocmd FileType python iabbrev <buffer> rt return
-- 	autocmd FileType python iabbrev <buffer> yl yield
-- 	autocmd FileType python iabbrev <buffer> fa False
-- 	autocmd FileType python iabbrev <buffer> tr True
-- 	autocmd FileType python iabbrev <buffer> br break
-- 	autocmd FileType python nnoremap <buffer> <cr> :silent w<bar>only<bar>vsp<bar>term ipython3 -i %<cr>
-- augroup
-- "}}}
-- ]])

