return {
  "folke/noice.nvim",
  lazy = false,
  priority = 1005,
  -- if activated, recording mode will not show
  -- event = { "VeryLazy"},
  opts = {
    -- add any options here
    messages = {
      -- NOTE: If you enable messages, then the cmdline is enabled automatically.
      -- This is a current Neovim limitation.
      view = "mini", --show default operation in lover right corner. Warn/Errors are still as popu (notify). options: notify, split, vsplit, popup, mini, cmdline, cmdline_popup, cmdline_output, messages, confirm, hover, popupmenu
    },
    routes = {
      { --this turns off notification in neo-tree that are distracting
        view = 'mini',
        filter = {
          event = 'notify',
          any = {
            { find = 'hidden' },
            { find = 'clipboard' },
            { find = 'Deleted' },
            { find = 'Renamed' },
          },
        },
      }
    }

  },
  keys = {
    { "<leader>mm", ":Noice<CR>", desc = "Show recent messages" },
    { "<leader>lm", ":Noice<CR>", desc = "Show recent messages" },
  },

  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  }
}
