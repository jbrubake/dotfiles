" pmalek (github.com/pmalek/toggle-maximize.vim)
let t:maximizeCurrentWindow = 0

function! wbtmgmt#ToggleMaximizeCurrentWindow()
    if t:maximizeCurrentWindow == 0
        :vertical resize
        :resize
        let t:maximizeCurrentWindow = 1
    else
        :exe "normal \<C-W>="
        let t:maximizeCurrentWindow = 0
    endif
endfunction

" Kevin Kuchta (www.vimbits.com/bits/317)
function! wbtmgmt#ToggleColorColumn()
    if &colorcolumn == ''
        setlocal colorcolumn=80
    else
        setlocal colorcolumn&
    endif
endfunction
