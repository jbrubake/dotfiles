#!/bin/bash vim: foldlevel=0
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# Setup {{{

# Source additional files
#
for file in /etc/bashrc /etc/bash.bashrc ; do
    test -r "$file" && 
          . "$file"
done;

# }}}

# Functions {{{

# Color Escape Functions {{{

###################################################
# Functions to set colors and attributes
#
#  ${FX bold} sets bold attribute
#  ${FG 1} sets foreground color to '31'
#  ${BG 1} sets background color to '41'
#  $(FX bold; FG 1) sets foreground color to '31'
#      and bold in one command
#
# These functions automatically interpret escape
# sequences so you don't need to pass '-e' to echo
#
# Based on P. C. SHyamshankar's spectrum script
# for zsh <github.com/sykora>. Changed to use
# functions instead of hashes since it's quicker
###################################################
# TODO: Find a way to alter functions and calls based on
# TODO: if terminal supports 256 colors
function FX()
{
    case "$1" in
        reset)       echo -en "\e[00m" ;;
        bold)        echo -en "\e[01m" ;;
        nobold)      echo -en "\e[22m" ;;
        italic)      echo -en "\e[03m" ;;
        noitalic)    echo -en "\e[23m" ;;
        underline)   echo -en "\e[04m" ;;
        nounderline) echo -en "\e[24m" ;;
        blink)       echo -en "\e[05m" ;;
        noblink)     echo -en "\e[25m" ;;
        reverse)     echo -en "\e[07m" ;;
        noreverse)   echo -en "\e[27m" ;;
        *) echo "";
    esac
}

function FG() {
    echo -en "\e[3$1m"
}

function BG()
{
    echo -en "\e[4$1m"
}

# }}}

# Miscellaneous Functions {{{

####
# ruler
#
# Print a ruler the width of the terminal
####
function ruler()
{
    # TODO: Make this colorized
    for s in "....^....|" '1234567890'; do
        w=${#s}
        str=$( for (( i=1; $i<=$(( ($COLUMNS + $w) / $w )) ; i=$i+1 )); do echo -en $s; done )
        str=$(echo -e $str | cut -c -$COLUMNS)
        echo -e $str
    done;
}

####
# google
#
# Google something
#
# Expects: a google search string, just like
#          you would enter it at the website
####
function google ()
{
    unset url

    # Create search string if arguments were passed
    if [[ "$*" ]]; then
        # Google search strings replace spaces with '+'
        IFS='+'
        SEARCH_STRING="$*"
        unset IFS

        url="search?hl=en&lr=&ie=UTF-8&oe=UTF-8&q="
        url="$url$SEARCH_STRING&btnG=Google+Search"
    fi

    # Open URL in browser. If no arguments were passed
    # it merely opens google.com
    openurl "www.google.com/$url"

    unset url
}

####
# define
#
# Define words and phrases with google
####
function define()
{
    local y="$@"
    curl -sA"Opera" "http://www.google.com/search?q=define:${y// /+}"|grep -Eo '<li>[^<]+'|sed 's/^<li>//g'|nl|/usr/bin/perl -MHTML::Entities -pe 'decode_entities($_)'
}

function rtfm()
{
    man "$@" || [[ -f "/usr/share/info/$@.info*" ]] && info "$@" ||
        echo "No info entry for $@" >/dev/stderr && "$@" --help ||
        openurl BROWSER "http://duckduckgo.com/?q=%21man+$@" ;
}

####
# hb/hc
# Blinking, Color Highlighted search for input/output
# and files, like grep --color
#hb blinks, hc does a reverse color with background.. both very nice.
#Run this:
#
#command ps -Hacl -F S -A f | hc ".*$PPID.*" | hb ".*$$.*"
####
function hb()
{
    sed "s/\($*\)/`tput setaf 2;tput setab 0;tput blink`\1`tput sgr0`/gI"
}

function hc()
{
    sed "s/\($*\)/`tput setaf 0;tput setab 6`\1`tput sgr0`/gI"
}

# }}}

# Helper Functions {{{
# (prefix names with '__')

##
# __git_ps1
# Print out the name of the current git branch of pwd
__git_ps1 ()
{
    local b="$(git symbolic-ref HEAD 2>/dev/null)";
    if [ -n "$b" ]; then
        printf " (%s)" "${b##refs/heads/}";
    fi
}

# }}}

# PATH Manipulation Functions {{{

# Usage: pls [<var>]
# List path entries of PATH or environment variable <var>.
pls () {
    eval echo \$${1:-PATH} |tr : '\n';
}

# Usage: puniq [<path>]
# Remove duplicate entries from a PATH style value while retaining
# the original order. Use PATH if no <path> is given.
#
# Example:
#   $ puniq /usr/bin:/usr/local/bin:/usr/bin
#   /usr/bin:/usr/local/bin
puniq () {
    echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
    cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

# }}}

# }}}

# Setup PATH {{{

# Put sbins and /usr/local/bin in PATH
PATH="/usr/local/bin:$PATH:/usr/local/sbin:/usr/sbin:/sbin"

# Put ~/bin in PATH if it exists
test -d "$HOME/bin" &&
    PATH="~/bin:$PATH"

PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

# }}}

# Environment {{{

: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# Always use my .inputrc
if [[ -z $INPUTRC && -r "$HOME/.inputrc" ]]; then
    INPUTRC="$HOME/.inputrc"
fi

# Hostnames for bash-completion
if [[ -z $HOSTFILE && -r "$HOME/.ssh/known_hosts" ]]; then
    HOSTFILE="$HOME/.ssh/known_hosts"
fi

# Locale settings default to en_US with utf-8 unless
# already set
#
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# Filename completion ignores backups and vim swap files
#
FIGNORE="~:.swp"

# History stuff
#
HISTSIZE=20               # Max commands in history
HISTFILESIZE=50           # Max lines in history
HISTCONTROL="ignoredups"  # No duplicate history entries
HISTIGNORE="&:[bf]g:exit" # History ignores these matches

# EDITOR/VISUAL
#
EDITOR=ed
if command -v vim >/dev/null; then
    EDITOR=vim
else
    EDITOR=vi
fi
VISUAL=$EDITOR
export EDITOR VISUAL

# PAGER/MANPAGER
#
if command -v vimpager >/dev/null; then
    PAGER=`command -v vimpager` # Only works with git if I set the whole path
elif command -v less >/dev/null; then
    PAGER=less
else
    PAGER=more
fi
MANPAGER=$PAGER
ACK_PAGER=$PAGER
ACK_PAGER_COLOR=$PAGER
export PAGER MANPAGER ACK_PAGER ACK_PAGER_COLOR

# Development
#
case $(uname -o) in
    Cygwin*)
        LD=gcc #Cygwin won't build without this. Weird
        ;;
esac

if command -v colorgcc >/dev/null; then
    CC=colorgcc
fi

# XXX: Make CFLAGS/CXXFLAGS more portable based on actual architecture
CFLAGS='-O3 -march=pentium4 -Wall -pedantic -ansi'
CXXFLAGS="$CFLAGS"
export CC CFLAGS CXXFLAGS LD

# All my xterm's are actually xterm-256color
# FIXME: How can I tell if my terminal supports 256 colors?
#
if [[ $TERM == "xterm" ]]; then
    TERM="xterm-256color";
fi;

# Setup dircolors using my .dircolors file for 256 colors
# if my terminal supports it
case $TERM in
    *256*) mycolors="$HOME/.dircolors.256" ;;
    *)     mycolors="$HOME/.dircolors" ;;
