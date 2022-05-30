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
Plug 'vim-airline/vim-airline'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'gruvbox-community/gruvbox'

Plug 'christoomey/vim-system-copy'
"Plug 'valloric/youcompleteme'
Plug 'tpope/vim-surround' " Surrounding ysw)
"Plug 'ambv/black'
Plug 'psf/black', { 'branch': 'stable' }
Plug 'tpope/vim-fugitive'
" " telescope requirements...
" Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'ThePrimeagen/harpoon'
" Plug 'nvim-telescope/telescope.nvim'
" Plug 'nvim-telescope/telescope-fzy-native.nvim'

" search
Plug 'dyng/ctrlsf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"File Navigation
Plug 'francoiscabrol/ranger.vim'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin' "git status in nerdtree
Plug 'ryanoasis/vim-devicons' "add file-icons to nerdtree

"fast async search
Plug 'dyng/ctrlsf.vim'
" prettier
Plug 'sbdchd/neoformat'

"support for go to defintion and autocompletion
"Plug 'davidhalter/jedi-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jmcantrell/vim-virtualenv'

Plug 'liuchengxu/vim-which-key'
Plug 'github/copilot.vim'
"Markdown (or any Outline
Plug 'simrat39/symbols-outline.nvim'
"Plug 'vimwiki/vimwiki'
call plug#end()
"install with :PlugInstall



" source coc custom configs
source $HOME/.config/nvim/coc.vim

" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/.git/*

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
set updatetime=300                      " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
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
set nocompatible                        " Recommende for VimWiki

set ruler            " show the cursor position all the time
set showcmd          " display incomplete commands
set laststatus=2     " Always display the status line

set number
set numberwidth=5
set relativenumber


" 
" REMAPS
" Swiss keyboard remap
"
"switch between two buffers -> C-^ does not work with current swiss layout
nnoremap <C-6> <C-^><cr>

" PYTHON

"auto format on save with Black
autocmd BufWritePre *.py execute ':Black'

" Turn off autocomplete for Markdown
autocmd FileType markdown let b:coc_suggest_disable = 1

let g:python3_host_prog = expand($HOME."/.venvs/nvim/bin/python3") 
"expand($VIRTUAL_ENV."/bin/python3")

" coc
"let g:coc_node_path = "/opt/homebrew/bin/node"
let g:coc_global_extensions = ['coc-json', 'coc-git']
nnoremap <Leader>tg :CocCommand git.toggleGutters<CR>  " toggle coc-git gutter 

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
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix

" Other Languages and indentaion
au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

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

" Single mappings
" let g:which_key_map['ff'] = [ 'Telescope'                 , 'find files' ]
" let g:which_key_map['fb'] = [ 'Telescope'                 , 'find buffer' ]
let g:which_key_map['h'] = [ '<C-W>'                      , 'split below']
let g:which_key_map['j'] = [ ':m .+1<CR>=='               , 'move current line one down']
let g:which_key_map['v'] = [ '<C-W>v'                     , 'split right']
let g:which_key_map['k'] = [ ':m .-2<CR>=='               , 'move current line one up']

" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search' ,
      \ '/' : [':History/'     , 'history'],
      \ ';' : [':Commands'     , 'commands'],
      \ 'a' : [':Ag'           , 'text Ag'],
      \ 'b' : [':BLines'       , 'current buffer'],
      \ 'B' : [':Buffers'      , 'open buffers'],
      \ 'c' : [':Commits'      , 'commits'],
      \ 'C' : [':BCommits'     , 'buffer commits'],
      \ 'f' : [':Files'        , 'files'],
      \ 'g' : [':GFiles'       , 'git files'],
      \ 'G' : [':GFiles?'      , 'modified git files'],
      \ 'h' : [':History'      , 'file history'],
      \ 'H' : [':History:'     , 'command history'],
      \ 'l' : [':Lines'        , 'lines'] ,
      \ 'm' : [':Marks'        , 'marks'] ,
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

" Easy CAPS

"inoremap <c-u> <ESC>viwUi
"nnoremap <c-u> viwU<Esc>

" Alternate way to save
nnoremap <C-s> :w<CR>
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

"tab and airline tabs navigation
nmap <leader>1 :bfirst<CR>
nmap <leader>2 :bfirst<CR>:bn<CR>
nmap <leader>3 :bfirst<CR>:2bn<CR>
nmap <leader>4 :bfirst<CR>:3bn<CR>
nmap <leader>5 :bfirst<CR>:4bn<CR>
nmap <leader>6 :bfirst<CR>:5bn<CR>
nmap <leader>7 :bfirst<CR>:6bn<CR>
nmap <leader>8 :bfirst<CR>:7bn<CR>

"NerdTree
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-n> :NERDTree<CR>
nnoremap <C-l> :NERDTreeToggle<CR>
nmap <leader>l :NERDTreeToggle<CR>
" nnoremap <C-f> :NERDTreeFind<CR>

" Outline Shortcut
nmap <leader>o :SymbolsOutline<CR>

" fzf: ctrl f for find files
nnoremap <C-p> :Files<CR>
" this will quick search content of files
nnoremap <C-f> :CtrlSF 

" Split window  
nmap ss :split<Return>
nmap sv :vsplit<Return>
" zoom vim split views
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

"nmap sv :vsplit<Return><C-w>w" Move window  
nmap st :tabnew<Return>
map sh <C-w>h  
map sk <C-w>k  
map sj <C-w>j  
map sl <C-w>l" Switch tab  
nmap <S-Tab> :tabprev<Return>  
" if you map <Tab> also ctrl+l will change!
"nnoremap <Tab> :tabnext<Return>

" Find files using Telescope command-line sugar. --> replaced by fzf as faster and more options such as search :Lines :Buffer and .gitignore integration
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" nnoremap <C-p> <cmd>Telescope find_files<cr>

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

" jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

"Moving text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
" moves current line one down
nnoremap <leader>j :m .+1<CR>==
" moves current line one up
nnoremap <leader>k :m .-2<CR>==

" Commenting blocks of code.
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,java,scala     let b:comment_leadej = '// '
  autocmd FileType sh,ruby,python,yaml  let b:comment_leader = '# '
  autocmd FileType conf,fstab           let b:comment_leader = '# '
  autocmd FileType tex                  let b:comment_leader = '% '
  autocmd FileType mail                 let b:comment_leader = '> '
  autocmd FileType vim                  let b:comment_leader = '" '
augroup END
noremap <silent> <Leader>cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <Leader>cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>


" Custom surrounds
let w:surround_{char2nr('w')} = "```\r```"
let b:surround_{char2nr('b')} = "**\r**"

" Open file in Obsidian vault
command IO execute "silent !open 'obsidian://open?vault=SecondBrain&file=" . expand('%:r') . "'"
nnoremap <leader>io :IO<CR>

"cusotm stuff just for neovim
source $HOME/.config/nvim/themes/airline.vim
source $HOME/.config/nvim/themes/onedark.vim

" source settings
source $HOME/.config/nvim/plugin/harpoon.vim

"syntax on

""Gruvbox:
colorscheme gruvbox
let g:airline_theme = 'gruvbox' "'one'
set encoding=utf8
let g:airline_powerline_fonts = 1

"set bg=dark
"let g:gruvbox_contrast_dark = 'hard'





au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
