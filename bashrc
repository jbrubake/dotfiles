#!/bin/bash
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "$HOME/.shinit" # common interactive shell configuration

# Shell options {{{
shopt -s  cdspell      # Fix spelling errors in cd commands
shopt -s  extglob      # Advanced pathname expansion
shopt -s  histappend   # Append to HISTFIL on exit - don't clobber it
shopt -s  checkwinsize # Update LINES/COLUMNS after each command
shopt -s  cmdhist      # Try to save multiline commands as one history entry
shopt -s  histverify   # Allow verification of history substitution
shopt -s  no_empty_cmd_completion # Don't TAB complete a blank line
shopt -so ignoreeof    # Ctl+D does not exit shell
# }}}
# Keybindings {{{
# fzf
test -f /usr/share/fzf/shell/key-bindings.bash && \
    . /usr/share/fzf/shell/key-bindings.bash
test -f /usr/local/share/fzf/key-bindings.bash && \
    . /usr/local/share/fzf/key-bindings.bash
command -v passmenu >/dev/null &&
    bind -x '"\C-]": passmenu --type'
command -v navi >/dev/null &&
    bind -x '"\C-g": _navi_widget'
# }}}
# Bash Completion {{{
# System settings
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /etc/profile.d/bash-completion.sh ]; then
        . /etc/profile.d/bash-completion.sh
    fi
fi

# System local settings
for f in /usr/local/etc/bash_completion.d/*; do
    if test -e "$f"; then
        . "$f"
    fi
done
unset f

# Personal settings
for f in ~/share/bash_completion.d/*; do
    if test -e "$f"; then
        . "$f"
    fi
done
unset f

# Allow todo.sh alias to use bash completion
command -v todo.sh >/dev/null &&
    complete -F _todo t

# fzf completion
if test -f /usr/local/share/fzf/completion.bash; then
    . /usr/local/share/fzf/completion.bash
fi
# Hostnames for bash-completion
if [[ -z $HOSTFILE && -r "$HOME/.ssh/known_hosts" ]]; then
    HOSTFILE="$HOME/.hosts"
fi
# }}}
# vim: foldlevel=0
