return {
  --align markdown tables or others
  "junegunn/vim-easy-align",
  event = "VeryLazy",
  config = function()
    -- Tool to align Markwodn tables
    -- e.g. markdown table with : `ga*|`
    -- Start interactive EasyAlign in visual mode (e.g. vipga)
    vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true })

    -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
    vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', { noremap = false, silent = true })
  end
}
