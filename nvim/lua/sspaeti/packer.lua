local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

--
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use("ldelossa/litee.nvim")

	--color scheme
	use("rebelot/kanagawa.nvim")
	use("gruvbox-community/gruvbox")
	-- use 'joshdick/onedark.vim'
	use({
		"ldelossa/gh.nvim",
		requires = { { "ldelossa/litee.nvim" } },
	})

	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
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
			-- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/lspkind-nvim
			-- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/vim-vsnip
			-- - Removed /Users/sspaeti/.local/share/nvim/site/pack/packer/start/cmp-vsnip
		},
	})

	--rust
	use("neovim/nvim-lspconfig")
	use("simrat39/rust-tools.nvim")
	use("puremourning/vimspector")
	use({ "akinsho/bufferline.nvim", tag = "v3.*", requires = "nvim-tree/nvim-web-devicons" })
	-- use 'simrat39/symbols-outline.nvim'
	use("goolord/alpha-nvim") --does not work!?

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		-- or                            , branch = '0.1.x',
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	--theme
	use("sheerun/vim-polyglot")
	use("christoomey/vim-system-copy")
	--use 'valloric/youcompleteme'
	use("tpope/vim-surround") -- Surrounding ysw)

	--Text Objects:
	--Utilities for user-defined text objects
	use("kana/vim-textobj-user")
	--Text objects for indentation levels
	use("kana/vim-textobj-indent")
	--Text objects for Python
	use("bps/vim-textobj-python")
	--preview CSS colors inline
	-- use 'ap/vim-css-color'
	use("norcalli/nvim-colorizer.lua")
	-- comment healper

	-- use 'preservim/nerdcommenter'
	use("tpope/vim-commentary")

	-- should be installed out of the box by neovim?
	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
	use("nvim-treesitter/playground")

	--use 'ambv/black'
	use("psf/black")
	use("tpope/vim-fugitive")
	use("tpope/vim-rhubarb")

	use("kdheepak/lazygit.nvim")
	use("sindrets/diffview.nvim") --nvim gitdiff
	use("mhinz/vim-signify") --highlighing changes not commited to last commit
	use("APZelos/blamer.nvim") --gitlens blame style
	-- -- telescope requirements...
	-- use 'nvim-lua/popup.nvim'
	use("nvim-lua/plenary.nvim")
	use("ThePrimeagen/harpoon")
	use("jose-elias-alvarez/null-ls.nvim")
	-- use 'nvim-telescope/telescope.nvim'
	-- use 'nvim-telescope/telescope-fzy-native.nvim'
	--terminal
	use("voldikss/vim-floaterm")

	-- search
	use("dyng/ctrlsf.vim")
	use({ "junegunn/fzf", run = ":call fzf#install()" })
	use({ "junegunn/fzf.vim" })

	--File Navigation
	use("nvim-lualine/lualine.nvim")
	use("christoomey/vim-tmux-navigator")

	-- use 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
	use("kevinhwang91/rnvimr") --replaces 'francoiscabrol/ranger.vim'
	--nerdtree in lua
	use("kyazdani42/nvim-web-devicons") -- optional, for file icons
	use("kyazdani42/nvim-tree.lua")
	use("lukas-reineke/indent-blankline.nvim")
	use("mbbill/undotree")

	-- prettier
	use("sbdchd/neoformat")

	--support for go to defintion and autocompletion
	--use 'davidhalter/jedi-vim'
	-- use 'neoclide/coc.nvim', {'branch': 'release'}
	use("jmcantrell/vim-virtualenv")

	-- use({
	-- 	"folke/which-key.nvim",
	-- 	config = function()
	-- 		require("which-key").setup({})
	-- 	end,
	-- })
	use("github/copilot.vim")
	--Markdown (or any Outline)
	use("simrat39/symbols-outline.nvim")
	use("stevearc/aerial.nvim")
	----Obsidian
	-- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
	use("preservim/vim-markdown")
	use("godlygeek/tabular") -- needed by 'preservim/vim-markdown'
	use("epwalsh/obsidian.nvim") --using neovim with the Obsidian vault
	-- use 'vimwiki/vimwiki'

	-- connect with Obsidian Second Brain
  -- vim.opt.nocompatible = true --Recommende for VimWiki
	use({
		"vimwiki/vimwiki"
		-- config = function()
		-- 	vim.g.vimwiki_list = {
		-- 		{
		-- 			path = "~/Simon/Sync/SecondBrain",
		-- 			syntax = "markdown",
		-- 			ext = ".md",
		-- 		},
		-- 	}
			--vim.g.vimwiki_global_ext = 0 --only mark files in the second brain as vim viki, rest are standard markdown
		-- end,
	})

	--dbt
	-- use 'lepture/vim-jinja' --needed for dbt below but errors in hugo htmls...
	use("pedramnavid/dbt.nvim")
	use("glench/vim-jinja2-syntax")
	-- use 'ivanovyordan/dbt.vim'

	-- Java
	use("mfussenegger/nvim-jdtls")
	--use nvim in browser
	use({
		"glacambre/firenvim",
		run = function()
			vim.fn["firenvim#install"](0)
		end,
	})
end)
