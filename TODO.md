" call minpac#update() to update all packages
"     **or** run `update-vim-plugins` to do that and
"     create links to optional 'ftdetect' scripts
" call minpac#clean() to remove unused plugins
" call minpac#status() to get plugin status
"
" TODO: look at http://vimcasts.org/episodes/minpac/ to only load minpac when
" needed. To keep plugin URL together with their config this will require
" building a "package.vim" file automatically

- vim: hunk jumping comment should go elsewhere
- vim: last known cursor position thing might not work with fugitive commit window
- vim: tagbar markdown support won't work with current dynamic loading method
- vim: ansible_goto_role_paths is not part of the plugin and should be moved
    (maybe make it the default along with a windows path)
- vim: move git_plugins to a better spot as well as loadgit
- vim: clientserver might cause an error
- slrn: see $SLRNHELP and art_help_line
- slrn: define macro_directory (% set macro_directory "~/.slrn")
- add checkmail and checkcal to crontab
- tmux copy/paste no longer working right
- is keychain being run from xinitrc or just the one in shell files?
- put all vim autocmd in an augroup
- reorganize vim plugins and configuration so things that go together logically
  are placed together physically (fzf stuff, git stuff, etc)
- replace tmux-pilot with tmux-navigator?
- move vim filetype autocmds to .vim/filetype.vim (or the proper file)
- once XDG_CONFIG_HOME=~/etc, replace ~/etc in all files with $XDG_CONFIG_HOME
- Look into replicating /etc/profile.d - ansible could create either system or personal scripts
- put firefox stuff in a standard directory that is easy to link to
- Save .news/posts
- What vim plugins could just be submodules or peru modules? Things like
    colorschemes shouldn't be plugins - why waste time loading something you won't
    always use (vim/colors/PaperColor.vim is a good start)


alias:
- make pickfont more useful
- # Example ex(1) aliases
  # TODO: These are *not* currently POSIX-compliant
  # https://vi.stackexchange.com/a/2692
  alias trim="ex +'bufdo!%s/\s\+$//e' -scxa"
  alias retab="ex +'set ts=2' +'bufdo retab' -scxa"

env:
- is DOTFILES still needed?
- Use this to disable systemctl auto-pager:
  export SYSTEMD_PAGER=

init.d/touchpad
- what does this actually do?

functions:
- make define() work again (change to duckduckgo is a first start)

muttrc:
- old settings:
  unset mark_old    # Unread messages are still "new"
  set reverse_realname = no # Always use realname
  old: set query_command = "abook --mutt-query '%s'"
  source ~/.mutt/headers          # Source header ignores
  source ~/.mutt/keys             # Key configuration
  source ~/.mutt/aliases          # Source aliases
  source ~/.mutt/address_book     # Source address book

mutt/accounts/local:
- set hostname = "HOSTNAME"


