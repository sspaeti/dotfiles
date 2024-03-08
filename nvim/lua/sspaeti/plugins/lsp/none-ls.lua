return {
  "nvimtools/none-ls.nvim", --before: jose-elias-alvarez/null-ls.nvim"
  lazy = true,
  -- event = { "BufReadPre", "BufNewFile" }, -- to enable uncomment this
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
  },
  config = function()
    local mason_null_ls = require("mason-null-ls")

    local null_ls = require("null-ls")

    local null_ls_utils = require("null-ls.utils")

    mason_null_ls.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "black", -- python formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
        "jq",   --json format
      },
    })

    -- for conciseness
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- to setup format on save
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    -- old black autoformat
    -- vim.cmd([[
    -- " Python: auto format on save with Black
    -- "autocmd BufWritePre *.py execute ':Black'
    -- ]])

    -- configure null_ls
    null_ls.setup({
      -- add package.json as identifier for root (for typescript monorepos)
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
      -- setup formatters & linters
      sources = {
        --  to disable file types use
        --  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)
        formatting.prettier.with({ extra_filetypes = { "svelte" } }), -- js/ts formatter
        formatting.stylua.with({ extra_args = { "indent_type=space" } }), -- lua formatter
        formatting.isort,
        formatting.black,
        -- formatting.black.with({ extra_args = { "--fast" } }),
        diagnostics.pylint,
        diagnostics.eslint_d.with({                                   -- js/ts linter
          condition = function(utils)
            return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
          end,
        }),
        --see also ~/.pylintrc or .my_example.toml
        -- R - refactoring related checks => snake_case
        -- C - convention related checks
        -- W0511 disable TODO warning
        -- W1201, W1202 disable log format warning. False positives (I think)
        -- W0231 disable super-init-not-called - pylint doesn't understand six.with_metaclass(ABCMeta)
        -- W0707 disable raise-missing-from which we cant use because py2 back compat
        -- C0301 Line too long => disabled as black-formatter handles long lines automatically
        diagnostics.flake8.with({
          extra_args = {
            "--max-line-length=88",
            "--disable=R,duplicate-code,W0231,W0511,W1201,W1202,W0707,C0301,no-init",
          },
        }),
        diagnostics.mypy.with({ extra_args = { "--ignore-missing-imports" } }),
        diagnostics.write_good,
      },
      -- configure format on save TODO: this seem not to work yet, at least for python
      on_attach = function(current_client, bufnr)
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        if current_client.supports_method("textDocument/formatting")
          -- and filetype == 'python' --only python formatin on save
          then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                filter = function(client)
                  --  only use null-ls for formatting instead of lsp server
                  print("on_attach called for buffer", bufnr)
                  return client.name == "null-ls"
                end,
                bufnr = bufnr,
              })
            end,
          })
        end
      end,
    })
  end,
}
