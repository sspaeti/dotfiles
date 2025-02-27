return {
  { "christoomey/vim-system-copy", event = "VeryLazy" },
  { "tpope/vim-surround",          event = "VeryLazy" }, -- Surrounding ys',
  { "nvim-lua/plenary.nvim",       event = "VeryLazy" }, -- Needed for obsidian.nvim
  
  --Text Objects:
  --Utilities for user-defined text objects
  { "kana/vim-textobj-user",       event = "VeryLazy" },
  { "tpope/vim-commentary",        event = "VeryLazy" },
  { "tpope/vim-abolish",           event = "VeryLazy" },


  -- search
  { "junegunn/fzf",                build = ":call fzf#install()", event = "VeryLazy" },
  { "junegunn/fzf.vim",            event = "VeryLazy" },
  { "mbbill/undotree",             event = "VeryLazy" },
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

}
