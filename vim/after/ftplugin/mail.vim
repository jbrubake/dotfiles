" Emails should be RFC 3676 format=flowed
"     https://incenp.org/notes/2020/format-flowed-neomutt-vim.html
"
" formatoptions=awq  Enable automatic formatting of paragraphs, with
"                    trailing white space indicating a paragraph
"                    continues in the next line
" comments+=nb:> Lines starting with > are “comments” (so quotes
"                within a mail are displayed differently from the rest
"                of the message).
" match ErrorMsg '\s\+$' Highlight the trailing space at the end of
"                        broken lines, to provide a visual distinction
"                        between “soft” and “hard” line breaks
setlocal textwidth=72
setlocal formatoptions=awq
setlocal comments+=nb:>
setlocal spell
match ErrorMsg '\s\+$'
