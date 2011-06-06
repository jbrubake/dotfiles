" vim: foldmarker={,} foldlevel=0

" Color and Syntax Settings {
if &t_Co > 2
    set background=dark   " Background color
    colorscheme desert256 " Colorscheme
    syntax enable         " Use syntax hilighting

    highlight StatusLineNC ctermfg=blue ctermbg=black " In-active window status line
    highlight StatusLine   ctermfg=blue ctermbg=white " Active window status line
endif
" }

" Basics {
set nocompatible                " Vim not vi
set noexrc                      " Do not source .exrc
set autowrite                   " Write file when changing to a new file
set wildmode=longest,list       " Filename completion like in Bash
" }

" General {
filetype plugin indent on      " Load filetype plugins and indent
                               "  settings
set autochdir                  " Automatically chdir to file (needed
                               "  for a.vim) automatically
set backspace=indent,eol,start " What BS can delete
set backupdir=~/.vim/backup    " Where to put backup files
set directory=~/.vim/tmp       " Where to put swap files
set mouse=a                    " Use mouse everywhere
set mousehide                  " Hide mouse while typing
" }

" Vim UI {
set incsearch                      " Incremental search
set laststatus=2                   " Always show status line
set list                           " Show listchars
set listchars=extends:>,precedes:< " Show long line continuation chars
set listchars=tab:->               " Show real tabs
set listchars=trail:.              " Show trailing spaces and higlight them
set hlsearch                       " Highlight search matches
set visualbell                     " Blink instead of beep
set number                         " Show line numbers
set numberwidth=4                  " Allows line numbers up to 999
set report=0                       " Always report when a : command
                                   "  changes something
set shortmess=aOstT                " Keep messages short
set scrolloff=10                   " Keep 10 lines at top/bottom
set sidescrolloff=10               " Keep 10 lines at right/left
set sidescroll=1                   " Horizontal scroll one column at a
                                   "  time
set statusline=%F%m%r\ %-15.(l,%c%V%)\ %P%%\ [Filetype=%Y]\ [ASCII=%03.3b]\ [Lines=%L]
set showtabline=2                  " Always show tabline
" }

" Text Formatting/Layout {
set formatoptions+=rqln " Insert comment leader on return, let gq format
                        "  comments and do not break an already long line
                        "  during insert, support numbered/bulleted lists
set ignorecase          " Case insensitive by default
set nowrap              " Long lines do not wrap
set shiftround          " Indent at multiples of shiftwidth 
set smartcase           " If there are caps, be case sensitive
set expandtab           " Expand tabs to spaces
set shiftwidth=4        " Indent and <</>> is 4 spaces
set softtabstop=4       " A tab is 4 spaces for a tab or backspace
set textwidth=80        " Lines wrap at column 80
set autoindent          " Automatically indent based on previous line
set smartindent         " Automatic indenting is intelligent
" }

" Folding {
    set foldenable        " Turn on folding
    set foldmethod=marker " Fold on the marker
    set foldopen=block,hor,mark,percent,quickfix,tag " what movements
                                                     "  open folds
" }

" Plugin Settings {
    " Taglist {
    let Tlist_Sort_Type="name"     " Sort taglist alphabetically
    let Tlist_Use_Right_Window=1   " Put taglist on the right
    let Tlist_Enable_Fold_column=0 " Do not show Vim fold column
    let Tlist_Exit_OnlyWindow=1    " Exit vim if only taglist is open
    " }
    " snipMate {
    let g:snips_author = 'Jeremy Brubaker' " Authorname for snipMate
    " }
" }

" Mappings {
    " Switch windows with Ctl-[hjkl]
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

    " Toggle taglist window
    noremap <silent> <F9> :TlistToggle<CR>

    " Toggle NERDTree browser
    noremap <silent> <F8> :NERDTreeToggle<CR>

    " Reflow paragraph with Q in normal and visual mode
    nnoremap Q gqap
    vnoremap Q gq
" }

" Autocommands {
    " Makefiles {
        au filetype make setlocal noexpandtab      " We need real tabs
        au filetype make setlocal listchars=tab:-> " How to show real tabs
        au filetype make setlocal tabstop=8        " Real tabs are 8 spaces
    " }

    " snipMate {
        au filetype snippet setlocal tabstop=8 " snipMate works better with
                                               " full tabs
        au filetype snippet setlocal softtabstop=0
        au filetype snippet setlocal tabstop=8
    " }

    au Filetype gitcommit set tw=68 " spell <-- annoying, but I'd like to use it

    au BufWritePost ~/.vimrc source ~/.vimrc " Reread .vimrc after editing
    au BufRead *.c,*.cc,*.h :TlistOpen " Open taglist when opening C source
                                       " Make this more generic

    " C {
        au Filetype c setlocal foldmethod=syntax "Fold on comments and braces
        au Filetype c setlocal foldlevel=100     " Don't automatically fold
    " }
" }
