-- LazyGit
vim.api.nvim_set_keymap('n', '<leader>gg', ':LazyGit<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', {noremap = true, silent = true})
--Blamer
vim.api.nvim_set_keymap('n', '<leader>gb', ':BlamerToggle<CR>', {noremap = true, silent = true})
--Diffview.nvim
vim.api.nvim_set_keymap('n', '<leader>go', ':DiffviewOpen<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gc', ':DiffviewClose<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gh', ':DiffviewFileHistory<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>gf', ':DiffviewFileHistory %<CR>', {noremap = true, silent = true})

--Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
--Browse to GitHub page
vim.api.nvim_set_keymap('n', '<leader>gw', ':GBrowse<CR>', {noremap = true, silent = false})
