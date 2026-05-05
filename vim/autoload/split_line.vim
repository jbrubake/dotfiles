" https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666

function! split_line#BreakHere()
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction

