return {
   -- Autocompletion
   'hrsh7th/nvim-cmp',
   event = 'InsertEnter',
   dependencies = {
     -- Snippet Engine & its associated nvim-cmp source
     {
       'L3MON4D3/LuaSnip',
       build = (function()
         -- Build Step is needed for regex support in snippets
         -- This step is not supported in many windows environments
         -- Remove the below condition to re-enable on windows
         if vim.fn.has 'win32' == 1 then
           return
         end
         return 'make install_jsregexp'
       end)(),
     },
     -- Adds LSP completion capabilities
     "hrsh7th/cmp-nvim-lsp",
     "hrsh7th/cmp-buffer", -- source for text in buffer
     "hrsh7th/cmp-path", -- source for file system paths
     "saadparwaiz1/cmp_luasnip", -- for autocompletion
     "rafamadriz/friendly-snippets", -- useful snippets
     "onsails/lspkind.nvim", -- vs-code like pictograms
     { "antosha417/nvim-lsp-file-operations", config = true },
   },
   config = function()
     local cmp = require("cmp")
     local luasnip = require("luasnip")
     local lspkind = require("lspkind")

     -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
     require("luasnip.loaders.from_vscode").lazy_load()

     --Copilot cycle through suggestions
     -- vim.cmd([[
     -- imap <silent> <Leader>cn <Plug>(copilot-next)
     -- imap <silent> <Leader>cp <Plug>(copilot-previous)
     -- imap <silent> <Leader>cd <Plug>(copilot-dismiss)
     -- ]])

    cmp.setup({
      window = {
         completion = cmp.config.window.bordered(),
         documentation = cmp.config.window.bordered(),
       },
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
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
        { name = "vsnip" },
        { name = "path" },
        { name = "luasnip" },
        { name = "obsidian" },
        { name = "obsidian_new" },
        { name = "nvim_lsp:lua_ls" },
        { name = "nvim_lsp:null-ls" },
        { name = "dictionary", keyword_length = 3, priority = 5, keyword_pattern = [[\w\+]] }, -- from uga-rosa/cmp-dictionary plug
      }),
      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
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
