return {
  'ldelossa/litee.nvim',

  --color scheme
  'rebelot/kanagawa.nvim',
  {'AlexvZyl/nordic.nvim', event = "VeryLazy"},
  --add one dark theme
  { 'navarasu/onedark.nvim', event = "VeryLazy"},
  { 'gruvbox-community/gruvbox', event = "VeryLazy"},
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
  {'simrat39/rust-tools.nvim', event = "VeryLazy"},
  -- 'puremourning/vimspector', --debugging in vim
  { "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
  -- 'simrat39/symbols-outline.nvim',
  {'goolord/alpha-nvim', event = "VeryLazy"}, --does not work!?

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    -- or                            , branch = '0.1.x',
    dependencies = { { "nvim-lua/plenary.nvim" } },
  },
  'christoomey/vim-system-copy',
  --'valloric/youcompleteme',
  {'tpope/vim-surround', event = "VeryLazy"}, -- Surrounding ys',

  --Text Objects:
  --Utilities for user-defined text objects
  'kana/vim-textobj-user',
  --Text objects for indentation levels
  -- 'kana/vim-textobj-indent',
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

  -- 'psf/black',
  -- {'psf/black', lazy = true},
  {'psf/black', event = "VeryLazy"},

  {'tpope/vim-fugitive', event = "VeryLazy"},
  {'tpope/vim-rhubarb', event = "VeryLazy"},

  {'kdheepak/lazygit.nvim', event = "VeryLazy"},
  {'sindrets/diffview.nvim', event = "VeryLazy"}, --nvim gitdi',
  {'mhinz/vim-signify', event = "VeryLazy"}, --highlighing changes not commited to last comm',
  {'APZelos/blamer.nvim', event = "VeryLazy"}, --gitlens blame sty',
  -- -- telescope requirements...
  -- 'nvim-lua/popup.nvim',
  {'nvim-lua/plenary.nvim', event = "VeryLazy"},
  {'ThePrimeagen/harpoon', event = "VeryLazy"},
  {'jose-elias-alvarez/null-ls.nvim', event = "VeryLazy"},
  -- 'nvim-telescope/telescope.nvim',
  -- 'nvim-telescope/telescope-fzy-native.nvim',
  --terminal
  {'voldikss/vim-floaterm', event = "VeryLazy"},

  -- search
  {'dyng/ctrlsf.vim', event = "VeryLazy"},
  { "junegunn/fzf", build = ":call fzf#install()" },
  'junegunn/fzf.vim',

  --File Navigation
  'nvim-lualine/lualine.nvim',
  'christoomey/vim-tmux-navigator',

  -- 'akinsho/bufferline.nvim', { 'tag': 'v2.*', }
  {'kevinhwang91/rnvimr', event = "VeryLazy"},
  --nerdtree in lua
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    }, 
    event = "VeryLazy",
    window = {
      mappings = {
        ["S"] = "open_split",
        ["s"] = nil,
        ["SS"] = "open_vsplit",
      }
    }
  },

  'lukas-reineke/indent-blankline.nvim',
  {'mbbill/undotree', event = "VeryLazy"},

  -- prettier
  {'sbdchd/neoformat', event = "VeryLazy"},

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
      {'github/copilot.vim', event = "VeryLazy"},
      --Markdown (or any Outline)
      {'simrat39/symbols-outline.nvim', event = "VeryLazy"},
      {'stevearc/aerial.nvim', event = "VeryLazy"},
      {
        "folke/zen-mode.nvim",
        event = "VeryLazy",
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
        event = "VeryLazy",
        build = function() vim.fn["mkdp#util#install"]() end,
      },

      -- use({ "iamcco/markdown-preview.nvim", build = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
      ----Obsidian
      -- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
      {'preservim/vim-markdown', event = "VeryLazy"},
      {'godlygeek/tabular', event = "VeryLazy"}, -- needed by 'preservim/vim-markdown'
      {'epwalsh/obsidian.nvim', event = "VeryLazy"}, --using neovim with the Obsidian vau'
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
              {'pedramnavid/dbt.nvim', event = "VeryLazy"},
              {'glench/vim-jinja2-syntax', event = "VeryLazy"},
              -- 'ivanovyordan/dbt.vim',

              -- Java
              --"mfussenegger/nvim-jdtls", --removed until https://github.com/neovim/neovim/issues/20795 is fixed
              --use nvim in browser
              {
                "glacambre/firenvim",
                event = "VeryLazy",
                build = function()
                  vim.fn["firenvim#install"](0)
                end,
              },
              --to delete later
              {'dstein64/vim-startuptime', event = "VeryLazy"},
            }
