" vim: foldlevel=0
"        _                    
" __   _(_)_ __ ___  _ __ ___ 
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__ 
"   \_/ |_|_| |_| |_|_|  \___|
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

" Fold C-like languages on the function prototype when braces are in the first column
"
" https://vim.fandom.com/wiki/Folding_functions_with_the_prototype_included
function FoldBrace()
    if getline(v:lnum+1)[0] == '{'
        return 1
    endif
    if getline(v:lnum) =~ '{'
        return 1
    endif
    if getline(v:lnum)[0] =~ '}'
        return '<1'
    endif
    return -1
endfunction
autocmd Filetype c,cpp,perl setlocal foldexpr=FoldBrace() " Use custom folding function
autocmd Filetype c,cpp,perl setlocal foldmethod=expr      "  for C/C++ code
autocmd Filetype c,cpp,perl setlocal foldlevel=99         " Don't fold at start
" Plugins {{{1
"============
" TODO: Only configure plugin if it exists
set rtp+=/usr/local/share/fzf
" TODO: automatically update plugins periodically
" minpac setup {{{2
"
" call minpac#update() to update all packages
" call minpac#clean() to remove unused plugins
" call minpac#status() to get plugin status

packadd minpac
call minpac#init()
call minpac#add('k-takata/minpac', {'type': 'opt'})
" calendar-vim: A calendar application for Vim {{{2

call minpac#add('mattn/calendar-vim')
" CCTree: Vim CCTree plugin {{{2
call minpac#add('hari-rangarajan/CCTree')

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

" No configuration needed

" cscope_maps: CSCOPE settings for vim {{{2
call minpac#add('chazy/cscope_maps')

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

" DrawIt: ASCII drawing plugin {{{2
call minpac#add('vim-scripts/DrawIt')

" fzf: Fuzzy finder {{{2
call minpac#add('junegunn/fzf')

" No configuration needed

" fzf.vim: fzf vim plugin {{{2
call minpac#add('junegunn/fzf.vim')

" :Files [PATH]     " Files ($FZF_DEFAULT_COMMAND)
" :GFiles [OPTS]    " GIt files (git ls-files)
" :GFiles?          " Git files (git status)
" :Buffers
" :Rg [PATTERN]     " Search using ripgrep
" :Lines [QUERY]    " Lines in all buffers
" :BLines [QUERY]   " Lines in current buffer
" :Tags [QUERY]     " Tags in current project (ctags -R)
" :BTags [QUERY]    " Tags in current buffer
" :Marks            " Marks
" :Snippets         " Snippets (UltiSnips)
" :Commits          " Git commits (vim-fugitive)
noremap <C-p> :Files<CR>
" nerdtree: A tree explorer plugin for vim {{{2
call minpac#add('preservim/nerdtree')

" <F10> : Toggle file tree browser
noremap <silent> <F10> :NERDTreeToggle<cr>

" Close Vim if last window open is NERDTree
autocmd bufenter * if (winnr("$") == 1 &&
    \ exists("b:NERDTree") && 
    \ b:NERDTree.isTabTree()) | q | 
    \ endif

" nerdtree-git-plugin: A plugin of NERDTree showing git status {{{2
call minpac#add('Xuyuanp/nerdtree-git-plugin')

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
call minpac#add('luochen1990/rainbow')
" let g:rainbow_active = 1 " Activate plugin

" NOTE: See 'Colors and Syntax Settings' for more
" tabular: Smart alignment of tables {{{2
call minpac#add('godlygeek/tabular')

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
call minpac#add('preservim/tagbar')

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

" Add support for Makefiles (requires adding
"     --regex-make=/^([^# \t:]*):/\1/t,target/
" to ~/.ctags)
let g:tagbar_type_make = {'kinds':
                        \ ['m:macros',
                        \ 't:targets']}

