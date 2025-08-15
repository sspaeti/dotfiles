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
nmap zR :unfoldall<CR>

exmap foldall obcommand editor:fold-all
nmap zM :foldall<CR>

exmap foldtoggle obcommand editor:toggle-fold
nmap za :foldtoggle<CR>

"map leader for local search"
exmap local_search obcommand editor:open-search
nmap <Space>/ :local_search<CR>
vmap <Space>/ :local_search<CR>
"fuzzy serach with omnisearch
exmap omnisearch_search obcommand omnisearch:show-modal
nmap <Space>f :omnisearch_search<CR>
" Leader key search/replace (<leader>s)
exmap search_replace obcommand editor:open-search-replace
nmap <Space>s :search_replace<CR>

exmap theme_switch obcommand theme:switch
nmap <Space>ts :theme_switch<CR>

exmap quick_switch obcommand switcher:open
nmap <Space>O :quick_switch<CR>

exmap lint_current_file obcommand obsidian-linter:lint-file
nmap <Space>lf :lint_current_file<CR>


exmap theme_dark obcommand theme:use-dark
exmap theme_light obcommand theme:use-light
nmap <Space>td :theme_dark<CR>
nmap <Space>tl :theme_light<CR>


" Zen mode (hide tab bar) and right side
exmap toggle_tab obcommand obsidian-hider:toggle-tab-containers
exmap toggle_right obcommand app:toggle-right-sidebar
nmap <Space>z :toggle_tab<CR>:toggle_right<CR>

" Copy file path (similar to your leader-y)
exmap copy_path obcommand workspace:copy-path
nmap <Space>y :copy_path<CR>

" Outline (similar to your aerial plugin)
exmap outline obcommand outline:open
nmap <Space>o :outline<CR>

" Folding (matching your zR and zM)
exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall<CR>

exmap foldall obcommand editor:fold-all
nmap zM :foldall<CR>

exmap toggle_fold obcommand editor:toggle-fold
nmap za :toggle_fold<CR>

" Leader key window/split operations (<space>q to close)
exmap close_others obcommand workspace:close-others
nmap <Space>q :close_others<CR>

" Explorer/file tree (<leader>e)
" exmap toggle_sidebar obcommand app:toggle-left-sidebar
" nmap <Space>e :toggle_sidebar<CR>
" nmap <Space>l :toggle_sidebar<CR>


" set scrolloff=8

"yank to clipboard
set clipboard=unnamed

" " Go back and forward with Ctrl+O and Ctrl+I
" " (make sure to remove default Obsidian shortcuts for these to work)
" exmap back obcommand app:go-back
" nmap <C-o> :back<CR>
" exmap forward obcommand app:go-forward
" nmap <C-i> :forward<CR>

" exmap togglefold obcommand editor:toggle-fold
" nmap za togglefold<CR>
