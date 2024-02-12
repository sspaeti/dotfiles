return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    {"<leader>1", function() require('bufferline').go_to_buffer(1) end, desc = "Go to buffer 1"},
    {"<leader>2", function() require('bufferline').go_to_buffer(2) end, desc = "Go to buffer 2"},
    {"<leader>3", function() require('bufferline').go_to_buffer(3) end, desc = "Go to buffer 3"},
    {"<leader>4", function() require('bufferline').go_to_buffer(4) end, desc = "Go to buffer 4"},
    {"<leader>5", function() require('bufferline').go_to_buffer(5) end, desc = "Go to buffer 5"},
    {"<leader>6", function() require('bufferline').go_to_buffer(6) end, desc = "Go to buffer 6"},
    {"<leader>7", function() require('bufferline').go_to_buffer(7) end, desc = "Go to buffer 7"},
    {"<leader>8", function() require('bufferline').go_to_buffer(8) end, desc = "Go to buffer 8"},
    {"<leader>9", function() require('bufferline').go_to_buffer(9) end, desc = "Go to buffer 9"},
  },

  config = function()
    vim.api.nvim_exec([[let $KITTY_WINDOW_ID=0]], true)
    require("bufferline").setup({
      options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
        right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
        left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
        -- indicator = {style = "icon", icon = "▎" },
        -- indicator = {style = "icon", icon = "|" },
        buffer_close_icon = "",
        separator_style = "thin",
        show_close_icon = false,
        show_buffer_close_icons = false,
        show_tab_indicators = false,
        -- diagnostics = "",
        diagnostics = {
          "nvim_lsp",
          { -- Error.
          enabled = true,
          icon = " ",
        },
        { -- Warning,
        enabled = false,
        icon = " ",
      },
      { -- Info.
      enabled = false,
    },
    { -- Hint.
    enabled = false,
  },
},
icon_separator_active = "▎",
icon_separator_inactive = " ",
icon_close_tab = " ",
icon_close_tab_modified = "● ",
icon_pinned = "車",
minimum_padding = 1,
maximum_padding = 5,
maximum_length = 15,
            },
          })
        end
      }
