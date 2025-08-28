augroup vimwiki | autocmd!
    " Force *.md Vimwiki files to use the real Markdown syntax
    autocmd BufWinEnter *.md set syntax=markdown

    " Override vimwiki fold options and use vim-markdown-folding instead
    "
    autocmd BufWinEnter *.md setlocal foldlevel=0
    autocmd BufWinEnter *.md setlocal foldmethod=expr
    autocmd BufWinEnter *.md setlocal foldexpr=NestedMarkdownFolds()
augroup end

