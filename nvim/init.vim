"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath=&runtimepath
"source ~/.vimrc

" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/.git/*

" search related
set hlsearch 
set ignorecase
set incsearch

syntax enable                           " Enables syntax highlighing
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
set pumheight=10                        " Makes popup menu smaller
set hidden                              " Required to keep multiple buffers open multiple buffers

"general
"colorscheme onedark
let mapleader = "\<Space>"
inoremap jk <ESC>
inoremap kj <Esc>
filetype plugin indent on
set clipboard=unnamedplus               " Copy paste between vim and everything else

set ruler            " show the cursor position all the time
set showcmd          " display incomplete commands
set laststatus=2     " Always display the status line

set number
set numberwidth=5
set relativenumber

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

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

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-p> <cmd>Telescope find_files<cr>
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
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==

"auto format on save with Black
autocmd BufWritePre *.py execute ':Black'


"plugs to intall
call plug#begin('~/.config/nvim/vim-plug')
"theme
Plug 'vim-airline/vim-airline'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'

Plug 'christoomey/vim-system-copy'
"Plug 'valloric/youcompleteme'
Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'ambv/black'

" telescope requirements...
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" prettier
Plug 'sbdchd/neoformat'

"support for go to defintion and autocompletion
Plug 'davidhalter/jedi-vim'
Plug 'jmcantrell/vim-virtualenv'

call plug#end()
"install with :PlugInstall


"cusotm stuff just for neovim
source $HOME/.config/nvim/themes/airline.vim
source $HOME/.config/nvim/themes/onedark.vim

au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