- Put all color related stuff in a single file so I can swap colorschemes easily
- Create GPG keypair and additional keys (password vault, etc)
- How to get keypair passphrase loaded (checkmail doesn't run without it)
- Fix the git_template hack
- Work nerd-fonts icons into various things (with fallback if not available)
- Properly install packages from newer versions of Ubuntu
- Setup proper logging and logrotation for systemd timers
- Script setup of dropbox links
- Add podboat config to newsboat
## bootstrap
- Add ability to run arbitrary code
- Improve bootstrap.ini syntax
- Create the corrct XDG directories and delete the original ones
## dotfiles
- Add a better custom installation framework
- Backup files to a directory instead of renaming (easier to delete/recover)
- Properly use the git repos for the single scripts that don't have an install method
- Make files robust: only config if command/plugin installed
- Change structure
    - symlink: do what i'm doing now
    - copy: copy folder contents (this will allow putting share/bash-completion.d here)
    - other: git submodules
- Make sure the systemd enable symlinks work, otherwise the services just need
  to be enabled
## muttrc
- Filtering
- Keybindings
## vimrc
- Add vimpager specific configuration to vimrc or use a vimpagerrc
- Figure out how to keep plugins updated
- Automate plugin helptags
- Implement calendar-vim hooks using wiki
- mapping to generate ctags or just start using make from vim
- wiki mappings don't work right if pwd isn't changed to wiki root
## rclone
- Need to run cloudsync.sh with --first-sync the first time it runs
- Make cloudsync.sh use a config file to determine what to sync where
- Create symlinks into .sync
    ln -s .sync/dropbox/etc etc
    ln -s .sync/dropbox/docs/ docs
    ln -s .sync/dropbox/password-store/ .password-store
    ln -s .sync/dropbox/todo/ .todo
    for d in ../.sync/dropbox/src/*; do ln -s $d $(basename $d); done
    for d in ../.sync/dropbox/share/*; do ln -s $d $(basename $d); done

Vim plugins to try: {{{

" auto_mkdir2: Automatically create directory tree for new files {{{3
""call minpac#add('arp242/auto_mkdir2.vim')

" Only make tree in wiki
let g:auto_mkdir2_autocmd = '$WIKI_DIR/content/**'

" nerdtree: A tree explorer plugin for vim {{{3
""call minpac#add('preservim/nerdtree')

" <F10> : Toggle file tree browser
noremap <silent> <F8> :NERDTreeToggle<cr>

" Close Vim if last window open is NERDTree
autocmd bufenter * if (winnr("$") == 1 &&
    \ exists("b:NERDTree") && 
    \ b:NERDTree.isTabTree()) | q | 
    \ endif

" nerdtree-git-plugin: A plugin of NERDTree showing git status {{{3
""call minpac#add('Xuyuanp/nerdtree-git-plugin')

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
    " \ "Ignored"   : "☒",
    " \ "Unknown"   : "?"
    " \ }

" NOTE: See 'Colors and Syntax Settings' for more

" SimplyFold: No-BS Python code folding{{{3
""call minpac#add('tmhedberg/SimpylFold')

" vim-autoformat:  Provide easy code formatting in Vim by integrating existing code formatters {{{3
""call minpac#add('vim-autoformat/vim-autoformat')

" vim-IndentCommentPrefix: Indents comments sensibly {{{3
""call minpac#add('inkarkat/vim-IndentCommentPrefix')

" >>  : Indent, keeping comment prefix where it is
" <<  : Deindent, keeping comment prefix where it is
" g>> : Indent, including comment prefix

" Use single > or < in Visual mode

" Comment chars in this list will *not* be left in column 1
"let g:IndentCommentPrefix_Blacklist = ['#', '>']

" Any string in this list *will* remain in column 1
"let g:IndentCommentPrefix_Whitelist = ['REMARK:']

" vim-ingo-library: library functions required by IndentCommentPrefix {{{3
""call minpac#add('inkarkat/vim-ingo-library')

" vim-markdown-folding: Fold Markdown files on headers {{{3
""call minpac#add('masukomi/vim-markdown-folding', {'type': 'opt'})

""autocmd load_plugins FileType markdown packadd vim-markdown-folding

""call minpac#add('luochen1990/rainbow') " Rainbow Parentheses Improved {{{3

""call minpac#add('jpalardy/vim-slime') " A vim plugin to give you some slime {{{3

""call minpac#add('sjl/gundo.vim') " Graph your Vim undo tree in style {{{3

""call minpac#add('mtth/scratch.vim') " Unobtrusive scratch window {{{3

""call minpac#add('dbeniamine/cheat.sh-vim') " cheat.sh-vim: A vim plugin to access cheat.sh sheets {{{3

""call minpac#add('neoclide/coc-snippets') " coc-snippets: snippets for coc {{{3

""call minpac#add('vim-scripts/Conque-GDB') " conque-gdb: integrate gdb with vim {{{3

""call minpac#add('Shougo/deoplete.nvim') " deoplete: vim completion framework {{{3

""call minpac#add('roryokane/detectindent') " detectindent: detect indent settings in vim {{{3

""call minpac#add('vim-scripts/DrawIt') " DrawIt: ASCII drawing plugin {{{3

""call minpac#add('Shougo/echodoc.vim') " echodoc.vim: Print documents in echo area {{{3

""call minpac#add('editorconfig/editorconfig-vim') " editorconfig-vim: EditorConfig plugin for Vim {{{3

""call minpac#add('ii14/exrc.vim') " exrc.vim: project vimrc {{{3

""call minpac#add('skywind3000/gutentags_plus') " gutentags_plus: vim_tags {{{3

""call minpac#add('junegunn/gv.vim') " gv.vim: Git commit browser {{{3

""call minpac#add('lervag/lists.vim') " lists.vim: A Vim plugin to handle lists {{{3

""call minpac#add('SidOfc/mkdx') " mkdx: A vim plugin that adds some nice extras for working with markdown documents {{{3

""call minpac#add('bennyyip/plugpac.vim') " plugpac.vim: Thin wrapper of minpac, provides vim-plug-like experience {{{3

""call minpac#add('sotte/presenting.vim') " presenting.vim: A simple tool for presenting slides in vim based on text files {{{3

""call minpac#add('unblevable/quick-scope') " quick-scope: Lightning fast left-right movement in Vim {{{3

""call minpac#add('Ron89/thesaurus_query.vim') " thesaurus-query: Multi-language Thesaurus Query and Replacement plugin {{{3

""call minpac#add('sirver/UltiSnips') " UltiSnips: vim snippets {{{3

""call minpac#add('mbbill/undotree') " undotree: The undo history visualizer for VIM {{{3

""call minpac#add('vifm/vifm.vim') " vifm.vifm: use vim as a file picker {{{3

""call minpac#add('pseewald/vim-anyfold') " vim-anyfold: Langague agnostic vim plugin for folding and motion based on indentation {{{3

""call minpac#add('tpope/vim-apathy') " vim-apathy: Set the 'path' option for miscellaneous file types {{{3

""call minpac#add('jenterkin/vim-autosource') " vim-autosource: project vimrc {{{3

""call minpac#add('bagrat/vim-buffet') " vim-buffet: IDE-like Vim tabline  {{{3

""call minpac#add('altercation/vim-colors-solarized') " vim-colors-solarized: Solarized colorscheme {{{3

""call minpac#add('romainl/vim-cool') " vim-cool: A very simple plugin that makes hlsearch more useful {{{3

""call minpac#add('ryanoasis/vim-devicons') " vim-devicons: NERDTree icons {{{3

""call minpac#add('rhysd/vim-grammarous') " vim-grammarous: vim grammar checker {{{3

""call minpac#add(ludovicchabant/vim-gutentags') " vim-gutentags: vim tags {{{3

""call minpac#add('RRethy/vim-hexokinase') " vim-hexokinase: Display colors in the file {{{3

""call minpac#add('euclio/vim-markdown-composer') " vim-markdown-composer: Asynchronous markdown preview {{{3

""call minpac#add('lifepillar/vim-mucomplete') " vim-mucomplete: Chained completion that works the way you want! {{{3

""call minpac#add('simnalamburt/vim-mundo') " vim-mundo: Vim undo tree visualizer {{{3

""call minpac#add('tpope/vim-obsession') " vim-obsession: Continuously updated session files {{{3

""call minpac#add('sickill/vim-pasta') " vim-pasta: Pasting in Vim with indentation adjusted to destination context {{{3

""call minpac#add('preservim/vim-pencil') " vim-pencil: Rethinking Vim as a tool for writing {{{3

""call minpac#add('tpope/vim-projectionist') " vim-projectionist: Granular project configuration {{{3

""call minpac#add('romainl/vim-qf') " vim-qf: Tame the quickfix window {{{3

""call minpac#add('airblade/vim-rooter') " vim-rooter: Change working directory to project root {{{3

""call minpac#add('tpope/vim-speeddating') " vim-speeddating: use CTRL-A/CTRL-X to increment dates, times and more {{{3

""call minpac#add('christoomey/vim-system-copy') " vim-system-copy: Vim plugin for copying to the system clipboard with text-objects and motions {{{3

""call minpac#add('kana/vim-textobj-entire') " vim-textobj-entire: Text objects for entire buffer {{{3

""call minpac#add('kana/vim-textobj-line') " vim-textobj-line: Text objects for the current line {{{3

""call minpac#add('tpope/vim-unimpaired') " vim-unimpaired: Pairs of handy bracket mappings {{{3

""call minpac#add('tpope/vim-vinegar') " vim-vinegar: Combine with netrw to create a delicious salad dressing {{{3

""call minpac#add('fcpg/vim-waikiki') " vim-waikiki: Vim minimal wiki {{{3

""call minpac#add('chaoren/vim-wordmotion') " vim-wordmotion: More useful word motions for vim {{{3

""call minpac#add('jreybert/vimagit') " vimagit: Ease your git workflow within Vim {{{3

""call minpac#add('LucHermitte/VimFold4C') " VimFold4C: Vim folding ftplugin for C & C++ (and similar languages) {{{3

""call minpac#add('vimoutliner/vimoutline') " vimoutline: Work fast, think well {{{3

""call minpac#add('vimwiki/vimwiki') " vimwiki: Personal Wiki for Vim {{{3

""call minpac#add('sysid/vimwiki-nirvana') " vimwiki-nirvana: vimwiki custom link handler {{{3

""call minpac#add('preservim/vim-lexical') " vim-lexical: Build on Vim's spell/thes/dict completion {{{3

