
" These functions are stored in harpoon. 
nnoremap <silent><leader>tt :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent><leader>tm :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent><leader>tc :lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>


nnoremap <silent><leader>tj :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent><leader>tk :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent><leader>tl :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent><leader>tö :lua require("harpoon.ui").nav_file(4)<CR>
