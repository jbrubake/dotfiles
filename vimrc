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
" augroup for miscellaneous autocmds in
" this file and those it directly sources
augroup vimrc | autocmd! | augroup end

" Source .vimrc when saving changes
autocmd vimrc BufWritePost ~/.vimrc nested source ~/.vimrc

set nocompatible " Don't be vi compatible

if has ('clientserver') && empty(v:servername) && exists('*remote_startserver')
    call remote_startserver('VIM')
endif

" Remap Leader here because it may be used *before* the mapping section
" Better than ',' which is used for backwards character searching
let mapleader = ' '
let maplocalleader = ' '

" Plugins {{{1
"============
" Optional packages {{{2
packadd! matchit    " Enhanced % matching
packadd! cfilter    " Filter quickfix or location lists

" minpac {{{2
"
" Initialize minpac and generate the list of packages
"
" Each package should be on a commented line that looks like:
" " plugin: <repo> [type:<type>] [rev:<rev>] [" comment...]
"
" (Only a single '"' will work. The double one is required so the above line
" isn't treated like a plugin request)
"
function PackInit()
    " Load and initialize minpac
    packadd minpac
    call minpac#init()

    " So I don't need this anywhere else
    call minpac#add('k-takata/minpac', {'type':'opt'})

    " Create the plugin list file
    "
    :read $MYVIMRC
    " We definitely want this
    :setlocal noignorecase
    " Delete everything but 'plugin:' lines
    :silent! g!/^"\s*plugin:/d
    " Delete 'plugin:'
    :silent! %s/"\s*plugin:\s*//
    " call minpac#add('<plugin repo>', {
    :silent! %s/^\(\S\+\)/call minpac#add('\1', {/
    " Properly quote <key>:<val> pairs
    :silent! %s/\s*\(\w\+\):\(\w\+\)/'\1':'\2',/g
    " Close the option argument
    :silent! %s/$/})/

    " Note that the file should not be edited
    :norm ggI"" Generated file. Do not edit"

    " Write and source the package list
    let pkgfile = '~/.vim/plugins.vim'
    execute 'write! '.pkgfile
    bdelete " in case we run this from an interactive session
    execute 'source '.pkgfile
endfunction

" Commands to manipulate minpac
"
" *AndQuit commands are intended to be used at the command line
command! PackUpdate        call PackInit() | call minpac#update()
command! PackUpdateAndQuit call PackInit() | call minpac#update("", {"do":"quitall"})
command! PackClean         call PackInit() | call minpac#clean()
command! PackCleanAndQuit  call PackInit() | call minpac#clean() | quitall
command! PackStatus        call PackInit() | call minpac#status()

" OPTIONAL {{{2
"
" augroup for loading optional plugins
augroup load_plugins | autocmd! | augroup end

" List of plugins to load only in a git repository
let s:git_plugins = []

" plugin: vim-scripts/a.vim type:opt                                               " Swap header and source files {{{3

" :A : Switch between header and source files
" :AS: Split and switch
" :AV: Vertical split and switch

autocmd load_plugins FileType c packadd a.vim

" plugin: hari-rangarajan/CCTree type:opt                                          " Vim CCTree plugin {{{3

" See Mappings & Commands -> Cscope for mappings

function LoadCCTree()
    if filereadable($CSCOPE_DB)
        let s:db = $CSCOPE_DB
    elseif filereadable("cscope.out")
        let s:db = 'cscope.out'
    else
        return 0
    endif

    packadd! CCTree

    set cscopetag                           " use cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetagorder=0                    " search cscope then ctags
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a- " Open all results in quickfix 

    execute 'CCTreeLoadDB ' . s:db
endfunction

if has("cscope")
    autocmd load_plugins VimEnter,DirChanged * call LoadCCTree()
endif

" plugin: chrisbra/Colorizer type:opt                                              " Color hex codes and color names{{{3

" Turn off color:
"   :ColorClear
" Toggle color:
"   :ColorToggle

" Automatically colorize these filetypes
let g:colorizer_auto_filetype = 'css,html,markdown,xdefaults'
let g:colorizer_disable_bufleave = 0 " Only highlight above files
" Highlight X11 colornames in Xresources and such
let g:colorizer_x11_names = 1

execute 'autocmd load_plugins Filetype ' . g:colorizer_auto_filetype . ' packadd Colorizer | ColorToggle'

" plugin: borissov/fugitive-gitea type:opt                                         " Plugin for :Gbrowse to work with GITea server {{{3

" Loaded by LoadGit()

" plugin: shumphrey/fugitive-gitlab.vim type:opt                                   " A vim extension to fugitive.vim for GitLab support {{{3

" Loaded by LoadGit()

" plugin: junegunn/fzf type:opt                                                    " Fuzzy finder {{{3

if executable('fzf')
    silent packadd! fzf
endif

" plugin: stsewd/fzf-checkout.vim type:opt                                         " Manage branches and tags with fzf {{{3

if executable('fzf')
    let s:git_plugins += ['fzf-checkout.vim']
endif

" plugin: junegunn/fzf.vim type:opt                                                " fzf vim plugin {{{3

if executable('fzf')
    silent packadd! fzf.vim
endif

" :Files [PATH]     " Files ($FZF_DEFAULT_COMMAND)
" :GFiles [OPTS]    " Git files (git ls-files)
" :GFiles?          " Git files (git status)
" :Buffers          " Vim buffers
" :Rg [PATTERN]     " Search using ripgrep
" :Lines [QUERY]    " Lines in all buffers
" :BLines [QUERY]   " Lines in current buffer
" :Tags [QUERY]     " Tags in current project (ctags -R)
" :BTags [QUERY]    " Tags in current buffer
" :Marks            " Marks
" :Snippets         " Snippets (UltiSnips)
" :Commits          " Git commits (vim-fugitive)

" plugin: AndrewRadev/tagalong.vim type:opt                                        " Change an HTML(ish) tag and update the matching one {{{3

let g:tagalong_additional_filetypes = ['xml', 'html', 'php']

execute printf('autocmd load_plugins FileType %s packadd tagalong.vim', join(g:tagalong_additional_filetypes, ','))

" plugin: preservim/tagbar type:opt                                                " Source code browser using ctags {{{3

function LoadTagbar()
    if ! filereadable('tags')
        return 0
    endif

    packadd tagbar

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
        \ 'ctagsbin'   : 'markdown2ctags',
        \ 'ctagsargs'  : '-f - --sort=yes --sro=»',
        \ 'kinds'      : ['s:sections', 'i:images'],
        \ 'sro'        : '»',
        \ 'kind2scope' : {'s' : 'section',},
        \ 'sort'       : 0}
endfunction

if executable('etags') || executable('ctags')
    autocmd load_plugins VimEnter,DirChanged * call LoadTagbar()
endif

" plugin: mikesmithgh/ugbi type:opt                                                " UserGettingBored Improved Vim Plugin {{{3

command -nargs=0 UgbiEnable packadd ugbi | :UgbiEnable

" plugin: alvan/vim-closetag type:opt                                              " Easily close HTML/XML tags {{{3

"   Current content:
"       <table|
"   Press >:
"       <table>|</table>
"   Press > again:
"       <table>
"           |
"       </table>

" Use closetag in these files
let g:closetag_filenames = "*.sgml,*.xml,*.html,*.xhtml,*.phtml,*.php"
autocmd load_plugins FileType  sgml packadd vim-closetag
autocmd load_plugins FileType   xml packadd vim-closetag
autocmd load_plugins FileType  html packadd vim-closetag
autocmd load_plugins FileType xhtml packadd vim-closetag
autocmd load_plugins FileType phtml packadd vim-closetag
autocmd load_plugins FileType   php packadd vim-closetag

" plugin: tpope/vim-fugitive type:opt                                              " Git in Vim {{{3

let s:git_plugins += ['vim-fugitive']

" plugin: tommcdo/vim-fugitive-blame-ext type:opt                                  " extend vim-fugitive to show commit message on statusline in :Gblame {{{3

let s:git_plugins += ['vim-fugitive-blame-ext']

" plugin: mattn/vim-gist type:opt                                                  " Edit github.com gists with vim {{{3

command -nargs=? Gist packadd webapi-vim | packadd vim-gist | :Gist <args>

let g:gist_post_private = 1 " Private gists by default
                            " :Gist -P to create public Gist

" plugin: airblade/vim-gitgutter type:opt                                          " Use the sign column to show git chanages {{{3

let s:git_plugins += ['vim-gitgutter']

" The default updatetime of 4000ms is not good for async update
set updatetime=100

" Use fontawesome icons as signs
" NOTE: requires a 'nerd font'
let g:gitgutter_sign_added = ''
let g:gitgutter_sign_modified = '󰜥'
let g:gitgutter_sign_removed = ''
let g:gitgutter_sign_removed_first_line = ''
let g:gitgutter_sign_modified_removed = ''

" plugin: matze/vim-ini-fold type:opt                                              " folding for ini-like files {{{3

autocmd load_plugins FileType dosini,gitconfig packadd vim-ini-fold | call IniFoldActivate()

" plugin: https://dev.sanctum.geek.nz/code/vim-redact-pass.git type:opt rev:master " Do not write passwords into vim files when using pass(1) {{{3

autocmd load_plugins BufRead **/pass*/*.txt packadd vim-redact-pass

" plugin: tpope/vim-rhubarb type:opt                                               " GitHub extension for fugitive.vim {{{3

let s:git_plugins += ['vim-rhubarb']

" C-X C-O: omni-complete GitHub issues or project collaborator usernames in commits

" Do not show issue preview window when omni-completing
autocmd load_plugins FileType gitcommit setlocal completeopt-=preview

" plugin: preservim/vim-textobj-sentence type:opt                                  " Improving native sentence text object and motion {{{3

augroup textobj_sentence | autocmd!
    autocmd FileType markdown packadd vim-textobj-user | packadd vim-textobj-sentence | call textobj#sentence#init()
    autocmd FileType text     packadd vim-textobj-user | packadd vim-textobj-sentence | call textobj#sentence#init()
augroup end

" plugin: kana/vim-textobj-user type:opt (required by vim-textobj-sentence)        " Create your own text objects {{{3

" No configuration needed

" plugin: urbainvaes/vim-tmux-pilot type:opt                                       " Unified navigation of splits and tabs in nvim and tmux {{{3

" Use Alt+[hjkl] to navigate windows
if has ('unix') " 'set convert-meta off' in .inputrc makes Alt not the Meta key
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

if $TMUX != ""
    packadd! vim-tmux-pilot
endif

" plugin: lervag/vimtex type:opt                                                   " vim LaTeX plugin {{{3

let g:vimtex_view_method = 'zathura'
let g:tex_flavor         = 'latex' " See <vim-tex>/ftdetect/tex.vim

autocmd load_plugins FileType tex,bib packadd vimtex | call vimtex#init()

" plugin: mattn/webapi-vim type:opt                                                " Needed for vim-gist {{{3

" No configuration needed

" Conditionally load git related plugins {{{3
"
function LoadGit()
    silent! !git rev-parse --is-inside-work-tree
    if ! v:shell_error " v:shell_error truth is backwards from vim truth
        for s:p in s:git_plugins
            execute 'packadd ' . s:p
        endfor

        if !empty(g:fugitive_gitlab_domains) " Set in private config
            packadd fugitive-gitlab
        endif

        if !empty(g:fugitive_gitea_domains) " Set in private config
            packadd fugitive-gitea
        endif
    endif
endfunction

autocmd load_plugins VimEnter,DirChanged * call LoadGit()

" AUTOMATIC {{{2
"
" plugin: pearofducks/ansible-vim                                                  " Syntax highlighting Ansible's common filetypes {{{3

let g:ansible_attribute_highlight      = 'ab' " highlight all key=value pairs
let g:ansible_name_highlight           = 'b'  " highlight 'name:'
let g:ansible_extra_keywords_highlight = 1    " highlight extra keywords

" Highlight groups using specified group (:help E669)
let g:ansible_normal_keywords_highlight      = 'Statement'
let g:ansible_loop_keywords_highlight        = 'Statement'
let g:ansible_extra_keywords_highlight_group = 'Delimiter'
" See custom color settings below to customize 'name_highlight'

" Properly highlight HCL Jinja templates
let g:ansible_template_syntaxes = {
    \ '*.hcl.j2':    'hcl', 
    \ '*.sh.j2':     'sh',
    \ '*.tf.j2':     'hcl',
    \ '*.tfvars.j2': 'hcl',
    \ '*.yml.j2':    'yaml',
    \ '*.yaml.j2':   'yaml',
\ }

" When to use filetype=yaml.ansible
let g:ansible_ftdetect_filename_regex = '\v(playbook|site|main|local|requirements)\.ya?ml$'

" plugin: momota/cisco.vim                                                         " Vim syntax for cisco configuration files {{{3

" No configuration needed

" plugin: jbrubake/embed-syntax                                                    " Simplifies applying different syntax highlighting to regions of a file {{{3

" No configuration needed

" plugin: calincru/flex-bison-syntax                                               " Flex & Bison syntax highlighting for vim {{{3

" No configuration needed

" plugin: wickles/indentLine                                                       " Display the indentation levels with thin vertical lines {{{3

let g:indentLine_char = '│'
let g:indentLine_bufTypeExclude = ['help', 'terminal', 'markdown']
"let g:indentLine_bufNameExclude = ['tagbar?']
" Hide indents on cursor line
let g:indentLine_concealcursor = ''
" Use this if JSON quotes are hidden
" let g:vim_json_syntax_conceal = 0

" plugin: kovisoft/paredit                                                         " Structured Editing of Lisp S-expressions {{{3

" No configuration needed

" plugin: cakebaker/scss-syntax.vim                                                " Sassy CSS for vim {{{3

" No configuration needed

" plugin: godlygeek/tabular                                                        " Smart alignment of tables {{{3

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

" plugin: freitass/todo.txt-vim                                                    " Vim plugin for Todo.txt {{{3
"
" <LocalLeader>s   : Sort by priority
" <LocalLeader>s+  : Sort on +Projects
" <LocalLeader>s@  : Sort on @Contexts
" <LocalLeader>sd  : Sort on due dates
" <LocalLeader>sc  : Sort by context, then priority
" <LocalLeader>scp : Sort by context, project, then priority
" <LocalLeader>sp  : Sort by project, then priority
" <LocalLeader>spc : Sort by project, context, then priority
" <LocalLeader>-sd : Sort by due date. Entries with due date are at the beginning
"
" <LocalLeader>j : Lower priority
" <LocalLeader>k : Increase priority
" <LocalLeader>a : Add priority (A)
" <LocalLeader>b : Add priority (B)
" <LocalLeader>c : Add priority (C)
"
" <LocalLeader>d : Insert current date
" date<tab> : (Insert mode) insert current date
" due:      : (Insert mode) insert due: <date>
" DUE:      : (Insert mode) insert DUE: <date>
"
" <LocalLeader>x : Toggle done
" <LocalLeader>C : Toggle cancelled
" <LocalLeader>X : Mark all completed
" <LocalLeader>D : Move completed tasks to done file

" No configuration needed

" plugin: tpope/vim-commentary                                                     " Commenting keymaps {{{3

" No configuration needed

" gc{motion} : Toggle commenting over {motion}
" gcc        : Toggle commenting of [count] lines
" {Visual}gc : Toggle commenting of highlighted lines
" gcu        : Uncomment current and adjacent lines

" plugin: junegunn/vim-easy-align                                                  " A Vim alignment plugin {{{3

" No configuration needed

" plugin: preservim/vim-markdown                                                   " Markdown vim mode {{{3

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 1
let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_conceal_code_blocks = 0
 
" plugin: tpope/vim-repeat                                                         " Enable repeating supported plugin maps with "." {{{3

" No configuration needed

" plugin: slint-ui/vim-slint                                                       " Support for the slint language {{{3

" No configuration needed

" plugin: tpope/vim-surround                                                       " Modify surrounding characters {{{3

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
"
" Using 't' for <r>
"     Vim will prompt for the tag to insert. Any attributes given
"     will be stripped from the closing tag.

" No configuration needed

" plugin: baskerville/vim-sxhkdrc                                                  " Vim syntax for sxhkd's configuration files {{{3

" No configuration needed

" plugin: hashivim/vim-terraform                                                   " basic vim/terraform integration {{{3

" No configuration needed

" plugin: vlime/vlime                                                              " A Common Lisp dev environment for Vim {{{3

let g:vlime_cl_impl = "sbcl"
function! VlimeBuildServerCommandFor_clisp(vlime_loader, vlime_eval)
    return ["clisp", "--load", expand($XDG_DATA_HOME) . "/quicklisp/setup.lisp",
                   \ "--load", a:vlime_loader,
                   \ "--eval", a:vlime_eval]
endfunction

" plugin: tmux-plugins/vim-tmux                                                    " Vim plugin for .tmux.conf {{{3

" No configuration needed

" plugin: tridactyl/vim-tridactyl                                                  " Syntax plugin for Tridactyl configuration files {{{3

" No configuration needed

" plugin: vim-scripts/YankRing.vim                                                 " Maintains a history of previous yanks, changes and deletes  {{{3

let g:yankring_history_dir = '$HOME/var/cache'

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
set cursorline                       " Highlight current line
set visualbell                       " Blink instead of beep
set relativenumber                   " Show relative line number
set number                           " Show line number of current line
set numberwidth=4                    " Allows line numbers up to 999
set report=0                         " Always report when a : command changes something
set shortmess=aOstT                  " Keep messages short
set scrolloff=99                     " Basically keep cursor centered on the screen vertically
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
set undofile                         " Persistent undo tree
set undodir=~/.vim/undo              " Put undo files here
call mkdir(&undodir, "p", 0o700)
set path^=$DOTFILES                  " Search for files in $DOTFILES
set path+=~/work/fen-x/fenx-infra
set path+=~/work/fen-x/fenx-infra/fenx_infra

" ttymouse is not properly set if TERM=tmux*
" and then I can't use the mouse to resize splits
if &term =~ "tmux"
    set ttymouse=sgr
endif

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim), for a commit or rebase message
" (likely a different one than last time), and when using xxd(1) to filter
" and edit binary files (it transforms input files back and forth, causing
" them to have dual nature, so to speak)
"
" From $VIMRUNTIME/defaults.vim (Vim 9.1.825, Fedora 39)
autocmd vimrc BufReadPost *
    \ let line = line("'\"")
    \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
    \      && index(['xxd', 'gitrebase'], &filetype) == -1
    \ |   execute "normal! g`\""
    \ | endif
" Absolute & Hybrid line numbers by buffer status {{{2
"
" https://jeffkreeftmeijer.com/vim-number/
augroup numbertoggle | autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &number && mode() != 'i' | set relativenumber   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &number                  | set norelativenumber | endif
augroup end

" Automatically open quickfix window {{{2
augroup quickfix | autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
augroup end

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
    return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'


" Text Formatting/Layout {{{1
"===========================
set formatoptions+=rqlnj " j: delete comment leader when joining lines
                         " l: do not break long lines in insert mode
                         " n: support numbered lists (:help formatlistpat)
                         " q: reformat comments with 'gq'
                         " r: insert comment leader on <Enter>
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
function! SL_GitHunks()
    if system('git rev-parse --is-inside-work-tree 2>/dev/null') !~ 'true'
        return ''
    endif
    let [a,m,r] = GitGutterGetHunkSummary()
    let s = printf('[+%d %~%d -%d] ', a, m, r)
    return s
endfunction

function! SL_GitBranch()
    let b = substitute(system('git rev-parse --abbrev-ref HEAD 2>/dev/null'), '\n\+$', '', '')
    let s = strlen(b) ? ' ' . b . ' ' : ''
    return s
endfunction

function! SL_isactive()
    return g:statusline_winid == win_getid(winnr())
endfunction

function! Statusline() abort
    let s = ' '
    "let s .= '%{SL_GitBranch()} '
    let s .= '%F'
    let s .= '%m'
    let s .= '%r'
    let s .= ' '
    let s .= '[%Y]'
    let s .= '%='
    "let s .= '%{SL_GitHunks()}'
    let s .= '%l(%L):%c'
    let s .= ' '
    let s .= '[UNICODE 0x%B]'
    return s
endfunction

set laststatus=2 " Always show status line

set statusline=%!Statusline()

" Terminal window status line
augroup termwindow | autocmd!
    autocmd TerminalWinOpen * setlocal statusline=%t
augroup end

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

" Window Management: {{{2
" ==================
" See vim-tmux-pilot configuration

" Resize windows with C-[ARROWS] {{{3
"
" C-[Up|Down]:    Grow|Shrink vertically
" C-[Left|Right]: Grow|Shrink horizontaally
nnoremap <C-Down>  <C-w>-
nnoremap <C-Up>    <C-w>+
nnoremap <C-Left>  <C-w><
nnoremap <C-Right> <C-w>>
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

" Terminal Mode {{{2
"
" <leader><Esc>: Enter normal mode
tnoremap <leader><Esc> <C-\><C-n>

" Searching {{{2
"
" Metacharacters do not need escaped (very magic, :help \v)
nnoremap / /\v
vnoremap / /\v

" <leader>c:           toggle colorcolumn {{{2
"
" Kevin Kuchta (www.vimbits.com/bits/317)
function! g:ToggleColorColumn()
    if &colorcolumn == ''
        setlocal colorcolumn=80
    else
        setlocal colorcolumn&
    endif
endfunction
nnoremap <silent> <leader>c :call g:ToggleColorColumn()<cr>

" <leader>l:           toggle listchars {{{2
nnoremap <silent> <leader>l :set list!<cr>

" <leader>s:           split line {{{2
"
" https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666
function! BreakHere()
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction
nnoremap <leader>s :<C-u>call BreakHere()<CR>

" <leader><leader>:    clear search highlighting {{{2
noremap <silent> <leader><leader> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" fN:                  set foldlevel=N {{{2
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

" [e / ]e:             exchange current line with previous/next {{{2
nnoremap [e kddp
nnoremap ]e jddkP

" <Tab>:               Map Tab to % {{{2
nmap <tab> %
vmap <tab> %

" Y:                   yank to end (consistent with C and D) {{{2
nnoremap Y y$

" :w!!:                write file when I forget to sudo {{{2
cnoremap w!! w !sudo tee % >/dev/null

" <C-P> / <C-N>:       command history navigation {{{2
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" <leader>u[c]:        underline current line with [c] {{{2
nnoremap <leader>u yypVr

" zl / zh:             horizontal left/right scrolling {{{2
nnoremap zl zL
nnoremap zh zH

" DiffOrig:            diff of buffer and file {{{2
" Redo the stock DiffOrig to suppress the '1 line less' message
command! DiffOrig vert new | set bt=nofile | r ++edit #
    \ | silent! 0d_ | diffthis | wincmd p | diffthis

" <F2>:                toggle relative/absoute line numbers {{{2
nnoremap <F2> :set norelativenumber!<CR>

" C-u:                 convert current word to uppercase {{{2

inoremap <C-u> <esc>gUiwea

" vim-fugitive & vim-gitgutter: {{{2
"
nnoremap <leader>gg :Git<CR>

nnoremap <leader>gB :GBrowse<CR>
vnoremap <leader>gB :GBrowse<CR>

" Open git diff split
nnoremap <leader>gd :Gdiffsplit<CR>

" Mappings to jump between hunks (fugitive & gitgutter)
" [c, ]c: previous, next hunk

" fzf.vim, fzf-checkout.vim: {{{2
"
noremap  <leader>b  :Buffers<CR>
nnoremap <leader>gc :Commits<CR>
nnoremap <leader>gb :GBranches<CR>
nnoremap <leader>f  :Files<CR>

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
"
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
" HilightSwap: make 'hi out' the reverse of 'hi in' {{{
"
" Based on https://vi.stackexchange.com/a/21547
function! HighlightSwap(in, out)
    let l:hi = execute('hi ' . a:in)

    let l:cterm = matchstr(l:hi, 'cterm=\zs\S*')
    let l:ctermfg = matchstr(l:hi, 'ctermfg=\zs\S*')
    let l:ctermbg = matchstr(l:hi, 'ctermbg=\zs\S*')

    let l:gui = matchstr(l:hi, 'gui=\zs\S*')
    let l:guifg = matchstr(l:hi, 'guifg=\zs\S*')
    let l:guibg = matchstr(l:hi, 'guibg=\zs\S*')

    let l:cterm = empty(l:cterm) ? 'NONE' : l:cterm
    let l:ctermfg = empty(l:ctermfg) ? 'NONE' : l:ctermfg
    let l:ctermbg = empty(l:ctermbg) ? 'NONE' : l:ctermbg

    let l:gui = empty(l:gui) ? 'NONE' : l:gui
    let l:guifg = empty(l:guifg) ? 'NONE' : l:guifg
    let l:guibg = empty(l:guibg) ? 'NONE' : l:guibg

    call execute(printf("hi %s cterm=%s,reverse ctermfg=%s ctermbg=%s gui=%s,reverse guifg=%s guibg=%s", a:out, l:cterm, l:ctermfg, l:ctermbg, l:gui, l:guifg, l:guibg))
endfunction " }}}

syntax enable
set hlsearch            " Highlight search matches
let c_comment_strings=1 " Highlight strings in C comments

if &term =~ '256color\|alacritty'
    if has('termguicolors')
        set termguicolors " Enable truecolor in the terminal

        let &t_Ts = "\e[9m"  " strikethrough
        let &t_Te = "\e[29m" " strikethrough end

	    let &t_Us = "\e[4:2m" " underdouble
	    let &t_ds = "\e[4:4m" " underdotted
	    let &t_Ds = "\e[4:5m" " underdashed
        let &t_Cs = "\e[4:3m" " undercurl
        let &t_Ce = "\e[4:0m" " undercurl / underline end

        let &t_AU = "\e[58:5:%p1%d%;m"     " colored underline
        let &t_8u = "\e[58:2:%lu:%lu:%lum" " underline color

        " ???
        " I was trying to use these to get terminal fg/bg in vim
        " (see my comp.editors post)
        " let &t_RB = "\e]11;?"
        " let &t_RF = "\e]10;?"

        " Make terminal colors match underlying terminal
        " let g:terminal_ansi_colors = $VIM_TERMINAL_COLORS
    endif
endif

" Custom colors {{{
function! s:colorscheme_local() abort
    " Use the terminal's background color as the default
    highlight Normal ctermbg=NONE guibg=NONE

    " Non-printing characters
    highlight NonText    ctermfg=166 ctermbg=NONE guifg=#d75f00 guibg=NONE
    highlight SpecialKey ctermfg=166 ctermbg=NONE guifg=#d75f00 guibg=NONE

    " Gutter and line number column
    highlight  LineNr ctermbg=NONE guibg=NONE
    highlight! link SignColumn LineNr

    " Custom highlighting for 'name' when using ansible-vim
    " The setup that makes this work is in ~/.vim/after/syntax/ansible.vim
    highlight link my_ansible_name Structure

    " Status line {{{
    " Active window status line
    highlight StatusLine   ctermfg=12 ctermbg=15 guifg=#4271ae guibg=#ffffff
    " In-active window status line
    highlight StatusLineNC ctermfg=12 ctermbg=16 guifg=#4271ae guibg=#000000

    " Link terminal status lines to normal ones
    highlight! link StatusLineTerm   StatusLine
    highlight! link StatusLineTermNC StatusLineNC

    " Statusline user colors
    highlight! link User1 StatusLine
    " }}}
    " Column and row highlighting {{{
    highlight ColorColumn  cterm=NONE            ctermbg=23                          guibg=#003644
    highlight CursorLine   cterm=NONE            ctermbg=23                          guibg=#003644
    highlight CursorLineNr cterm=NONE ctermfg=15 ctermbg=NONE gui=NONE guifg=#ffffff guibg=NONE
    " }}}
    " Spelling colors {{{
    highlight SpellBad   cterm=undercurl ctermul=160 ctermbg=NONE gui=undercurl guisp=#d70000 guibg=NONE
    highlight SpellCap   cterm=undercurl ctermul=226 ctermbg=NONE gui=underline guisp=#ffff00 guibg=NONE
    highlight SpellLocal cterm=undercurl ctermul=166 ctermbg=NONE gui=underline guisp=#d75f00 guibg=NONE
    highlight SpellRare  cterm=undercurl ctermul=135 ctermbg=NONE gui=underline guisp=#af5fff guibg=NONE
    " }}}
    " Diffs {{{
    highlight DiffDelete term=bold ctermfg=12 ctermbg=6 guifg=#cf669f guibg=#5f0000

    " Make all types of diffs look the same
    highlight! link diffAdded   DiffAdd 
    highlight! link diffChanged DiffChange
    highlight! link diffRemoved DiffDelete
    " DiffText (changed line)
    " }}}
    " vim-gitgutter {{{
    " The defaults aren't very good
    highlight GitGutterAdd    cterm=bold ctermfg=40  ctermbg=NONE gui=bold guifg=#00d700 guibg=NONE
    highlight GitGutterChange cterm=bold ctermfg=226 ctermbg=NONE gui=bold guifg=#ffff00 guibg=NONE
    highlight GitGutterDelete cterm=bold ctermfg=160 ctermbg=NONE gui=bold guifg=#d70000 guibg=NONE
    " }}}
endfunction

" Automatcially source custom colors when a colorscheme is loaded
" unless we are running vimpager
if !exists('g:vimpager.enabled')
    autocmd vimrc ColorScheme * call s:colorscheme_local()
endif
" }}}

set background=dark
colorscheme PaperColor
let g:PaperColor_Theme_Options = {
            \ 'theme' : {
            \     'default' : {
            \         'allow_bold' : 1,
            \         'allow_italic' : 1 }},
            \ 'language': {
            \     'python': { 'highlight_builtins' : 1 },
            \     'cpp': { 'highlight_standard_library': 1 },
            \     'c': {'highlight_builtins' : 1 }}
            \ }

if exists('g:vimpager.enabled')
    highlight Normal ctermbg=250 guibg=#002b36
endif

" Mode aware cursors
let &t_SI = "\<Esc>[6 q" " Insert mode (bar)
let &t_SR = "\<Esc>[4 q" " Replace mode (underline)
let &t_EI = "\<Esc>[2 q" " Normal mode (block)


" Local Vimrc {{{1
" ===========
if filereadable(expand("~/etc/vimrc.local"))
    source ~/etc/vimrc.local
endif

