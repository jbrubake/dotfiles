" Markdown Bold and Italic don't display right when using vim-colors-solarized
" as no bold attribute is available
" highlight markdownBold   ctermfg=red
" highlight markdownItalic ctermfg=white

" Conceal links
"
" https://vi.stackexchange.com/questions/26825/conceal-markdown-links-and-extensions
"
syn region markdownLinkText matchgroup=markdownLinkTextDelimiter
    \ start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@="
    \ nextgroup=markdownLink,markdownId skipwhite
    \ contains=@markdownInline,markdownLineStart
    \ concealends
syn region markdownLink matchgroup=markdownLinkDelimiter
    \ start="(" end=")" keepend contained conceal contains=markdownUrl
syn match markdownExt /{[.:#][^}]*}/ conceal contains=ALL

" Match and highlight @ tags
syn match wikiTag /\(^\|\s\+\)@\w\S*/
highlight wikiTag ctermfg=2

" Highlight YAML block
syn region wikiYAML start=/^---$/ end=/^...$/
highlight wikiYAML ctermfg=3
