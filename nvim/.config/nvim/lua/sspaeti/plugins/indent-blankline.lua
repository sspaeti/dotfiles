return {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main = "ibl",
  config = function()
    local function set_ibl_hl()
      local c1, c2
      if vim.o.background == "light" then
        c1, c2 = "#DCD7AA", "#C8CCAA"
      else
        c1, c2 = "#1F1F28", "#252535"
      end
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { bg = c1, default = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { bg = c2, default = true })
    end
    set_ibl_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("IblCustomHighlights", { clear = true }),
      callback = set_ibl_hl,
    })
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
