" rm -rf for netrw
"
if exists("autoloaded_netrw")
    finish
endif
let autoloaded_netrw = 1

function! netrw#RemoveRecursive()
  if &filetype ==# 'netrw'
    cnoremap <buffer> <CR> rm -r<CR>
    normal mu
    normal mf

    try
      normal mx
    catch
      echo "Canceled"
    endtry

    cunmap <buffer> <CR>
  endif
endfunction

" source the real netrw.vim
runtime! autoload/netrw.vim
