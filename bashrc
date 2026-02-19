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

# Bash completion is not automatically loaded on X login
if [ "${BASH_COMPLETION_VERSINFO-}" = '' ]; then
    # Load Bash completion framework
    if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    fi

    # Redefine have() because the Bash completion script unsets it
    # Seriously? WTF?
    have() { command -v "$1" >/dev/null; }
fi

# Load local and deprecated completion directories
#
# Basic structure ripped from /usr/share/bash-completion/bash_completion
#
if shopt -q progcomp; then
    _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
    for d in \
        /etc/bash_completion.d \
        /usr/share/bash_completion.d \
        /usr/local/etc/bash_completion.d \
        /usr/local/share/bash_completion.d \
        /usr/local/share/bash-completion/completions \
    ; do
        if [[ -d $d && -r $d && -x $d ]]; then
            for i in "$d"/*; do
                [[ ${i##*/} != @($_backup_glob|Makefile*) && -f \
                    $i && -r $i ]] && . "$i"
            done
            unset i
        fi
    done
    unset d _backup_glob

    # terraform / tofu
    have terraform && complete -C "$(command -v terraform)" terraform
    have tofu      && complete -C "$(command -v tofu)" tofu

    # todo.sh
    if have todo.sh && [ -n "$todo_alias" ]; then
        complete -F _todo "$todo_alias"
        unset todo_alias
    fi

    # gcloud
    [ -f /opt/google-cloud-sdk/completion.bash.inc ] &&
        . /opt/google-cloud-sdk/completion.bash.inc

    # Prefer personal cargo over system cargo
    for d in '' "$HOME"; do
        [ -f "$d/opt/rust/etc/bash_completion.d/cargo" ] &&
            . "$d/opt/rust/etc/bash_completion.d/cargo"
    done

fi

# }}}
# Cleanup {{{1
#
unset have

# vim: foldlevel=0

