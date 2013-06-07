" Modeline and Notes {{{
" vim: foldlevel=0

" Folding cheet sheet 
" zR    open all folds
" zM    close all folds
" za    toggle fold at cursor position
" zj    move down to start of next fold
" zk    move up to end of previous fold

"      _ _                _____  __  ____  
"     (_) |__  _ __ _   _|___ / / /_|___ \ 
"     | | '_ \| '__| | | | |_ \| '_ \ __) |
"     | | |_) | |  | |_| |___) | (_) / __/ 
"    _/ |_.__/|_|   \__,_|____/ \___/_____|
"   |__/                                   

"   Jeremy Brubaker's .vimrc. Some stuff in here was shame-
"   lessly ripped from places I completely forget about.
"
"   https://github.com/jbrubake/dotfiles/blob/master/vimrc

    set nocompatible " This needs to be first

" }}}

" Color and Syntax Settings {{{
"===============================
    set background=dark   " Background color
    colorscheme desert256 " Colorscheme
    syntax enable         " Use syntax hilighting
    set hlsearch          " Highlight search matches

   " In-active window status line
   highlight StatusLineNC ctermfg=blue ctermbg=black
   " Active window status line
   highlight StatusLine   ctermfg=blue ctermbg=white

   highlight NonText    ctermfg =darkblue " Listchars
   highlight SpecialKey ctermfg =brown    " Non-printable chars
   
   " Statusline colors
   highlight User1 ctermfg=red   ctermbg=blue
   highlight User2 ctermfg=green ctermbg=blue
" }}}

" Statusline {{{
"===============
set laststatus=2                 " Always show status line
set statusline=                  " Clear status line
set statusline+=%t               " Filename
set statusline+=%m               " Modified flag
set statusline+=%r               " Readonly flag
set statusline+=\ %-15.(%l,%c%)  " Line number and column number
set statusline+=\ %p             " Percentage through file in lines
set statusline+=\ [Filetype=%Y]  " Filetype
set statusline+=\ [ASCII=%03.3b] " ASCII value of char under cursor
set statusline+=\ [Lines=%L]     " Total lines in buffer

" }}}

" Basics {{{
"===========
filetype plugin indent on           " Load filetype plugins and indent settings

set encoding=utf8                   " Use Unicode

set noexrc                          " Do not source .exrc
set autowrite                       " Write file when changing to a new file
set wildmenu                        " Show Tab completion menu
set wildmode=longest,list           " Tab complete longest part, then show menu
set autochdir                       " Automatically chdir to file (needed
                                    " for a.vim) automatically
set backspace=indent,eol,start      " What BS can delete
set backupdir=~/.vim/backup         " Where to put backup files
set directory=~/.vim/tmp            " Where to put swap files
set mouse=a                         " Use mouse everywhere
set mousehide                       " Hide mouse while typing
set incsearch                       " Incremental search
set nolist                          " Do not show listchars
set listchars=
set listchars+=extends:>,precedes:< " Show long line continuation chars
set listchars+=tab:»\               " Show real tabs
set listchars+=trail:.              " Show trailing spaces and higlight them
set listchars+=eol:¬                " Show end of line
set visualbell                      " Blink instead of beep
set relativenumber                  " Use relative line numbers
set numberwidth=4                   " Allows line numbers up to 999
set report=0                        " Always report when a : command
                                    " changes something
set shortmess=aOstT                 " Keep messages short
set scrolloff=10                    " Keep 10 lines at top/bottom
set sidescrolloff=10                " Keep 10 lines at right/left
set sidescroll=1                    " Horizontal scroll one column at a
                                    " time
set showtabline=2                   " Always show tabline
set hidden                          " Allow hidden buffers
"set colorcolumn=70                 " Higlight column 70
" }}}

" Text Formatting/Layout {{{
"===========================
set formatoptions+=rqln  " Insert comment leader on return, let gq format
                         "  comments and do not break an already long line
                         "  during insert, support numbered/bulleted lists
set ignorecase           " Case insensitive by default
set smartcase            "  but case sensitive if search string is multi-case
set nowrap               " Long lines do not wrap
set shiftround           " Indent at multiples of shiftwidth
set smartcase            " If there are caps, be case sensitive
set expandtab            " Expand tabs to spaces
set tabstop=4            " Real tabs are 4 spaces
set softtabstop=4        " A tab is 4 spaces for a tab or backspace
set shiftwidth=4         " Indent and <</>> is 4 spaces
set textwidth=80         " Lines wrap at column 80
set autoindent           " Automatically indent based on previous line
set smartindent          " Automatic indenting is intelligent
set matchpairs+=<:>      " Match <,> with %
" }}}

