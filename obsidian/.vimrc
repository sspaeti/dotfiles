unmap <Space>
" let mapleader = " "
" exmap leader <Space>

" remap esc key
imap kj <Esc>
imap jk <Esc>
imap jj <Esc>

" map to visual line instead of full line as in obsidian line are always
" wraped
noremap <C-j> j
noremap <C-k> k
nmap j gj
nmap k gk

" better scrolling and searching with centered always
noremap <c-d> <C-d>zz
noremap <c-u> <C-u>zz
noremap <n> nzzzv
noremap <N> Nzzzv

" vim fold navigation
exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall

exmap foldall obcommand editor:fold-all
nmap zM :foldall

exmap foldtoggle obcommand editor:toggle-fold
nmap za :foldtoggle

"map leader for local search"
exmap local_search obcommand editor:open-search
nmap <Space>/ :local_search
vmap <Space>/ :local_search
"fuzzy serach with omnisearch
exmap omnisearch_search obcommand omnisearch:show-modal
nmap <Space>f :omnisearch_search
" Leader key search/replace (<leader>s)
exmap search_replace obcommand editor:open-search-replace
nmap <Space>s :search_replace

exmap theme_switch obcommand theme:switch
nmap <Space>ts :theme_switch

exmap theme_dark obcommand theme:use-dark
exmap theme_light obcommand theme:use-light
nmap <Space>td :theme_dark
nmap <Space>tl :theme_light

" Copy file path (similar to your leader-y)
exmap copy_path obcommand workspace:copy-path
nmap <Space>y :copy_path

" Outline (similar to your aerial plugin)
exmap outline obcommand outline:open
nmap <Space>o :outline

" Folding (matching your zR and zM)
exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall

exmap foldall obcommand editor:fold-all
nmap zM :foldall

exmap toggle_fold obcommand editor:toggle-fold
nmap za :toggle_fold

" Leader key window/split operations (<space>q to close)
exmap close_others obcommand workspace:close-others
nmap <Space>q :close_others

" Explorer/file tree (<leader>e)
exmap toggle_sidebar obcommand app:toggle-left-sidebar
nmap <Space>e :toggle_sidebar
nmap <Space>l :toggle_sidebar


" set scrolloff=8

"yank to clipboard
set clipboard=unnamed

" " Go back and forward with Ctrl+O and Ctrl+I
" " (make sure to remove default Obsidian shortcuts for these to work)
" exmap back obcommand app:go-back
" nmap <C-o> :back
" exmap forward obcommand app:go-forward
" nmap <C-i> :forward

" exmap togglefold obcommand editor:toggle-fold
" nmap za togglefold
