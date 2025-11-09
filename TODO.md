# cron

- test that all jobs are running, including the ones anacron should handle
- Reminder to update vim plugins
- install at (at daemon)

# rclone

- Need to run cloudsync.sh with --first-sync the first time it runs

# Vim

- last known cursor position thing might not work with fugitive commit window
- tagbar markdown support won't work with current dynamic loading method
- clientserver might cause an error
- replace tmux-pilot with tmux-navigator?

## Vim plugins to try: {{{

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

}}}


# slrn

- see $SLRNHELP and art_help_line
- define macro_directory (% set macro_directory "~/.slrn")

# dotfiles

- once XDG_CONFIG_HOME=~/etc, replace ~/etc in all files with $XDG_CONFIG_HOME
- Look into replicating /etc/profile.d - ansible could create either system or personal scripts
- Put all color related stuff in a single file so I can swap colorschemes easily
- How to get keypair passphrase loaded (checkmail doesn't run without it)
- Setup proper logging and logrotation for systemd timers
- Add podboat config to newsboat
- Work nerd-fonts icons into various things (with fallback if not available)

# scripts

- Properly use the git repos for the single scripts that don't have an install method
- should anything be it's own repo?

# Mail

- Filtering
- Keybindings
- old settings:
  unset mark_old    # Unread messages are still "new"
  set reverse_realname = no # Always use realname
  old: set query_command = "abook --mutt-query '%s'"
  source ~/.mutt/headers          # Source header ignores
  source ~/.mutt/keys             # Key configuration
  source ~/.mutt/aliases          # Source aliases
  source ~/.mutt/address_book     # Source address book
- mutt/accounts/local: set hostname = "HOSTNAME"

# bootstrap

- Add a better custom installation framework
- Backup files to a directory instead of renaming (easier to delete/recover)
- Create GPG keypair and additional keys (password vault, etc)
- Fix the git_template hack
- Properly install packages from newer versions of Ubuntu
- Script setup of dropbox links
- put firefox stuff in a standard directory that is easy to link to
- Add ability to run arbitrary code
- Improve bootstrap.ini syntax
- Create the corrct XDG directories and delete the original ones

