return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "vimdoc", "python", "markdown", "markdown_inline", "css", "html",
        "javascript", "yaml", "bash", "json", "lua", "regex", "sql",
        "toml", "vim", "rust", "glimmer",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 1,
        min_window_height = 0,
        multiline_threshold = 5,
        mode = "cursor",
        separator = nil,
      })
    end,
  },
}