" Add support for Markdown
let g:tagbar_type_markdown = {
    \ 'ctagstype'  : 'markdown',
    \ 'ctagsbin'   : 'markdown2ctags.py',
    \ 'ctagsargs'  : '-f - --sort=yes --sro=»',
    \ 'kinds'      : ['s:sections', 'i:images'],
    \ 'sro'        : '»',
    \ 'kind2scope' : {'s' : 'section',},
    \ 'sort'       : 0}
" thesaurus-query: Multi-language Thesaurus Query and Replacement plugin {{{2
call minpac#add('Ron89/thesaurus_query.vim')

" <leader>cs : query thesauras for word under cursor

" No configuration needed default

" tlib_vim: Utility functions required by snipMate {{{2
call minpac#add('tomtom/tlib_vim')

" vem-tabline: Vim plugin to display tabs and buffers in the tabline {{{2
call minpac#add('pacha/vem-tabline')

let g:vem_tabline_show             = 2 " Always show the tabline
let g:vem_tabline_multiwindow_mode = 0 " Show all buffers in a tab

" NOTE: See 'Colors and Syntax Settings' for more
" vim-addon-mw-utils: Caching required by snipMate {{{2
call minpac#add('MarcWeber/vim-addon-mw-utils')

" vim-closetag: Easily close HTML/XML tags {{{2
call minpac#add('alvan/vim-closetag')

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
call minpac#add('tpope/vim-commentary')

" gc{motion} : Toggle commenting over {motion}
" gcc        : Toggle commenting of [count] lines
" {Visual}gc : Toggle commenting of highlighted lines
" gcu        : Uncomment current and adjacent lines

" vim-devicons: NERDTree icons {{{2
call minpac#add('ryanoasis/vim-devicons')

" vim-fugitive: Git in Vim{{{2
call minpac#add('tpope/vim-fugitive')

" vim-gist: Edit github.com gists with vim {{{2
call minpac#add('mattn/vim-gist')

let g:gist_post_private = 1 " Private gists by default
                            " :Gist -P to create public Gist

" vim-IndentCommentPrefix: Indents comments sensibly {{{2
call minpac#add('inkarkat/vim-IndentCommentPrefix')

" >>  : Indent, keeping comment prefix where it is
" <<  : Deindent, keeping comment prefix where it is
" g>> : Indent, including comment prefix

" Use single > or < in Visual mode

" Comment chars in this list will *not* be left in column 1
"let g:IndentCommentPrefix_Blacklist = ['#', '>']

" Any string in this list *will* remain in column 1
"let g:IndentCommentPrefix_Whitelist = ['REMARK:']

" vim-ingo-library: library functions required by IndentCommentPrefix {{{2
call minpac#add('inkarkat/vim-ingo-library')

" vim-markdown-folding: Fold Markdown files on headers {{{2
call minpac#add('masukomi/vim-markdown-folding')

" Use Nested folding for all Markdown files
autocmd Filetype markdown setlocal foldexpr=NestedMarkdownFolds()
"
" vim-surround: Modify surrounding characters {{{2
call minpac#add('tpope/vim-surround')

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
call minpac#add('tmux-plugins/vim-tmux')

" vim-tmux-pilot: Unified navigation of splits and tabs in nvim and tmux {{{2
call minpac#add('urbainvaes/vim-tmux-pilot')

" Use Alt+[hjkl] to navigate windows
if has ('unix') " set convert-meta off in .inputrc makes Alt not the Meta key
    let g:pilot_key_h='h'
    let g:pilot_key_j='j'
    let g:pilot_key_k='k'
    let g:pilot_key_l='l'
    let g:pilot_key_p='\'
else
    let g:pilot_key_h='<a-h>'
    let g:pilot_key_j='<a-j>'
    let g:pilot_key_k='<a-k>'
    let g:pilot_key_l='<a-l>'
    let g:pilot_key_p='<a-\>'
