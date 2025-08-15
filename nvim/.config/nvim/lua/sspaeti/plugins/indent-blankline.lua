return {
  	 "lukas-reineke/indent-blankline.nvim",
     event = "VeryLazy",
     version = "2.20.8",
     main = "ibl",
     config = function()
      vim.cmd [[highlight IndentBlanklineIndent1 guibg=#1F1F28 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guibg=#252535 gui=nocombine]]
      require("indent_blankline").setup {
          char = "",
          char_highlight_list = {
              "IndentBlanklineIndent1",
              "IndentBlanklineIndent2",
          },
          space_char_highlight_list = {
              "IndentBlanklineIndent1",
              "IndentBlanklineIndent2",
          },
          show_trailing_blankline_indent = false,
      }
    end
}
