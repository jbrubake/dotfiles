" Highlight awk embedded in shell
"
" Adapted from :help sh-embed

if exists("b:current_syntax")
    unlet b:current_syntax
endif

syntax include @AWKScript syntax/awk.vim
try
    syntax include @AWKScript after/syntax/awk.vim
catch
endtry

syntax region AWKScriptCode
    \ matchgroup= AWKCommand
    \ start=      +[=\\]\@<!'+
    \ skip=       +\\'+
    \ end=        +'+
    \ contains=   @AWKScript
    \ contained

syntax region AWKScriptEmbedded
    \ matchgroup= AWKCommand
    \ start=      +\<awk\>+
    \ skip=       +\\$+
    \ end=        +[=\\]\@<!'+me=e-1
    \ contains=   @shIdList,@shExprList2
    \ nextgroup=  AWKScriptCode

syntax cluster shCommandSubList add=AWKScriptEmbedded

highlight default link AWKCommand Type

