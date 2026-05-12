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
" Miscellaneous autocmds
augroup misc | autocmd! | augroup end

" Use a "file" mark to open .vimrc
nmap <silent> 'V <Cmd>next $MYVIMRC<CR>

" Source .vimrc when saving changes
autocmd misc BufWritePost $MYVIMRC nested source $MYVIMRC 

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
packadd! matchit " Enhanced % matching
packadd! cfilter " Filter quickfix or location lists

" Commands to manipulate minpac {{{2
"
" *AndQuit commands are intended to be used at the command line
command! PackUpdate        call plugins#PackInit() | call minpac#update()
command! PackUpdateAndQuit call plugins#PackInit() | call minpac#update("", {"do":"quitall"})
command! PackClean         call plugins#PackInit() | call minpac#clean()
command! PackCleanAndQuit  call plugins#PackInit() | call minpac#clean() | quitall
command! PackStatus        call plugins#PackInit() | call minpac#status()

" Plugin Configuration {{{2
"
" Plugins should use this augroup
augroup plugins | autocmd! | augroup end

" Conditionally load git related plugins {{{3
"
" List of plugins to load
let s:git_plugins = []

function! LoadGit()
    silent! !git rev-parse --is-inside-work-tree
    if v:shell_error
        return
    endif

    for s:p in s:git_plugins
        execute 'packadd ' . s:p
    endfor

    if !empty(get(g:, 'fugitive_gitlab_domains', "")) " Set in private config
        packadd fugitive-gitlab
    endif

    if !empty(get(g:, 'fugitive_gitea_domains', "")) " Set in private config
        packadd fugitive-gitea
    endif

    " TODO: I would rather make subcommands to :Git
    command! -bar -nargs=* JumpDiff  cexpr system('git jump --stdout diff'  . expand(<q-args>))
    command! -bar -nargs=* JumpMerge cexpr system('git jump --stdout merge' . expand(<q-args>))
    command! -bar -nargs=* JumpGrep  cexpr system('git jump --stdout grep'  . expand(<q-args>))
endfunction

autocmd plugins VimEnter,DirChanged * call LoadGit()

