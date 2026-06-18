return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    -- Per-filetype formatters (run in order). Filetypes not listed fall back to
    -- LSP formatting via default_format_opts.lsp_format = "fallback".
    formatters_by_ft = {
      go = { "gofmt" }, -- ships with Go
      python = { "ruff_format" }, -- ruff (installed via mason)
      lua = { "stylua" }, -- stylua (installed via mason-tool-installer)
      -- JS/TS/etc. still handled by none-ls (prettier).
    },

    -- Defaults applied to every format() call (including format_on_save).
    default_format_opts = {
      lsp_format = "fallback", -- use LSP when no formatter is listed for the filetype
      timeout_ms = 2000,
    },

    -- Format on save — gated by vim.g.format_on_save (toggle with <Leader>lF, see remap.lua).
    -- Return nil from the function to skip; return a table to run with those options.
    format_on_save = function(bufnr)
      if not vim.g.format_on_save then
        return
      end
      return { lsp_format = "fallback", timeout_ms = 2000 }
    end,

    notify_on_error = true,

    -- Override built-in formatter args.
    -- stylua defaults to tabs; match the rest of the config (2-space indent — see set.lua).
    -- Per-project stylua.toml still takes precedence if present.
    -- Change in `format_on_save` in remap.lua
    formatters = {
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
    },
  },
}
