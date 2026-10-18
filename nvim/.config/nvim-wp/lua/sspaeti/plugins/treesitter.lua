-- No nvim-treesitter plugin: nvim 0.12 bundles markdown + markdown_inline
-- parsers and queries in $VIMRUNTIME. Builtin vim.treesitter does highlight
-- and folds. Avoids compiling parsers (needs tree-sitter CLI) on the Pi.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

return {}
