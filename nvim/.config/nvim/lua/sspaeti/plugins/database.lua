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

      -- Ctrl+Enter: run the statement under cursor without selecting.
      -- Statement = lines between the previous and the next line ending in ';'
      -- (blank lines inside a statement are fine). Buffers without any ';'
      -- fall back to the paragraph (vip) behaviour.
      local function run_statement_under_cursor()
        local plug = vim.api.nvim_replace_termcodes('<Plug>(DBUI_ExecuteQuery)', true, false, true)
        local ends_statement = function(lnum)
          return vim.fn.getline(lnum):match(';%s*$') ~= nil
        end

        if vim.fn.search(';\\s*$', 'nw') == 0 then
          vim.cmd('normal! vip')
          vim.api.nvim_feedkeys(plug, 'x', false)
          return
        end

        local cur, last = vim.fn.line('.'), vim.fn.line('$')
        local first = cur
        while first > 1 and not ends_statement(first - 1) do
          first = first - 1
        end
        local final = cur
        while final < last and not ends_statement(final) do
          final = final + 1
        end

        vim.cmd(string.format('normal! %dGV%dG', first, final))
        vim.api.nvim_feedkeys(plug, 'x', false)
      end

      vim.keymap.set('n', '<C-CR>', run_statement_under_cursor, { desc = 'DB: run statement under cursor' })
      vim.api.nvim_set_keymap('x', '<C-CR>', '<Plug>(DBUI_ExecuteQuery)', { noremap = true })

      -- Remap default action to open in vertical split
      -- vim.api.nvim_set_keymap('n', 'o', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})
      -- vim.api.nvim_set_keymap('n', '<CR>', '<Plug>(DBUI_SelectLineVsplit)', {noremap = true})
    end,
  },
}
