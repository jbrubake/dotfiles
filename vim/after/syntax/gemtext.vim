" Basically override the included gemtext syntax
"

" Highlight the marker, URL and title like the gemini-vim-syntax plugin
"
" https://tildegit.org/sloum/gemini-vim-syntax
"
syntax match LinkStart /^=>/            nextgroup=LinkURL   skipwhite
syntax match LinkURL   /\S\+/ contained nextgroup=LinkTitle skipwhite
syntax match LinkTitle /.*$/  contained

highlight default link LinkStart Todo
highlight default link LinkTitle String

" Match blockquote marker immediately (otherwise it looks weird as I type)
"
syntax match Quote /^>.*/

highlight default link Quote Constant

" Highlight each heading level differently
"
syntax match Heading1 /^#[^#].*$/
syntax match Heading2 /^##[^#].*$/
syntax match Heading3 /^###[^#].*$/

highlight default link Heading1 htmlH1
highlight default link Heading2 htmlH2
highlight default link Heading3 htmlH3

" Remove as unneeded
syntax clear Heading

" Highlight just the list item marker
"
highlight default link ListMarker Statement

syntax match ListMarker /^\*/

" Remove as unneeded
syntax clear List

" Preformatted text
"
syntax region Preformatted start=/^```/ end=/```/

highlight default link Preformatted Identifier


let b:current_syntax = 'gemtext'

