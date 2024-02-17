--color scheme, themes,
return {
	{ "rebelot/kanagawa.nvim", lazy = false },
	{ "ellisonleao/gruvbox.nvim", lazy = false },
	{ "rose-pine/neovim",
    lazy = false,
    config = function()
      require("rose-pine").setup({
         variant = "auto", -- auto, main, moon, or dawn
         dark_variant = "main" -- main, moon, or dawn
       })
    end
  },
	{ "AlexvZyl/nordic.nvim", event = "VeryLazy" },
	{ "navarasu/onedark.nvim", event = "VeryLazy" },
	{ "catppuccin/nvim", name = "catppuccin", event = "VeryLazy" }, --light theme
	{ "craftzdog/solarized-osaka.nvim", lazy = false, priority = 1000 },
	{ "projekt0n/github-nvim-theme", event = "VeryLazy", version = "*" },
	{ "sainnhe/gruvbox-material", event = "VeryLazy", version = "*" },
  -- { "ColorMyPencil",
  --   function ColorMyPencils(color) 
  --     color = color or "kanagawa"
  --     vim.cmd.colorscheme(color)

  --     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  --     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  --   end
  -- }
}
