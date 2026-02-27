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
      { "K",          vim.lsp.buf.hover,                                    desc = "LSP Documentation Hover" },
      { "gd",         vim.lsp.buf.definition,                               desc = "LSP Definition" },
      { "gD",         vim.lsp.buf.declaration,                              desc = "LSP Declaration" },
      { "gR",         vim.lsp.buf.references,                               desc = "LSP References" },
      -- defined in rempa.lua
      -- { "gr",         require("telescope.builtin").lsp_references,          desc = "Telescope LSP References" },
      -- { "so",         require("telescope.builtin").lsp_document_symbols,    desc = "Telescope LSP Document Symbols" },
      { "gI",         vim.lsp.buf.implementation,                           desc = "LSP Implementation" },
      { "gs",         vim.lsp.buf.signature_help,                           desc = "LSP Signature Help" },
      --{ "ga",         vim.lsp.buf.code_action,                              desc = "LSP Code Action" }, -- easy alignment
      { "<Leader>la", vim.lsp.buf.code_action,                              desc = "LSP Code Action" },
      { "<Leader>lf", vim.lsp.buf.format,                                   desc = "LSP Format" },
      { "<Leader>lr", vim.lsp.buf.rename,                                   desc = "LSP Rename" },
      { "<Leader>lc", function() vim.diagnostic.enable(false) end,            desc = "Diagnostic Disable" },
      { "<Leader>le", function() vim.diagnostic.enable() end,               desc = "Diagnostic Enable" },
      { "<leader>lo", vim.diagnostic.open_float,                            desc = "Diagnostic Open (Float)" },
      { "<Leader>ln", vim.diagnostic.goto_next,                             desc = "Diagnostic Go To Next" },
      { "]d",         vim.diagnostic.goto_next,                             desc = "Diagnostic Go To Next" },
      { "]]",         vim.diagnostic.goto_next,                             desc = "Diagnostic Go To Next" },
      { "<Leader>lp", vim.diagnostic.goto_prev,                             desc = "Diagnostic Go To Previous" },
      { "[d",         vim.diagnostic.goto_prev,                             desc = "Diagnostic Go To Previous" },
      { "[[",         vim.diagnostic.goto_prev,                             desc = "Diagnostic Go To Previous" },
      { "<leader>lh", vim.lsp.buf.signature_help,                           desc = "LSP Signature Help" },
      { "<leader>ls", ":LspRestart<CR>",                                                    desc = "LSP Restart" },
      --prime
      -- { "sC",         function() vim.lsp.buf.workspace_symbol() end,                        desc = "LSP Workspace Symbol" },
      -- { "<Leader>lw", function() vim.lsp.buf.workspace_symbol() end,                        desc = "LSP Workspace Symbol (Leader)" },
    },
    config = function()
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
          severity_sort = true,
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

      end

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Change the Diagnostic symbols in the sign column (gutter)
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "󰌶",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
      })

      -- Define LSP servers with their configurations
      local servers = {
        { "html", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "ts_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "cssls", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "tailwindcss", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "helm_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "helm", "yaml" },
        }},
        { "graphql", {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
        }},
        { "emmet_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        }},
        { "pyright", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "ruff", {
          capabilities = capabilities,
          on_attach = on_attach,
          init_options = {
            settings = {
              args = {},
            }
          }
        }},
        { "lua_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            Lua = {
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  align_continuous_assign_statement = false,
                  align_continuous_rect_table_field = false,
                  align_array_table = false
                },
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
              },
            },
          },
        }},
        { "lemminx", {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            xml = {
              server = {
                workDir = "~/.cache/lemminx",
              }
            }
          }
        }},
        { "bashls", {
          capabilities = capabilities,
          on_attach = on_attach,
        }},
        { "jdtls", {
          capabilities = capabilities,
          on_attach = on_attach,
          root_dir = vim.fs.root(0, {'gradlew', '.git', 'mvnw', 'pom.xml', 'build.gradle', 'build.sbt', 'build.sc'}),
        }},
      }

      -- Configure all servers using the new vim.lsp.config API
      -- They will be automatically enabled when you open a matching filetype
      for _, server in ipairs(servers) do
        local name, config = server[1], server[2]
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

    end,

  }
}
