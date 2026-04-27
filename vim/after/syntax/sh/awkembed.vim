" Highlight awk embedded in shell
"
" Adapted from :help sh-embed

let s:save_syntax = b:current_syntax
unlet b:current_syntax

syntax include @AWKScript syntax/awk.vim
try
    syntax include @AWKScript after/syntax/awk.vim
catch
endtry

let b:current_syntax = s:save_syntax
unlet s:save_syntax

syntax region AWKScriptCode
    \ matchgroup= AWKCommand
    \ start=      +[=\\]\@<!'+
    \ skip=       +\\'+
    \ end=        +'+
    \ contains=   @AWKScript
    \ contained
    \ skipwhite
    \ skipempty

syntax region AWKScriptEmbedded
    \ matchgroup= AWKCommand
    \ start=      +\<awk\>+
    \ skip=       +\\$+
    \ end=        +[=\\]\@<!'+me=e-1
    \ contains=   @shIdList,@shExprList2
    \ nextgroup=  AWKScriptCode

syntax cluster shCommandSubList add=AWKScriptEmbedded

highlight default link AWKCommand shStatement

