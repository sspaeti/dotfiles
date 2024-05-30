return {
  "glacambre/firenvim",
  event = "VeryLazy",
  build = function()
    vim.fn["firenvim#install"](0)
  end,
  config = function()
    -- configure firenvim for the browser
    if vim.g.started_by_firenvim then
      vim.cmd("source $HOME/.config/nvim/plugin/firenvim.vim")
    end
  end
}
