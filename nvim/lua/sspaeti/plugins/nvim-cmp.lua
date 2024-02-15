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
     'saadparwaiz1/cmp_luasnip',

     -- Adds LSP completion capabilities
     'hrsh7th/cmp-nvim-lsp',
     'hrsh7th/cmp-path',

     -- Adds a number of user-friendly snippets
     'rafamadriz/friendly-snippets',
   },
   config = function()

     local cmp = require("cmp")
     local cmp_select = { behavior = cmp.SelectBehavior.Select }
     local cmp_mappings = {
       ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
       ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
       ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
       ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
       ["<C-d>"] = cmp.mapping.scroll_docs(-4),
       ["<C-u>"] = cmp.mapping.scroll_docs(4),
       ["<C-e>"] = cmp.mapping.close(),
       ["<CR>"] = cmp.mapping.confirm({ select = true }),
       ["<C-Space>"] = cmp.mapping.complete()
     }
     -- remove buffer (that suggests words from current buffer): https://stackoverflow.com/a/73144320
     -- full list: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
     local sources = {
       { name = "nvim_lsp", priority = 1 },
       { name = "vsnip" },
       { name = "path" },
       { name = "luasnip" },
       { name = "obsidian" },
       { name = "obsidian_new" },
       { name = "nvim_lsp:lua_ls" },
       { name = "nvim_lsp:null-ls" },
       { name = "dictionary", keyword_length = 3, priority = 5, keyword_pattern = [[\w\+]] }, -- from uga-rosa/cmp-dictionary plug
     }
     -- disable completion with tab this helps with copilot setup
     cmp_mappings["<Tab>"] = nil
     cmp_mappings["<S-Tab>"] = nil

     --Copilot cycle through suggestions
     vim.cmd([[
     imap <silent> <Leader>cn <Plug>(copilot-next)
     imap <silent> <Leader>cp <Plug>(copilot-previous)
     imap <silent> <Leader>cd <Plug>(copilot-dismiss)
     ]])

     cmp.setup({
       window = {
         completion = cmp.config.window.bordered(),
         documentation = cmp.config.window.bordered(),
         mapping = cmp_mappings,
         sources = cmp.config.sources(sources)
       },
     })

   end
 }
