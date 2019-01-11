#!/bin/bash vim: foldlevel=0
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "$HOME/.functions"
source "$HOME/.alias" # Aliases might depend on functions

# Setup PATH {{{

# FIXME: This is here so the necessary functions are already sourced

# Put /usr/local/bin in PATH
PATH="/usr/local/bin:$PATH"

# Put ~/bin in PATH if it exists
test -d "$HOME/bin" &&
    PATH="$HOME/bin:$PATH"

PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

# }}}
# Shell options {{{
shopt -s cdspell      # Fix spelling errors in cd commands
shopt -s extglob      # Advanced pathname expansion
shopt -s histappend   # Append to HISTFIL on exit - don't clobber it
shopt -s checkwinsize # Update LINES/COLUMNS after each command
shopt -s cmdhist      # Try to save multiline commands as one history
                      # entry
shopt -s histverify   # Allow verification of history substitution
shopt -s no_empty_cmd_completion # Don't TAB complete a blank line

set   +o ignoreeof    # Ctl+D does not exit shell
# }}}
# Prompts {{{
# Determine if terminal supports color
#
test $( tput colors ) -ge 0 && HAS_COLOR=yes

# Put code for my current prompt here
#
# Additional prompts can be found in ~/.prompts
# TODO: Probably want to eventually source that file
#       and set a variable to select the prompt I want
# TODO: Add bg jobs
# TODO: Add git info

# Screen auto-title escape
#
#screen_esc="\[\033k\033\134\]"

#############################################
# This prompt looks roughly like this:
#
# 'pwd'
# '<username@hostname> [command number] [$?]'
# '$ '
#############################################

# Prompt color definitions
#
if test $HAS_COLOR; then
    dir_color='\[$(FG 2)\]'
    slash_color='\[$(FG 1)\]'
    hostname_color='\[$(FG 5)\]'
    at_color='\[$(FG 4)\]'
    bracket_color='\[$(FG 4)\]'
    history_color='\[$(FG 2)\]'
    error_color='\[$(FG 7; BG 1)\]'
    prompt_color='\[$(FG 3)\]'
    user_color='\[$(FG 6)\]'
    root_user_color='\[$(FG 1)\]'
else
    dir_color=
    slash_color=
    hostname_color=
    at_color=
    bracket_color=
    history_color=
    error_color=
    prompt_color=
    user_color=
    root_user_color=
fi

reset='\[$(FX reset)\]'

# Colorize username differently if we are root
[ $UID == '0' ] && user_color=$root_user_color

#
# NEW_PWD and PS1_ERROR modified from Yu-Jie Lin's example <libb.wordpress.com>
#

# Print pwd with ~ and highlighted /'s
NEW_PWD='$(
           pwd | sed 's@^@$dir_color@' | sed 's@$HOME@~@' | sed 's@/@$slash_color/$dir_color@g'
          )'
# Output $? if it is non-zero
#
PS1_ERROR='$(
    if [ $RETVAL -gt 0 ]; then (( i = 3 - ${#RETVAL} ));
        echo -n "'"$error_color"'[";
        [ $i -gt 0 ] && echo -n " ";
        echo -n "$RETVAL";
        [ $i -eq 2 ] && echo -n " ";
        echo -n "']"$reset"'";
    fi
    )'

PS1="$reset$NEW_PWD\n$bracket_color<$user_color\u$at_color@$hostname_color\h$bracket_color> $bracket_color[$history_color\!$bracket_color] $PS1_ERROR\n$prompt_color$ $reset"

# Need to save $? here so that PS1_ERROR can occur anywhere in the prompt
# Otherwise, NEW_PWD will clobber the value of $? that we want
PROMPT_COMMAND='RETVAL=$?;'

unset dir_color slash_color hostname_color at_color bracket_color
unset history_color error_color prompt_color user_color root_user_color
unset reset
unset screen_esc 
unset NEW_PWD PS1_ERROR
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

# Personal settings
for f in ~/share/bash_completion.d/*; do
    . $f
done

# Allow todo.sh alias to use bash completion
complete -F _todo t

# Hostnames for bash-completion
if [[ -z $HOSTFILE && -r "$HOME/.ssh/known_hosts" ]]; then
    HOSTFILE="$HOME/.ssh/known_hosts"
fi
# }}}

