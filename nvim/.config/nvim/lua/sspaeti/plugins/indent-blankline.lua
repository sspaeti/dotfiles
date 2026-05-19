return {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main = "ibl",
  config = function()
    vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1F1F28 gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent2 guibg=#252535 gui=nocombine]]
    require("ibl").setup({
      indent = { char = " " },
      whitespace = {
        highlight = { "IndentBlanklineIndent1", "IndentBlanklineIndent2" },
        remove_blankline_trail = true,
      },
      scope = { enabled = false },
    })
  end,
}