" Folding {{{
"============
    set foldenable                                   " Turn on folding
    set foldmethod=marker                            " Fold on the marker
    set foldopen=block,hor,mark,percent,quickfix,tag " What movements open folds
" }}}

" Plugins {{{
"============
" TODO: Only configure plugin if it exists

    " Manage plugins with pathogen
    call pathogen#infect()
    call pathogen#helptags()

    " ShowMarks {{{
    " Enable ShowMarks
    let g:showmarks_enable=1

    " Only show marks in files I am editing
    let g:showmarks_ignore_type="hmpqr"

    " Marks to show
    "
    " '`: last position
    " . : last change
    " (): start/end of sentence
    " {}: start/end of paragraph
    let g:showmarks_include="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'`.(){}"

    highlight ShowMarksHLl cterm=bold ctermfg=yellow ctermbg=darkgrey " Lower case
    highlight ShowMarksHLu cterm=bold ctermfg=yellow ctermbg=darkgrey " Upper case
    highlight ShowMarksHLo cterm=bold ctermfg=yellow ctermbg=darkgrey " Other
    highlight ShowMarksHLm cterm=bold ctermfg=yellow ctermbg=darkgrey " Multiple
    " }}}

    " Taglist {{{
    "let Tlist_Sort_Type="name"     " Sort taglist alphabetically
    "let Tlist_Use_Right_Window=1   " Put taglist on the right
    "let Tlist_Enable_Fold_column=0 " Do not show Vim fold column
    "let Tlist_Exit_OnlyWindow=1    " Exit vim if only taglist is open

    " Function to cleanly open TagList window
    " XXX: Is there a better way to do this?
    "function! My_tlist_open()
        "TlistOpen
        "setlocal norelativenumber
        "wincmd p
    "endfunction

    " Toggle taglist window
    "noremap <silent> <F9> :TlistToggle<CR>

    " }}}

    " Tagbar {{{

    " Toggle taglist window
    noremap <silent> <F9> :TagbarToggle<CR>

    " }}}

    " snipMate {{{
    let g:snips_author = 'Jeremy Brubaker <jbru362@gmail.com>' " Authorname for snipMate
    " }}}

    " tabular {{{
    if exists(":Tabularize")
        " Align '=' with padding spaces on both sides
        nmap <leader>t= :Tabularize /=<cr>
        vmap <leader>t= :Tabularize /=<cr>

        "nmap <Leader>a= :Tabularize /=<CR>
        "vmap <Leader>a= :Tabularize /=<CR>
        "nmap <Leader>a: :Tabularize /:<CR>
        "vmap <Leader>a: :Tabularize /:<CR>
        "nmap <Leader>a:: :Tabularize /:\zs<CR>
        "vmap <Leader>a:: :Tabularize /:\zs<CR>
        "nmap <Leader>a, :Tabularize /,<CR>
        "vmap <Leader>a, :Tabularize /,<CR>
        "nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
        "vmap <Leader>a<Bar> :Tabularize /<Bar><CR>

        "" The following function automatically aligns when typing a
        "" supported character
        "inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

        "function! s:align()
            "let p = '^\s*|\s.*\s|\s*$'
            "if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
                "let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
                "let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
                "Tabularize/|/l1
                "normal! 0
                "call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
            "endif
        "endfunction
    endif
    " }}}

    " neocomplcache {{{
    "let g:neocomplcache_enable_at_startup = 1
    "let g:neocomplcache_enable_camel_case_completion = 1
    "let g:neocomplcache_enable_smart_case = 1
    "let g:neocomplcache_enable_underbar_completion = 1
    "let g:neocomplcache_min_syntax_length = 3
    "let g:neocomplcache_enable_auto_delimiter = 1

    " AutoComplPop like behavior.
    "let g:neocomplcache_enable_auto_select = 0

    " SuperTab like snippets behavior.
    "imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

    " Plugin key-mappings.
    "imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    "smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    "inoremap <expr><C-g>     neocomplcache#undo_completion()
    "inoremap <expr><C-l>     neocomplcache#complete_common_string()

    " <CR>: close popup
    " <s-CR>: close popup and save indent.
    "inoremap <expr><CR>  pumvisible() ? neocomplcache#close_popup() : "\<CR>"
    "inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup() "\<CR>" : "\<CR>"
    " <TAB>: completion.
    "inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

    " <C-h>, <BS>: close popup and delete backword char.
    "inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    "inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    "inoremap <expr><C-y>  neocomplcache#close_popup()
    "inoremap <expr><C-e>  neocomplcache#cancel_popup()

    " Enable omni completion.
    "autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    "autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    "autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    "autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    "autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    "if !exists('g:neocomplcache_omni_patterns')
        "let g:neocomplcache_omni_patterns = {}
    "endif
    "let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    "autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    "let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
    "let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

    " For snippet_complete marker.
    "if has('conceal')
        "set conceallevel=2 concealcursor=i
    "endif
    " }}}

    " NERDTree {{{
        let NERDTreeQuitOnOpen=1 " Close browser when opening a file

        " Toggle NERDTree browser
        noremap <silent> <F8> :NERDTreeToggle<CR>

        " Find current file in NERDTree
        noremap <silent> <F7> :NERDTreeFind<CR>
     " }}}

     " Fugitive {{{
     "nnoremap <silent> <leader>gs :Gstatus<CR>
     "nnoremap <silent> <leader>gd :Gdiff<CR>
     "nnoremap <silent> <leader>gc :Gcommit<CR>
     "nnoremap <silent> <leader>gb :Gblame<CR>
     "nnoremap <silent> <leader>gl :Glog<CR>
     "nnoremap <silent> <leader>gp :Git push<CR>
     " }}}
     
