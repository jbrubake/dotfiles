" Turn on conceal
setlocal conceallevel=2

" gf works with files that do not exist
" TODO: Make this an autocmd that only applies to the wiki
" FIXME: Fails if cursor is in the middle of a link
nnoremap <buffer> gf f( :find <cfile><CR>

" Override vim-markdown foldtext
set foldtext=NeatFoldText()

