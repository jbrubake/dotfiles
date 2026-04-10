# dotfiles

- Change `XDG_CONFIG_HOME` to `~/etc`
- Consider replicating `/etc/profile.d`
- Configure logging and logrotation for systemd timers
- Add `podboat` configuration to `newsboat`
- Work nerd-fonts icons into various configurations (with a fallback, if not available)

## Installation

- Backup files to a directory instead of renaming them (easier to delete/recover)
- put Firefox configuration in a standard directory that the user can manually
    link to

## Colors

- Put color related configuration in a single file to simplify managing colorschemes
- Match `mutt` and `slrn` colors:

### Mutt Color Configuration

```
color   object foreground background [regexp]
color   index  foreground background pattern
uncolor index  pattern [pattern ...]
```

`object` can be:

Value                        | Use
-----                        | ---
attachment                   |
body                         | match regexp
bold                         | bold patterns
error                        | error messages
header                       | match regexp
hdrdefault                   | default header color
index                        | match pattern
indicator                    | current menu item indicator
markers                      | '+' markers for wrapped lines
message                      | info messages
normal                       |
quoted                       |
quoted1, quoted2,...,quotedN |
search                       | hilites in pager
signature                    |
status                       | mode lines
tilde                        | '~' for blank lines in pager
tree                         | thread tree
underline                    | underline patterns

`foreground` and `background` can be:
- white
- black
- green
- magenta
- blue
- cyan
- yellow
- red
- default

`foreground` can be prefixed with `bright` to make bold

### Slrn Color Configuration

```
color display_element foreground background [attributes]
```

`display_element` can be:

Value           | Use
-----           | ---
article         |
author          | author name/email in header overview
boldtext        |
box             | text in selection boxes, like when choosing sort mode
cursor          | in group and header overview
date            | in header overview
description     | group descriptions
error           |
frame           | frame around selection boxes
from_myself     | From: if it contains your name
group           | group names in group window
header_name     | From:, To:, etc
header_number   | header number in header overview
headers         | header content
high_score      | '!' used to mark high scoring articles
italicstext     |
menu            | first line of display
menu_press      | a menu item when you click on it
message         | messages/prompts at bottom of screen
neg_score       | subject/score of negative score articles
normal          | everything else
pos_score       | subject/score of positive score articles
pgpsignature    |
quotes          |
quotes0-quotes7 |
response_char   | highlighted char in selections
selection       | cursor in selection boxes
signature       |
status          |
subject         | in header overview
thread_number   | number of articles in thread
tilde           | '~' at end of article
tree            | thread tree
underlinetext   |
unread_subject  |
url             |
verbatim        |

`foreground` and `background` can be:

Base Color | Bright Color
---------- | ------------
black      | gray
red        | brightred
green      | brightgreen
brown      | yellow
blue       | brightblue
magenta    | brightmagenta
cyan       | brightcyan
lightgray  | white
default    | default

`attributes` can be:
- bold
- blink
- underline
- reverse

## cron

- Test `cron` jobs are running, including `anacron` jobs
- Add a job to update `vim` plugins and `python` packages

## mutt

- Add `gpgme` configuration

## slrn

- document my configuration (see `$SLRNHELP` and `art_help_line`)
- define `macro_directory`

# scripts

- Properly use the git repos for the single scripts that don't have an install method
- should anything be it's own repo?

# Vim

- Test the `last_position` function in `vim-fugitive` and `git` commit windows
- Consider replacing `tmux-pilot` with `tmux-navigator`

## Vim Plugins to Test:

- auto_mkdir2: Automatically create directory tree for new files (arp242/auto_mkdir2.vim
```vim
" Only make tree in wiki
let g:auto_mkdir2_autocmd = '$WIKI_DIR/content/**'
```
- DrawIt: ASCII drawing plugin (vim-scripts/DrawIt)
- UltiSnips: vim snippets (sirver/UltiSnips)
- VimFold4C: Vim folding ftplugin for C & C++ (and similar languages) (LucHermitte/VimFold4C)
- cheat.sh-vim: A vim plugin to access cheat.sh sheets (dbeniamine/cheat.sh-vim)
- coc-snippets: snippets for coc (neoclide/coc-snippets)
- conque-gdb: integrate gdb with vim (vim-scripts/Conque-GDB)
- deoplete: vim completion framework (Shougo/deoplete.nvim)
- detectindent: detect indent settings in vim (roryokane/detectindent)
- echodoc.vim: Print documents in echo area (Shougo/echodoc.vim)
- editorconfig-vim: EditorConfig plugin for Vim (editorconfig/editorconfig-vim)
- exrc.vim: project vimrc (ii14/exrc.vim)
- gundo: Graph your Vim undo tree in style (sjl/gundo.vim)
- gutentags_plus: vim_tags (skywind3000/gutentags_plus)
- gv.vim: Git commit browser (junegunn/gv.vim)
- lists.vim: A Vim plugin to handle lists (lervag/lists.vim)
- mkdx: A vim plugin that adds some nice extras for working with markdown documents (SidOfc/mkdx)
- nerdtree: A tree explorer plugin for vim (preservim/nerdtree
```vim
" <F10> : Toggle file tree browser
noremap <silent> <F8> :NERDTreeToggle<cr>

" Close Vim if last window open is NERDTree
autocmd bufenter * if (winnr("$") == 1 &&
    \ exists("b:NERDTree") &&
    \ b:NERDTree.isTabTree()) | q |
    \ endif
```
- nerdtree-git-plugin: A plugin of NERDTree showing git status (Xuyuanp/nerdtree-git-plugin
```vim
" Custom indicators
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Ignored"   : "☒",
    \ "Unknown"   : "?"
    \ }

" NOTE: See 'Colors and Syntax Settings' for more
```
- plugpac.vim: Thin wrapper of minpac, provides vim-plug-like experience (bennyyip/plugpac.vim)
- presenting.vim: A simple tool for presenting slides in vim based on text files (sotte/presenting.vim)
- quick-scope: Lightning fast left-right movement in Vim (unblevable/quick-scope)
- rainbow: Rainbow Parentheses Improved (luochen1990/rainbow)
- scratch: Unobtrusive scratch window (mtth/scratch.vim)
- SimplyFold: No-BS Python code folding (tmhedberg/SimpylFold
- thesaurus-query: Multi-language Thesaurus Query and Replacement plugin (Ron89/thesaurus_query.vim)
- undotree: The undo history visualizer for VIM (mbbill/undotree)
- vifm.vifm: use vim as a file picker (vifm/vifm.vim)
- vim-anyfold: Langague agnostic vim plugin for folding and motion based on indentation (pseewald/vim-anyfold)
- vim-apathy: Set the 'path' option for miscellaneous file types (tpope/vim-apathy)
- vim-autoformat:  Provide easy code formatting in Vim by integrating existing code formatters (vim-autoformat/vim-autoformat
- vim-autosource: project vimrc (jenterkin/vim-autosource)
- vim-buffet: IDE-like Vim tabline (bagrat/vim-buffet)
- vim-colors-solarized: Solarized colorscheme (altercation/vim-colors-solarized)
- vim-cool: A very simple plugin that makes hlsearch more useful (romainl/vim-cool)
- vim-devicons: NERDTree icons (ryanoasis/vim-devicons)
- vim-grammarous: vim grammar checker (rhysd/vim-grammarous)
- vim-gutentags: vim tags (ludovicchabant/vim-gutentags)
- vim-hexokinase: Display colors in the file (RRethy/vim-hexokinase)
- vim-IndentCommentPrefix: Indents comments sensibly (inkarkat/vim-IndentCommentPrefix
```vim
" >>  : Indent, keeping comment prefix where it is
" <<  : Deindent, keeping comment prefix where it is
" g>> : Indent, including comment prefix

" Use single > or < in Visual mode

" Comment chars in this list will *not* be left in column 1
let g:IndentCommentPrefix_Blacklist = ['#', '>']

" Any string in this list *will* remain in column 1
let g:IndentCommentPrefix_Whitelist = ['REMARK:']
```
- vim-ingo-library: library functions required by IndentCommentPrefix (inkarkat/vim-ingo-library
- vim-lexical: Build on Vim's spell/thes/dict completion (preservim/vim-lexical)
- vim-markdown-composer: Asynchronous markdown preview (euclio/vim-markdown-composer)
- vim-markdown-folding: Fold Markdown files on headers (masukomi/vim-markdown-folding', {'type': 'opt'})
```vim
autocmd load_plugins FileType markdown packadd vim-markdown-folding
```
- vim-mucomplete: Chained completion that works the way you want!  (lifepillar/vim-mucomplete)
- vim-mundo: Vim undo tree visualizer (simnalamburt/vim-mundo)
- vim-obsession: Continuously updated session files (tpope/vim-obsession)
- vim-pasta: Pasting in Vim with indentation adjusted to destination context (sickill/vim-pasta)
- vim-pencil: Rethinking Vim as a tool for writing (preservim/vim-pencil)
- vim-projectionist: Granular project configuration (tpope/vim-projectionist)
- vim-qf: Tame the quickfix window (romainl/vim-qf)
- vim-rooter: Change working directory to project root (airblade/vim-rooter)
- vim-slime: A vim plugin to give you some slime (jpalardy/vim-slime)
- vim-speeddating: use CTRL-A/CTRL-X to increment dates, times and more (tpope/vim-speeddating)
- vim-system-copy: Vim plugin for copying to the system clipboard with text-objects and motions (christoomey/vim-system-copy)
- vim-textobj-entire: Text objects for entire buffer (kana/vim-textobj-entire)
- vim-textobj-line: Text objects for the current line (kana/vim-textobj-line)
- vim-unimpaired: Pairs of handy bracket mappings (tpope/vim-unimpaired)
- vim-vinegar: Combine with netrw to create a delicious salad dressing (tpope/vim-vinegar)
- vim-waikiki: Vim minimal wiki (fcpg/vim-waikiki)
- vim-wordmotion: More useful word motions for vim (chaoren/vim-wordmotion)
- vimagit: Ease your git workflow within Vim (jreybert/vimagit)
- vimoutline: Work fast, think well (vimoutliner/vimoutline)
- vimwiki-nirvana: vimwiki custom link handler (sysid/vimwiki-nirvana)
- vimwiki: Personal Wiki for Vim (vimwiki/vimwiki)

