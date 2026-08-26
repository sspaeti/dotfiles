return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod',                     lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql' }, lazy = true }, -- Optional
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
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
      -- Database connections
      vim.g.dbs = {
        local_postgres_postgres = 'postgres://postgres@localhost:5432/postgres',
        duckdb_memory = 'duckdb:',
        duckdb_file = 'duckdb:///home/sspaeti/Documents/sandbox/duckdbs/default_nvim.duckdb',
        -- Local Exasol (docker exasol/nano). Custom adapter in autoload/db/adapter/exasol.vim
        -- shells out to usql; validateservercertificate=0 = DBeaver's driver property for
        -- the self-signed cert. Credentials come from the environment (set in zsh).
        exasol_local = 'exasol://' .. (os.getenv('EXASOL_NANO_USER') or '')
            .. ':' .. (os.getenv('EXASOL_NANO_PW') or '')
            .. '@127.0.0.1:8563?validateservercertificate=0',
      }

      vim.g.db_ui_execute_on_save = 0 --do not execute on save
      vim.g.db_ui_win_position = "right"

      -- nmap <expr> <C-Q> db#op_exec()
      -- xmap <expr> <C-Q> db#op_exec()
      vim.api.nvim_set_keymap('n', '<leader>S', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader><CR>', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })

      vim.api.nvim_set_keymap('x', '<leader>S', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })
      vim.api.nvim_set_keymap('x', '<leader><CR>', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })

      -- Ctrl+Enter: run statement under cursor (paragraph) without selecting;
      -- needs noremap=false so the <Plug> mapping expands
      vim.api.nvim_set_keymap('n', '<C-CR>', 'vip<Plug>(DBUI_ExecuteQuery)', { noremap = false })
      vim.api.nvim_set_keymap('x', '<C-CR>', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })

      -- Remap default action to open in vertical split
      -- vim.api.nvim_set_keymap('n', 'o', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})
      -- vim.api.nvim_set_keymap('n', '<CR>', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})
    end,
  },
}
