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

" Source .vimrc when saving changes
autocmd BufWritePost ~/.vimrc nested source ~/.vimrc

set nocompatible " Don't be vi compatible

" vimpager specific initialization
if exists('g:vimpager_plugin_loaded')
    " set noloadplugins
endif

" Basics {{{1
" ======
filetype plugin indent on            " Load filetype plugins and indent settings

set omnifunc=syntaxcomplete#Complete " Complete on syntax (CTL-X CTL-O to complete)

set encoding=utf8                    " Use Unicode

set noexrc                           " Do not source .exrc
set autowrite                        " Write file when changing to a new file
set wildmenu                         " Show wildmenu
set wildmode=longest:full,full       " Tab complete longest part, then show wildmenu
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
set listchars+=nbsp:+                " Show non-breaking space
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
set tags-=./tags                     " Remove ./tags and ./tags; from 'tags'
set tags-=./tags;                    "  and prepend ./tags; in order to search
set tags^=./tags;                    "  up the tree for the tags file
set complete-=i                      " *Do not* search included files when completing
set history=1000                     " Save more command history
set fillchars=vert:\|,fold:―
set path^=$DOTFILES                  " Search for files in $DOTFILES
set path+=~/work/fen-x/fenx-infra
set path+=~/work/fen-x/fenx-infra/fenx_infra

