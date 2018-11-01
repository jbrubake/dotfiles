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
" Remove all autocommands if sourcing .vimrc again
autocmd!

set nocompatible " Don't be vi compatible

" Basics {{{1
" ======
filetype plugin indent on            " Load filetype plugins and indent settings

set omnifunc=syntaxcomplete#Complete " Complete on syntax (CTL-X CTL-O to complete)

set encoding=utf8                    " Use Unicode

set noexrc                           " Do not source .exrc
set autowrite                        " Write file when changing to a new file
set wildmenu                         " Show Tab completion menu
set wildmode=longest,list            " Tab complete longest part, then show menu
set autochdir                        " Automatically chdir to file (needed for a.vim)
set backspace=indent,eol,start       " What BS can delete
set backupdir=~/.vim/backup          " Where to put backup files
set directory=~/.vim/tmp             " Where to put swap files
set mouse=a                          " Use mouse everywhere
set mousehide                        " Hide mouse while typing
set incsearch                        " Incremental search
set nolist                           " Do not show listchars
set listchars=
set listchars+=extends:>,precedes:<  " Show long line continuation chars
set listchars+=tab:»\                " Show real tabs
set listchars+=trail:.               " Show trailing spaces and higlight them
set listchars+=eol:¬                 " Show end of line
set visualbell                       " Blink instead of beep
set relativenumber                   " Show relative line number
set number                           " Show line number of current line
set numberwidth=4                    " Allows line numbers up to 999
set report=0                         " Always report when a : command changes something
set shortmess=aOstT                  " Keep messages short
set scrolloff=10                     " Keep 10 lines at top/bottom
set sidescrolloff=10                 " Keep 10 lines at right/left
set sidescroll=1                     " Horizontal scroll one column at a time
set showtabline=0                    " Never show tabline
set hidden                           " Allow hidden buffers

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
set statusline+=%15.l(%L),%c     " Line number (total lines), column number
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
" CCTree: Vim CCTree plugin {{{2
" CTRL-\ > : Get forward call tree
" CTRL-\ < : Get reverse call tree
" CTRL-\ w : Toogle call tree window
" CTRL-\ = : Increase depth
" CTRL-\ - : Decrease depth
" CTRL-p   : Preview symbol

" Note: Folding commands work on call tree window

" Automatically load database if it exists in
" currenty directory when Vim is started
autocmd VimEnter * if filereadable("cscope.out") 
    \ | exec "CCTreeLoadDB cscope.out" 
    \ | endif

" conkyrc: Vim plugin for *conkyrc and conky.conf {{{2
" No configuration needed

" IndentCommentPrefix: Indents comments sensibly {{{2
" >>  : Indent, keeping comment prefix where it is
" <<  : Deindent, keeping comment prefix where it is
" g>> : Indent, including comment prefix

" Use single > or < in Visual mode

" Comment chars in this list will *not* be left in column 1
"let g:IndentCommentPrefix_Blacklist = ['#', '>']

" Any string in this list *will* remain in column 1
"let g:IndentCommentPrefix_Whitelist = ['REMARK:']

" ingo-library: library functions required by IndentCommentPrefix {{{2
" No configuration needed

" nerdtree: A tree explorer plugin for vim {{{2
" <F10> : Toggle file tree browser
noremap <silent> <F10> :NERDTreeToggle<cr>

" Close Vim if last window open is NERDTree
autocmd bufenter * if (winnr("$") == 1 &&
    \ exists("b:NERDTree") && 
    \ b:NERDTree.isTabTree()) | q | 
    \ endif

" nerdtree-git-plugin: A plugin of NERDTree showing git status {{{2
" Note: currently only works if Vim is started in a git repository
"
" Custom indicators
"let g:NERDTreeIndicatorMapCustom = {
    " \ "Modified"  : "✹",
    " \ "Staged"    : "✚",
    " \ "Untracked" : "✭",
    " \ "Renamed"   : "➜",
    " \ "Unmerged"  : "═",
    " \ "Deleted"   : "✖",
    " \ "Dirty"     : "✗",
    " \ "Clean"     : "✔︎",
    " \ 'Ignored'   : '☒',
    " \ "Unknown"   : "?"
    " \ }

" rainbow: Highlight "parentheses" with varying colors {{{2
let g:rainbow_active = 1 " Activate plugin

"Customize configuration
" let g:rainbow_conf = {
"   \	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
" 	\	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
" 	\	'operators': '_,_',
" 	\	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
" 	\	'separately': {
" 	\		'*': {},
" 	\		'tex': {
" 	\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
" 	\		},
" 	\		'lisp': {
" 	\			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
" 	\		},
" 	\		'vim': {
" 	\			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
" 	\		},
" 	\		'html': {
" 	\			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
" 	\		},
" 	\		'css': 0,
" 	\	}
" 	\}

" guifgs      : colors for gui interface, will be used in order.
" ctermfgs    : colors for terms
" operators   : describe the operators you want to highlight(read the vim help                                                                                                      : syn-pattern)
" parentheses : describe what will be processed as parentheses, a pair of parentheses was described by two re pattern
" separately  : configure for specific filetypes(decided by &ft), key `*` for filetypes without separate configuration, value `0` means disable rainbow only for this type of files

