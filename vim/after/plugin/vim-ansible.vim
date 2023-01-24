" Extension to https://github.com/pearofducks/ansible-vim
"
" Based on https://gist.github.com/mtyurt/3529a999af675a0aff00eb14ab1fdde3
"
function! FindAnsibleRoleUnderCursor()
  if exists("g:ansible_goto_role_paths")
    let l:role_paths = g:ansible_goto_role_paths
  else
    let l:role_paths = "./roles"
  endif
  let l:tasks_main = expand("<cfile>") . "/tasks/main.y*ml"
  let l:found_role_path = globpath(l:role_paths, l:tasks_main)
  if l:found_role_path == ""
    echo l:tasks_main . " not found"
  else
    execute "edit " . fnameescape(l:found_role_path)
  endif
endfunction

autocmd FileType yaml.ansible nnoremap <leader>gr :call FindAnsibleRoleUnderCursor()<CR>
autocmd FileType yaml.ansible vnoremap <leader>gr :call FindAnsibleRoleUnderCursor()<CR>

