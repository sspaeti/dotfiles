return {
  "ldelossa/gh.nvim",
  event = "VeryLazy",
  dependencies = {
    {
      "ldelossa/litee.nvim",
      config = function()
        require("litee.lib").setup()
      end,
    },
  },
  config = function()
    require("litee.gh").setup()
  end,
}
