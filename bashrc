#!/bin/bash vim: foldlevel=0
#
# Jeremy Brubaker <jbru362@gmail.com>
#
# Some stuff ripped from Ryan Tomayko <tomayko.com/about>

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Setup {{{

# Source additional files
#
test -r /etc/bashrc && . /etc/bashrc
test -r /etc/bash.bashrc && . /etc/bash.bashrc

# Determine if terminal supports color
#
test $( tput colors ) -ge 0 && HAS_COLOR=yes

# }}}

# Functions {{{

# Color Escape Functions {{{

###################################################
# Functions to set colors and attributes
#
#  $(FX bold) sets bold attribute
#  $(FG 1) sets foreground color to ANSI color 1
#  $(BG 1) sets background color to ANSI color 1
#  $(FX bold; FG 1) sets foreground color to ANSI
#      color 1 and bold in one command
#
# These functions automatically interpret escape
# sequences so you don't need to pass '-e' to echo
#
# Based on P. C. SHyamshankar's spectrum script
# for zsh <github.com/sykora>.
# Changed to use functions instead of hashes for speed
# Changed to use tput(1) as much as possible
###################################################
function FX()
{
    case "$1" in
        reset)       tput sgr0 ;;
        bold)        tput bold ;;
        nobold)      echo -en "\e[22m" ;; # no tput sequence
        dim)         tput dim ;;
        nodim)       ;;                   # no tput sequence
        italic)      tput sitm ;;
        noitalic)    tput ritm ;;
        underline)   tput smul ;;
        nounderline) tput rmul ;;
        blink)       tput blink ;;
        fastblink)   echo -en "\e[6m" ;;  # no tput sequence
        noblink)     echo -en "\e[25m" ;; # no tput sequence
        reverse)     tput rev ;;
        noreverse)   echo -en "\e[27m" ;; # no tput sequence
        hidden)      echo -en "\e[8m" ;;  # no tput sequence
        nohidden)    echo -en "\e[28m" ;; # no tput sequence
        standout)    tput smso ;;
        nostandout)  tput rmso ;;
        strikeout)   echo -en "\e[9m" ;;  # no tput sequence
        nostrikeout) echo -en "\e[29m" ;; # no tput sequence

        *)           echo "";
    esac
}

if test $HAS_COLOR; then
    # TODO: Create 24bit color versions
    function FG() {
        tput setaf $1
    }

    function BG()
    {
        tput setab $1
    }
else
    function FG() {
        :
    }

    function BG() {
        :
    }
fi

# }}}

# Miscellaneous Functions {{{

###
# lsp
#
# Print numerical permissions at the start of each line
#
# https://github.com/blaenk/dots/blob/master/zsh/zsh/functions.zsh
#
###
# TODO: Make this consistent with my ls aliases
function lsp ()
{
    command ls -lh --time-style '+%m/%d/%y %I:%M %p' --color=always $@ | \
        awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)\
        *2^(8-i));if(k)printf("%0o ",k);print}'
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
    # Create search string if arguments were passed
    if [[ "$*" ]]; then
        # Google search strings replace spaces with '+'
        IFS='+'
        local search_string="$*"
        unset IFS

        local url="search?hl=en&lr=&ie=UTF-8&oe=UTF-8&q="
        url="$url$search_string&btnG=Google+Search"
    fi

    # Open URL in browser. If no arguments were passed
    # it merely opens google.com
    openurl "www.google.com/$url"
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
        openurl "http://duckduckgo.com/?q=%21man+$@" ;
}

####
# hb/hr/hbl
# Bold, Reverse-Video and Blinking highlighted search
#
# Args:
#  $1 - search string
#  $2 - optional foreground color number
#
# Examples:
# who | hb "$USER" 1 
# ps | hr ".*$PPID.*" | hbl ".*$$.*"
####
# TODO: Make these more versatile
function hb()
{
    local fg
    test $2 && fg=$( FG $2 )
    sed "s/\($1\)/$(FX bold)$fg\1`tput sgr0`/gI"

}

function hr()
{
    local fg
    test $2 && bg=$( FG $2 )
    sed "s/\($1\)/$(FX reverse)$fg\1`tput sgr0`/gI"
}

function hbl()
{
    local fg
    test $2 && fg=$( FG $2 )
    sed "s/\($1\)/$(FX blink)$fg\1`tput sgr0`/gI"
}