" Absolute & Hybrid line numbers by buffer status {{{2
"
" https://jeffkreeftmeijer.com/vim-number/
" TODO: stop this from applying to vim helpfiles
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Automatically open quickfix window {{{2
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
augroup END

" Searching {{{2
if executable('rg')
    set grepprg=rg\ --vimgrep
endif

" grep/lgrep without polluting the terminal or opening the first match
"
" Respects &grepprg
"
" https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
function! Grep(...)
    " return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
    return system(join(extend([&grepprg], a:000), ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'


" Text Formatting/Layout {{{1
"===========================
set formatoptions+=rqln  " Insert comment leader on return, let gq format
                         "  comments and do not break an already long line
                         "  during insert, support numbered/bulleted lists
set formatoptions+=j     " Delete comment character when joining lines
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
" Terminal window status line
augroup termwindow | autocmd!
    autocmd TerminalWinOpen * setlocal statusline=%t
    autocmd ColorScheme * highlight! link StatusLineTerm StatusLine
    autocmd ColorScheme * highlight! link StatusLineTermNC StatusLineNC
augroup end

" Folding {{{1
"============
set foldenable                                   " Turn on folding
set foldmethod=marker                            " Fold on the marker
set foldopen=block,hor,mark,percent,quickfix,tag " What movements open folds

" Right justify folded line count
"
" dhruvasagar (dhruvasagar.com/2013/03/28/vim-better-foldtext)
" TODO: modify this (look at vim-markdown-folding) to include depth at the beginning
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
" Optional packages {{{2
packadd! matchit    " Enhanced % matching
packadd! cfilter    " Filter quickfix or location lists

" minpac setup {{{2
"
" call minpac#update() to update all packages
" call minpac#clean() to remove unused plugins
" call minpac#status() to get plugin status

packadd minpac
call minpac#init()
call minpac#add('k-takata/minpac', {'type': 'opt'})
" auto_mkdir2: Automatically create directory tree for new files {{{2

call minpac#add('arp242/auto_mkdir2.vim')

" Only make tree in wiki
let g:auto_mkdir2_autocmd = '$WIKI_DIR/content/**'

" calendar-vim: A calendar application for Vim {{{2

call minpac#add('mattn/calendar-vim')
" CCTree: Vim CCTree plugin {{{2
if has("cscope")
    call minpac#add('hari-rangarajan/CCTree')

    " See Mappings & Commands -> Cscope for mappings

    set cscopetag                           " use cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetagorder=0                    " search cscope then ctags
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a- " Open all results in quickfix 

    " Automatically load database if it exists in current directory
    " or if defined in $CSCOPE_DB
    function! s:load_cscope_db()
        if filereadable("cscope.out")
            CCTreeLoadDB cscope.out
        elseif $CSCOPE_DB != ""
            CCTreeLoadDB $CSCOPE_DB
        endif
    endfunction
    autocmd VimEnter * call s:load_cscope_db()
endif

" DrawIt: ASCII drawing plugin {{{2
call minpac#add('vim-scripts/DrawIt')

" fzf: Fuzzy finder {{{2
call minpac#add('junegunn/fzf')

" fzf plugin is located here
set rtp+=/usr/local/share/fzf

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

" gv.vim: Git commit browser {{{2
call minpac#add('junegunn/gv.vim')

" nerdtree: A tree explorer plugin for vim {{{2
call minpac#add('preservim/nerdtree')

" <F10> : Toggle file tree browser
noremap <silent> <F8> :NERDTreeToggle<cr>

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

" TODO: enable only for specific filetypes
let g:rainbow_active = 1 " Activate plugin

" NOTE: See 'Colors and Syntax Settings' for more
" SimplyFold: No-BS Python code folding{{{2
call minpac#add('tmhedberg/SimpylFold')

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

" tagalong: Change an HTML(ish) tag and update the matching one {{{2
call minpac#add('AndrewRadev/tagalong.vim')

let g:tagalong_additional_filetypes = ['xhtml', 'phtml']

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

let g:vem_tabline_show             = 2        " Always show the tabline
let g:vem_tabline_multiwindow_mode = 1        " Only show buffers in current tab
let g:vem_tabline_show_number      = "buffnr" " Show Vim buffer numbers

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

" vim-colors-solarized: Solarized colorscheme {{{2
call minpac#add('altercation/vim-colors-solarized')

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

" vim-gitgutter: Use the sign column to show git chanages {{{2
call minpac#add('airblade/vim-gitgutter')

" The default updatetime of 4000ms is not good for async update
set updatetime=100
" Statusline function
" let l:hunks = GitGutterGetHunkSummary()
" if l:hunks[0] || l:hunks[1] || l:hunks[2]
    " let l:line .= '%#GitGutterAdd# +' . l:hunks[0] .
                " \ ' %#GitGutterChange#~' . l:hunks[1] .
                " \ ' %#GitGutterDelete#-' . l:hunks[2] . ' '

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

" vim-ini-fold: folding for ini-like files {{{2
call minpac#add('matze/vim-ini-fold')

" vim-markdown: Markdown vim mode {{{2
call minpac#add('plasticboy/vim-markdown')

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 1
let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_coneal_code_blocks = 0

" vim-markdown-folding: Fold Markdown files on headers {{{2
call minpac#add('masukomi/vim-markdown-folding')

" vim-pconf: Project-local vimrc files {{{2
call minpac#add('jbrubake/vim-pconf')

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

" a.vim: Swap header and source files {{{2
call minpac#add('vim-scripts/a.vim')

" :A : Switch between header and source files
" :AS: Split and switch
" :AV: Vertical split and switch
"
" XXX: Not true? Use 'set autochdir' to make it work

" No configuration needed

" Mappings & Commands {{{1
"========================
" Help {{{2
" map:  normal, visual, select, operator-pending
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
" *nore*: non-recursive mapping
"
" <silent> : don't echo mapping on command line
" <expr>   : mapping inserts result of {rhs}
" <buffer> : buffer local mapping

" Window Management {{{2
" ======================
" See vim-tmux-pilot configuration
" Resize windows with C-[hjkl] {{{3
nnoremap <C-j> <C-w>-
nnoremap <C-k> <C-w>+
nnoremap <C-h> <C-w><
nnoremap <C-l> <C-w>>

" Maximize/Minimize window with CTRL-W m  {{{3
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
nnoremap <silent> <C-W>m :call ToggleMaximizeCurrentWindow() <cr>

" <leader>e[wsvt]       edit in current file's directory {{{2
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%
" <leader>c:        toggle colorcolumn {{{2
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

" S:                split line {{{2
"
" https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666
function! BreakHere()
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction
nnoremap S :<C-u>call BreakHere()<CR>

" fN:               set foldlevel=N {{{2
noremap <leader>f0 :set foldlevel=0<cr>
noremap <leader>f1 :set foldlevel=1<cr>
noremap <leader>f2 :set foldlevel=2<cr>
noremap <leader>f3 :set foldlevel=3<cr>
noremap <leader>f4 :set foldlevel=4<cr>
noremap <leader>f5 :set foldlevel=5<cr>
noremap <leader>f6 :set foldlevel=6<cr>
noremap <leader>f7 :set foldlevel=7<cr>
noremap <leader>f8 :set foldlevel=8<cr>
noremap <leader>f9 :set foldlevel=9<cr>

" [<Space> / ]<Space>: add [n] blank lines before/after line {{{2
"
" https://superuser.com/a/607168
nnoremap <silent> [<Space> :<C-u>put!=repeat(nr2char(10),v:count)<Bar>execute "']+1"<CR>
nnoremap <silent> ]<Space> :<C-u>put =repeat(nr2char(10),v:count)<Bar>execute "'[-1"<CR>

" [e / ]e:          exchange current line with previous/next {{{2
nnoremap [e kddp
nnoremap ]e jddkP

" //:               clear search shighlighting {{{2
noremap <silent> // :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" <Tab>:            % {{{2
nmap <tab> %
vmap <tab> %

" <leader>l:        toggle listchars {{{2
nnoremap <silent> <leader>l :set list!<cr>

" Y:                yank to end (consistent with C and D) {{{2
nnoremap Y y$

" :w!!:             write file when I forget to sudo {{{2
cnoremap w!! w !sudo tee % >/dev/null

" Q:                reflow paragraph {{{2
nnoremap Q gqap
vnoremap Q gq

" <C-P> / <C-N>:    command history navigation {{{2
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" <leader>[=-#]:    underline current line {{{2
" TODO: Make this work with comments
nnoremap <leader>= yyp^v$r=
nnoremap <leader>- yyp^v$r-
nnoremap <leader># yyp^v$r#

" zl / zh:          horizontal left/right scrolling {{{2
nnoremap zl zL
nnoremap zh zH

" DiffOrig:         diff of buffer and file {{{2
" command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
            " \ | wincmd p | diffthis

" Cscope: {{{2
" Based on https://raw.githubusercontent.com/chazy/cscope_maps/master/plugin/cscope_maps.vim

if has("cscope")
    " CCTree mappings:
    " ----------------
    " CTRL-\ > : Get forward call tree
    " CTRL-\ < : Get reverse call tree
    " CTRL-\ w : Toogle call tree window
    " CTRL-\ = : Increase depth
    " CTRL-\ - : Decrease depth
    " CTRL-p   : Preview symbol
    " Note: Folding commands work on call tree window

    " Cscope mappings:
    " ----------------
    " CTRL-\        : Open result in current window
    " CTRL-]        : Open result in horizontal split
    " CTRL-] CTRL+] : Open result in vertical split

    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).

    nmap <C-\>s :cscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cscope find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-]>s :scscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>g :scscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>c :scscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>t :scscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>e :scscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>f :scscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-]>i :scscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-]>d :scscope find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-]><C-]>s :vert scscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>g :vert scscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>c :vert scscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>t :vert scscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>e :vert scscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>f :vert scscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-]><C-]>i :vert scscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-]><C-]>d :vert scscope find d <C-R>=expand("<cword>")<CR><CR>

