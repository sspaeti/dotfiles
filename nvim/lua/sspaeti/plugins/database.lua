return {
  --use nvim in browser
  { "kristijanhusak/vim-dadbod-ui",         event = "VeryLazy" },
  { "kristijanhusak/vim-dadbod-completion", event = "VeryLazy" },
  -- Database
  {
    "tpope/vim-dadbod",
    lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    event = "VeryLazy",
    config = function()
      vim.g.db_ui_execute_on_save = 0 --do not execute on save
      vim.g.db_ui_win_position = "right"
    end,
  },

}
