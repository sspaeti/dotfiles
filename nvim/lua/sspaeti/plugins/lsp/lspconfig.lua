return {
  {
    "folke/neodev.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local neodev_status_ok, neodev = pcall(require, "neodev")

      if not neodev_status_ok then
        return
      end

      neodev.setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    keys = {
      { "K",          function() vim.lsp.buf.hover() end,                                   desc = "LSP Documentation Hover" },
      { "gd",         function() vim.lsp.buf.definition() end,                              desc = "LSP Definition" },
      { "gD",         function() vim.lsp.buf.declaration() end,                             desc = "LSP Declaration" },
      { "gR",         function() vim.lsp.buf.references() end,                              desc = "LSP References" },
      { "gr",         function() require("telescope.builtin").lsp_references({}) end,       desc = "Telescope LSP References" },
      { "gC",         function() require("telescope.builtin").lsp_document_symbols({}) end, desc = "Telescope LSP Document Symbols" },
      { "gI",         function() vim.lsp.buf.implementation() end,                          desc = "LSP Implementation" },
      { "gs",         function() vim.lsp.buf.signature_help() end,                          desc = "LSP Signature Help" },
      -- { "ga",         function() vim.lsp.buf.code_action() end,                             desc = "LSP Code Action" }, -- easy alignment
      { "<Leader>la", function() vim.lsp.buf.code_action() end,                             desc = "LSP Code Action" },
      { "<Leader>lf", function() vim.lsp.buf.format() end,                                  desc = "LSP Format" },
      { "<Leader>lr", function() vim.lsp.buf.rename() end,                                  desc = "LSP Rename" },
      { "<Leader>lc", function() vim.diagnostic.disable() end,                              desc = "Diagnostic Disable" },
      { "<Leader>le", function() vim.diagnostic.enable() end,                               desc = "Diagnostic Enable" },
      { "<leader>lo", function() vim.diagnostic.open_float() end,                           desc = "Diagnostic Open (Float)" },
      { "<Leader>ln", function() vim.diagnostic.goto_next() end,                            desc = "Diagnostic Go To Next" },
      { "]d",         function() vim.diagnostic.goto_next() end,                            desc = "Diagnostic Go To Next" },
      { "]]",         function() vim.diagnostic.goto_next() end,                            desc = "Diagnostic Go To Next" },
      { "<Leader>lp", function() vim.diagnostic.goto_prev() end,                            desc = "Diagnostic Go To Previous" },
      { "[d",         function() vim.diagnostic.goto_prev() end,                            desc = "Diagnostic Go To Previous" },
      { "[[",         function() vim.diagnostic.goto_prev() end,                            desc = "Diagnostic Go To Previous" },
      { "<C-h>",      function() vim.lsp.buf.signature_help() end,                          mode = "i",                                       desc = "LSP Signature Help (Insert Mode)" },
      { "<C-h>",      function() vim.lsp.buf.signature_help() end,                          mode = "n",                                       desc = "LSP Signature Help (Insert Mode)" },
      { "<leader>lh", function() vim.lsp.buf.signature_help() end,                          desc = "LSP Signature Help" },
      { "<leader>ls", ":LspRestart<CR>",                                                    desc = "LSP Restart" },
      --prime
      -- { "sC",         function() vim.lsp.buf.workspace_symbol() end,                        desc = "LSP Workspace Symbol" },
      -- { "<Leader>lw", function() vim.lsp.buf.workspace_symbol() end,                        desc = "LSP Workspace Symbol (Leader)" },
    },
    config = function()
      -- import lspconfig plugin
      local lspconfig = require("lspconfig")

      -- import cmp-nvim-lsp plugin
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local keymap = vim.keymap -- for conciseness

      local opts = { noremap = true, silent = true }
      local on_attach = function(client, bufnr)
        opts.buffer = bufnr

         --TODO: Check if still needed? Was done for Rust config
         -- -- Disable hover in favor of Pyright
         -- client.server_capabilities.hoverProvider = false

         -- Fixed column for diagnostics to appear
         vim.opt.signcolumn = "yes"
         -- Show autodiagnostic popup on cursor hover_range
         -- vim.cmd([[
         -- autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
         -- ]])

         vim.diagnostic.config({
           virtual_text = true,
           severity_sort =true,
         })

         --TODO: moved to lazy.nvim keys above: delete if works as expected
         ----mine
         --vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
         --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
         --vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
         --vim.keymap.set("n", "gR", function() vim.lsp.buf.references() end, opts)
         --vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, {})
         --vim.keymap.set("n", "gC", require("telescope.builtin").lsp_document_symbols, {})
         --vim.keymap.set("n", "gI", function() vim.lsp.buf.implementation() end, opts)
         --vim.keymap.set("n", "gs", function() vim.lsp.buf.signature_help() end, opts)
         --vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts)
         --vim.keymap.set("n", "<Leader>la", function() vim.lsp.buf.code_action() end, opts)
         --vim.keymap.set("n", "<Leader>lf", function() vim.lsp.buf.format() end, opts)
         --vim.keymap.set("n", "<Leader>lr", function() vim.lsp.buf.rename() end, opts)
         --vim.keymap.set("n", "<Leader>lc", function() vim.diagnostic.disable() end, opts)
         --vim.keymap.set("n", "<Leader>le", function() vim.diagnostic.enable() end, opts)
         ----prime
         --vim.keymap.set("n", "sC", function() vim.lsp.buf.workspace_symbol() end, opts)
         --vim.keymap.set("n", "<Leader>lw", function() vim.lsp.buf.workspace_symbol() end, opts)
         --vim.keymap.set("n", "<Leader>lo", function() vim.diagnostic.open_float() end, opts) --done with :TroubleToggle

         --vim.keymap.set("n", "<Leader>ln", function() vim.diagnostic.goto_next() end, opts)
         --vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
         --vim.keymap.set("n", "]]", function() vim.diagnostic.goto_next() end, opts)
         --vim.keymap.set("n", "<Leader>lp", function() vim.diagnostic.goto_prev() end, opts)
         --vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
         --vim.keymap.set("n", "[[", function() vim.diagnostic.goto_prev() end, opts)

         --vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
         --vim.keymap.set("n", "<leader>lh", function() vim.lsp.buf.signature_help() end, opts)

         -- turn on grammarly language server only for filetype=markdown
         if client.name == "grammarly" then
           vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
         end
      end

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Change the Diagnostic symbols in the sign column (gutter)
      -- (not in youtube nvim video)
      local signs = { Error = "", Warn = "", Hint = "", Info = "", }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- configure html server
      lspconfig["html"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure typescript server with plugin
      lspconfig["tsserver"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure css server
      lspconfig["cssls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure tailwindcss server
      lspconfig["tailwindcss"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- configure svelte server
      lspconfig["svelte"].setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            callback = function(ctx)
              if client.name == "svelte" then
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
              end
            end,
          })
        end,
      })

      -- configure graphql language server
      lspconfig["graphql"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      })

      -- configure emmet language server
      lspconfig["emmet_ls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
      })

      -- configure python server
      lspconfig["pyright"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

     -- Configure `ruff-lsp`.
     -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
     -- For the default config, along with instructions on how to customize the settings
     lspconfig["ruff_lsp"].setup {
       capabilities = capabilities,
       on_attach = on_attach,
       init_options = {
         settings = {
           -- Any extra CLI arguments for `ruff` go here.
           args = {},
         }
       }
     }
      -- configure lua server (with special settings)
      lspconfig["lua_ls"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { -- custom settings for lua
          Lua = {
           format = {
             enable = true,
             defaultConfig = {
               indent_style = "space",
               indent_size = "2",
             },
           },
            -- make the language server recognize "vim" global
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              -- make language server aware of runtime files
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })

      lspconfig["lemminx"].setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          xml = {
            server = {
              workDir = "~/.cache/lemminx",
            }
          }
        }
      })



    end,
  }
}