endif

" My wiki {{{1
" Find wiki files
set path^=$WIKI_DIR/content
" Open wiki index
nnoremap <leader>ni :e $WIKI_DIR/content/index.md<CR>

" Search the wiki
if executable('rg')
    command! -nargs=1 Ngrep silent! grep! "<args>" -g "*.md" $WIKI_DIR/content | execute ':redraw!'
else
    command! -nargs=1 Ngrep vimgrep "<args>" $WIKI_DIR/content/**/*.md
endif
nnoremap <leader>nn :Ngrep<Space>

" Colors and Syntax Settings {{{1
" ==========================
" NOTE: Rainbow doesn't work unless this is at the end
set background=dark

" Automatcially source local colors when a colorscheme is loaded
function! s:colorscheme_local() abort
    " Active window status line
    highlight StatusLine   ctermfg=darkblue ctermbg=white
    " In-active window status line
    highlight StatusLineNC ctermfg=darkblue ctermbg=black

    " Non-printing characters
    highlight NonText    ctermfg=brown
    highlight SpecialKey ctermfg=brown

    " Turn Underlined back on after turning it off because
    " vim-colors-solarized uses it too much
    " highlight Underlined cterm=underline

    " Make gutter background match line number column
    highlight! link SignColumn LineNr

    highlight ColorColumn ctermbg=8
    " vem-tabline {{{
    " Selected, visible buffer
    highlight VemTablineSelected         ctermfg=white ctermbg=darkblue
    highlight VemTablineLocationSelected ctermfg=white ctermbg=darkblue
    highlight VemTablineNumberSelected   ctermfg=white ctermbg=darkblue
    " Non-selected, visible buffers
    highlight VemTablineShown           ctermfg=black ctermbg=darkblue
    highlight VemTablineLocationShown   ctermfg=black ctermbg=darkblue
    highlight VemTablineNumberShown     ctermfg=black ctermbg=darkblue
    " Non-selected, non-visible buffers
    highlight VemTablineNormal          ctermfg=black ctermbg=darkblue
    highlight VemTablineLocation        ctermfg=black ctermbg=darkblue
    highlight VemTablineNumber          ctermfg=black ctermbg=darkblue

    " Directory name (when present)
    highlight VemTablineLocation       ctermfg=white ctermbg=darkblue
    " +X more text
    highlight VemTablineSeparator       ctermfg=black ctermbg=darkblue
    " Partially shown buffer
    highlight VemTabSelected            ctermfg=black ctermbg=darkblue
    " Selected tab
    highlight VemTablineTabSelected     ctermfg=white ctermbg=darkblue
    " Non-selected tab
    highlight VemTablineTabNormal       ctermfg=black ctermbg=darkblue
    " }}}
endfunction
augroup colorscheme_local
    autocmd!
    autocmd ColorScheme * call s:colorscheme_local()
augroup END

colorscheme desert256

syntax enable

" Highlight strings in C comments
let c_comment_strings=1

set hlsearch " Highlight search matches
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
" Highlight code in different filetypes {{{1
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

" Local Vimrc {{{1
" ===========
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif

