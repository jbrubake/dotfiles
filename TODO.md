- Put all color related stuff in a single file so I can swap colorschemes easily
- Create GPG keypair and additional keys (password vault, etc)
- How to get keypair passphrase loaded (checkmail doesn't run without it)
- Fix the git_template hack
- Work nerd-fonts icons into various things (with fallback if not available)
- Properly install packages from newer versions of Ubuntu
- Setup proper logging and logrotation for systemd timers
- Script setup of dropbox links
## bootstrap
- Add ability to run arbitrary code
- Improve bootstrap.ini syntax
## dotfiles
- Add a better custom installation framework
- Backup files to a directory instead of renaming (easier to delete/recover)
- Properly use the git repos for the single scripts that don't have an install method
- Make files robust: only config if command/plugin installed
- Change structure
    - symlink: do what i'm doing now
    - copy: copy folder contents (this will allow putting share/bash-completion.d here)
    - other: git submodules
## muttrc
- Filtering
- Keybindings
## vimrc
- Add vimpager specific configuration to vimrc or use a vimpagerrc
- Figure out how to keep plugins updated
- Automate plugin helptags
- Implement calendar-vim hooks using vimwiki
- mapping to generate ctags or just start using make from vim
- wiki mappings don't work right if pwd isn't changed to wiki root

