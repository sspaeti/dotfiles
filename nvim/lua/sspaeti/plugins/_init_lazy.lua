return {
  --rust
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
            vim.keymap.set(
              "n",
              "<C-space>",
              require("rust-tools").hover_actions.hover_actions,
              { buffer = bufnr }
            )
            -- Code action groups
            vim.keymap.set(
              "n",
              "<Leader>a",
              require("rust-tools").code_action_group.code_action_group,
              { buffer = bufnr }
            )
          end,
        }, -- rust-analyser options
      }
      require("rust-tools").setup(opts)
    end,
    ft = { "rust", "rs" },
  },
  --'puremourning/vimspector', --debugging in vim
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
    end,
  },
  { "christoomey/vim-system-copy", event = "VeryLazy" },
  --'valloric/youcompleteme',
  { "tpope/vim-surround",          event = "VeryLazy" }, -- Surrounding ys',

  --Text Objects:
  --Utilities for user-defined text objects
  { "kana/vim-textobj-user",       event = "VeryLazy" },
  --Text objects for indentation levels
  -- 'kana/vim-textobj-indent',
  --Text objects for Python
  { "bps/vim-textobj-python",      event = "VeryLazy" },
  --preview CSS colors inline
  -- 'ap/vim-css-color',
  -- { "NvChad/nvim-colorizer.lua", event = "VeryLazy" },
  -- comment healper

  -- 'preservim/nerdcommenter',
  { "tpope/vim-commentary",        event = "VeryLazy" },
  { "tpope/vim-abolish", event = "VeryLazy"},

  -- 'psf/black',
  -- {'psf/black', lazy = true},
  { "psf/black",                   event = "VeryLazy" },

  { "tpope/vim-fugitive",          event = "VeryLazy" },
  { "tpope/vim-rhubarb",           event = "VeryLazy" },

  { "kdheepak/lazygit.nvim",       event = "VeryLazy" },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        hooks = {
          hooks = {
            diff_buf_win_enter = function(bufnr)
              vim.cmd("norm! gg]c")
            end,
          },
          diff_buf_read = function(bufnr)
            -- print("Opening diff buffer...")
            vim.cmd("norm! gg]c")
            if vim.fn.search("]c") ~= 0 then
              vim.cmd("norm! zz")
            end
          end,
          diff_buf_win_enter = function(bufnr)
            vim.opt_local.foldlevel = 99
          end,
        },
      })
    end,
  },
  { "mhinz/vim-signify",              event = "VeryLazy" }, --highlighing changes not commited to last commmit

  { "APZelos/blamer.nvim",            event = "VeryLazy" }, --gitlens blame style',
  -- 'nvim-lua/popup.nvim',
  { "nvim-lua/plenary.nvim",          event = "VeryLazy" },
  -- search
  { "junegunn/fzf",                   build = ":call fzf#install()", event = "VeryLazy" },
  { "junegunn/fzf.vim",               event = "VeryLazy" },
  -- {
  --   'stevearc/oil.nvim',
  --   event = "VeryLazy",
  --   -- Optional dependencies
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  -- },
  { "mbbill/undotree",                event = "VeryLazy" },
  {
    "tzachar/highlight-undo.nvim",
    event = "VeryLazy",
    config = function()
      require("highlight-undo").setup({
        hlgroup = "HighlightUndo",
        duration = 600,
        keymaps = {
          { "n", "u",     "undo", {} },
          { "n", "<C-r>", "redo", {} },
        },
      })
    end,
  },
  "farmergreg/vim-lastplace", --remember last cursor position

  -- prettier
  { "sbdchd/neoformat",         event = "VeryLazy" },

  --support for go to defintion and autocompletion
  --'davidhalter/jedi-vim',
  -- "jmcantrell/vim-virtualenv", --very slow: check if still needed?
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
            require("wpm").historic_graph,
          },
        },
      })
    end,
  },

  --dbt
  -- 'lepture/vim-jinja', --needed for dbt below but errors in hugo htmls...
  { "glench/vim-jinja2-syntax", event = "VeryLazy" },
  --{
  --  "folke/flash.nvim",
  --  event = "VeryLazy",
  --  ---@type Flash.Config
  --  opts = {},
  --  -- stylua: ignore
  --  keys = {
  --    { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  --    { "F", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  --    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
  --    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  --    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  --  },
  --},
  --
  --{
  {
    "hiphish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },
  {"alexlafroscia/tree-sitter-glimmer", event = "VeryLazy"},
  {"LunarVim/bigfile.nvim", event = "VeryLazy"}
}
