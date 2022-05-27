
" These functions are stored in harpoon. 
nnoremap <silent><leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent><C-e> :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <silent><leader>tc :lua require("harpoon.cmd-ui").toggle_quick_menu()<CR>


nnoremap <silent><C-j> :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent><C-k> :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent><C-ö> :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent><C-ä> :lua require("harpoon.ui").nav_file(4)<CR>
