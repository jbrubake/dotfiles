#!/bin/bash
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "$HOME/.shinit" # common interactive shell configuration

have() { command -v "$1" >/dev/null; }

# Shell options {{{
shopt -s  cdspell      # Fix spelling errors in cd commands
shopt -s  extglob      # Advanced pathname expansion
shopt -s  histappend   # Append to HISTFIL on exit - don't clobber it
shopt -s  lithist      # Preserve newlines in history
shopt -s  checkwinsize # Update LINES/COLUMNS after each command
shopt -s  cmdhist      # Try to save multiline commands as one history entry
shopt -s  histverify   # Allow verification of history substitution
shopt -s  no_empty_cmd_completion # Don't TAB complete a blank line
shopt -so ignoreeof    # Ctl+D does not exit shell
# }}}
# Keybindings {{{
# fzf {{{
if have fzf; then
    for f in /usr/share/fzf/shell/*.bash /usr/local/share/fzf/shell/*.bash; do
        [ -f "$f" ] && . "$f"
    done

    # Override __fzfcmd because it uses fzf-tmux whenever FZF_TMUX_OPTS is set
    # *even* if FZF_TMUX is *not* set
    __fzfcmd() {
        [[ -n "${TMUX_PANE-}" ]] && [[ "${FZF_TMUX:-0}" != 0 ]] &&
            echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
    }
fi
# }}}
have passmenu &&
    bind -x '"\C-]": passmenu --type'
have navi &&
    bind -x '"\C-g": _navi_widget'
# }}}
# Bash Completion {{{
# System settings
if ! shopt -oq posix; then
    if [ -f /etc/profile.d/bash-completion.sh ]; then
        . /etc/profile.d/bash-completion.sh
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    fi
fi

# System local settings (deprecated location)
_backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
for dir in /usr/local/share/bash_completion.d /usr/local/etc/bash_completion.d; do
    if [[ -d $dir && -r $dir && -x $dir ]]; then
        for i in "$dir"/*; do
            [[ ${i##*/} != @($_backup_glob|Makefile*) && -f \
                $i && -r $i ]] && . "$i"
        done
    fi
done
unset dir i _backup_glob

# Allow todo.sh alias to use bash completion
    have todo.sh &&
    complete -F _todo t

# gcloud
[ -f /opt/google-cloud-sdk/completion.bash.inc ] &&
    . /opt/google-cloud-sdk/completion.bash.inc

# fzf completion
if test -f /usr/local/share/fzf/completion.bash; then
    . /usr/local/share/fzf/completion.bash
fi

# terraform / opentofu
    have terraform &&
        complete -C $(have terraform) terraform
    have tofu &&
        complete -C $(have tofu) tofu
# }}}

# vim: foldlevel=0

