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
