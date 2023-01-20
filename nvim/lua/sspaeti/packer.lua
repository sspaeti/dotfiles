local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
--
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

return require("lazy").setup({

	'ldelossa/litee.nvim',

	--color scheme
	'rebelot/kanagawa.nvim',
	'gruvbox-community/gruvbox',
	-- 'joshdick/onedark.vim',
	{
		"ldelossa/gh.nvim",
		dependencies = { { "ldelossa/litee.nvim" } },
	},

	{
		"VonHeikemen/lsp-zero.nvim",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	},

	--rust
	'neovim/nvim-lspconfig',
	'simrat39/rust-tools.nvim',
	'puremourning/vimspector',
	{ "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
	-- 'simrat39/symbols-outline.nvim',
	'goolord/alpha-nvim', --does not work!?

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		-- or                            , branch = '0.1.x',
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},

	--theme
	'sheerun/vim-polyglot',
	'christoomey/vim-system-copy',
	--'valloric/youcompleteme',
	'tpope/vim-surround', -- Surrounding ys',

	--Text Objects:
	--Utilities for user-defined text objects
	'kana/vim-textobj-user',
	--Text objects for indentation levels
	'kana/vim-textobj-indent',
	--Text objects for Python
	'bps/vim-textobj-python',
	--preview CSS colors inline
	-- 'ap/vim-css-color',
	'norcalli/nvim-colorizer.lua',
	-- comment healper

	-- 'preservim/nerdcommenter',
	'tpope/vim-commentary',

	-- should be installed out of the box by neovim?
	{
		'nvim-treesitter/nvim-treesitter',
		build = function()
			pcall(require('nvim-treesitter.install').update { with_sync = true })
		end,
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects' ,
		}
	},

	--'ambv/black',
	'psf/black',
	'tpope/vim-fugitive',
	'tpope/vim-rhubarb',

	'kdheepak/lazygit.nvim',
	'sindrets/diffview.nvim', --nvim gitdi',
	'mhinz/vim-signify', --highlighing changes not commited to last comm',
	'APZelos/blamer.nvim', --gitlens blame sty',
	-- -- telescope requirements...
	-- 'nvim-lua/popup.nvim',
	'nvim-lua/plenary.nvim',
	'ThePrimeagen/harpoon',
	'jose-elias-alvarez/null-ls.nvim',
	-- 'nvim-telescope/telescope.nvim',
	-- 'nvim-telescope/telescope-fzy-native.nvim',
	--terminal
	'voldikss/vim-floaterm',

	-- search
	'dyng/ctrlsf.vim',
	{ "junegunn/fzf", build = ":call fzf#install()" },
	'junegunn/fzf.vim',

	--File Navigation
	'nvim-lualine/lualine.nvim',
	'christoomey/vim-tmux-navigator',

	-- 'akinsho/bufferline.nvim', { 'tag': 'v2.*', }
	'kevinhwang91/rnvimr',
	--nerdtree in lua
	-- 'kyazdani42/nvim-web-devicons', -- optional, for file ico',
	'kyazdani42/nvim-tree.lua',
	'lukas-reineke/indent-blankline.nvim',
	'mbbill/undotree',

	-- prettier
	'sbdchd/neoformat',

	--support for go to defintion and autocompletion
	--'davidhalter/jedi-vim',
	-- 'neoclide/coc.nvim', {'branch': 'release',}
	-- "jmcantrell/vim-virtualenv", --very slow: check if still needed?

	-- {
	-- 	"folke/which-key.nvim",
	-- 	config = function()
	-- 		require("which-key").setup({})
	-- 	end,
	-- },
	'github/copilot.vim',
	--Markdown (or any Outline)
	'simrat39/symbols-outline.nvim',
	'stevearc/aerial.nvim',
	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end
	},
	-- install without yarn or npm
	{
			"iamcco/markdown-preview.nvim",
			build = function() vim.fn["mkdp#util#install"]() end,
		},

	-- use({ "iamcco/markdown-preview.nvim", build = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
	----Obsidian
	-- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
	'preservim/vim-markdown',
	'godlygeek/tabular', -- needed by 'preservim/vim-markdown'
	'epwalsh/obsidian.nvim', --using neovim with the Obsidian vau'
	-- 'vimwiki/vimwiki',

	-- connect with Obsidian Second Brain
  -- vim.opt.nocompatible = true --Recommende for VimWiki
	--{
	--	"vimwiki/vimwiki"
	--	-- config = function()
	--	-- 	vim.g.vimwiki_list = {
	--	-- 		{
	--	-- 			path = "~/Simon/Sync/SecondBrain",
	--	-- 			syntax = "markdown",
	--	-- 			ext = ".md",
	--	-- 		},
	--	-- 	}
	--		--vim.g.vimwiki_global_ext = 0 --only mark files in the second brain as vim viki, rest are standard markdown
	--	-- end,
	--},

	--dbt
	-- 'lepture/vim-jinja', --needed for dbt below but errors in hugo htmls...
	'pedramnavid/dbt.nvim',
	'glench/vim-jinja2-syntax',
	-- 'ivanovyordan/dbt.vim',

	-- Java
	--"mfussenegger/nvim-jdtls", --removed until https://github.com/neovim/neovim/issues/20795 is fixed
	--use nvim in browser
	{
		"glacambre/firenvim",
		build = function()
			vim.fn["firenvim#install"](0)
		end,
	},
	--to delete later
	'dstein64/vim-startuptime',
})
