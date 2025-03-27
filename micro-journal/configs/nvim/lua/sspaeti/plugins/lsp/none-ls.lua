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
        "write_good", -- only keep write_good
      },
    })
    -- for conciseness
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters
    -- to setup format on save
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    -- configure null_ls
    null_ls.setup({
      -- add package.json as identifier for root (for typescript monorepos)
      root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
      -- setup formatters & linters
      sources = {
        diagnostics.write_good, -- only write_good for diagnostics
      },
      -- configure format on save
      on_attach = function(current_client, bufnr)
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        if current_client.supports_method("textDocument/formatting") then
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
