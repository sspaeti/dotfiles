local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end
local util = require'packer.util'

local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn
-- ensure that packer is installed
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
    execute 'packadd packer.nvim'
end
vim.cmd('packadd packer.nvim')
packer.init({
  package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

--here we define packer installed plugins
--return require('packer').startup(function()
packer.startup(function(use)

  use 'ldelossa/litee.nvim'
  use {
    'ldelossa/gh.nvim',
    requires = { { 'ldelossa/litee.nvim' } }
  }
  --instaling plugs
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  --cmp does not work?
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/lspkind-nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/cmp-path'
  --rust
  use 'neovim/nvim-lspconfig' 
  use 'simrat39/rust-tools.nvim'
  use 'puremourning/vimspector'
	use 'christoomey/vim-tmux-navigator'
  use {'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}
  -- use 'simrat39/symbols-outline.nvim'
  use 'goolord/alpha-nvim' --does not work!?

end)