" }}}

" Mappings {{{
"=============
    " TODO: Mapping to turn on colorcolumn

    " Use ',' as <leader>
    let mapleader = ","

    " Clear search string to remove highlighting
    nnoremap <leader><space> :noh<cr>

    " Use TAB to jump between braces, etc
    nnoremap <tab> %
    vnoremap <tab> %

    " Toggle listchars
    nmap <silent> <leader>l :set list!<cr>

    " Switch windows with Ctl-[hjkl]
    " TODO: <C-W>?<C-W>_ switches *and* maximizes
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-H> <C-W>h
    map <C-L> <C-W>l

    " Make Y consistent with C and D
    nnoremap Y y$

    " Resize windows with + and -
    map + <C-W>+
    map - <C-W>-
    " <C-W>> and <C-W>< do this for vertical windows, but
    " < and > are already bound. Hmm...

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Clearing highlighted search
    nmap <silent> <leader>/ :nohlsearch<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Reflow paragraph with Q in normal and visual mode
    nnoremap Q gqap
    vnoremap Q gq

    " Basically underline current line with '='
    " TODO: Conflicts with mapping above
    "nmap <leader>= yypVr=

    " Turn on paste mode with F12
    set pastetoggle=<F12>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>
" }}}

" Autocommands {{{
"=================

    " Always switch to the current file directory.
    au BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

    au Filetype gitcommit set tw=68 " spell <-- annoying, but I'd like to use it

    au BufWritePost ~/.vimrc source ~/.vimrc " Reread .vimrc after editing

    "au BufRead *.c,*.cc,*.h :call My_tlist_open() " Open taglist when opening C source

    " Makefiles {{{
        au filetype make setlocal noexpandtab       " We need real tabs
        au filetype make setlocal tabstop=8         " Real tabs are 8 spaces
        au filetype make setlocal softtabstop=8
        au filetype make setlocal shiftwidth=8
    " }}}
    " snipMate {{{
        au filetype snippet setlocal tabstop=8 " snipMate works better with
                                               " full tabs
        au filetype snippet setlocal softtabstop=0
        au filetype snippet setlocal tabstop=8
    " }}}
    " C {{{
        au Filetype c setlocal foldmethod=syntax "Fold on comments and braces
        au Filetype c setlocal foldlevel=100     " Don't automatically fold
    " }}}
" }}}

" Local Vimrc{{{
" ================================
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    endif
" }}}

" Functions {{{

"function! InitializeDirectories()
    "let separator = "."
    "let parent = $HOME
    "let prefix = '.vim'
    "let dir_list = {
                "\ 'backup': 'backupdir',
                "\ 'views': 'viewdir',
                "\ 'swap': 'directory' }

    "if has('persistent_undo')
        "let dir_list['undo'] = 'undodir'
    "endif

    "for [dirname, settingname] in items(dir_list)
        "let directory = parent . '/' . prefix . dirname . "/"
        "if exists("*mkdir")
            "if !isdirectory(directory)
                "call mkdir(directory)
            "endif
        "endif
        "if !isdirectory(directory)
            "echo "Warning: Unable to create backup directory: " . directory
            "echo "Try: mkdir -p " . directory
        "else
            "let directory = substitute(directory, " ", "\\\\ ", "g")
            "exec "set " . settingname . "=" . directory
        "endif
    "endfor
"endfunction
"call InitializeDirectories()

"function! NERDTreeInitAsNeeded()
    "redir => bufoutput
    "buffers!
    "redir END
    "let idx = stridx(bufoutput, "NERD_tree")
    "if idx > -1
        "NERDTreeMirror
        "NERDTreeFind
        "wincmd l
    "endif
"endfunction
" }}}