endif
" vim-wiki: Personal Wiki for Vim {{{2
" call minpac#add('vimwiki/vimwiki')

" Use Markdown instead of Vimwiki wyntax
let g:vimwiki_list = [{
    \ 'path_html': '~/docs/vimwiki/site',
    \ 'path': '~/docs/vimwiki/content',
    \ 'syntax': 'markdown',
    \ 'ext': '.md'
    \ }]

" Do not create temporary wikis outside of vimwiki_list
let g:vimwiki_global_ext = 0

autocmd FileType vimwiki map <buffer> <leader>d :VimwikiMakeDiaryNote<CR>
autocmd FileType vimwiki map <buffer> <leader>c :Calendar<CR>
" webapi-vim: Needed for vim-gist {{{2
call minpac#add('mattn/webapi-vim')

" todo-txt.vim: Vim plugin for Todo.txt {{{2
call minpac#add('freitass/todo.txt-vim')

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

" a.vim: Swap header and source files {{{2
call minpac#add('vim-scripts/a.vim')

" :A : Switch between header and source files
" :AS: Split and switch
" :AV: Vertical split and switch
"
" Use 'set autochdir' to make it work

" No configuration needed

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
" See vim-tmux-pilot configuration
" Resize windows with C-[hjkl] {{{
"   C-h : decrease vertical
"   C-j : decrease horizontal
"   C-k : increase horizontal
"   C-l : increase vertical

nnoremap <C-j> <C-w>-
nnoremap <C-k> <C-w>+
nnoremap <C-h> <C-w><
nnoremap <C-l> <C-w>>
" }}}
" Maximize/Minimize window with CTRL-W m  {{{
"
" pmalek (github.com/pmalek/toggle-maximize.vim)
let t:maximizeCurrentWindow = 0
function! ToggleMaximizeCurrentWindow()
    if t:maximizeCurrentWindow == 0
        :vertical resize
        :resize
        let t:maximizeCurrentWindow = 1
    else
        :exe "normal \<C-W>="
        let t:maximizeCurrentWindow = 0
    endif
endfunction
map <silent> <C-W>m :call ToggleMaximizeCurrentWindow() <cr>
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

" Underline current line with '=', '-' or '#'
" TODO: Make this work with comments
nnoremap <leader>= yyp^v$r=
nnoremap <leader>- yyp^v$r-
nnoremap <leader># yyp^v$r#

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

" Filetypes {{{1
"=================
" Markdown {{{2
" Enable fenced code block syntax highlighting
let g:markdown_fenced_languages = ['sh', 'c', 'html', 'make', 'python']
" Disable using conceal for bold, etc
let g:markdown_syntax_conceal = 0
" Use .mdp extentions for mdp presentations
autocmd BufRead,BufNewFile *.mdp setfiletype markdown
" autocmds {{{1
"=================
" All autocmds were cleared at the top of the file

" Source .vimrc when saving changes
autocmd BufWritePost ~/.vimrc source ~/.vimrc
" git commit files {{{2
" Set options for git commit files
autocmd Filetype gitcommit set tw=68 spell
" }}}
" Mail {{{2
" Emails should be RFC 3676 format=flowed
"     https://incenp.org/notes/2020/format-flowed-neomutt-vim.html
"
" formatoptions=awq  Enable automatic formatting of paragraphs, with
"                    trailing white space indicating a paragraph
"                    continues in the next line
" comments+=nb:> Lines starting with > are “comments” (so quotes
"                within a mail are displayed differently from the rest
"                of the message).
" match ErrorMsg '\s\+$' Highlight the trailing space at the end of
"                        broken lines, to provide a visual distinction
"                        between “soft” and “hard” line breaks
autocmd Filetype mail setlocal textwidth=72 |
                    \ setlocal formatoptions=awq |
                    \ setlocal comments+=nb:> |
                    \ setlocal spell |
                    \ match ErrorMsg '\s\+$'
