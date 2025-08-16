return {
   -- Autocompletion
   'hrsh7th/nvim-cmp',
   event = 'InsertEnter',
   dependencies = {
     -- Adds LSP completion capabilities
     "hrsh7th/cmp-buffer", -- source for text in buffer
     "hrsh7th/cmp-path", -- source for file system paths
     { "antosha417/nvim-lsp-file-operations", config = true },
   },
   config = function()
     local cmp = require("cmp")

    cmp.setup({
      window = {
         completion = cmp.config.window.bordered(),
         documentation = cmp.config.window.bordered(),
       },
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        -- ["<C-e>"] = cmp.mapping.close(),
        ["<C-y>"] = cmp.mapping.confirm({ select = false }),
        ["<C-x>"] = cmp.mapping.confirm({ select = false }),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        -- disable completion with tab this helps with copilot setup
        ["<Tab>"] = nil,
        ["<S-Tab>"] = nil
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1 },
        { name = "path" },
        { name = "obsidian" },
        { name = "obsidian_new" },
        { name = "nvim_lsp:lua_ls" },
        { name = "dictionary", keyword_length = 3, priority = 5, keyword_pattern = [[\w\+]] }, -- from uga-rosa/cmp-dictionary plug
      }),
    })

  -- Setup autocompletion for vim-dadbod
  cmp.setup.filetype({ "sql" }, {
    sources = {
      { name = "vim-dadbod-completion" },
      { name = "buffer" },
    },
  })
  end,
}