esac

# Setup dircolors. Use system default configuration
# unless I have my own
#
if command -v dircolors >/dev/null; then
    test -r '/etc/DIR_COLORS' && COLORS='/etc/DIR_COLORS'
    test -r "$mycolors"       && COLORS="$HOME/.dircolors"
    eval $(dircolors -b $COLORS)
fi
unset COLORS mycolors

# Miscellaneous
# FIXME: Make this more robust
#
BROWSER="chrome"
export BROWSER

# }}}

# Shell options {{{

shopt -s cdspell      # Fix spelling errors in cd commands
shopt -s extglob      # Advanced pathname expansion
shopt -s histappend   # Append to HISTFIL on exit - don't clobber it
shopt -s checkwinsize # Update LINES/COLUMNS after each command
shopt -qso ignoreeof  # Don't logout on ^D
shopt -s cmdhist      # Try to save multiline commands as one history
                      # entry
shopt -s histverify   # Allow verification of history substitution
shopt -s no_empty_cmd_completion # Don't TAB complete a blank line

umask 077

# }}}

# Aliases {{{

# My standard ls aliases
#
LS_OPTS='--color=auto --group-directories-first -XF --dereference-command-line-symlink-to-dir'
alias ls="command  ls $LS_OPTS"
alias la="command  ls $LS_OPTS -A"
alias ll="command  ls $LS_OPTS -lh"
alias lal="command ls $LS_OPTS -lhA"
alias l.="command  ls $LS_OPTS -d .*"
unset LS_OPTS

# If my pager is not less, make me think it is
#
test $PAGER != 'less' &&
    alias less="$PAGER"

# Screen automatically reattaches if able
command -v screen >/dev/null &&
    alias screen='screen -dR'

