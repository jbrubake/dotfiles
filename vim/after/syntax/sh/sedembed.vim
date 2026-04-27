" Highlight sed embedded in shell
"
" Adapted from https://stackoverflow.com/a/53066372

let s:save_syntax = b:current_syntax
unlet b:current_syntax

syntax include @SedScript syntax/sed.vim
try
    syntax include @SedScript after/syntax/sed.vim
catch
endtry

let b:current_syntax = s:save_syntax
unlet s:save_syntax

" Remove 'sed' so it will match SedCommand
syntax clear shStatement
syntax keyword shStatement basename cat chgrp chmod chown cksum clear cmp comm cp cut date dirname du egrep expr false fgrep find fmt fold getconf grep head iconv id join kill killall less ln login logname ls md5sum mkdir mkfifo mknod mktemp mv newgrp nice nohup od paste pathchk printenv pwd readlink realpath rename rev rm rmdir sha1sum sha224sum sha256sum sha384sum sha512sum sleep sort strip stty sum sync tail tee test tput tr true tty uname uniq wc which xargs

syntax region SedScriptCode
    \ matchgroup= SedCommand
    \ start=      +[=\\]\@<!'\n+
    \ skip=       +\\'+
    \ end=        +'+
    \ contains=   @SedScript
    \ contained
    \ skipwhite
    \ skipempty

syntax region SedScriptEmbedded
    \ matchgroup= SedCommand
    \ start=      +\<sed\>+
    \ skip=       +\\$+
    \ end=        +[=\\]\@<!'+me=e-1
    \ contains=   @shIdList,@shExprList2
    \ nextgroup=  SedScriptCode

syntax cluster shCommandSubList add=SedScriptEmbedded

highlight default link SedCommand shStatement
