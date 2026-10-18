return {
  { "christoomey/vim-system-copy", event = "VeryLazy" },
  { "tpope/vim-surround",          event = "VeryLazy" }, -- Surrounding ys',
  { "nvim-lua/plenary.nvim",       event = "VeryLazy" }, -- Needed for obsidian.nvim

  --Text Objects:
  --Utilities for user-defined text objects
  { "kana/vim-textobj-user",       event = "VeryLazy" },
  { "tpope/vim-commentary",        event = "VeryLazy" },
  { "tpope/vim-abolish",           event = "VeryLazy" },

  { "kdheepak/lazygit.nvim",       event = "VeryLazy" },

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
  -- wpm.nvim removed: its InsertCharPre handler cost ~34ms per keystroke on a
  -- 4k-word chapter on the Pi, and lualine shows nvim-prose counts, not wpm.
}
