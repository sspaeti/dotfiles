return {
  { "ldelossa/litee.nvim", event = "VeryLazy" },

  --color theme
  { "rebelot/kanagawa.nvim", event = "VeryLazy", priority = 1000, },
  { "AlexvZyl/nordic.nvim", event = "VeryLazy" },
  { "navarasu/onedark.nvim", event = "VeryLazy" },
  { "catppuccin/nvim", name = "catppuccin", event = "VeryLazy"  }, --light theme
  { "gruvbox-community/gruvbox", event = "VeryLazy" , priority = 1000, },
  { 'projekt0n/github-nvim-theme', event = "VeryLazy", version = "*", },
  {
    "ldelossa/gh.nvim",
    event = "VeryLazy",
    dependencies = { "ldelossa/litee.nvim" },
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    -- event = "VeryLazy",
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
  -- { --doesn't work well with trouble below
  --   "folke/todo-comments.nvim",
  --   event = "VeryLazy",
  --   dependencies = "nvim-lua/plenary.nvim",
  --   config = function()
  --     require("todo-comments").setup({
  --       vim.keymap.set("n", "<leader>tt", ":TodoTrouble<CR>", { noremap = true, silent = true }),
  --       vim.keymap.set("n", "<leader>tc", ":TodoTelescope<CR>", { noremap = true, silent = true }),
  --     })
  --   end,
  -- },
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("trouble").setup({
        vim.keymap.set("n", "<leader>lt", ":TroubleToggle<CR>", { noremap = true, silent = true }),
      })
    end,
  }, --nice diagnostic errors
  --rust
  { "neovim/nvim-lspconfig", event = "VeryLazy" },
  {
    "simrat39/rust-tools.nvim",
    event = "VeryLazy",
    config = function()
      local opts = {
        tools = {
          -- rust-tools options
        },
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", require("rust-tools").hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", require("rust-tools").code_action_group.code_action_group, { buffer = bufnr })
          end,
        }, -- rust-analyser options
      }
      require("rust-tools").setup(opts)
    end,
    ft = { "rust", "rs" },
  },
  --'puremourning/vimspector', --debugging in vim
  { "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons", event = "VeryLazy" },
  -- 'simrat39/symbols-outline.nvim',
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        require'alpha'.setup(require'alpha.themes.startify'.config)
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "christoomey/vim-system-copy", event = "VeryLazy" },
  --'valloric/youcompleteme',
  { "tpope/vim-surround", event = "VeryLazy" }, -- Surrounding ys',

  --Text Objects:
  --Utilities for user-defined text objects
  { "kana/vim-textobj-user", event = "VeryLazy" },
  --Text objects for indentation levels
  -- 'kana/vim-textobj-indent',
  --Text objects for Python
  { "bps/vim-textobj-python", event = "VeryLazy" },
  --preview CSS colors inline
  -- 'ap/vim-css-color',
  { "norcalli/nvim-colorizer.lua", event = "VeryLazy" },
  -- comment healper

  -- 'preservim/nerdcommenter',
  { "tpope/vim-commentary", event = "VeryLazy" },

  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = function()
      pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context", -- sticky functions
    },
    --test
    --test L3MON4D3
    --make some changes
  },

  -- 'psf/black',
  -- {'psf/black', lazy = true},
  { "psf/black", event = "VeryLazy" },

  { "tpope/vim-fugitive", event = "VeryLazy" },
  { "tpope/vim-rhubarb", event = "VeryLazy" },

  { "kdheepak/lazygit.nvim", event = "VeryLazy" },
  { "sindrets/diffview.nvim"}, --nvim gitdiff like vscode',
  { "mhinz/vim-signify", event = "VeryLazy" }, --highlighing changes not commited to last commmit

  { "APZelos/blamer.nvim", event = "VeryLazy" }, --gitlens blame style',
  -- -- telescope requirements...
  -- 'nvim-lua/popup.nvim',
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  { "ThePrimeagen/harpoon", event = "VeryLazy" },
  { "jose-elias-alvarez/null-ls.nvim"},
  -- 'nvim-telescope/telescope.nvim',
  -- 'nvim-telescope/telescope-fzy-native.nvim',
  --terminal
  { "voldikss/vim-floaterm", event = "VeryLazy" },

  -- search
  { "junegunn/fzf", build = ":call fzf#install()", event = "VeryLazy" },
  { "junegunn/fzf.vim", event = "VeryLazy" },

  --File Navigation
  { "nvim-lualine/lualine.nvim", event = "VeryLazy" },
  { "christoomey/vim-tmux-navigator", event = "VeryLazy" },

  -- 'akinsho/bufferline.nvim', { 'version': '*', }
  --nerdtreein lua
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    event = "VeryLazy",
  },
  { "lukas-reineke/indent-blankline.nvim", event = "VeryLazy" },
  { "mbbill/undotree", event = "VeryLazy" },
  "farmergreg/vim-lastplace", --remember last cursor position

  -- prettier
  { "sbdchd/neoformat", event = "VeryLazy" },

  --support for go to defintion and autocompletion
  --'davidhalter/jedi-vim',
  -- "jmcantrell/vim-virtualenv", --very slow: check if still needed?
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        triggers_blacklist = {
          n = { "s" },
          v = { "s" },
          i = { "<leader>" },
        },
      })
    end,
  },
  {
    "github/copilot.vim",
    event = "VeryLazy",
    -- config = function()
      --   require("copilot").setup {
        --     vim.keymap.set("n", "<leader>cn", "<Plug>(copilot-next)", { noremap = true, silent = true }),
        --     vim.keymap.set("n", "<leader>cp", "<Plug>(copilot-previous)", { noremap = true, silent = true }),
        --     vim.keymap.set("n", "<leader>cd", "<Plug>(copilot-dismiss)", { noremap = true, silent = true })
        --   }
        -- end
      },
      {
        "folke/zen-mode.nvim",
        event = "VeryLazy",
        config = function()
          require("zen-mode").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
          })
        end,
      },
      {
        "jcdickinson/wpm.nvim",
        event = "VeryLazy",
        config = function()
          require("wpm").setup({
            sections = {
              lualine_x = {
                require("wpm").wpm,
                require("wpm").historic_graph
              }
            }
          })
        end
      },
      -- install without yarn or npm
      {
        "iamcco/markdown-preview.nvim",
        event = "VeryLazy",
        build = function()
          vim.fn["mkdp#util#install"]()
        end,
      },

      --Markdown (or any Outline)
      { "simrat39/symbols-outline.nvim", event = "VeryLazy" },
      { "stevearc/aerial.nvim", event = "VeryLazy" },
      -- use({ "iamcco/markdown-preview.nvim", build = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
      ----Obsidian
      -- (optional) recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter:
      { "preservim/vim-markdown", event = "VeryLazy" },
      { "godlygeek/tabular", event = "VeryLazy" }, -- needed by 'preservim/vim-markdown'
      { "epwalsh/obsidian.nvim", event = "VeryLazy" }, --using neovim with the Obsidian vau'
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
              { "glench/vim-jinja2-syntax", event = "VeryLazy" },
              { "PedramNavid/dbtpal", 
              event = "VeryLazy",
              config = function()
                require("dbtpal").setup({
              -- Path to the dbt executable
              path_to_dbt = "dbt",
    
              -- Path to the dbt project, if blank, will auto-detect
              -- using currently open buffer for all sql,yml, and md files
              path_to_dbt_project = "",
    
              -- Path to dbt profiles directory
              path_to_dbt_profiles_dir = vim.fn.expand "~/.dbt",
    
              -- Search for ref/source files in macros and models folders
              extended_path_search = true,
    
              -- Prevent modifying sql files in target/(compiled|run) folders
              protect_compiled_files = true
    
              })
              end,
            },
              -- Java
              --"mfussenegger/nvim-jdtls", --removed until https://github.com/neovim/neovim/issues/20795 is fixed
              --use nvim in browser
              {
                "glacambre/firenvim",
                build = function()
                  vim.fn["firenvim#install"](0)
                end,
              },
            }
