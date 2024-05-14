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

      -- nmap <expr> <C-Q> db#op_exec()
      -- xmap <expr> <C-Q> db#op_exec()
      vim.api.nvim_set_keymap('n', '<leader>S', '<Plug>(DBUI_ExecuteQuery)', {noremap = true})
      vim.api.nvim_set_keymap('n', '<leader><CR>', '<Plug>(DBUI_ExecuteQuery)', {noremap = true})

      vim.api.nvim_set_keymap('x', '<leader>S', '<Plug>(DBUI_ExecuteQuery)', {noremap = true})
      vim.api.nvim_set_keymap('x', '<leader><CR>', '<Plug>(DBUI_ExecuteQuery)', {noremap = true})


      -- Does not work: Define the custom key mapping for executing the query under the cursor
      -- vim.api.nvim_set_keymap('n', '<leader><CR>', 'vip<leader>S', { noremap = true, silent = true })

      -- Remap default action to open in vertical split
      -- vim.api.nvim_set_keymap('n', 'o', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})
      -- vim.api.nvim_set_keymap('n', '<CR>', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})

    end,
  },

}
