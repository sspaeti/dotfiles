--color scheme, themes,
return {
  { "rebelot/kanagawa.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true, version = "*" },
  {
    "rose-pine/neovim",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "auto",      -- auto, main, moon, or dawn
        dark_variant = "main"  -- main, moon, or dawn
      })
    end
  },
  { "AlexvZyl/nordic.nvim",           lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "catppuccin/nvim", lazy = true,                name = "catppuccin" }, --light theme
  { "craftzdog/solarized-osaka.nvim", lazy = true },
  { "projekt0n/github-nvim-theme", lazy = true,  version = "*" },
  { "sho-87/kanagawa-paper.nvim"    , lazy = true, opts = {}, }
  -- { "ColorMyPencil",
  --   function ColorMyPencils(color)
  --     color = color or "kanagawa"
  --     vim.cmd.colorscheme(color)

  --     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  --   end
  -- }
}
