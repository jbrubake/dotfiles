" Fold quotations {{{1
setlocal foldexpr=strlen(substitute(matchstr(getline(v:lnum),'\\v^\\s*%(\\>\\s*)+'),'\\s','','g')) 
setlocal foldmethod=expr foldlevel=1 foldminlines=2

" formatoptions=aq  Enable automatic formatting of paragraphs and comments
" comments+=nb:> Lines starting with > are “comments” (so quotes
"                within a mail are displayed differently from the rest
"                of the message).
" match ErrorMsg '\s\+$' Highlight the trailing space at the end of
"                        broken lines, to provide a visual distinction
"                        between “soft” and “hard” line breaks
setlocal formatoptions=aq
setlocal comments=nb:>
match ErrorMsg '\s\+$'

setlocal textwidth=72
setlocal spell

" goobook address completion for emails {{{1
"
" https://jfreak53.blogspot.com/2012/07/vim-as-mutt-email-editor.html
" Code at https://pastebin.com/tR08XHbF
fun! MailcompleteC(findstart, base)
    if a:findstart == 1
        let line = getline('.')
        let idx = col('.')
        while idx > 0
            let idx -= 1
            let c = line[idx]
            " break on header and previous email
            if c == ':' || c == '>'
                return idx + 2
            else
                continue
            endif
        endwhile
        return idx
    else
        if exists("g:goobookrc")
            let goobook="goobook -c " . g:goobookrc
        else
            let goobook="goobook"
        endif
        let res=system(goobook . ' query ' . shellescape(a:base))
        if v:shell_error
            return []
        else
            "return split(system(trim . '|' . fmt, res), '\n')
            return MailcompleteF(MailcompleteT(res))
        endif
    endif
endfun

fun! MailcompleteT(res)
    " next up: port this to vimscript!
    let trim="sed '/^$/d' | grep -v '(group)$' | cut -f1,2"
    return split(system(trim, a:res), '\n')
endfun

fun! MailcompleteF(contacts)
    "let fmt='awk ''BEGIN{FS="\t"}{printf "%s <%s>\n", $2, $1}'''
    let contacts=map(copy(a:contacts), "split(v:val, '\t')")
    let ret=[]
    for [email, name] in contacts
        call add(ret, printf("%s <%s>", name, email))
    endfor
    return ret
endfun
setlocal completefunc=MailcompleteC

