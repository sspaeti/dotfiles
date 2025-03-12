return {
  "folke/zen-mode.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("zen-mode").setup({
      on_open = function(_)
        vim.fn.system([[tmux set status off]])
        vim.fn.system(
          [[tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z]])
      end,
      on_close = function(_)
        vim.fn.system([[tmux set status on]])
        vim.fn.system(
          [[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
      end,
      window = {
        -- backdrop = 1,
        -- width = 0.66, 
        width = 97, --98,
        options = {
          relativenumber = false,
          signcolumn = "no",
        },
      },
    })
  end,
}
