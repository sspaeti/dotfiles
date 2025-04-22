--color scheme, themes,
return {
  { "rebelot/kanagawa.nvim",    lazy = false },
  { "ellisonleao/gruvbox.nvim", lazy = false, event = "VeryLazy" },
  { "sainnhe/gruvbox-material", lazy = false, event = "VeryLazy", version = "*" },
  {
    "rose-pine/neovim",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",      -- auto, main, moon, or dawn
        dark_variant = "main"  -- main, moon, or dawn
      })
    end
  },
  { "AlexvZyl/nordic.nvim",           lazy = false,        priority = 1000 },
  { "navarasu/onedark.nvim",          event = "VeryLazy" },
  { "catppuccin/nvim",                name = "catppuccin", event = "VeryLazy" }, --light theme
  { "craftzdog/solarized-osaka.nvim", lazy = false,        priority = 1000 },
  { "projekt0n/github-nvim-theme",    event = "VeryLazy",  version = "*" },
  { "sho-87/kanagawa-paper.nvim"    , lazy = false, priority = 1000, opts = {}, },
  { "vague2k/vague.nvim", lazy = false, priority = 1000}
  -- { "ColorMyPencil",
  --   function ColorMyPencils(color)
  --     color = color or "kanagawa"
  --     vim.cmd.colorscheme(color)

  --     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  --   end
  -- }
}
