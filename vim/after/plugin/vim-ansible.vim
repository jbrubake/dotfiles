" Load the tasks/main.y[a]ml file for the role under the cursor
"
" Based on https://gist.github.com/mtyurt/3529a999af675a0aff00eb14ab1fdde3
"
function! FindAnsibleRoleUnderCursor()
    if exists('g:ansible_goto_role_paths')
        let l:role_paths = g:ansible_goto_role_paths
    else
        " This is the default search path with ./roles prepended
        let l:role_paths = 'roles, ~/.ansible/roles, /usr/share/ansible/roles, /etc/ansible/roles'
    endif
    let l:tasks_main = expand('<cfile>') . '/tasks/main.y*ml'
    let l:found_role_path = globpath(l:role_paths, l:tasks_main, 0, 1)
    if l:found_role_path == []
        echo l:tasks_main . ' not found'
    else
        execute 'edit ' . fnameescape(l:found_role_path[0])
    endif
endfunction

autocmd FileType yaml.ansible nnoremap <leader>gr :call FindAnsibleRoleUnderCursor()<CR>
autocmd FileType yaml.ansible vnoremap <leader>gr :call FindAnsibleRoleUnderCursor()<CR>

