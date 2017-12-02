" vim: foldlevel=0
"    _ _                _           _        
"   (_) |__  _ __ _   _| |__   __ _| | _____ 
"   | | '_ \| '__| | | | '_ \ / _` | |/ / _ \
"   | | |_) | |  | |_| | |_) | (_| |   <  __/
"  _/ |_.__/|_|   \__,_|_.__/ \__,_|_|\_\___|
" |__/                                       
"
"   Jeremy Brubaker's .vimrc. Some stuff in here was shame-
"   lessly ripped from places I completely forget about.
"
"   https://github.com/jbrubake/dotfiles/blob/master/vimrc

" Folding cheet sheet (because I always forget)
" zR    open all folds
" zM    close all folds
" za    toggle fold at cursor position
" zj    move down to start of next fold
" zk    move up to end of previous fold

" Initialization {{{1
" ==============
set nocompatible

" helptags ALL

" Basics {{{1
" ======
filetype plugin indent on           " Load filetype plugins and indent settings

" XXX: Not sure this works
set omnifunc=syntaxcomplete#Complete " Complete on syntax

set encoding=utf8                   " Use Unicode

set noexrc                          " Do not source .exrc
set autowrite                       " Write file when changing to a new file
set wildmenu                        " Show Tab completion menu
set wildmode=longest,list           " Tab complete longest part, then show menu
set autochdir                       " Automatically chdir to file (needed for a.vim)
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
set relativenumber                  " Show relative line number
set number                          " Show line number of current line
set numberwidth=4                   " Allows line numbers up to 999
set report=0                        " Always report when a : command changes something
set shortmess=aOstT                 " Keep messages short
set scrolloff=10                    " Keep 10 lines at top/bottom
set sidescrolloff=10                " Keep 10 lines at right/left
set sidescroll=1                    " Horizontal scroll one column at a time
set showtabline=0                   " Never show tabline
set hidden                          " Allow hidden buffers

" Text Formatting/Layout {{{1
"===========================
set formatoptions+=rqln  " Insert comment leader on return, let gq format
                         "  comments and do not break an already long line
                         "  during insert, support numbered/bulleted lists
set ignorecase           " Case insensitive by default
set smartcase            "  but case sensitive if search string is multi-case
set nowrap               " Long lines do not wrap
set shiftround           " Indent at multiples of shiftwidth
set expandtab            " Expand tabs to spaces
set tabstop=4            " Real tabs are 4 spaces
set softtabstop=4        " A tab is 4 spaces for a tab or backspace
set shiftwidth=4         " Indent and <</>> is 4 spaces
set textwidth=80         " Lines wrap at column 80
set autoindent           " Automatically indent based on previous line
set smartindent          " Automatic indenting is intelligent

" Statusline {{{1
" ==========
set laststatus=2                 " Always show status line

set statusline=                  " Clear status line
set statusline+=%t               " Filename
set statusline+=%m               " Modified flag
set statusline+=%r               " Readonly flag
set statusline+=%15.l(%L),%c     " Line and column numbers
set statusline+=\ [%Y]           " Filetype
set statusline+=\ [ASCII=%03.3b] " ASCII value of char under cursor

" Folding {{{1
"============
set foldenable                                   " Turn on folding
set foldmethod=marker                            " Fold on the marker
set foldopen=block,hor,mark,percent,quickfix,tag " What movements open folds

" Right justify folded line count
"
" dhruvasagar (dhruvasagar.com/2013/03/28/vim-better-foldtext)
function! NeatFoldText()
    let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
    let foldchar = matchstr(&fillchars, 'fold:\zs.')
    let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(foldchar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) .  foldtextend
endfunction
set foldtext=NeatFoldText()
" Plugins {{{1
"============
" TODO: Only configure plugin if it exists

" conkyrc: Syntax files {{{
"
"   Used with *conkyrc and conky.conf
" }}}
"
" IndentCommentPrefix: Indents comments sensibly {{{
"
"   >>  : Indent keeping comment prefix where it is
"   <<  : Deindent keeping comment prefix where it is
"   g>> : Indent, including comment prefix
"
"   Use single > or < in Visual mode
"

" Comment chars in this list will *not* be left in column 1
"let g:IndentCommentPrefix_Blacklist = ['#', '>']

" Any string in this list *will* remain in column 1
"let g:IndentCommentPrefix_Whitelist = ['REMARK:']
" }}}

" ingo-library: library functions required by IndentCommentPrefix {{{
" No configuration here
" }}}

" rainbow: Highlight "parentheses" with varying colors {{{
let g:rainbow_active = 1 
" }}}

" tabular: Smart alignment of tables {{{
"
"   :Tabularize /<delimiter>/<format>
"
"   <format> : (l)eft, (r)ight, (center)
"       Each is followed by a number indicating padding
"
"   Example:
"       x = 12;
"       num = 13;
"       var2 = 1;
"
"       :Tabularize /=/l0r1
"
"       x   = 12;
"       num = 13;
"       var2= 1;
"
"   :AddTabularPattern <name> <pattern> allows you to save patterns
"
" Custom mappings:
" ---------------------------------
" <Leader>t=  : = (with space)
" <Leader>t:  : : (with space)
" <Leader>t:: : : (no space before)
" <Leader>t,  : , (with space)
" <Leader>t|  : | (with space)
"

nmap <Leader>t= :Tabularize /=<cr>
vmap <Leader>t= :Tabularize /=<cr>
nmap <Leader>t: :Tabularize /:<cr>
vmap <Leader>t: :Tabularize /:<cr>
nmap <Leader>t:: :Tabularize /:\zs<cr>
vmap <Leader>t:: :Tabularize /:\zs<cr>
nmap <Leader>t, :Tabularize /,<cr>
vmap <Leader>t, :Tabularize /,<cr>
nmap <Leader>t<Bar> :Tabularize /<Bar><cr>
vmap <Leader>t<Bar> :Tabularize /<Bar><cr>

" s:align() - automatically align '|' delimited tables {{{
"
" Typing '|' in insert mode, automatically
" aligns the containing '|' delimited table
" FIXME: Can't get it to work
"
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
"inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<cr>a
" }}}
" }}}

" tagbar: Source code browser using ctags {{{
"
"   <F1> : display help
"   <F9> : toggle TagBar
"
" Default settings
" ----------------
" let g:tagbar_left = 1
" let g:tagbar_width = 40
" let g:tagbar_autoclose = 0
"

" Toggle taglist window
noremap <silent> <F9> :TagbarToggle<cr>
" }}}

" tlib_vim: Utility functions required by snipMate {{{
" No configuration here
" }}}

" vim-addon-mw-utils: Caching required by snipMate {{{
" No configuration here
" }}}

" vim-closetag: Easily close HTML/XML tags {{{
"
"   Current content:
"       <table|
"   Press >:
"       <table>|</table>
"   Press > again:
"       <table>
"           |
"       </table>
"

" Use closetag in these files
let g:closetag_filenames = "*.html,*.xhtml,*.phtml"
" }}}

" vim-commentary: Commenting keymaps {{{
"
"   gc{motion} : Toggle commenting over {motion}
"   gcc        : Toggle commenting of [count] lines
"   {Visual}gc : Toggle commenting of highlighted lines
"   gcu        : Uncomment current and adjacent lines
"

" No configuration here
" }}}

" vim-devicons: Patched fonts with more icons {{{
" No configuration here
" }}}

" vim-markdown: Markdown syntax {{{
let g:markdown_fenced_languages = ['python', 'html', 'bash=sh', 'c']
let g:markdown_fenced_languages = ['python', 'html', 'bash=sh', 'c']
" }}}

" vim-repeat: Allows '.' to repeat plugin keymaps {{{
" No configuration here
" }}}

" vim-snipmate: Code snippets {{{
" TODO: Configuration and manual
let g:snips_author = 'Jeremy Brubaker <jbru362@gmail.com>'
" }}}

" vim-space: Use <space> as smart move command {{{
"
"   Map <space> to repeat previous movement command and <BS> to
"   previous backwards movement command
"
"   Example:
"   /foo
"   n
"   N
"
"   becomes:
"   /foo
"   <space>
"   <BS>
"

" No configuration here
" }}}

" vim-surround: Modify surrounding characters {{{
"
"   ds<t>    : delete
"   cs<t><r> : change
"   ys<motion><t> : surround <motion>
"
"   csw<r> : surround current word
"   yss<r> : surround current line
"   ysS<r> : put <t> on separate lines
"
"   Valid characters for <t> and <r>
"       ( { [ < : trim/insert spaces
"       ) } ] > : DO NOT trim/insert spaces
"       " ' `   : quote pairs (current line only)
"       t       : HTML tag
"       w, W    : word, WORD (<t> only)
"       s       : sentence (<t> only)
"       p       : paragraph (<t> only)
"
"   Using 't' for <r>
"       Vim will prompt for the tag to insert. Any attributes given
"       will be stripped from the closing tag. Any attributes will be
"       kept, unless you close the tag with >. If C-T is used, tags
"       will appear on lines by themselves.
"

" No configuration here
" }}}

" vim-workspace: Automated session management and file auto-save {{{
" Make it look like Powerline
" let g:workspace_powerline_separators = 1
" let g:workspace_tab_icon = "\uf00a"
" let g:workspace_left_trunc_icon = "\uf0a8"
" let g:workspace_right_trunc_icon = "\uf0a9"

noremap <C-n> :WSNext<CR>
noremap <C-p> :WSPrev<CR>
noremap <C-tab> :WSNext<CR>
noremap <Leader>q :WSClose<CR>
noremap <Leader>Q :WSClose!<CR>
noremap <C-t> :WSTabNew<CR>

" use 'bonly' as an abbreviation for WSBufOnly
cabbrev bonly WSBufOnly
"}}}

" a.vim: Swap header and source files {{{
"
"   :A : Switch between header and source files
"   :AS: Split and switch
"   :AV: Vertical split and switch
"
"   Use 'set autochdir' to make it work
"

" No configuration here
" }}}

" gundo.vim: View Vim undo tree {{{
nnoremap <F8> :GundoToggle<cr>
" }}}

" Mappings {{{1
"=============

" XXX: Don't forget Shift/C/M+Arrows
" XXX: Don't forget C+hjkl

" Help {{{
" map: normal, visual, select, operator-pending
" nmap: normal
" vmap: visual and select
" omap: operator-pending
" xmap: visual
" smap: select
" map!: insert and command-line
" imap: insert
" cmap: command line
" lmap: insert, command line, language-arg
"
" noremap: non-recursive mapping
"
" <silent> : don't echo mapping on command line
" <expr> : mapping inserts result of {rhs} }}}

" Window Management {{{
" ======================

" Switch windows with Ctl-[hjkl] {{{
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l
" }}}

" Resize windows with M-hjkl {{{
"   M-h : decrease vertical
"   M-j : decrease horizontal
"   M-k : increase horizontal
"   M-l : increase vertical
if has ('unix') " Doesn't work otherwise
    nnoremap j <C-w>-
    nnoremap k <C-w>+
    nnoremap h <C-w><
    nnoremap l <C-w>>
else
    nnoremap <M-j> <C-w>-
    nnoremap <M-k> <C-w>+
    nnoremap <M-h> <C-w><
    nnoremap <M-l> <C-w>>
endif
" }}}

" Maximize/Minimize split {{{
" TODO: Make ^wm toggle this state
" FIXME: Maximizing doesn't work for all splits
noremap <C-W>M :resize<cr> :vertical resize <cr>
nnoremap <C-W>m <C-W>=
" }}}

" }}}

" Miscellaneous {{{

" Toggle colorcolumn with <leader>c {{{
"
" Kevin Kuchta (www.vimbits.com/bits/317)
function! g:ToggleColorColumn()
    if &colorcolumn == ''
        setlocal colorcolumn=70
    else
        setlocal colorcolumn&
    endif
endfunction
nnoremap <silent> <leader>c :call g:ToggleColorColumn()<cr>
" }}}

" Clear search string to remove highlighting
nnoremap <silent> // :nohlsearch<cr>

" Use TAB to jump between braces, etc
nnoremap <tab> %
vnoremap <tab> %

" Toggle listchars
nnoremap <silent> <leader>l :set list!<cr>

" Make Y consistent with C and D
nnoremap Y y$

" Really write the file when you forget to sudo 
cnoremap w!! w !sudo tee % >/dev/null

" Reflow paragraph with Q in normal and visual mode
nnoremap Q gqap
vnoremap Q gq

" Easier history navigation
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Underline current line with '=' or '-'
" TODO: Make this work with comments
nnoremap <leader>= yyp^v$r=
nnoremap <leader>- yyp^v$r-

" Easier horizontal scrolling
map zl zL
map zh zH

" Code folding{{{
nmap <leader>f0 :set foldlevel=0<cr>
nmap <leader>f1 :set foldlevel=1<cr>
nmap <leader>f2 :set foldlevel=2<cr>
nmap <leader>f3 :set foldlevel=3<cr>
nmap <leader>f4 :set foldlevel=4<cr>
nmap <leader>f5 :set foldlevel=5<cr>
nmap <leader>f6 :set foldlevel=6<cr>
nmap <leader>f7 :set foldlevel=7<cr>
nmap <leader>f8 :set foldlevel=8<cr>
nmap <leader>f9 :set foldlevel=9<cr>
" }}}

" }}}

" Autocommands {{{1
"=================

" Remove everything if sourcing .vimrc again
autocmd!

au BufWritePost ~/.vimrc source ~/.vimrc
au Filetype gitcommit set tw=68 spell

" Makefiles {{{
au Filetype make setlocal noexpandtab   " We need real tabs
au Filetype make setlocal tabstop=8
au Filetype make setlocal softtabstop=8
au Filetype make setlocal shiftwidth=8
" }}}

" snipMate {{{
au Filetype snippet setlocal noexpandtab   " We need real tabs
au Filetype snippet setlocal tabstop=8
au Filetype snippet setlocal softtabstop=0
au Filetype snippet setlocal tabstop=8
" }}}

" C {{{
au Filetype c setlocal foldmethod=syntax " Fold on comments and braces
au Filetype c setlocal foldlevel=100     " Don't automatically fold
" }}}

" ================================

" Colors and Syntax Settings {{{1
" ==========================
" XXX: Rainbow stopped working unless this was at the end
set background=dark
colorscheme desert256
syntax enable
set hlsearch " Highlight search matches

" In-active window status line
highlight StatusLineNC ctermfg=darkblue ctermbg=black
" Active window status line
highlight StatusLine   ctermfg=darkblue ctermbg=white

" Non-printing characters
highlight NonText    ctermfg=brown
highlight SpecialKey ctermfg=brown

" Colors used in the statusline
highlight User1 ctermfg=red   ctermbg=blue
highlight User2 ctermfg=green ctermbg=blue

" Mode aware cursors
highlight InsertCursor ctermfg=grey ctermbg=grey
highlight VisualCursor ctermfg=grey ctermbg=grey
highlight ReplaceCursor ctermfg=grey ctermbg=grey
highlight CommandCursor ctermfg=grey ctermbg=grey

" Powerline setup {{{1
" ================================
" python from powerline.vim import setup as powerline_setup
" python powerline_setup()
" python del powerline_setup

" Local Vimrc {{{1
" ================================
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif
