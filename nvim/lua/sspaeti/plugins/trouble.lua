return {
  {
    "folke/trouble.nvim", --nice diagnostic errors
    dependencies = "nvim-tree/nvim-web-devicons",
    event = { "VeryLazy"},
    keys = {
      -- document_diagnostics needed, otherwise todo-comments below breaks it: https://github.com/folke/todo-comments.nvim/issues/158
      {
        "<leader>lt", ":Trouble document_diagnostics<CR>", desc = "Trouble Open Diagnostics", noremap = true, silent = true,
      },
    },
    opts = {}
  },
  {
    "folke/todo-comments.nvim",
    event = { "VeryLazy"},
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>tt", ":TodoTrouble<CR>", desc = "TodoTrouble", noremap = true, silent = true },
      { "<leader>tc", ":TodoTelescope<CR>", desc = "TodoTelescope", noremap = true, silent = true },
    },
    opts = {} --needed!
  },
}