###
# lh
#
# List last "n" commands in history
###
function lh()
{
    history | tail -"$1"
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
    if test -n "$b" ; then
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

# Usage: pshift [-n <num>] [<var>]
# Shift <num> entries off the front of PATH or environment var <var>.
# with the <var> option. Useful: pshift $(pwd)
pshift () {
    local n=1
    [ "$1" = "-n" ] && { n=$(( $2 + 1 )); shift 2; }
    eval "${1:-PATH}='$(pls |tail -n +$n |tr '\n' :)'"
}

# Usage: ppop [-n <num>] [<var>]
# Pop <num> entries off the end of PATH or environment variable <var>.
ppop () {
    local n=1 i=0
    [ "$1" = "-n" ] && { n=$2; shift 2; }
    while [ $i -lt $n ]
    do eval "${1:-PATH}='\${${1:-PATH}%:*}'"
       i=$(( i + 1 ))
    done
}

# Usage: punshift <path> [<var>]
# Shift <path> onto the beginning of PATH or environment variable <var>.
punshift () {
    eval "${2:-PATH}='$1:$(eval echo \$${2:-PATH})'"
}

# Usage: ppush <path> [<var>]
ppush () {
    eval "${2:-PATH}='$(eval echo \$${2:-PATH})':$1"
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

# Usage: prm <path> [<var>]
# Remove <path> from PATH or environment variable <var>.
prm () {
    eval "${2:-PATH}='$(pls $2 |
        grep -v "^$1\$" |tr '\n' :)'"
}
# }}}

# }}}

# Setup PATH {{{
# FIXME: This should be done in xsession/bash_profile

# Put /usr/local/bin in PATH
PATH="/usr/local/bin:$PATH"

# Put ~/bin in PATH if it exists
test -d "$HOME/bin" &&
    PATH="$HOME/bin:$PATH"

PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

# }}}

# Environment {{{

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

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

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

# }}}

# Aliases {{{

test $HAS_COLOR && color_flag='--color=auto'

# My standard ls aliases
#
LS_OPTS="$color_flag --group-directories-first -XF --dereference-command-line-symlink-to-dir"
alias ls="command  ls $LS_OPTS"
alias la="command  ls $LS_OPTS -A"
alias ll="command  ls $LS_OPTS -lh"
alias lal="command ls $LS_OPTS -lhA"
alias l.="command  ls $LS_OPTS -d .*"
unset LS_OPTS

# Force color in *grep
#
alias grep="grep $color_flag"
alias fgrep="fgrep $color_flag"
alias egrep="egrep $color_flag"
unset color_flag

# If my pager is not less, make me think it is
#
test "x$PAGER" != 'xless' &&
    alias less="$PAGER" && alias zless="$PAGER"

# Screen automatically reattaches if able
command -v screen >/dev/null &&
    alias screen='screen -dR'

# OS specific aliases
#
case $(uname -o) in
    # Cygwin only
    Cygwin*) 
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

# Display latest xkcd comic if I have # feh and curl available
#
if command -v feh >/dev/null && command -v curl >/dev/null; then
    alias xkcd="curl -s 'http://xkcd.com/' | sed -n 's/Image URL.*: \(.*\)/\1/p' | feh -"
fi

# Fancy fortunes if toilet(1) exists
command -v toilet >/dev/null &&
   alias colfortune="fortune | toilet --metal -f term"

# Use pretty_make and colorgcc
#
command -v pretty_make >/dev/null &&
    alias make=pretty_make

command -v colorgcc >/dev/null && test $HAS_COLOR &&
    alias gcc=colorgcc

# If todo.txt is installed, make it simpler
# to access
command -v todo.sh >/dev/null &&
    alias t=todo.sh

# Keep uzbl-browser from polluting the terminal
if command -v uzbl >/dev/null; then
    alias uzbl="uzbl-browser $@ &> /dev/null &"
    alias uzblt="uzbl-tabbed &> /dev/null &"
fi

# Get my real IP
#
if command -v wget >/dev/null; then
    alias myip='wget http://ipecho.net/plain -O - -q'
elif command -v curl >/dev/null; then
    alias myip='curl http://ipecho.net/plain'
else
    alias myip="wget or curl not available"
fi

# Miscellaneous
#
alias dut='du -h --max-depth=1'  # du(1) prints totals for one level down
alias df='df -hT'                # Make df output nicer
alias reset=$( FX reset )        # Reset system palette

# }}}

# Prompts {{{

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

# Unset Variables {{{

# TODO: Make variables local instead?
unset HAS_COLOR
unset INTERACITIVE
unset LOGIN

# }}}

PATH="/home/jbrubake/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/jbrubake/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/jbrubake/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/jbrubake/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/jbrubake/perl5"; export PERL_MM_OPT;
