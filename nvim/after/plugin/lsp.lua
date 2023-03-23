local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'eslint',
  'rust_analyzer',
  'lua_ls',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-d>'] = cmp.mapping.scroll_docs(-4),
  ['<C-u>'] = cmp.mapping.scroll_docs(4),
  ['<C-e>'] = cmp.mapping.close(),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

-- remove buffer (that suggests words from current buffer): https://stackoverflow.com/a/73144320
-- full list: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
local sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'obsidian' },
    { name = 'obsidian_new' },
    { name = 'nvim_lsp:sumneko_lua' },
    { name = 'nvim_lsp:null-ls' },
  }
-- disable completion with tab
-- this helps with copilot setup
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

--Copilot cycle through suggestions
vim.cmd([[
imap <silent> <Leader>cn <Plug>(copilot-next)
imap <silent> <Leader>cp <Plug>(copilot-previous)
imap <silent> <Leader>cd <Plug>(copilot-dismiss)
]])


lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
    sources = sources
  })

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = '',
        warn = '',
        hint = '',
        info = ''
    }
})

vim.diagnostic.config({
    virtual_text = true,
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  --mine
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
  vim.keymap.set("n", "gR", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "gr", require('telescope.builtin').lsp_references, {})
  vim.keymap.set("n", "gC", require('telescope.builtin').lsp_document_symbols, {})
  vim.keymap.set("n", "gI", function() vim.lsp.buf.implementation() end, opts)
  vim.keymap.set("n", "gs", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<Leader>la", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<Leader>lf", function() vim.lsp.buf.format() end, opts)
  vim.keymap.set("n", "<Leader>lr", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("n", "<Leader>lc", function() vim.diagnostic.disable() end, opts)
  vim.keymap.set("n", "<Leader>lo", function() vim.diagnostic.enable() end, opts)
  --prime
  vim.keymap.set("n", "sC", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<Leader>lw", function() vim.lsp.buf.workspace_symbol() end, opts)
  -- vim.keymap.set("n", "<Leader>lt", function() vim.diagnostic.open_float() end, opts) --done with :TroubleToggle

  vim.keymap.set("n", "<Leader>ln", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]n", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "<Leader>lp", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "[p", function() vim.diagnostic.goto_prev() end, opts)

  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>lh", function() vim.lsp.buf.signature_help() end, opts)

  -- turn on grammarly language server only for filetype=markdown
  if client.name == "grammarly" then
    vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
  end
end)

lsp.setup()


