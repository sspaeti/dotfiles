

"" fzf: ctrl f for find files
"nnoremap <C-p> :Files<CR>
"" nnoremap <C-f> :Rg<CR> "-> now on sf
"nnoremap <leader>fw
"  \ :call fzf#vim#files('.', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<cr>
"nnoremap <silent> <Leader>fr :Rg<CR>
"nnoremap <silent> <Leader>fb :Buffers<CR>
"nnoremap <silent> <Leader>f/ :BLines<CR>
"nnoremap <silent> <Leader>fm :Marks<CR>
"nnoremap <silent> <Leader>fc :Commits<CR>
"nnoremap <silent> <Leader>fH :Helptags<CR>
"" find in a specific repo
"command! -bang -nargs=* Rg2
"  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}, <bang>0)
"nnoremap <silent> <Leader>fd :Rg2 search folder


"" move window with christoomey/vim-tmux-navigator to align tmux and nvim
"let g:tmux_navigator_no_mappings = 1
"" If the tmux window is zoomed, keep it zoomed when moving from Vim to another pane
"let g:tmux_navigator_preserve_zoom = 1

"noremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
"noremap <silent> <c-j> :<C-U>TmuxNavigateDown<cr>
"noremap <silent> <c-k> :<C-U>TmuxNavigateUp<cr>
"noremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>
"noremap <silent> <c-t> :<C-U>TmuxNavigatePrevious<cr>

"" Resize window ABSOLUTE (doing it the same direction wheter in right or left
"" split)
"nnoremap <C-w>l :if winnr() == winnr('$') \| vertical resize -5 \| else \| vertical resize +5 \| endif<CR>
"nnoremap <C-w>h :if winnr() == 1 \| vertical resize -5 \| else \| vertical resize +5 \| endif<CR>

"" resize window RELATIVE (Haven't found a absoulte way)
"" nnoremap <C-w>k :wincmd k \| if winnr() == winnr('$') \| resize -5 \| else \| resize +5 \| endif<CR>
"" nnoremap <C-w>j :wincmd j \| if winnr() == 1 \| resize +5 \| else \| resize -5 \| endif<CR>
"nnoremap <C-w>k :resize -5<CR>
"nnoremap <C-w>j :resize +5<CR>

"" Open current directory
"nmap te :tabedit
"nmap <leader>tn :tabnew<Return>
"nmap <S-Tab> :tabprev<Return>
"" Attention, sometimes when you map <Tab> also ctrl+i will change!
""nmap <Tab> :tabnext<Return>

""nnoremap <Tab> :tabnext<Return>

"" Find files using Telescope command-line sugar. --> replaced by fzf as faster and more options such as search :Lines :Buffer and .gitignore integration
"" nnoremap <leader>ff <cmd>Telescope find_files<cr>
"" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
"" nnoremap <leader>fb <cmd>Telescope buffers<cr>
"" nnoremap <leader>fh <cmd>Telescope help_tags<cr>
"" nnoremap <C-p> <cmd>Telescope find_files<cr>

""ranger nvim
"" nnoremap <leader>e :RnvimrToggl<CR>

""
"" Replace `$EDITOR` candidate with this command to open the selected file
"let g:rnvimr_edit_cmd = 'drop'

""
""let blame default be on
"let g:blamer_enabled = 1

"" keeping it centered
"nnoremap n nzzzv
"nnoremap N Nzzzv
"nnoremap J mzJ`z

"" undo break points
"inoremap , ,<c-g>u
"inoremap . .<c-g>u
"inoremap [ [<c-g>u
"inoremap ( (<c-g>u

"" jumplist mutations
"nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
"nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'
"" binding j and k to gj and gk
"nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
"nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

"" Custom surrounds
"let w:surround_{char2nr('w')} = "```\r```"
"let b:surround_{char2nr('b')} = "**\r**"




"au! BufWritePost $RC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
