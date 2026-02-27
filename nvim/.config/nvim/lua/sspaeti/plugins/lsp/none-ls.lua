return {
  "nvimtools/none-ls.nvim", --before: jose-elias-alvarez/null-ls.nvim"
  event = { "BufReadPre", "BufNewFile" },
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
        "jq",   -- json format
        "mypy", -- python type checker
        -- "eslint_d", -- removed from none-ls builtins; use eslint LSP instead
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
        formatting.prettier.with({ extra_filetypes = { "svelte" } }), -- js/ts formatter
        -- diagnostics.eslint_d removed from none-ls builtins; use eslint LSP instead
        -- diagnostics.eslint_d.with({
        --   condition = function(utils)
        --     return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" })
        --   end,
        -- }),
        diagnostics.mypy.with({ extra_args = { "--ignore-missing-imports" } }),
        -- Replaced by ruff LSP (configure rules in ruff.toml / pyproject.toml):
        -- formatting.stylua.with({ extra_args = { "indent_type=space" } }), -- lua_ls handles lua formatting
        -- formatting.isort,        -- ruff handles import sorting
        -- formatting.black,        -- ruff handles python formatting
        -- diagnostics.pylint,      -- ruff covers pylint rules (PLW, PLC, PLR prefixes)
        -- diagnostics.flake8.with({
        --   extra_args = {
        --     "--max-line-length=88",
        --     "--disable=R,duplicate-code,W0231,W0511,W1201,W1202,W0707,C0301,no-init",
        --   },
        -- }),
        -- diagnostics.write_good,
        --
        -- Ruff equivalents for your pylint/flake8 disables (put in ruff.toml or pyproject.toml):
        --   [tool.ruff.lint]
        --   ignore = ["PLR", "PLW0511", "PLW1201", "PLW1202", "PLW0231", "PLW0707", "E501"]
      },
      -- configure format on save TODO: this seem not to work yet, at least for python
      on_attach = function(current_client, bufnr)
        local filetype = vim.bo[bufnr].filetype
        if current_client.supports_method("textDocument/formatting")
          -- and filetype == 'python' --only python formatin on save
          then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              if not vim.g.format_on_save then return end
              vim.lsp.buf.format({
                filter = function(client)
                  --  only use null-ls for formatting instead of lsp server
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