# OS specific aliases
#
case $(uname -o) in
    # Cygwin only
    Cygwin*) 
        # Create a shortcut to chrome
        # XXX: Hardcoded path == bad
        alias chrome='/cygdrive/c/Documents\ and\ Settings/jbrubake/Local\ Settings/Application\ Data/Google/Chrome/Application/chrome.exe &'
        # Use ssh to emulate su(1)
        # TODO: Work out how to emulate 'su command', etc.
        alias su='ssh Administrator@localhost'
        ;;
    # Everything else
    *)
        ;;
esac

# Emulate clear(1) if I don't have it
#
command -v clear >/dev/null ||
    alias clear='echo -en "\e[2J\e[H"'

# Display latest xkcd comic if I have
# feh and w3m available
#
if command -v feh >/dev/null && command -v w3m >/dev/null; then
    alias xkcd='feh `w3m -dump http://xkcd.com/| grep png | awk {print $5}`'
fi

# Fancy fortunes if toilet(1) exists
#
command -v toilet >/dev/null &&
    alias colfortune="fortune | toilet --metal -f term"

# If todo.txt is installed, make it simpler
# to access
command -v todo.sh >/dev/null &&
    alias t=todo.sh

# Miscellaneous
#
alias du='du -h --max-depth=1'  # du(1) prints totals for one level down
alias lh='history | tail -10'   # List last 10 commands
alias df='df -hT'               # Make df output nicer
alias reset='echo -en "\e]R"'   # Reset system palette
alias update_sigfortunes='strfile -r ~/.fortunes/sigfortunes' # XXX: This alias is kinda lame

# }}}

# Prompts {{{

# Put code for my current prompt here
#
# Additional prompts can be found in ~/.prompts
# TODO: Probably want to eventually source that file
#       and set a variable to select the prompt I want

# Screen auto-title escape
#
screen_esc="\[\033k\033\134\]"

#############################################
# This prompt looks roughly like this:
#
# 'pwd'
# '<username@hostname> [command number] [$?]'
# '$ '
#############################################

# Prompt color definitions
#
dir_color='\[$(FG 2)\]'
slash_color='\[$(FG 1)\]'
hostname_color='\[$(FG 5)\]'
at_color='\[$(FG 4)\]'
bracket_color='\[$(FG 4)\]'
history_color='\[$(FG 2)\]'
error_color='\[$(FG 7; BG 1)\]'
prompt_color='\[$(FX bold; FG 3)\]'
reset='\[$(FX reset)\]'
# Colorize username differently if we are root or not
[ $UID == '0' ] && user_color='\[$(FG 1)\]' || user_color='\[$(FG 6)\]'

#
# NEW_PWD and PS1_ERROR modified from Yu-Jie Lin's example <libb.wordpress.com>
#

# Print pwd with ~ and highlighted /'s
NEW_PWD='$(
           pwd | sed 's/^/$dir_color/' | sed 's@$HOME@~@' | sed 's@/@$slash_color/$dir_color@g'
          )'

# Output $? if it is non-zero
#
PS1_ERROR='$(
    if [ $RETVAL -gt 0 ]; then (( i = 3 - ${#RETVAL} ));
        echo -n "'"$error_color"'[";
        [ $i -gt 0 ] && echo -n " ";
        echo -n "$RETVAL";
        [ $i -eq 2 ] && echo -n " ";
        echo -n "]"'"$reset"'" ";
    fi
    )'

PS1="$reset$NEW_PWD\n$bracket_color<$user_color\u$at_color@$hostname_color\h$bracket_color> $bracket_color[$history_color\!$bracket_color] $PS1_ERROR\n$prompt_color $ $reset"

# Need to save $? here so that PS1_ERROR can occur anywhere in the prompt
# Otherwise, NEW_PWD will clobber the value of $? that we want
PROMPT_COMMAND='RETVAL=$?;'

# Set PROMPT_COMMAND based on terminal type
#
# FIXME: This doesn't quite work right. Screen titles suck mostly
#        and I can't get the xterm part to work with screen
#        Maybe I can just assume that I will always use screen with
#        xterm and just include the screen part automatically?
#case "$TERM" in
    # If this is an xterm set the title to user@host
    #xterm*|*rxvt*)
        #PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}\007"'
        #;;

    # If this is screen, setup automatic titles
    #screen*)
        # This ***NEVER*** works
        #PROMPT_COMMAND='echo -ne "\ek\e\\"'
        #PS1="$PS1$screen_esc"
        #;;
#esac

unset screen_esc reset dir_color slash_color
unset hostname_color at_color user_color
unset bracket_color history_color prompt_color
unset NEW_PWD PS1_ERROR

# }}}

# Bash Completion {{{

test -z "$BASH_COMPLETION" && {
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    test -n "$PS1" && test $bmajor -gt 1 && {
        # Search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /etc/bash_completion
        do
            test -f $f && {
                . $f
                break
            }
        done
    }
    unset bash bmajor bminor
}

# Override and disable tilde expansion
_expand() {
    return 0
}

# }}}

