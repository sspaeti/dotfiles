return {
  {
    "folke/trouble.nvim", --nice diagnostic errors
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("trouble").setup({
        vim.keymap.set("n", "<leader>lt", ":TroubleToggle<CR>", { noremap = true, silent = true }),
      })
    end,
  },
  { --doesn't work well with trouble below
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("todo-comments").setup({
      vim.keymap.set("n", "<leader>tt", ":TodoTrouble<CR>", { noremap = true, silent = true }),
      vim.keymap.set("n", "<leader>tc", ":TodoTelescope<CR>", { noremap = true, silent = true }),
    })
  end,
  },
}
