"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath=&runtimepath
"source ~/.vimrc
syntax on

" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/.git/*

" search related
set hlsearch 
set ignorecase
set incsearch
set smartcase

"general
"colorscheme onedark
let mapleader = " "
inoremap jk <ESC>
filetype plugin indent on

set ruler            " show the cursor position all the time
set showcmd          " display incomplete commands
set laststatus=2     " Always display the status line

set number
set numberwidth=5
set relativenumber

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-p> <cmd>Telescope find_files<cr>

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

call plug#end()
"install with :PlugInstall


"cusotm stuff just for neovim
source $HOME/.config/nvim/themes/airline.vim
source $HOME/.config/nvim/themes/onedark.vim
