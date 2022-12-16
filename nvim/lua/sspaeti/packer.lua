-- local status, packer = pcall(require, "packer")
-- if (not status) then
--   print("Packer is not installed")
--   return
-- end
-- local util = require'packer.util'

-- local vim = vim
-- local execute = vim.api.nvim_command
-- local fn = vim.fn
-- -- ensure that packer is installed
-- local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
-- if fn.empty(fn.glob(install_path)) > 0 then
--     execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
--     execute 'packadd packer.nvim'
-- end

-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'ldelossa/litee.nvim'

  --color scheme
  use 'rebelot/kanagawa.nvim'

  use {
    'ldelossa/gh.nvim',
    requires = { { 'ldelossa/litee.nvim' } }
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
 -- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/lspkind-nvim
 -- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/vim-vsnip
 -- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/cmp-vsnip
    }
  }

  --rust
  use 'neovim/nvim-lspconfig'
  use 'simrat39/rust-tools.nvim'
  use 'puremourning/vimspector'
	use 'christoomey/vim-tmux-navigator'
  use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
  -- use 'simrat39/symbols-outline.nvim'
  use 'goolord/alpha-nvim' --does not work!?


  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.0',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }



  --theme
  use 'sheerun/vim-polyglot'
  --themes
  -- use 'joshdick/onedark.vim'
  use 'gruvbox-community/gruvbox'
  use 'rebelot/kanagawa.nvim'
  use 'christoomey/vim-system-copy'
  --use 'valloric/youcompleteme'
  use 'tpope/vim-surround' -- Surrounding ysw)

  --Text Objects:
  --Utilities for user-defined text objects
  use 'kana/vim-textobj-user'
  --Text objects for indentation levels
  use 'kana/vim-textobj-indent'
  --Text objects for Python
  use 'bps/vim-textobj-python'
  --preview CSS colors inline
  -- use 'ap/vim-css-color'
  use 'norcalli/nvim-colorizer.lua'

  -- comment healper
  -- use 'preservim/nerdcommenter'
  use 'tpope/vim-commentary'

  -- should be installed out of the box by neovim?
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('nvim-treesitter/playground')

  --use 'ambv/black'
  use 'psf/black'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'

  use 'kdheepak/lazygit.nvim'
  use 'sindrets/diffview.nvim' --nvim gitdiff
  use 'mhinz/vim-signify' --highlighing changes not commited to last commit
  use 'APZelos/blamer.nvim' --gitlens blame style
  -- -- telescope requirements...
  -- use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'ThePrimeagen/harpoon'
  use 'jose-elias-alvarez/null-ls.nvim'
  -- use 'nvim-telescope/telescope.nvim'
  -- use 'nvim-telescope/telescope-fzy-native.nvim'
  --terminal
  use 'voldikss/vim-floaterm'

  -- search
  use 'dyng/ctrlsf.vim'
  use { 'junegunn/fzf', run = ":call fzf#install()" }
  use { 'junegunn/fzf.vim' }

  --File Navigation
  use 'nvim-lualine/lualine.nvim'
  use 'christoomey/vim-tmux-navigator'
  -- If you want to have icons in your statusline choose one of these
  use 'kyazdani42/nvim-web-devicons'

  -- use 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
  use 'kevinhwang91/rnvimr' --replaces 'francoiscabrol/ranger.vim'
  --nerdtree in lua
  use 'kyazdani42/nvim-web-devicons' -- optional, for file icons
  use 'kyazdani42/nvim-tree.lua'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'mbbill/undotree'

  --fast async search
  use 'dyng/ctrlsf.vim'
  -- prettier
  use 'sbdchd/neoformat'

  --support for go to defintion and autocompletion
  --use 'davidhalter/jedi-vim'
  -- use 'neoclide/coc.nvim', {'branch': 'release'}
  use 'jmcantrell/vim-virtualenv'

  use 'liuchengxu/vim-which-key'
  use 'github/copilot.vim'
  --Markdown (or any Outline)
  use 'simrat39/symbols-outline.nvim'
  use 'stevearc/aerial.nvim'
  ----Obsidian
  -- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
  use 'preservim/vim-markdown'
  use 'godlygeek/tabular'  -- needed by 'preservim/vim-markdown'
  use 'epwalsh/obsidian.nvim' --using neovim with the Obsidian vault 
  -- use 'vimwiki/vimwiki'
  --dbt
  -- use 'lepture/vim-jinja' --needed for dbt below but errors in hugo htmls...
  use 'pedramnavid/dbt.nvim'
  use 'glench/vim-jinja2-syntax'
  -- use 'ivanovyordan/dbt.vim'

  -- Java
  use 'mfussenegger/nvim-jdtls'
  --use nvim in browser
  use {
	  'glacambre/firenvim',
	  run = function() vim.fn['firenvim#install'](0) end 
  }

end)