" Keep a field empty to use the default setting.

" tabular: Smart alignment of tables {{{2
"
" :Tabularize /<delimiter>/<format>
"
" <format> : (l)eft, (r)ight, (center)
"     Each can be followed by a number indicating padding
"
" Example:
"     x = 12;
"     num = 13;
"     var2 = 1;
"
"     :Tabularize /=/l0r1
"
"     x   = 12;
"     num = 13;
"     var2= 1;
"
" Example:
"     osh/Sh6: V6 sh ports (http://v6shell.org)
"     sent: Console "powerpoint" (http://tools.suckless.org/sent)
"     pixie: Color picker (http://nattyware.com/pixie.php)
"
"     Align on *first* character only:
"     :Tabularize /^[^:]*\zs:
"
"     osh/Sh6 : V6 sh ports (http://v6shell.org)
"     sent    : Console "powerpoint" (http://tools.suckless.org/sent)
"     pixie   : Color picker (http://nattyware.com/pixie.php)
"
" :AddTabularPattern <name> <pattern> allows you to save patterns
"

" Custom mappings:
" ----------------
" <Leader>t=  : = (with space)
" <Leader>t:  : : (with space)
" <Leader>t:: : : (no space before)
" <Leader>t,  : , (with space)
" <Leader>t|  : | (with space)
"
nmap <Leader>t=     :Tabularize /=<cr>
vmap <Leader>t=     :Tabularize /=<cr>
nmap <Leader>t:     :Tabularize /:<cr>
vmap <Leader>t:     :Tabularize /:<cr>
nmap <Leader>t::    :Tabularize /:\zs<cr>
vmap <Leader>t::    :Tabularize /:\zs<cr>
nmap <Leader>t,     :Tabularize /,<cr>
vmap <Leader>t,     :Tabularize /,<cr>
nmap <Leader>t<Bar> :Tabularize /<Bar><cr>
vmap <Leader>t<Bar> :Tabularize /<Bar><cr>

" tagbar: Source code browser using ctags {{{2
" ctags commands
" --------------
" CTRL-] : Jump to tag underneath cursor
" CTRL-o : Jump back in the tag stack
" :ts <tag> : Search for <tag>
" :tn : Go to next definition of last tag
" :tp : Go to previous definition of last tag
" :ts : List all definitions of last tag
"
" Default settings
" ----------------
" let g:tagbar_left      = 1
" let g:tagbar_width     = 40
" let g:tagbar_autoclose = 0

" <F9> : toggle TagBar
noremap <silent> <F9> :TagbarToggle<cr>

" tlib_vim: Utility functions required by snipMate {{{2
" No configuration needed

" vem-tabline: Vim plugin to display tabs and buffers in the tabline {{{2
let g:vem_tabline_show             = 2 " Always show the tabline
let g:vem_tabline_multiwindow_mode = 0 " Show all buffers in a tab

" vim-addon-mw-utils: Caching required by snipMate {{{2
" No configuration needed

" vim-closetag: Easily close HTML/XML tags {{{2
"   Current content:
"       <table|
"   Press >:
"       <table>|</table>
"   Press > again:
"       <table>
"           |
"       </table>

" Use closetag in these files
let g:closetag_filenames = "*.html,*.xhtml,*.phtml"

" vim-commentary: Commenting keymaps {{{2
" gc{motion} : Toggle commenting over {motion}
" gcc        : Toggle commenting of [count] lines
" {Visual}gc : Toggle commenting of highlighted lines
" gcu        : Uncomment current and adjacent lines

" No configuration needed

" vim-markdown: Markdown syntax {{{2
" Enable fenced code block syntax highlighting
let g:markdown_fenced_languages = ['python', 'html', 'bash=sh', 'c']

" vim-surround: Modify surrounding characters {{{2
" ds<t>         : delete <t>
" cs<t><r>      : change <t> to <r>
" csw<t>        : surround current word with <t>
" ysiw<t>       : surround current word with <t>
" yss<t>        : surround current line with <t>
" ys<motion><t> : surround <motion> with <t>
" VS<t>         : surround selection with <t> on separate lines

" Special characters for <t> and <r>
"     ( { [ < : trim/insert spaces
"     ) } ] > : DO NOT trim/insert spaces
"     " ' `   : quote pairs (current line only)
"     t       : HTML tag
"     w, W    : word, WORD (<t> only)
"     s       : sentence (<t> only)
"     p       : paragraph (<t> only)

" Using 't' for <r>
"     Vim will prompt for the tag to insert. Any attributes given
"     will be stripped from the closing tag.

" No configuration needed

" vim-tmux: Vim plugin for .tmux.conf {{{2
" No configuration needed

" a.vim: Swap header and source files {{{2
" :A : Switch between header and source files
" :AS: Split and switch
" :AV: Vertical split and switch
"
" Use 'set autochdir' to make it work

" No configuration needed

