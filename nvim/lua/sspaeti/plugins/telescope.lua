return
{
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ft", "<cmd>Telescope resume<cr>", desc = "Resume Telescope" },
    {
      "<leader>ff",
      function() require("telescope.builtin").find_files({}) end,
      desc = "Find Plugin File",
    },
    {
      "<C-p>",
      function() require("telescope.builtin").git_files({}) end,
      desc = "Find Open Files",
    },
    {
      "<leader>fg",
      function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end,
      desc = "Grep String",
    },
    {
      "<leader>?",
      function() require("telescope.builtin").keymaps({}) end,
      desc = "Telescope: Grep Keymaps",
    },
    ----lsp
    --{"gr", function() require("telescope.builtin").lsp_references() end, desc = "Telescope LSP References" },
    --{"gC", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Telescope LSP Document Symbols" },
  },
  opts = {}
}
