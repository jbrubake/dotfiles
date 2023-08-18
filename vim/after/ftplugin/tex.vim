setlocal spell

let b:spellfile = 'wordlist.utf-8.add'

if filereadable(b:spellfile) && (!filereadable(b:spellfile . '.spl') || getftime(b:spellfile) > getftime(b:spellfile . '.spl'))
    exec 'mkspell! '. fnameescape(b:spellfile)
endif

let &l:spellfile = b:spellfile

nmap <localleader><F5> <Plug>(vimtex-compile)
nmap <localleader><F6> <Plug>(vimtex-view)