" cscope_maps.vim: CSCOPE settings for vim {{{2
" CTRL-\                   : Show search in current window
" CTRL-<space>             : Show search in horizontal split
" CTRL-<space> Ctl+<space> : Show search in vertical split
" CTRL-o                   : jump back to previous locations

" s : symbol - all references to token under cursor
" g : global - global definition
" c : calls - all calls to function
" t : text - all instances
" e : egrep - egrep search
" f : file - open file
" i : includes - files that include filename
" d : called - functions called by this function

" No configuration needed

" todo-txt.vim: Vim plugin for Todo.txt {{{2
" <LocalLeader>s   : Sort by priority
" <LocalLeader>s+  : Sort on +Projects
" <LocalLeader>s@  : Sort on @Contexts
" <LocalLeader>sd  : Sort on due dates
" <LocalLeader>sc  : Sort by context, then priority
" <LocalLeader>scp : Sort by context, project, then priority
" <LocalLeader>sp  : Sort by project, then priority
" <LocalLeader>spc : Sort by project, context, then priority
" <LocalLeader>-sd : Sort by due date. Entries with due date are at the beginning

" <LocalLeader>j : Lower priority
" <LocalLeader>k : Increase priority
" <LocalLeader>a : Add priority (A)
" <LocalLeader>b : Add priority (B)
" <LocalLeader>c : Add priority (C)

" <LocalLeader>d : Insert current date
" date<tab> : (Insert mode) insert current date
" due:      : (Insert mode) insert due: <date>
" DUE:      : (Insert mode) insert DUE: <date>

" <LocalLeader>x : Toggle done
" <LocalLeader>C : Toggle cancelled
" <LocalLeader>X : Mark all completed
" <LocalLeader>D : Move completed tasks to done file

"Use todo#complete as the omni complete function for todo files
autocmd filetype todo setlocal omnifunc=todo#complete

" Automatically complete + and @
autocmd filetype todo imap <buffer> + +<C-X><C-O>
autocmd filetype todo imap <buffer> @ @<C-X><C-O>

" Mappings {{{1
"=============
" XXX: Don't forget Shift/C/M+Arrows
" Help {{{2
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
" <expr> : mapping inserts result of {rhs}

" Window Management {{{2
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
" Miscellaneous {{{2
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

" autocmds {{{1
"=================
" Source .vimrc when saving changes
autocmd BufWritePost ~/.vimrc source ~/.vimrc
" Set options for git commit files
autocmd Filetype gitcommit set tw=68 spell
" Enable C syntax higlighting in non-C files
autocmd BufNewFile,BufRead  *xt :call TextEnableCodeSnip ('c', '@c', '@c', 'SpecialComment')
" Makefiles {{{
autocmd Filetype make setlocal noexpandtab   " We need real tabs
autocmd Filetype make setlocal tabstop=8
autocmd Filetype make setlocal softtabstop=8
autocmd Filetype make setlocal shiftwidth=8
" }}}
" snipMate {{{
autocmd Filetype snippet setlocal noexpandtab   " We need real tabs
autocmd Filetype snippet setlocal tabstop=8
autocmd Filetype snippet setlocal softtabstop=0
autocmd Filetype snippet setlocal tabstop=8
" }}}
" C {{{
autocmd Filetype c setlocal foldmethod=syntax " Fold on comments and braces
autocmd Filetype c setlocal foldlevel=100     " Don't automatically fold
" }}}

" Colors and Syntax Settings {{{1
" ==========================
" Note: Rainbow doesn't working unless this is at the end
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

" vem-tabline {{{
" Needs to be in the color section

" Selected buffer
highlight VemTablineSelected    ctermfg=white ctermbg=red
" Non-selected buffers
highlight VemTablineNormal      ctermfg=white ctermbg=darkblue
" Non-selected buffers displayed in windows
highlight VemTablineShown       ctermfg=white ctermbg=darkblue
" Directory name (when present)
" highlight VemTablineLocation    ctermfg=white ctermbg=darkblue
" +X more text
" highlight VemTablineSeparator   ctermfg=white ctermbg=darkblue
" Selected tab
" highlight VemTablineTabSelected ctermfg=white ctermbg=darkblue
" Non-selected tab
" highlight VemTablineTabNormal   ctermfg=white ctermbg=darkblue
" }}}

" Local Vimrc {{{1
" ===========
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" Testing {{{1
" ================================
" function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
"     " http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
"     "     by Ivan Tishchenko (2005)
"     let ft=toupper(a:filetype)
"     let group='textGroup'.ft
"     if exists('b:current_syntax')
"         let s:current_syntax=b:current_syntax
"         " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
"         " do nothing if b:current_syntax is defined.
"         unlet b:current_syntax
"     endif
"     execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
"     try
"         execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
"     catch
"     endtry
"     if exists('s:current_syntax')
"         let b:current_syntax=s:current_syntax
"     else
"         unlet b:current_syntax
"     endif
"     execute 'syntax region textSnip'.ft.'
"     \ matchgroup='.a:textSnipHl.'
"     \ start="'.a:start.'" end="'.a:end.'"
"     \ contains=@'.group
" endfunction

