return {
  --rust
  {
    "neovim/nvim-lspconfig",
    ft = { "rust" },
    config = function()
      -- Configure rust_analyzer using the new vim.lsp.config API
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })

      -- Enable rust_analyzer for rust files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          vim.lsp.enable("rust_analyzer")

          -- Set up keymaps for rust files
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "<C-space>", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover actions" })
          vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code actions" })
        end,
      })
    end,
  },
  --'puremourning/vimspector', --debugging in vim
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
  { "tpope/vim-abolish",           event = "VeryLazy" },

  -- 'psf/black',
  -- {'psf/black', lazy = true},
  { "psf/black",                   event = "VeryLazy" },

  { "tpope/vim-fugitive",          event = "VeryLazy" },
  { "tpope/vim-rhubarb",           event = "VeryLazy" },

  { "kdheepak/lazygit.nvim",       event = "VeryLazy" },
  { --potentially replace with esmuellert/vscode-diff.nvim as below does not get updates?
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
  -- 'nvim-lua/popup.nvim',
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  -- search
  { "junegunn/fzf",          build = ":call fzf#install()", event = "VeryLazy" },
  { "junegunn/fzf.vim",      event = "VeryLazy" },
  -- {
  --   'stevearc/oil.nvim',
  --   event = "VeryLazy",
  --   -- Optional dependencies
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  -- },
  --
  { 'echasnovski/mini.icons', version = '*',  event = "VeryLazy"  }, --for snacks.nvim
  { "mbbill/undotree",       event = "VeryLazy" },
  {
    "tzachar/highlight-undo.nvim",
    event = "VeryLazy",
    config = function()
      require("highlight-undo").setup({
        hlgroup = "HighlightUndo",
        duration = 600,
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
  { "alexlafroscia/tree-sitter-glimmer", event = "VeryLazy" },
  { "LunarVim/bigfile.nvim",             event = "VeryLazy" },
  { "towolf/vim-helm",                   event = "VeryLazy", ft = "helm" }
}
