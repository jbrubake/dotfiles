if exists("did_load_filetypes_userafter")
    finish
endif
let load_filetypes_userafter = 1

augroup filetypedetect
    autocmd! BufRead,BufNewFile *.mdp set filetype=markdown
augroup END
