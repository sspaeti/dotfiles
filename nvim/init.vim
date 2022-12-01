" If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

"plugs to intall
call plug#begin('~/.config/nvim/vim-plug')
"theme
Plug 'sheerun/vim-polyglot'
"themes
" Plug 'joshdick/onedark.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'rebelot/kanagawa.nvim'
Plug 'christoomey/vim-system-copy'
"Plug 'valloric/youcompleteme'
Plug 'tpope/vim-surround' " Surrounding ysw)

"Text Objects:
"Utilities for user-defined text objects
Plug 'kana/vim-textobj-user'
"Text objects for indentation levels
Plug 'kana/vim-textobj-indent'
"Text objects for Python
Plug 'bps/vim-textobj-python'
"preview CSS colors inline
" Plug 'ap/vim-css-color'
Plug 'norcalli/nvim-colorizer.lua'

" comment healper
" Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-commentary'

" should be installed out of the box by neovim?
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"" cmp plugins
" Completion framework:
Plug 'hrsh7th/nvim-cmp'
" LSP completion source:
Plug 'hrsh7th/cmp-nvim-lsp'
" Useful completion sources:
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-cmdline' "used?

"Plug 'ambv/black'
Plug 'psf/black', { 'branch': 'stable' }
Plug 'tpope/vim-fugitive'
Plug 'kdheepak/lazygit.nvim'
Plug 'sindrets/diffview.nvim' "nvim gitdiff
Plug 'mhinz/vim-signify' "highlighing changes not commited to last commit
Plug 'APZelos/blamer.nvim' "gitlens blame style
" " telescope requirements...
" Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'ThePrimeagen/harpoon'
Plug 'jose-elias-alvarez/null-ls.nvim'
" Plug 'nvim-telescope/telescope.nvim'
" Plug 'nvim-telescope/telescope-fzy-native.nvim'
"terminal
Plug 'voldikss/vim-floaterm'

" search
Plug 'dyng/ctrlsf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"File Navigation
Plug 'nvim-lualine/lualine.nvim'
Plug 'christoomey/vim-tmux-navigator'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'

" Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
Plug 'kevinhwang91/rnvimr' "replaces 'francoiscabrol/ranger.vim'
"nerdtree in lua
Plug 'kyazdani42/nvim-web-devicons' " optional, for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mbbill/undotree'

"fast async search
Plug 'dyng/ctrlsf.vim'
" prettier
Plug 'sbdchd/neoformat'

"support for go to defintion and autocompletion
"Plug 'davidhalter/jedi-vim'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jmcantrell/vim-virtualenv'

Plug 'liuchengxu/vim-which-key'
Plug 'github/copilot.vim'
"Markdown (or any Outline)
Plug 'simrat39/symbols-outline.nvim'
Plug 'stevearc/aerial.nvim'
""Obsidian
" (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
Plug 'preservim/vim-markdown'
Plug 'godlygeek/tabular'  " needed by 'preservim/vim-markdown'
Plug 'epwalsh/obsidian.nvim' "using neovim with the Obsidian vault 
" Plug 'vimwiki/vimwiki'
"dbt
" Plug 'lepture/vim-jinja' "needed for dbt below but errors in hugo htmls...
Plug 'pedramnavid/dbt.nvim'
Plug 'glench/vim-jinja2-syntax'
" Plug 'ivanovyordan/dbt.vim'

" Java
Plug 'mfussenegger/nvim-jdtls'
"use nvim in browser
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

call plug#end()
"install with :PlugInstall

" source coc custom configs
" source $HOME/.config/nvim/coc.vim
" I will try lsp commands -> Should be moved to ~/.config/nvim/lua/lsp/config.lua
nmap <silent> K :lua vim.lsp.buf.hover()<CR>
nmap <silent> gd :lua vim.lsp.buf.definition()<CR>
nmap <silent> gD :lua vim.lsp.buf.declaration()<CR>
nmap <silent> gr :lua vim.lsp.buf.references()<CR>
nmap <silent> gI :lua vim.lsp.buf.implementation()<CR>
nmap <silent> gs :lua vim.lsp.buf.signature_help()<CR>