" ansible-vim:             Syntax highlighting Ansible's common filetypes                         plugurl:pearofducks/ansible-vim " {{{3

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
    \ '*.xml.j2':    'xml',
    \ '*.yml.j2':    'yaml',
    \ '*.yaml.j2':   'yaml',
\ }

autocmd plugins BufRead,BufNewFile playbooks/*.yaml set filetype=yaml.ansible
autocmd plugins BufRead,BufNewFile playbooks/*.yml  set filetype=yaml.ansible

" CCTree:                  Vim CCTree plugin                                                      plugurl:hari-rangarajan/CCTree type:opt " {{{3

" See Mappings & Commands -> Cscope for mappings

if has("cscope")
    autocmd plugins VimEnter,DirChanged * call cscope#LoadCCTree()
endif

" cisco.vim:               Vim syntax for cisco configuration files                               plugurl:momota/cisco.vim " {{{3

" No configuration needed

" Colorizer:               Color hex codes and color names                                        plugurl:chrisbra/Colorizer type:opt " {{{3

" Turn off color:
"   :ColorClear
" Toggle color:
"   :ColorToggle

" Automatically colorize these filetypes
let g:colorizer_auto_filetype = 'css,html,markdown,xdefaults'
let g:colorizer_disable_bufleave = 0 " Only highlight above files
" Highlight X11 colornames in Xresources and such
let g:colorizer_x11_names = 1

execute 'autocmd plugins Filetype ' . g:colorizer_auto_filetype . ' packadd Colorizer | ColorToggle'

" embed-syntax:            Simplifies applying different syntax highlighting to regions of a file plugurl:jbrubake/embed-syntax " {{{3

" No configuration needed

" flex-bison-syntax:       Flex & Bison syntax highlighting for vim                               plugurl:calincru/flex-bison-syntax " {{{3

" No configuration needed

" fugitive-gitea:          Plugin for :Gbrowse to work with GITea server                          plugurl:borissov/fugitive-gitea type:opt " {{{3

" Loaded by LoadGit()

" fugitive-gitlab.vim:     A vim extension to fugitive.vim for GitLab support                     plugurl:shumphrey/fugitive-gitlab.vim type:opt " {{{3

" Loaded by LoadGit()

" indentLine:              Display the indentation levels with thin vertical lines                plugurl:wickles/indentLine " {{{3

let g:indentLine_char = '│'
let g:indentLine_bufTypeExclude = ['help', 'terminal', 'markdown']
"let g:indentLine_bufNameExclude = ['tagbar?']
" Hide indents on cursor line
let g:indentLine_concealcursor = ''
" Use this if JSON quotes are hidden
" let g:vim_json_syntax_conceal = 0

" jump-to-ansible-role:    Load the main task file for role under the cursor                      plugurl:jbrubake/jump-to-ansible-role " {{{3

autocmd plugins FileType yaml.ansible nnoremap <localleader>gr <Cmd>call JumpToAnsibleRole()<CR>
autocmd plugins FileType yaml.ansible vnoremap <localleader>gr <Cmd>call JumpToAnsibleRole()<CR>

" paredit:                 Structured Editing of Lisp S-expressions                               plugurl:kovisoft/paredit " {{{3

" No configuration needed

" pseudo-syntax:           Syntax highlighting for various forms of pseudocode for vim            plugurl:joelbeedle/pseudo-syntax " {{{3

" readline.vim:            Readline emulation for command-line mode                               plugurl:ryvnf/readline.vim " {{{3

" NOTE: These bindings are in the readline.vim documentation
" but not actually created
"
" Alt-Ctrl-H    : Cut to start of previous word
" Ctrl-X Ctrl-H : Cut to beginning of line
cmap <Esc><C-H> <Esc><BS>
cmap <C-X><C-H> <C-U>

" Replacements for overridden maps:
"
" Alt+= / Alt+? (c_CTRL-D) : Display all names that match pattern in front of cursor
" Alt+*         (c_CTRL-A) : Insert all names that match pattern in front of cursor
" Ctrl-X Ctrl-E (c_CTRL-F) : Open command-line window

" scss-syntax.vim:         Sassy CSS for vim                                                      plugurl:cakebaker/scss-syntax.vim " {{{3

" No configuration needed

" SyntaxAttr.vim:          Show syntax highlighting attributes of character under cursor          plugurl:inkarkat/SyntaxAttr.vim " {{{3

nnoremap -a <Cmd>call SyntaxAttr#SyntaxAttr()<CR>

" tagalong.vim:            Change an HTML(ish) tag and update the matching one                    plugurl:AndrewRadev/tagalong.vim " {{{3

" Plugin is active for these filetypes
let g:tagalong_additional_filetypes = ['xml', 'html', 'php']

" tagbar:                  Source code browser using ctags                                        plugurl:preservim/tagbar type:opt " {{{3

if executable('ctags')
    autocmd plugins VimEnter,DirChanged * call tagbar#load()
endif

" todo.txt-vim:            Vim plugin for Todo.txt                                                plugurl:freitass/todo.txt-vim " {{{3
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

" ugbi:                    UserGettingBored Improved Vim Plugin                                   plugurl:mikesmithgh/ugbi type:opt " {{{3

command! -nargs=0 UgbiEnable packadd ugbi | UgbiEnable

" vim-characterize         Unicode character metadta                                              plugurl:tpope/vim-characterize " {{{3

nmap gA <Plug>(characterize)

" vim-closetag:            Easily close HTML/XML tags                                             plugurl:alvan/vim-closetag " {{{3

"   Current content:
"       <table|
"   Press >:
"       <table>|</table>
"   Press > again:
"       <table>
"           |
"       </table>

" Plugin is active for these filetypes
let g:closetag_filetypes = 'sgml, xml, html, xhtml, phtml, php'

" vim-commentary:          Commenting keymaps                                                     plugurl:tpope/vim-commentary " {{{3

" No configuration needed

" gc{motion} : Toggle commenting over {motion}
" gcc        : Toggle commenting of [count] lines
" {Visual}gc : Toggle commenting of highlighted lines
" gcu        : Uncomment current and adjacent lines

" vim-easy-align:          A Vim alignment plugin                                                 plugurl:junegunn/vim-easy-align " {{{3

vmap <Enter> <Plug>(EasyAlign)
nmap ga      <Plug>(EasyAlign)

" vim-fugitive:            Git in Vim                                                             plugurl:tpope/vim-fugitive type:opt " {{{3

let s:git_plugins += ['vim-fugitive']

" vim-fugitive-blame-ext:  extend vim-fugitive to show commit message on statusline in :Gblame    plugurl:tommcdo/vim-fugitive-blame-ext type:opt " {{{3

let s:git_plugins += ['vim-fugitive-blame-ext']

" vim-gist:                Edit github.com gists with vim                                         plugurl:mattn/vim-gist type:opt " {{{3

command! -nargs=? Gist packadd webapi-vim | packadd vim-gist | :Gist <args>

let g:gist_post_private = 1 " Private gists by default
                            " :Gist -P to create public Gist

" vim-gitgutter:           Use the sign column to show git chanages                               plugurl:airblade/vim-gitgutter type:opt " {{{3

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

" vim-ini-fold:            folding for ini-like files                                             plugurl:matze/vim-ini-fold " {{{3

" No configuration needed

" vim-markdown:            Markdown vim mode                                                      plugurl:preservim/vim-markdown " {{{3

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 1
let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_conceal_code_blocks = 0

" vim-qlist:               Send results of :ilist and related commands to the quickfix list       plugurl:romainl/vim-qlist " {{{3

" No configuration needed

" vim-redact-pass.git:     Do not write passwords into vim files when using pass(1)               plugurl:https://dev.sanctum.geek.nz/code/vim-redact-pass.git rev:master " {{{3

" No configuration needed

" vim-redir:               Redirect the output of a Vim or external command into a scratch buffer plugurl:romainl/vim-redir type:opt " {{{3

command! -nargs=? Redir packadd vim-redir | :Redir <args>

" vim-repeat:              Enable repeating supported plugin maps with "."                        plugurl:tpope/vim-repeat " {{{3

" No configuration needed

" vim-rhubarb:             GitHub extension for fugitive.vim                                      plugurl:tpope/vim-rhubarb type:opt " {{{3

let s:git_plugins += ['vim-rhubarb']

" C-X C-O: omni-complete GitHub issues or project collaborator usernames in commits

" Do not show issue preview window when omni-completing
autocmd plugins FileType gitcommit setlocal completeopt-=preview

" vim-slint:               Support for the slint language                                         plugurl:slint-ui/vim-slint " {{{3

" No configuration needed

" vim-surround:            Modify surrounding characters                                          plugurl:tpope/vim-surround " {{{3

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

" vim-sxhkdrc:             Vim syntax for sxhkd's configuration files                             plugurl:baskerville/vim-sxhkdrc " {{{3

" No configuration needed

" vim-table-mode           VIM Table Mode for instant table creation                              plugurl:dhruvasagar/vim-table-mode " {{{3

" No configuration needed
"
" TODO: Open an issue that allows tables like
"
" foo | bar      | baz
" --- | ---      | ---
" asd | asdfasdf | asdf

" vim-terraform:           basic vim/terraform integration                                        plugurl:hashivim/vim-terraform " {{{3

" No configuration needed

" vim-tmux:                Vim plugin for .tmux.conf                                              plugurl:tmux-plugins/vim-tmux " {{{3

" No configuration needed

" vim-tmux-navigator       Seamless navigation between tmux panes and vim splits                  plugurl:jbrubake/vim-tmux-navigator type:opt " {{{3

" Do not unzoom if trying to move away from zoomed vim pane
let g:tmux_navigator_disable_when_zoomed = 1

" Do not wrap around
let g:tmux_navigator_no_wrap = 1

" Use Alt+[hjkl] to navigate windows
if has ('unix') " 'set convert-meta off' in .inputrc makes Alt not the Meta key
    let g:navigator_key_h='h'
    let g:navigator_key_j='j'
    let g:navigator_key_k='k'
    let g:navigator_key_l='l'
    let g:navigator_key_p='\'
else
    let g:navigator_key_h='<a-h>'
    let g:navigator_key_j='<a-j>'
    let g:navigator_key_k='<a-k>'
    let g:navigator_key_l='<a-l>'
    let g:navigator_key_p='<a-\>'
endif

let g:tmux_navigator_no_mappings = 1
execute "nnoremap <silent> " . g:navigator_key_h . " :<C-U>TmuxNavigateLeft<cr>"
execute "nnoremap <silent> " . g:navigator_key_j . " :<C-U>TmuxNavigateDown<cr>"
execute "nnoremap <silent> " . g:navigator_key_k . " :<C-U>TmuxNavigateUp<cr>"
execute "nnoremap <silent> " . g:navigator_key_l . " :<C-U>TmuxNavigateRight<cr>"
execute "nnoremap <silent> " . g:navigator_key_p . " :<C-U>TmuxNavigatePrevious<cr>"

if $TMUX != "" | packadd! vim-tmux-navigator | endif

" vim-tridactyl:           Syntax plugin for Tridactyl configuration files                        plugurl:tridactyl/vim-tridactyl " {{{3

" No configuration needed

" vimtex:                  vim LaTeX plugin                                                       plugurl:lervag/vimtex type:opt " {{{3

let g:vimtex_view_method = 'zathura'
let g:tex_flavor         = 'latex' " See <vim-tex>/ftdetect/tex.vim
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \    '-shell-escape',
    \    '-verbose',
    \    '-file-line-error',
    \    '-synctex=1',
    \    '-interaction=nonstopmode',
    \ ],
    \}

autocmd plugins FileType tex,bib packadd vimtex | call vimtex#init()

" vimux:                   Easily interact with tmux from vim                                     plugurl:preservim/vimux " {{{3

" Always spawn a new pane
let g:VimuxUseNeareset = 0

" vlime:                   A Common Lisp dev environment for Vim                                  plugurl:vlime/vlime " {{{3

let g:vlime_cl_impl = "sbcl"
function! VlimeBuildServerCommandFor_clisp(vlime_loader, vlime_eval)
    return ["clisp", "--load", expand($XDG_DATA_HOME) . "/quicklisp/setup.lisp",
                   \ "--load", a:vlime_loader,
                   \ "--eval", a:vlime_eval]
endfunction

" webapi-vim:              Needed for vim-gist                                                    plugurl:mattn/webapi-vim type:opt " {{{3

" No configuration needed

" YankRing.vim:            Maintains a history of previous yanks, changes and deletes             plugurl:vim-scripts/YankRing.vim " {{{3

nnoremap <silent> <F5> :YRShow<CR>

let g:yankring_history_dir = 
    \ ($XDG_CACHE_HOME != '') ? $XDG_CACHE_HOME : '~/.cache'

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
set updatecount=10                   " Write swapfile every 10 keystrokes
set undofile                         " Persistent undo tree
set undodir=~/.vim/undo              " Put undo files here
call mkdir(&undodir, "p", 0o700)
set path^=$DOTFILES                  " Search for files in $DOTFILES

" Use cursorline only in active window
" TODO: cursorline is off when vim is first opened
autocmd misc WinEnter,FocusGained * setlocal cursorline
autocmd misc WinLeave,FocusLost   * setlocal nocursorline

" ttymouse is not properly set if TERM=tmux*
" and then I can't use the mouse to resize splits
if &term =~ "tmux" | set ttymouse=sgr | endif

" Set buffer to use detected tabbing style
"
" Ignore buffers that don't work with autotab
if executable('autotab')
    let autotab_blacklist = ['fugitive']
    autocmd misc BufReadPost *
        \ if bufname('%:p') != "" && index(autotab_blacklist, &ft) < 0 |
            \ execute system("autotab -l <" .  bufname('%:p')) |
        \ endif
endif

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim), for a commit or rebase message
" (likely a different one than last time), and when using xxd(1) to filter
" and edit binary files (it transforms input files back and forth, causing
" them to have dual nature, so to speak)
"
" From $VIMRUNTIME/defaults.vim (Vim 9.1.825, Fedora 39)
autocmd misc BufReadPost *
    \ let line = line("'\"")
    \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
    \      && index(['xxd', 'gitrebase'], &filetype) == -1
    \ |   execute "normal! g`\""
    \ | endif

" netrw {{{1
" =====
"
" Based on ideas from https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
"
let g:netrw_keepdir = 0 " Keep browsing directory separate from current directory
let g:netrw_banner = 0  " Hide banner (I to toggle)
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+' " Hide dotfiles (gh to show)
let g:netrw_localcopydircmd = 'cp -r'          " Allow copying directories

" Open netrw in buffer directory
nnoremap <leader>eb <Cmd>Lexplore %:p:h<CR>

" Open netrw in current directory
nnoremap <Leader>ee <Cmd>Lexplore<CR>

" Configure netrw mappings
"
function! NetrwMapping()
    " <localleader>ee : close netrw
    " . : toggle hidden files
    " H : go back in history
    " H : go forward in history
    " h : go up a directory
    nmap <buffer> <Leader>ee <Cmd>Lexplore<CR>
    nmap <buffer> . gh
    nmap <buffer> H u
    nmap <buffer> L U
    nmap <buffer> h -

    " l : open a file and close netrw
    " L : open directory or file
    " P : close preview window
    nmap <buffer> l <CR><Cmd>Lexplore<CR>
    nmap <buffer> L <CR>
    nmap <buffer> P <C-w>z

    " TAB : (un)mark a file
    " Shift+TAB : unmark files in buffer
    " <localleader>TAB : unmark all files
    nmap <buffer> <TAB> mf
    nmap <buffer> <S-TAB> mF
    nmap <buffer> <localleader><TAB> mu

    " ff : touch a file
    " fe : rename a file
    " fc : copy marked files
    " fC : copy marked files to highlighted directory
    " fx : move marked files
    " fX : move marked files to highlighted directory
    " f; : run external command on marked files
    " FF : rm -rf WHAT???
    nmap <buffer> ff %<Cmd>w<CR><Cmd>buffer #<CR>
    nmap <buffer> fe R
    nmap <buffer> fc mc
    nmap <buffer> fC mtmc
    nmap <buffer> fx mm
    nmap <buffer> fX mtmm
    nmap <buffer> f; mx
    nmap <buffer> FF <Cmd>call netrw#RemoveRecursive()<CR>

    " Convience mappings if banner is hidden
    "
    " fl : show marked files
    " fq : show target directory
    " fd : set target ???
    nmap <buffer> fl <Cmd>echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>
    nmap <buffer> fq <Cmd>echo 'Target:' . netrw#Expose("netrwmftgt")<CR>
    nmap <buffer> fd mtfq

    " bb : create bookmark
    " bd : remove last bookmark
    " bl : jump to last bookmark
    nmap <buffer> bb mb
    nmap <buffer> bd mB
    nmap <buffer> bl gb
endfunction

autocmd misc filetype netrw call NetrwMapping()

" Absolute & Hybrid line numbers by buffer status {{{2
"
" https://jeffkreeftmeijer.com/vim-number/
autocmd misc BufEnter,FocusGained,InsertLeave,WinEnter * if &number && mode() != 'i' | set relativenumber   | endif
autocmd misc BufLeave,FocusLost,InsertEnter,WinLeave   * if &number                  | set norelativenumber | endif

" Automatically open quickfix window {{{2
autocmd misc QuickFixCmdPost [^l]* cwindow
autocmd misc QuickFixCmdPost l*    lwindow

" Searching {{{2
if executable('rg') | set grepprg=rg\ --vimgrep | endif

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
function! Statusline() abort
    let s  = ' '
    let s .= '%-2c'           " Column
    let s .= ' '
    let s .= '%f'             " Relative path to file in buffer
    let s .= '%m'             " Modified flag
    let s .= '%r'             " Readonly flag
    let s .= ' '
    let s .= '[%Y]'           " Filetype

    let s .= '%='             " Divide left and right halves

    let s .= '%l:%L'          " Line:Lines
    let s .= ' '
    let s .= '[UNICODE 0x%B]' " Unicode codepoint
    return s
endfunction

set laststatus=2 " Always show status line

set statusline=%!Statusline()

" Terminal window status line
autocmd misc TerminalWinOpen * setlocal statusline=%t

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
" Mapping Help {{{2
"
" :map <key>         : see what is mapped to <key>
" :verbose map <key> : also see where it was last mapped
" :help key-notation : how to express special keys
"
" Modes (:help map-commands)
" --------------------------
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
" ?nore*: non-recursive mapping
"
" Options
" -------
" <silent> : don't echo mapping on command line
" <expr>   : mapping inserts result of {rhs}
" <buffer> : buffer local mapping
"
" Other
" -----
" <bar> : use in {rhs} to chain commands
"
" Command Help {{{2
"

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
nnoremap <silent> <C-W>m <Cmd>call wbtmgmt#ToggleMaximizeCurrentWindow() <cr>

" Buffer Management {{{2
"
nnoremap <silent> <Up>   :bprevious<CR>
nnoremap <silent> <Down> :bnext<CR>

" Terminal Mode {{{2
"
" <leader><Esc>: Enter normal mode
tnoremap <leader><Esc> <C-\><C-n>

" Searching & Search/Replace {{{2
"
" Metacharacters do not need escaped (very magic, :help \v)
nnoremap / /\v
vnoremap / /\v

" Search for character under cursor
nnoremap <leader>* xhp/<C-R>-<Return>

" Start a global search & replace
nnoremap S :%s//g<Left><Left>

" Populate a global search & replace with previous search
nnoremap <expr> M ':%s/' . @/ . '//g<Left><Left>'

" Simplify jumping to results of a "list" command
"
cnoremap <expr> <CR> ccr#CCR()

" Quickfix Window {{{2
"
" nnoremap <silent> <LEFT>          :cprev<CR>
" nnoremap <silent> <RIGHT>         :cnext<CR>
" nnoremap <silent> <LEFT><LEFT>    :cpfile<CR><C-G>
" nnoremap <silent> <RIGHT><RIGHT>  :cnfile<CR><C-G>

" Toggle quickfix and location list
nnoremap <silent> <F3> <Cmd>call qfhistory#ToggleQuickFix(1)<cr>
nnoremap <silent> <F4> <Cmd>call qfhistory#ToggleQuickFix(0)<cr>

" <leader>c:           toggle colorcolumn {{{2
"
nnoremap <silent> <leader>c <Cmd>call wbtmgmt#ToggleColorColumn()<cr>

" <leader>C:           toggle cursorcolumn {{{2
"
map <leader>C :set cursorcolumn!<cr>

" <leader>l:           toggle listchars {{{2
nnoremap <silent> <leader>l <Cmd>set list!<cr>

" <leader>s:           split line {{{2
"
nnoremap <leader>s <Cmd>call split_line#BreakHere()<CR>

" <localleader><F7>    toggle spellcheck {{{2
nnoremap <localleader><F7> <Cmd>setlocal spell!<CR>

" <C-L>:               clear search highlighting {{{2
"
" This allows n and N to resume the previous search while 'let @/ = ""' does not
noremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" fN:                  set foldlevel=N {{{2
noremap <leader>f0 <Cmd>set foldlevel=0<cr>
noremap <leader>f1 <Cmd>set foldlevel=1<cr>
noremap <leader>f2 <Cmd>set foldlevel=2<cr>
noremap <leader>f3 <Cmd>set foldlevel=3<cr>
noremap <leader>f4 <Cmd>set foldlevel=4<cr>
noremap <leader>f5 <Cmd>set foldlevel=5<cr>
noremap <leader>f6 <Cmd>set foldlevel=6<cr>
noremap <leader>f7 <Cmd>set foldlevel=7<cr>
noremap <leader>f8 <Cmd>set foldlevel=8<cr>
noremap <leader>f9 <Cmd>set foldlevel=9<cr>

" [<Space> / ]<Space>: add [n] blank lines before/after line {{{2
"
" https://superuser.com/a/607168
nnoremap <silent> [<Space> <Cmd>put!=repeat(nr2char(10),v:count)<Bar>execute "']+1"<CR>
nnoremap <silent> ]<Space> <Cmd>put =repeat(nr2char(10),v:count)<Bar>execute "'[-1"<CR>

" [e / ]e:             exchange current line with previous/next {{{2
nnoremap [e kddp
nnoremap ]e jddkP

" <Tab>:               Map Tab to % {{{2
nmap <tab> %
vmap <tab> %

" Y:                   yank to end (consistent with C and D) {{{2
nnoremap Y y$

" <localleader>Y:      yank to system clipboard {{{2
"
" Allow these to remap to include any subsequent yank maps
"
vmap <localleader>y "+y
nmap <localleader>y "+y
nmap <localleader>Y "+Y

" v_p:                 do not yank replaced text {{{2
"
xnoremap p P

" :w!!:                write file when I forget to sudo {{{2
cnoremap w!! w !sudo tee % >/dev/null

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
nnoremap <F2> <Cmd>set norelativenumber!<CR>

" C-u:                 convert current word to uppercase {{{2

inoremap <C-u> <esc>gUiwea

"                      Add count to dot {{{2

nnoremap . :<C-u>execute "normal! " . repeat(".", v:count1)<CR>

" vim-fugitive & vim-gitgutter: {{{2
"
nnoremap <leader>gg <Cmd>Git<CR>

nnoremap <leader>gB <Cmd>GBrowse<CR>
vnoremap <leader>gB <Cmd>GBrowse<CR>

" Open git diff split
nnoremap <leader>gd <Cmd>Gdiffsplit<CR>

" Mappings to jump between hunks (fugitive & gitgutter)
" [c, ]c: previous, next hunk (default binding)

" fzf.vim, fzf-checkout.vim: {{{2
"
noremap  <leader>b  <Cmd>Buffers<CR>
nnoremap <leader>gc <Cmd>Commits<CR>
nnoremap <leader>gb <Cmd>GBranches<CR>
nnoremap <leader>f  <Cmd>Files<CR>

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

    nmap <C-\>s <Cmd>cscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g <Cmd>cscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c <Cmd>cscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t <Cmd>cscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e <Cmd>cscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f <Cmd>cscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i <Cmd>cscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d <Cmd>cscope find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-]>s <Cmd>scscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>g <Cmd>scscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>c <Cmd>scscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>t <Cmd>scscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>e <Cmd>scscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]>f <Cmd>scscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-]>i <Cmd>scscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-]>d <Cmd>scscope find d <C-R>=expand("<cword>")<CR><CR>

    nmap <C-]><C-]>s <Cmd>vert scscope find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>g <Cmd>vert scscope find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>c <Cmd>vert scscope find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>t <Cmd>vert scscope find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>e <Cmd>vert scscope find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-]><C-]>f <Cmd>vert scscope find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-]><C-]>i <Cmd>vert scscope find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-]><C-]>d <Cmd>vert scscope find d <C-R>=expand("<cword>")<CR><CR>
endif

" My wiki {{{1
"
" Find wiki files
set path^=$WIKI_DIR/content

" Open wiki index
nnoremap <leader>ni <Cmd>e $WIKI_DIR/content/index.md<CR>

" Search the wiki
if executable('rg')
    command! -nargs=1 Ngrep silent! grep! "<args>" -g "*.md" $WIKI_DIR/content | execute ':redraw!'
else
    command! -nargs=1 Ngrep vimgrep "<args>" $WIKI_DIR/content/**/*.md
endif
nnoremap <leader>nn <Cmd>Ngrep<Space>

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
    highlight  ColorColumn  cterm=NONE            ctermbg=23                          guibg=#003644
    highlight  CursorLineNr cterm=NONE ctermfg=15 ctermbg=NONE gui=NONE guifg=#ffffff guibg=NONE
    highlight  CursorLine   cterm=NONE            ctermbg=23                          guibg=#003644
    highlight! link CursorColumn CursorLine
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
    autocmd misc ColorScheme * call s:colorscheme_local()
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

" Mode aware cursors {{{
"
" t_SI : insert mode
" t_SR : replace mode
" t_EI : normal mode
"
" Cursor shape: [X q where X is
"
"   0 : blinking block
"   1 : blinking block
"   2 : steady block
"   3 : blinking underline
"   4 : steady underline
"   5 : blinking bar
"   6 : steady bar
"
" Cursor color: ]12;COLOR\ where COLOR is an X11 color name
"
" (See https://invisible-island.net/xterm/ctlseqs/ctlseqs.pdf)
"
" Shapes
let &t_SI = "[6 q"
let &t_SR = "[4 q"
let &t_EI = "[2 q"

" Colors
let &t_SI .= ""
let &t_SR .= ""
let &t_EI .= ""

" Reset cursor on exit
autocmd misc VimLeave * silent !printf ']112\\'
" }}}

" Private and Local Vimrc {{{1
" ===========
let private = 
    \ (($XDG_CONFIG_HOME != '') ? $XDG_CONFIG_HOME : '~/.config') .. '/vimrc'
for f in [ private, '~/.vimrc.local' ]
    if filereadable(expand(f))
        execute 'source ' . f
    endif
endfor
unlet private

