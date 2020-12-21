"Use todo#complete as the omni complete function for todo files
setlocal omnifunc=todo#complete

" Automatically complete + and @
imap <buffer> + +<C-X><C-O>
imap <buffer> @ @<C-X><C-O>

