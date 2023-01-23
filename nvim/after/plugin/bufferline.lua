require('bufferline').setup {
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
    -- indicator = {style = "icon", icon = "▎" },
    -- indicator = {style = "icon", icon = "|" },
    buffer_close_icon = "",
    show_close_icon = false,
    diagnostics = "nvim_lsp",
  }
}
-- navigation
vim.keymap.set("n", "<leader>1", function() require('bufferline').go_to_buffer(1) end, {})
vim.keymap.set("n", "<leader>2", function() require('bufferline').go_to_buffer(2) end, {})
vim.keymap.set("n", "<leader>3", function() require('bufferline').go_to_buffer(3) end, {})
vim.keymap.set("n", "<leader>4", function() require('bufferline').go_to_buffer(4) end, {})
vim.keymap.set("n", "<leader>5", function() require('bufferline').go_to_buffer(5) end, {})
vim.keymap.set("n", "<leader>6", function() require('bufferline').go_to_buffer(6) end, {})
vim.keymap.set("n", "<leader>7", function() require('bufferline').go_to_buffer(7) end, {})
vim.keymap.set("n", "<leader>8", function() require('bufferline').go_to_buffer(8) end, {})
vim.keymap.set("n", "<leader>9", function() require('bufferline').go_to_buffer(9) end, {})