" }}}
" Makefiles {{{
autocmd Filetype make setlocal noexpandtab   " We need real tabs
autocmd Filetype make setlocal tabstop=8
autocmd Filetype make setlocal softtabstop=8
autocmd Filetype make setlocal shiftwidth=8
" }}}
" Colors and Syntax Settings {{{1
" ==========================
" NOTE: Rainbow doesn't work unless this is at the end
set background=dark
" colorscheme desert256

" Solarized configuration
"  (must be done before 'syntax enable')
colorscheme solarized
" Don't use underline (folds like ugly)
let g:solarized_underline=0
" Remind vim that my terminal can't actually do undercurl
" which solarized wants to use for spellchecking
set t_Cs=

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
" highlight User1 ctermfg=red   ctermbg=blue
" highlight User2 ctermfg=green ctermbg=blue

" Mode aware cursors
" highlight InsertCursor ctermfg=grey ctermbg=grey
" highlight VisualCursor ctermfg=grey ctermbg=grey
" highlight ReplaceCursor ctermfg=grey ctermbg=grey
" highlight CommandCursor ctermfg=grey ctermbg=grey
" vem-tabline {{{
" Needs to be in the color section

" Selected buffer
" highlight VemTablineSelected    ctermfg=white ctermbg=red
" Non-selected buffers
" highlight VemTablineNormal      ctermfg=white ctermbg=darkblue
" Non-selected buffers displayed in windows
" highlight VemTablineShown       ctermfg=white ctermbg=darkblue

" Directory name (when present)
" highlight VemTablineLocation    ctermfg=white ctermbg=darkblue
" +X more text
" highlight VemTablineSeparator   ctermfg=white ctermbg=darkblue
" Selected tab
" highlight VemTablineTabSelected ctermfg=white ctermbg=darkblue
" Non-selected tab
" highlight VemTablineTabNormal   ctermfg=white ctermbg=darkblue
" }}}
" rainbow {{{
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
" }}}
" Local Vimrc {{{1
" ===========
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif
" Other {{{1
" Highlight code in different filetypes {{{2
"
" Ivan Tischenko (vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file)
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ keepend
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction

" Enable C syntax higlighting in non-C files
autocmd BufNewFile,BufRead  * :call TextEnableCodeSnip ('c', '@c', '@c', 'SpecialComment')

" goobook address completion for emails {{{2
"
" https://jfreak53.blogspot.com/2012/07/vim-as-mutt-email-editor.html
" Code at https://pastebin.com/tR08XHbF
fun! MailcompleteC(findstart, base)
    if a:findstart == 1
        let line = getline('.')
        let idx = col('.')
        while idx > 0
            let idx -= 1
            let c = line[idx]
            " break on header and previous email
            if c == ':' || c == '>'
                return idx + 2
            else
                continue
            endif
        endwhile
        return idx
    else
        if exists("g:goobookrc")
            let goobook="goobook -c " . g:goobookrc
        else
            let goobook="goobook"
        endif
        let res=system(goobook . ' query ' . shellescape(a:base))
        if v:shell_error
            return []
        else
            "return split(system(trim . '|' . fmt, res), '\n')
            return MailcompleteF(MailcompleteT(res))
        endif
    endif
endfun

fun! MailcompleteT(res)
    " next up: port this to vimscript!
    let trim="sed '/^$/d' | grep -v '(group)$' | cut -f1,2"
    return split(system(trim, a:res), '\n')
endfun

fun! MailcompleteF(contacts)
    "let fmt='awk ''BEGIN{FS="\t"}{printf "%s <%s>\n", $2, $1}'''
    let contacts=map(copy(a:contacts), "split(v:val, '\t')")
    let ret=[]
    for [email, name] in contacts
        call add(ret, printf("%s <%s>", name, email))
    endfor
    return ret
endfun


autocmd Filetype mail setlocal completefunc=MailcompleteC

