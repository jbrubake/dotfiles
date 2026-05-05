function! tagbar#load()
    if ! filereadable('tags') && empty(glob('*.md')) == 1
        return 0
    endif

    packadd tagbar

    " ctags commands
    " --------------
    " CTRL-] : Jump to tag underneath cursor
    " CTRL-o : Jump back in the tag stack
    " :ts <tag> : Search for <tag>
    " :tn : Go to next definition of last tag
    " :tp : Go to previous definition of last tag
    " :ts : List all definitions of last tag
    "
    " Default settings
    " ----------------
    " let g:tagbar_left      = 1
    " let g:tagbar_width     = 40
    " let g:tagbar_autoclose = 0

    " <F9> : toggle TagBar
    noremap <silent> <F9> <Cmd>TagbarToggle<cr>

    " Add support for Makefiles (requires adding
    "     --regex-make=/^([^# \t:]*):/\1/t,target/
    " to ~/.ctags)
    let g:tagbar_type_make = {'kinds':
                            \ ['m:macros',
                            \ 't:targets']}

    " Add support for Markdown
    let g:tagbar_type_markdown = {
        \ 'ctagstype'  : 'markdown',
        \ 'ctagsbin'   : 'markdown2ctags',
        \ 'ctagsargs'  : '-f - --sort=yes --sro=»',
        \ 'kinds'      : ['s:sections', 'i:images'],
        \ 'sro'        : '»',
        \ 'kind2scope' : {'s' : 'section',},
        \ 'sort'       : 0}
endfunction


