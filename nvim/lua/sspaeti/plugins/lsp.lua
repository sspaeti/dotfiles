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
  { "neovim/nvim-lspconfig",
     event = "VeryLazy"
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Mason",
    lazy = false,
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
    },
    keys = {
      {"K", function() vim.lsp.buf.hover() end, desc = "LSP Hover" },
      {"gd", function() vim.lsp.buf.definition() end, desc = "LSP Definition" },
      {"gD", function() vim.lsp.buf.declaration() end, desc = "LSP Declaration" },
      {"gR", function() vim.lsp.buf.references() end, desc = "LSP References" },
      {"gr", require("telescope.builtin").lsp_references, desc = "Telescope LSP References" },
      {"gC", require("telescope.builtin").lsp_document_symbols, desc = "Telescope LSP Document Symbols" },
      {"gI", function() vim.lsp.buf.implementation() end, desc = "LSP Implementation" },
      {"gs", function() vim.lsp.buf.signature_help() end, desc = "LSP Signature Help" },
      {"ga", function() vim.lsp.buf.code_action() end, desc = "LSP Code Action" },
      {"<Leader>la", function() vim.lsp.buf.code_action() end, desc = "LSP Code Action (Leader)" },
      {"<Leader>lf", function() vim.lsp.buf.format() end, desc = "LSP Format" },
      {"<Leader>lr", function() vim.lsp.buf.rename() end, desc = "LSP Rename" },
      {"<Leader>lc", function() vim.diagnostic.disable() end, desc = "Diagnostic Disable" },
      {"<Leader>le", function() vim.diagnostic.enable() end, desc = "Diagnostic Enable" },
      { "<leader>lo", function() vim.diagnostic.open_float() end, desc = "Diagnostic Open (Float)" },
      { "<Leader>ln", function() vim.diagnostic.goto_next() end, desc = "Diagnostic Go To Next" },
      { "]d", function() vim.diagnostic.goto_next() end, desc = "Diagnostic Go To Next (Shortcut)" },
      { "]]", function() vim.diagnostic.goto_next() end, desc = "Diagnostic Go To Next (Shortcut Alt)" },
      { "<Leader>lp", function() vim.diagnostic.goto_prev() end, desc = "Diagnostic Go To Previous" },
      { "[d", function() vim.diagnostic.goto_prev() end, desc = "Diagnostic Go To Previous (Shortcut)" },
      { "[[", function() vim.diagnostic.goto_prev() end, desc = "Diagnostic Go To Previous (Shortcut Alt)" },
      { "<C-h>", function() vim.lsp.buf.signature_help() end, mode = "i", desc = "LSP Signature Help (Insert Mode)" },
      { "<C-h>", function() vim.lsp.buf.signature_help() end, mode = "n", desc = "LSP Signature Help (Insert Mode)" },
      { "<leader>lh", function() vim.lsp.buf.signature_help() end, desc = "LSP Signature Help (Leader)" },
      --prime
      { "sC", function() vim.lsp.buf.workspace_symbol() end, desc = "LSP Workspace Symbol" },
      { "<Leader>lw", function() vim.lsp.buf.workspace_symbol() end, desc = "LSP Workspace Symbol (Leader)" },
    },
    config = function()
      local lsp = require("lsp-zero")

      lsp.preset("recommended")

      lsp.ensure_installed({
        "eslint",
        "rust_analyzer",
        "lua_ls",
      })

      -- Fix Undefined global 'vim'
      lsp.configure("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      local cmp_mappings = lsp.defaults.cmp_mappings({
        ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-u>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      })

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

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

      lsp.setup_nvim_cmp({
        mapping = cmp_mappings,
        sources = sources,
      })

      lsp.set_preferences({
        suggest_lsp_servers = false,
        sign_icons = {
          error = "",
          warn = "",
          hint = "",
          info = "",
        },
      })

      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
              },
            },
          },
        },
      })

      require('lspconfig').lemminx.setup({
          settings = {
              xml = {
                  server = {
                      workDir = "~/.cache/lemminx",
                  }
              }
          }
      })

      -- Configure `ruff-lsp`.
      -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
      -- For the default config, along with instructions on how to customize the settings
      local on_attach = function(client, bufnr)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end

      require('lspconfig').ruff_lsp.setup {
        on_attach = on_attach,
        init_options = {
          settings = {
            -- Any extra CLI arguments for `ruff` go here.
            args = {},
          }
        }
      }

      lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }

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
        ---- vim.keymap.set("n", "<Leader>lo", function() vim.diagnostic.open_float() end, opts) --done with :TroubleToggle

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
      end)

      lsp.setup()
    end,
  },
}
