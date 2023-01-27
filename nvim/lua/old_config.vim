
" " Autocomplete with ctrl space
" if has("gui_running")
"     " C-Space seems to work under gVim on both Linux and win32
"     inoremap <C-Space> <C-n>
" else " no gui
"   if has("unix")
"     inoremap <Nul> <C-n>
"   else
"   " I have no idea of the name of Ctrl-Space elsewhere
"   endif
" endif




" fzf: ctrl f for find files
nnoremap <C-p> :Files<CR>
" nnoremap <C-f> :Rg<CR> "-> now on sf
nnoremap <leader>fw
  \ :call fzf#vim#files('.', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<cr>
nnoremap <silent> <Leader>fr :Rg<CR>
nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>f/ :BLines<CR>
nnoremap <silent> <Leader>fm :Marks<CR>
nnoremap <silent> <Leader>fc :Commits<CR>
nnoremap <silent> <Leader>fH :Helptags<CR>
" find in a specific repo
command! -bang -nargs=* Rg2
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}, <bang>0)
nnoremap <silent> <Leader>fd :Rg2 search folder
" :Rg2 apple ./folder_test
" :Rg2 "apple teste" ./folder_test
" :Rg2 --type=js "apple"
" :Rg2 --fixed-strings "apple"
" :Rg2 -e -foo
" :Rg2 apple
" :Rg2 '^port'                                       # Search for lines beginning with 'port'
" :Rg2 '^\s*port'                                   # Search for lines beginning with 'port', possibly after initial whitespace
" :Rg2 Apple --case-sensitive
" :Rg2 Apple --sortr=created             #   (none, created, path, modified, accessed)   descending order
" :Rg2 Apple --sort=created               #  (none, created, path, modified, accessed)   ascending order
" :Rg2 --passthru 'blue' -r 'red' test.txt  > tmp.txt && mv tmp.txt test.txt                       #Replace example
" :Rg2 'port|http'                                     # Search for string 'port' OR string 'http':
" :Rg2 --passthru 'blue' -r 'red' test.txt  | sponge test.txt                       # Replace example If you have moreutils installed
" this will quick search content of files


" move window with christoomey/vim-tmux-navigator to align tmux and nvim
let g:tmux_navigator_no_mappings = 1
" If the tmux window is zoomed, keep it zoomed when moving from Vim to another pane
let g:tmux_navigator_preserve_zoom = 1

noremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
noremap <silent> <c-j> :<C-U>TmuxNavigateDown<cr>
noremap <silent> <c-k> :<C-U>TmuxNavigateUp<cr>
noremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>
noremap <silent> <c-t> :<C-U>TmuxNavigatePrevious<cr>

" Resize window
nnoremap <C-w>l <C-w>5>
nnoremap <C-w>h <C-w>5<
nnoremap <C-w>k <C-w>5+
nnoremap <C-w>j <C-w>5-
nmap <C-w><left> <C-w>5<
nmap <C-w><right> <C-w>5>
nmap <C-w><up> <C-w>5+
nmap <C-w><down> <C-w>5-


" Open current directory
nmap te :tabedit
nmap <leader>tn :tabnew<Return>
nmap <S-Tab> :tabprev<Return>
" Attention, sometimes when you map <Tab> also ctrl+i will change!
"nmap <Tab> :tabnext<Return>

"nnoremap <Tab> :tabnext<Return>

" Find files using Telescope command-line sugar. --> replaced by fzf as faster and more options such as search :Lines :Buffer and .gitignore integration
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" nnoremap <C-p> <cmd>Telescope find_files<cr>

"ranger nvim
" nnoremap <leader>e :RnvimrToggl<CR>

"
" Replace `$EDITOR` candidate with this command to open the selected file
let g:rnvimr_edit_cmd = 'drop'

"
"let blame default be on
let g:blamer_enabled = 1

" keeping it centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap [ [<c-g>u
inoremap ( (<c-g>u

" jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'
" binding j and k to gj and gk
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Custom surrounds
let w:surround_{char2nr('w')} = "```\r```"
let b:surround_{char2nr('b')} = "**\r**"




au! BufWritePost $RC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
