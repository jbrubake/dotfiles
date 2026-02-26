#!/bin/bash
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "${SSHRC:-"$HOME"}/.shinit" # common interactive shell configuration

have() { command -v "$1" >/dev/null; }

# Shell options {{{1
#
shopt -s  cdspell      # Fix spelling errors in cd commands
shopt -s  extglob      # Advanced pathname expansion
shopt -s  histappend   # Append to HISTFIL on exit - don't clobber it
shopt -s  lithist      # Preserve newlines in history
shopt -s  checkwinsize # Update LINES/COLUMNS after each command
shopt -s  cmdhist      # Try to save multiline commands as one history entry
shopt -s  histverify   # Allow verification of history substitution
shopt -s  no_empty_cmd_completion # Don't TAB complete a blank line
shopt -so ignoreeof    # Ctl+D does not exit shell

# Keybindings {{{1
#
# fzf {{{2
#
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

have passmenu &&
    bind -x '"\C-]": passmenu --type'
have navi &&
    bind -x '"\C-g": _navi_widget'

# Bash Completion {{{1
#
if shopt -q progcomp; then
    # Load bash completion if necessary (it is not loaded when logging into X) {{{2
    if [ -z "${BASH_COMPLETION_VERSINFO}" ]; then
        # Load Bash completion framework
        [ -r /usr/share/bash-completion/bash_completion ] &&
            . /usr/share/bash-completion/bash_completion

        # Redefine have() because the Bash completion script unsets it
        # Seriously? WTF?
        type have >/dev/null 2>&1 ||
            have() { command -v "$1" >/dev/null; }
    fi

    # Load local and deprecated completion directories {{{2
    #
    # Basic structure ripped from /usr/share/bash-completion/bash_completion
    #
    _backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
    for d in \
        /etc/bash_completion.d \
        /usr/share/bash_completion.d \
        /usr/local/etc/bash_completion.d \
        /usr/local/share/bash_completion.d \
        /usr/local/share/bash-completion/completions \
        "${BASH_COMPLETION_USER_DIR:-"$XDG_DATA_HOME/bash-completion"}" \
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

    # Load and configure other completions {{{2
    #
    # Use the completion specs defined for $cmd for $my_cmd
    #
    # From a Stackoverflow answer by Philippe Carphin
    #   (https://stackoverflow.com/a/79371508)
    # License - CC BY-SA 4.0
    #
    use_same_completion_spec(){
        local cmd=$1
        local my_cmd=$2

        if ! _comp_load "$cmd" ; then
            printf '_comp_load failed to load completion for "%s"\n' "$cmd" >&2
            return 1
        fi

        spec="$(complete -p "$cmd")"
        if [ -z "$spec" ]; then
            printf 'Error getting completion specification for "%s"\n' "$cmd" >&2
            return 1
        fi

        $spec $my_cmd
    }

    # terraform / tofu
    have terraform && complete -C "$(command -v terraform)" terraform
    have tofu      && complete -C "$(command -v tofu)" tofu

    # todo.sh
    # (todo_alias is set in ~/.alias)
    if have todo.sh && [ -n "$todo_alias" ]; then
        complete -F _todo "$todo_alias"
        unset todo_alias
    fi

    # gcloud
    [ -f /opt/google-cloud-sdk/completion.bash.inc ] &&
        . /opt/google-cloud-sdk/completion.bash.inc

    # Prefer personal cargo over system cargo
    for d in "$HOME" ''; do
        if [ -f "$d/opt/rust/etc/bash_completion.d/cargo" ]; then
            . "$d/opt/rust/etc/bash_completion.d/cargo"
            break
        fi
    done

    # sshrc
    have sshrc && use_same_completion_spec ssh sshrc

    unset use_same_completion_spec
fi

# Cleanup {{{1
#
unset have

# vim: foldlevel=0

