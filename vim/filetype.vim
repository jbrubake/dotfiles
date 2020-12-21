" if exists("did_load_filetypes")
    " finish
" endif
augroup filetypedetect
    autocmd! BufRead,BufNewFile *.mdp set filetype=markdown
augroup END
