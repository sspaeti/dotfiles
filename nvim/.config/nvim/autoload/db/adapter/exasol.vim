" Exasol adapter for vim-dadbod, backed by usql (https://github.com/xo/usql).
" vim-dadbod has no native Exasol support; usql ships with the official
" exasol-driver-go, so we simply hand the URL through to it.
"
" URL format:
"   exasol://user:password@host:port?validateservercertificate=0
"
" The query params are passed straight to the Exasol Go driver, so
" validateservercertificate=0 is the equivalent of DBeaver's
" `validateservercertificate = 0` driver property (self-signed TLS cert).

function! db#adapter#exasol#interactive(url) abort
  return ['usql', '-q', a:url]
endfunction

function! db#adapter#exasol#input(url, in) abort
  return ['usql', '-q', '-f', a:in, a:url]
endfunction

" Used by vim-dadbod-ui / vim-dadbod-completion to list tables.
function! db#adapter#exasol#tables(url) abort
  return map(db#systemlist(['usql', '-q', '-t', '-A', '-c',
        \ 'SELECT table_schema || ''.'' || table_name FROM exa_all_tables ORDER BY 1;',
        \ a:url]), 'trim(v:val)')
endfunction
