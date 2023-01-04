-- VimWiki
vim.cmd([[
set nocompatible
let g:vimwiki_list = [{'path': '~/Simon/Sync/SecondBrain', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 0 " o
]])

-- Outline Shortcut
vim.cmd('autocmd FileType markdown,vimwiki nmap <leader>o :SymbolsOutline<CR>')

-- create WikiLink and paste clipboard as link when in visual mode
vim.cmd('autocmd FileType markdown vnoremap <leader>k <Esc>`<i[<Esc>`>la](<Esc>"*]pa)<Esc>')

-- create empty wikilink when in normal mode
vim.cmd('autocmd FileType markdown nmap <leader>k i[]()<Esc>hhi')

-- Open file in Obsidian vault
vim.cmd("command! IO execute \"silent !open 'obsidian://open?vault=SecondBrain&file=\" . expand('%:r') . \"'\"")
vim.keymap.set("n", "<leader>io", ":IO<CR>", { noremap = true, silent = true })

-- Turn off autocomplete for Markdown
vim.cmd('au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown')

-- Highlights for headers in markdown -> doesn't really work
vim.cmd([[
highlight htmlH1 guifg=#50fa7b gui=bold
highlight htmlH2 guifg=#ff79c6 gui=bold
highlight htmlH3 guifg=#ffb86c gui=bold
highlight htmlH4 guifg=#8be9fd gui=bold
highlight htmlH5 guifg=#f1fa8c gui=bold
]])

