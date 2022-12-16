" set lines=80
" set columns=100
" configure firenvim for the browser
let g:firenvim_config = {
    \ 'lines': '80',
    \ 'columns': '100',
    \ 'globalSettings': {
        \ 'lines': '80',
        \ 'columns': '100',
    \  },
\ }
let g:firenvim_config = {
    \ 'localSettings': {
        \ '.*': {
            \ 'lines': '10',
            \ 'columns': '100',
        \ },
    \ }
\ }
