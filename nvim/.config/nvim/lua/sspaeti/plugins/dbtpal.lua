return {
  "PedramNavid/dbtpal",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  ft = {
    "sql",
    "md",
    "yaml",
  },
  keys = {
    { "<leader>dbr", "<cmd>DbtRun<cr>" },
    { "<leader>dba", "<cmd>DbtRunAll<cr>" },
    { "<leader>dbt", "<cmd>DbtTest<cr>" },
    { "<leader>fd",  "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
  },
  config = function()
    require("dbtpal").setup({
      path_to_dbt = "dbt",
      path_to_dbt_project = "",
      path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
      extended_path_search = true,
      protect_compiled_files = true,
    })
    require("telescope").load_extension("dbtpal")
  end,
}
