" vim: foldlevel=0

" Folding cheet sheet 
" zR    open all folds
" zM    close all folds
" za    toggle fold at cursor position
" zj    move down to start of next fold
" zk    move up to end of previous fold

" I want vim not vi. This needs to be first
set nocompatible

" Color and Syntax Settings {{{
"===============================
if &t_Co > 2 " What about 16/256 color schemes?
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
endif
" }}}

" Statusline {{{
"===============
set laststatus=2                 " Always show status line
set statusline=                  " Clear status line
set statusline+=%F               " Full path to file
set statusline+=%m               " Modified flag
set statusline+=%r               " Readonly flag
set statusline+=\ %-15.(%l,%c%)  " Line number and column number
set statusline+=\ %P             " Percentage through file of displayed window
set statusline+=\ [Filetype=%Y]  " Filetype
set statusline+=\ [ASCII=%03.3b] " ASCII value of char under cursor
set statusline+=\ [Lines=%L]     " Total lines in buffer

" }}}

" Basics {{{
"===========
filetype plugin indent on      " Load filetype plugins and indent settings

set noexrc                          " Do not source .exrc
set autowrite                       " Write file when changing to a new file
set wildmode=longest,list           " Filename completion like in Bash
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
" set number                        " Show line numbers
" set colorcolumn=85                " Higlight a column for wrapping
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
" }}}

" Folding {{{
"============
    set foldenable                                   " Turn on folding
    set foldmethod=marker                            " Fold on the marker
    set foldopen=block,hor,mark,percent,quickfix,tag " What movements open folds
" }}}

" Plugins {{{
"============
    " Taglist {{{
    let Tlist_Sort_Type="name"     " Sort taglist alphabetically
    let Tlist_Use_Right_Window=1   " Put taglist on the right
    let Tlist_Enable_Fold_column=0 " Do not show Vim fold column
    let Tlist_Exit_OnlyWindow=1    " Exit vim if only taglist is open
    " }}}
    " snipMate {{{
    let g:snips_author = 'Jeremy Brubaker' " Authorname for snipMate
    " }}}
    " tabular {{{
    if exists(":Tabularize")
        nmap <leader>t= :Tabularize /=<cr>
        vmap <leader>t= :Tabularize /=<cr>
    endif
    " }}}
" }}}

" Mappings {{{
"=============
    let mapleader = "," " Use ',' as <leader>

    " Clear search string to remove highlighting
    nnoremap <leader><space> :noh<cr>

    " Use TAB to jump between braces, etc
    nnoremap <tab> %
    vnoremap <tab> %

    " Toggle listchars
    nmap <silent> <leader>l :set list!<cr>

    " Switch windows with Ctl-[hjkl]
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-H> <C-W>h
    map <C-L> <C-W>l

    " Make Y consistent with C and D
    nnoremap Y y

    " Resize windows with + and -
    map + <C-W>+
    map - <C-W>-
    " <C-W>> and <C-W>< do this for vertical windows, but
    " < and > are already bound. Hmm...

    " Toggle taglist window
    noremap <silent> <F9> :TlistToggle<CR>

    " Toggle NERDTree browser
    noremap <silent> <F8> :NERDTreeToggle<CR>

    " Reflow paragraph with Q in normal and visual mode
    nnoremap Q gqap
    vnoremap Q gq

    " Basically underline current line with '='
    nmap <leader>= yypVr=
" }}}

" Autocommands {{{
"=================
    au Filetype gitcommit set tw=68 " spell <-- annoying, but I'd like to use it

    au BufWritePost ~/.vimrc source ~/.vimrc " Reread .vimrc after editing

    au BufRead *.c,*.cc,*.h :TlistOpen " Open taglist when opening C source
                                       " Make this more generic

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

