#!/bin/bash

# Color Themes {{{
case $(uname -o) in
    Cygwin*) # {{{
        # Set scheme to whatever color scheme you want
        #
        # Currently supports:
        #  default : terminal default
        #  custom  : one I made up
        #  solar   : Solarized
        scheme=solar

        # Color numbers:
        #  0 black    8 bold black
        #  1 red      9 bold red
        #  2 green    A bold green
        #  3 yellow   B bold yellow
        #  4 blue     C bold blue
        #  5 magenta  D bold magenta
        #  6 cyan     E bold cyan
        #  7 white    F bold white 
        case $scheme in
            custom*) # {{{
                echo -en "\e]P0222222" # black
                echo -en "\e]P8222222" # bold black
                echo -en "\e]P1803232" # red
                echo -en "\e]P9982b2b" # bold red
                echo -en "\e]P25b762f" # green
                echo -en "\e]PA89b83f" # bold green
                echo -en "\e]P3aa9943" # yellow
                echo -en "\e]PBefef60" # bold yellow
                echo -en "\e]P4324c80" # blue
                echo -en "\e]PC2b4f98" # bold blue
                echo -en "\e]P5706c9a" # magenta
                echo -en "\e]PD826ab1" # bold magenta
                echo -en "\e]P692b19e" # cyan
                echo -en "\e]PEa1cdcd" # bold cyan
                echo -en "\e]P7ffffff" # white
                echo -en "\e]PFdedede" # bold white
                ;; # }}}
            solar) # {{{
                echo -en '\e]P1DC322F\a'   # red
                echo -en '\e]P2859900\a'   # green
                echo -en '\e]P3B58900\a'   # yellow
                echo -en '\e]P4268BD2\a'   # blue
                echo -en '\e]P5D33682\a'   # magenta
                echo -en '\e]P62AA198\a'   # cyan
                echo -en '\e]P7EEE8D5\a'   # white (light grey really) -> Base2
                echo -en '\e]P9CB4B16\a'   # bold red -> orange
                echo -en '\e]PA586E75\a'  # bold green -> base01
                echo -en '\e]PB657B83\a'  # bold yellow -> base00
                echo -en '\e]PC839496\a'  # bold blue -> base0
                echo -en '\e]PD6C71C4\a'  # bold magenta -> violet
                echo -en '\e]PE93A1A1\a'  # bold cyan -> base1
                echo -en '\e]PFFDFDE3\a'  # bold white -> Base3
                ;; # }}}
            default) # {{{
                ;; # }}}
        esac

        # Clear screen to prevent background artifacting
        echo -en "\e[2J\e[H" # Use escape codes since clear(1) may not exist
        ;;
    # }}}
esac
# }}}

# Everything is in .bashrc
source $HOME/.bashrc

# Print motd
if test  -e /run/motd.dynamic; then
    cat /run/motd.dynamic
else
    uname -npsr
    uptime=$( uptime )
    echo "Uptime: $uptime\n"
fi