nmap <silent> ga :lua vim.lsp.buf.code_action()<CR>


" Ignore files
set wildignore=*.pyc,*_build/*,**/coverage/*,**/.git/*,**/__pycache__/*

" search related
set hlsearch
set ignorecase
set incsearch

syntax enable          "done in onedark.vim                  Enables syntax highlighing
set smartcase
set conceallevel=0                      " So that I can see `` in markdown files
set tabstop=2                           " Insert 2 spaces for a tab
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smarttab                            " Makes tabbing smarter will realize you have 2 vs 4
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set t_Co=256                            " Support 256 colors
set cmdheight=2                         " More space for displaying messages
set updatetime=200                      " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
set pumheight=10                        " Makes popup menu smaller
set hidden                              " Required to keep multiple buffers open multiple buffers
set timeoutlen=500                      " By default timeoutlen is 1000 ms



"general
let mapleader = "\<Space>"
inoremap jk <ESC>
inoremap kj <Esc>
filetype plugin indent on
set clipboard=unnamedplus               " Copy paste between vim and everything else -> inserts all into system clipboard
noremap <Leader>ca ggVG"*y              " Copy all in file to system clipboard

" " VimWiki
" set nocompatible                        " Recommende for VimWiki
" connect with Obsidian Second Brain
" let g:vimwiki_list = [{'path': '~/Simon/Sync/SecondBrain', 'syntax': 'markdown', 'ext': '.md'}]
" let g:vimwiki_global_ext = 0 " only mark files in the second brain as vim viki, rest are standard markdown

" create WikiLink and paste clipboard as link when in visual mode
autocmd FileType markdown vnoremap <leader>k <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>
" create empty wikilink when in normal mode
autocmd FileType markdown nmap <leader>k i[]()<Esc>hhi

" Open file in Obsidian vault
command IO execute "silent !open 'obsidian://open?vault=SecondBrain&file=" . expand('%:r') . "'"
nnoremap <leader>io :IO<CR>



" Turn off autocomplete for Markdown
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" Autocomplete with ctrl space
if has("gui_running")
    " C-Space seems to work under gVim on both Linux and win32
    inoremap <C-Space> <C-n>
else " no gui
  if has("unix")
    inoremap <Nul> <C-n>
  else
  " I have no idea of the name of Ctrl-Space elsewhere
  endif
endif

" Highlights for headers in markdown -> doesn't really work
highlight htmlH1 guifg=#50fa7b gui=bold
highlight htmlH2 guifg=#ff79c6 gui=bold
highlight htmlH3 guifg=#ffb86c gui=bold
highlight htmlH4 guifg=#8be9fd gui=bold
highlight htmlH5 guifg=#f1fa8c gui=bold

" Highlight what I yanked
autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=500 }

set ruler            " show the cursor position all the time
set showcmd          " display incomplete commands
set laststatus=3     " 3: Only show global status line in acitve window 2: Always display the status line

set number
set numberwidth=5
set relativenumber

"fold settings
"set foldnestmax=2
set foldmethod=indent
set foldlevel=5
nnoremap <Leader>z za
vnoremap <Leader>z zf
map z1  :set foldlevel=0<CR><Esc>
map z2  :set foldlevel=1<CR><Esc>
map z3  :set foldlevel=2<CR><Esc>
map z4  :set foldlevel=3<CR><Esc>
map z5  :set foldlevel=4<CR><Esc>
map z6  :set foldlevel=5<CR><Esc>
map z7  :set foldlevel=6<CR><Esc>
map z8  :set foldlevel=7<CR><Esc>
nnoremap z9 zR
"
" REMAPS
" Swiss keyboard remap
"
"switch between two buffers -> C-^ does not work with current swiss layout
nnoremap <C-6> <C-^><cr>

" PYTHON

"auto format on save with Black
autocmd BufWritePre *.py execute ':Black'

" format JSON
:command Formatj :%!jq .
:command Unformatj :%!jq -c .

"null-ls formatting, diagnostic and linting configs
map <Leader>lf :lua vim.lsp.buf.format()<CR>

let g:python3_host_prog = expand($HOME."/.venvs/nvim/bin/python3")
"expand($VIRTUAL_ENV."/bin/python3")

" coc
"let g:coc_node_path = "/opt/homebrew/bin/node"
" let g:coc_global_extensions = ['coc-json', 'coc-git']


" This will run a python file by hitting 'enter' and debug it directly in
" debug mode with -i
""FileType settings {{{
"augroup mb_filetype
"	autocmd!
"	autocmd FileType brainfuck xmap <buffern R "xygv*;%s;;<c-r>x;g<left><left>
"	autocmd FileType yaml nnoremap <buffer> <CR> :AnsibleDoc<CR>
"	autocmd FileType python iabbrev <buffer> im import
"	autocmd FileType python iabbrev <buffer> rt return
"	autocmd FileType python iabbrev <buffer> yl yield
"	autocmd FileType python iabbrev <buffer> fa False
"	autocmd FileType python iabbrev <buffer> tr True
"	autocmd FileType python iabbrev <buffer> br break
"	autocmd FileType python nnoremap <buffer> <cr> :silent w<bar>only<bar>vsp<bar>term ipython3 -i %<cr>
"augroup
""}}}

" auto create a folder if we save a file in a non existing folder
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END

" jedi - shortcuts -> replced with coc
" let g:jedi#goto_command = "<leader>d"
" let g:jedi#goto_assignments_command = "<leader>g"
" let g:jedi#goto_stubs_command = "<leader>s"
" let g:jedi#goto_definitions_command = ""
" let g:jedi#documentation_command = "K"
" let g:jedi#usages_command = "<leader>n"
" let g:jedi#completions_command = "<C-Space>"
" let g:jedi#rename_command = "<leader>r"

" PEP 8 indentation
" au BufNewFile,BufRead *.py
"      \ set tabstop=4
"      \ set softtabstop=4
"      \ set shiftwidth=4
"      \ set textwidth=79
"      \ set expandtab
"      \ set autoindent
"      \ set fileformat=unix

" Other Languages and indentaion
" au BufNewFile,BufRead *.js, *.html, *.css
"     \ set tabstop=2
"     \ set softtabstop=2
"     \ set shiftwidth=2

" Others
"

"Which-key healper for leader-key mapping
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
" Create map to add keys to
let g:which_key_map =  {}
" Define a separator
let g:which_key_sep = '→'

" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0
" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler


" Easy CAPS

"inoremap <c-u> <ESC>viwUi
"nnoremap <c-u> viwU<Esc>

" Alternate way to save
nnoremap <C-s> :w<CR>
nnoremap <leader>r q:


" Select all
nmap <C-a> gg<S-v>G

" replace without losing what I hade in the clipboard
xnoremap("<leader>p", "\"_dP")

" Alternate way to quit
" nnoremap <C-Q> :wq!<CR>
" Use control-c instead of escape
nnoremap <C-c> <Esc>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l

" for bufferline navigation
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

nmap gt :bnext<CR>
nmap gT :bprevious<CR>

nmap 1gt :bfirst<CR>
nmap 2gt :bfirst<CR>:bn<CR>
nmap 3gt :bfirst<CR>:2bn<CR>
nmap 4gt :bfirst<CR>:3bn<CR>
nmap 5gt :bfirst<CR>:4bn<CR>
nmap 6gt :bfirst<CR>:5bn<CR>
nmap 7gt :bfirst<CR>:6bn<CR>
nmap 8gt :bfirst<CR>:7bn<CR>
"file navigation nvim-tree
" nnoremap <leader>ll :NvimTreeToggle<CR>
"not needed anymore, maped to sl
nmap <leader>lf :NvimTreeFindFile<CR>
nnoremap <leader>ll :NvimTreeToggle<CR>
"not needed anymore, maped to se
nnoremap <leader>l :NvimTreeToggle<CR>


"floatterm
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
" let g:floaterm_keymap_toggle = '<C-x>'
let g:floaterm_width = 160
let g:floaterm_height = 45


" Outline Shortcut
nmap <leader>oo :CocList outline methods<CR>
nmap <leader>o :AerialToggle<CR>
autocmd FileType markdown,vimwiki nmap <leader>o :SymbolsOutline<CR>

" fzf: ctrl f for find files
nnoremap <C-p> :Files<CR>
" nnoremap <C-f> :Rg<CR> "-> now on sf
nnoremap <leader>fw
  \ :call fzf#vim#files('.', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<cr>
nnoremap <silent> <Leader>fr :Rg<CR>
nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>f/ :BLines<CR>
nnoremap <silent> <Leader>fm :Marks<CR>
nnoremap <silent> <Leader>fc :Commits<CR>
nnoremap <silent> <Leader>fH :Helptags<CR>
" find in a specific repo
command! -bang -nargs=* Rg2
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}, <bang>0)
nnoremap <silent> <Leader>fd :Rg2 search folder
" :Rg2 apple ./folder_test
" :Rg2 "apple teste" ./folder_test
" :Rg2 --type=js "apple"
" :Rg2 --fixed-strings "apple"
" :Rg2 -e -foo
" :Rg2 apple
" :Rg2 '^port'                                       # Search for lines beginning with 'port'
" :Rg2 '^\s*port'                                   # Search for lines beginning with 'port', possibly after initial whitespace
" :Rg2 Apple --case-sensitive
" :Rg2 Apple --sortr=created             #   (none, created, path, modified, accessed)   descending order
" :Rg2 Apple --sort=created               #  (none, created, path, modified, accessed)   ascending order
" :Rg2 --passthru 'blue' -r 'red' test.txt  > tmp.txt && mv tmp.txt test.txt                       #Replace example
" :Rg2 'port|http'                                     # Search for string 'port' OR string 'http':
" :Rg2 --passthru 'blue' -r 'red' test.txt  | sponge test.txt                       # Replace example If you have moreutils installed
" this will quick search content of files
nnoremap <leader>ff :CtrlSF
nnoremap <leader>fl :CtrlSFToggle<CR>
nnoremap <leader>ft :CtrlSFToggle<CR>

"plug for search and replace
nnoremap S :s%//g<Left><Left>
" Split window
nmap ss :split<Return>
nmap sv :vsplit<Return>

"Move window
" noremap sh <C-w>h
" noremap sk <C-w>k
" noremap sj <C-w>j
" noremap sl <C-w>l

" Single mappings
" let g:which_key_map['ff'] = [ 'Telescope'                 , 'find files' ]
" let g:which_key_map['fb'] = [ 'Telescope'                 , 'find buffer' ]
let g:which_key_map['h'] = [ '<C-W>'                      , 'split below']
let g:which_key_map['j'] = [ ':m .+1<CR>=='               , 'move current line one down']
let g:which_key_map['v'] = [ '<C-W>v'                     , 'split right']
let g:which_key_map['k'] = [ ':m .-2<CR>=='               , 'move current line one up']

" s-shortcuts is for search -> without leader, directly with s
nnoremap sb :Buffers<CR>
nnoremap s/ :History/<CR>
nnoremap s; :Commands<CR>
nnoremap sa :Ag<CR>
nnoremap sB :BLines<CR>
nnoremap sb :Buffers<CR>
nnoremap sc :Commits<CR>
nnoremap sC :BCommits<CR>
" nnoremap sf :Files<CR>
nnoremap sg :GFiles<CR>
nnoremap sG :GFiles?<CR>
nnoremap sr :History<CR>
nnoremap s: :History:<CR>
nnoremap s/ :History/<CR>
nnoremap sL :Lines<CR>
" nnoremap sm :Marms<CR>
nnoremap sM :Maps<CR>
nnoremap <silent>sh :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent>sm :lua require("harpoon.mark").add_file()<CR>
nnoremap sl :NvimTreeToggle<CR>
nnoremap se :NvimTreeFindFile<CR>
nnoremap sp :Files<CR>
nnoremap sz :Helptags<CR>
nnoremap sZ :Tags<CR>
"undo tree
nnoremap su :UndotreeToggle<CR>


" nnoremap ss :Snippets<CR>
nnoremap sS :Colors<CR>
nnoremap sf :Rg<CR>
nnoremap sT :BTags<CR>
nnoremap sw :Windows<CR>
nnoremap sy :Filetypes<CR>
nnoremap sz :FZF<CR>

" s-shortcuts is for search -> uses leader+s..
let g:which_key_map.s = {
      \ 'name' : '+search' ,
      \ '/' : [':History/'     , 'history'],
      \ ';' : [':Commands'     , 'commands'],
      \ 'a' : [':Ag'           , 'text Ag'],
      \ 'B' : [':BLines'       , 'current buffer'],
      \ 'b' : [':Buffers'      , 'open buffers'],
      \ 'c' : [':Commits'      , 'commits'],
      \ 'C' : [':BCommits'     , 'buffer commits'],
      \ 'f' : [':Files'        , 'files'],
      \ 'g' : [':GFiles'       , 'git files'],
      \ 'G' : [':GFiles?'      , 'modified git files'],
      \ 'h' : [':History'      , 'file history'],
      \ 'H' : [':History:'     , 'command history'],
      \ 'l' : [':Lines'        , 'lines'] ,
      \ 'm' : [':Marms'        , 'marks'] ,
      \ 'M' : [':Maps'         , 'normal maps'] ,
      \ 'p' : [':Helptags'     , 'help tags'] ,
      \ 'P' : [':Tags'         , 'project tags'],
      \ 's' : [':Snippets'     , 'snippets'],
      \ 'S' : [':Colors'       , 'color schemes'],
      \ 't' : [':Rg'           , 'text Rg'],
      \ 'T' : [':BTags'        , 'buffer tags'],
      \ 'w' : [':Windows'      , 'search windows'],
      \ 'y' : [':Filetypes'    , 'file types'],
      \ 'z' : [':FZF'          , 'FZF'],
      \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
" zoom vim split views
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" move window with christoomey/vim-tmux-navigator to align tmux and nvim
let g:tmux_navigator_no_mappings = 1
" If the tmux window is zoomed, keep it zoomed when moving from Vim to another pane
let g:tmux_navigator_preserve_zoom = 1

noremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
noremap <silent> <c-j> :<C-U>TmuxNavigateDown<cr>
noremap <silent> <c-k> :<C-U>TmuxNavigateUp<cr>
noremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>
noremap <silent> <c-t> :<C-U>TmuxNavigatePrevious<cr>

" Resize window
nnoremap <C-w>l <C-w>5>
nnoremap <C-w>h <C-w>5<
nnoremap <C-w>k <C-w>5+
nnoremap <C-w>j <C-w>5-
nmap <C-w><left> <C-w>5<
nmap <C-w><right> <C-w>5>
nmap <C-w><up> <C-w>5+
nmap <C-w><down> <C-w>5-

" Harpoon
nnoremap <silent><leader>hh :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent><leader>hm :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent><leader>hc :lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>

nnoremap <silent><leader>hj :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent><leader>hk :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent><leader>hl :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent><leader>hö :lua require("harpoon.ui").nav_file(4)<CR>
" closing buffers "https://stackoverflow.com/a/8585343/5246670
map <C-w>q :bp<bar>sp<bar>bn<bar>bd<CR>
nnoremap <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>
" close all buffers execpt current one
" nnoremap <leader>wa :%bd|e#<Return>

" Close current window
nnoremap <leader>x <C-w>c

" Open current directory
nmap te :tabedit
nmap <leader>t :tabnew<Return>
nmap <S-Tab> :tabprev<Return>
" Attention, sometimes when you map <Tab> also ctrl+i will change!
"nmap <Tab> :tabnext<Return>

"nnoremap <Tab> :tabnext<Return>

" Find files using Telescope command-line sugar. --> replaced by fzf as faster and more options such as search :Lines :Buffer and .gitignore integration
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" nnoremap <C-p> <cmd>Telescope find_files<cr>

"ranger nvim
" nnoremap <leader>e :RnvimrToggl<CR>
"
" Replace `$EDITOR` candidate with this command to open the selected file
let g:rnvimr_edit_cmd = 'drop'


"coc git
" nnoremap <Leader>tg :CocCommand git.toggleGutters<CR>  " toggle coc-git gutter

" setup mapping to call :LazyGit
nnoremap <silent> <leader>gg :LazyGit<CR>
nnoremap <silent> <leader>lg :LazyGit<CR>

"git blame
nnoremap <silent> <leader>gb :BlamerToggle<CR>
"git diffview.nvim
nnoremap <silent> <leader>go :DiffviewOpen<CR>
nnoremap <silent> <leader>gc :DiffviewClose<CR>
nnoremap <silent> <leader>gh :DiffviewFileHistory<CR>
nnoremap <silent> <leader>gf :DiffviewFileHistory %<CR>
"
"let blame default be on
let g:blamer_enabled = 1

nnoremap Y y$
" keeping it centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap [ [<c-g>u
inoremap ( (<c-g>u

" set undofile to keep undo history unlimited (even if buffer is closed)
set undofile

" jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'
" binding j and k to gj and gk
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

"Moving text
" vnoremap J :m '>+1<CR>gv=gv
" vnoremap K :m '<-2<CR>gv=gv
" inoremap <C-j> <esc>:m .+1<CR>==
" inoremap <C-k> <esc>:m .-2<CR>==

" moves current line one down
" nnoremap <leader>j :m .+1<CR>==
" moves current line one up
" nnoremap <leader>k :m .-2<CR>==

" Commenting blocks of code.
" replaced with vim-commentary
" augroup commenting_blocks_of_code
"   autocmd!
"   autocmd FileType c,cpp,java,scala     let b:comment_leadej = '// '
"   autocmd FileType sh,ruby,python,yaml  let b:comment_leader = '# '
"   autocmd FileType conf,fstab           let b:comment_leader = '# '
"   autocmd FileType tex                  let b:comment_leader = '% '
"   autocmd FileType mail                 let b:comment_leader = '> '
"   autocmd FileType vim                  let b:comment_leader = '" '
" augroup END
noremap <silent> <Leader>cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <Leader>cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>


" Custom surrounds
let w:surround_{char2nr('w')} = "```\r```"
let b:surround_{char2nr('b')} = "**\r**"

"cusotm stuff just for neovim
"source $HOME/.config/nvim/themes/onedark.vim
"source $HOME/.config/nvim/themes/tokyonight.vim

" source settings
source $HOME/.config/nvim/plugin/copilot.vim
" configure firenvim for the browser
if exists("g:started_by_firenvim")
  source $HOME/.config/nvim/plugin/firenvim.vim
endif

"syntax on

lua require('themes.kanagawa')
"colorscheme kanagawa

""Theme configs - tokyonight gruvbox onedark kanagawa
" let g:tokyonight_style = "night"
" let g:tokyonight_italic_functions = 1
" let g:tokyonight_comments = 1
" let g:tokyonight_sidebars = [ "qf", "vista_kind", "terminal", "packer" ]
"
" " Change the "hint" color to the "orange" color, and make the "error" color bright red
" let g:tokyonight_colors = {
"   \ 'hint': 'orange',
"   \ 'error': '#ff0000'
" \ }


"lua plugins installing with packer.nvim
lua require('plugins') --these are specified in lua/plugins.lua

" lua basic settings
lua require('init')
lua require('lsp.config')
" lua plugins settings
lua require('plugins.bufferline')
lua require('plugins.indent-blankline')
lua require('plugins.symbols-outline')
lua require('plugins.aerial')
lua require('plugins.treesitter')
lua require('plugins.cmp')
lua require('plugins.pyright')
lua require('plugins.null-ls')
lua require('plugins.lualine')
lua require('plugins.github')
lua require('plugins.nvim-tree')
lua require('plugins.colorizer')
lua require('plugins.alpha-nvim')
lua require('plugins.obsidian')
" plugin installations
lua require('plugins.mason')



set encoding=utf8

"set bg=dark
"let g:gruvbox_contrast_dark = 'hard'


"lua plugins
"lua require('~/.config/nvim/plugin/copilot')



au! BufWritePost $RC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
