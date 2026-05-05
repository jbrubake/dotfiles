" Turn on conceal
setlocal conceallevel=2

" Override vim-markdown foldtext
set foldtext=NeatFoldText()

" markdown : jump to next heading
"
" From https://gist.github.com/romainl/ac63e108c3d11084be62b3c04156c263
"
" TODO: Should this be an autoload with the maps defined here?
function! s:JumpToNextHeading(direction, count)
    let col = col(".")

    silent execute a:direction == "up" ? '?^#' : '/^#'

    if a:count > 1
        silent execute a:direction ==? "up"
            \ ? '?^#?normal! N' .. a:count .. 'n'
            \ : '/^#/normal! N' .. a:count .. 'n'
    endif

    silent execute "normal! " . col . "|"

    unlet col
endfunction

nnoremap <buffer> <silent> ]] :<C-u>call <SID>JumpToNextHeading("down", v:count1)<CR>
nnoremap <buffer> <silent> [[ :<C-u>call <SID>JumpToNextHeading("up", v:count1)<CR>
