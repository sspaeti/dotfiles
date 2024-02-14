return {
  {
    "folke/trouble.nvim", --nice diagnostic errors
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("trouble").setup({
        -- document_diagnostics needed, otherwise todo-comments below breaks it: https://github.com/folke/todo-comments.nvim/issues/158
        vim.keymap.set("n", "<leader>lt", ":Trouble document_diagnostics<CR>", { noremap = true, silent = true }),
      })
    end,
  },
  {
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
