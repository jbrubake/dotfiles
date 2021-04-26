" Match and highlight @ tags
syn match wikiTag /\(^\|\s\+\)@\w\S*/
highlight wikiTag ctermfg=2

" Highlight YAML block
syn region wikiYAML start=/^---$/ end=/^...$/
highlight wikiYAML ctermfg=3
