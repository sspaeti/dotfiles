return {
  { "mhinz/vim-signify",   event = "VeryLazy" },   --highlighing changes not commited to last commmit
  { "APZelos/blamer.nvim", event = "VeryLazy" },   --gitlens blame style',
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require('blame').setup {}
    end,
    opts = {
      blame_options = { '-w' },
    },
  },
}
