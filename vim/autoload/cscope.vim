function! cscope#LoadCCTree()
    if filereadable($CSCOPE_DB)
        let s:db = $CSCOPE_DB
    elseif filereadable("cscope.out")
        let s:db = 'cscope.out'
    else
        return 0
    endif

    packadd! CCTree

    set cscopetag                           " use cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetagorder=0                    " search cscope then ctags
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a- " Open all results in quickfix 

    execute 'CCTreeLoadDB ' . s:db
endfunction

