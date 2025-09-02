" lib.sh syntax
"
syntax match shImport    /@import/
syntax match shNamespace /\<\a\i\+::/ containedin=shCommandSub " add to $()

" Add shNamespace to conditional and loop tests
syntax cluster shIfList   add=shNamespace
syntax cluster shLoopList add=shNamespace
" Add shNamespace to case body
syntax cluster shCaseList add=shNamespace
" Add shNamespacGist e to [] tests
syntax cluster shTestList add=shNamespace

highlight default link shImport    Statement
highlight default link shNamespace Identifier

