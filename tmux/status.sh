#!/bin/sh

# Source plugin framework
. $(tmux show-option -gqv @plugin_dir)/utils.sh

# Global configuration {{{1

# used by colorize()
TMUX_COLOR_RED=color203
TMUX_COLOR_YELLOW=color214
TMUX_COLOR_GREEN=color42
# Brighter colors
# TMUX_COLOR_RED=color196
# TMUX_COLOR_YELLOW=color226
# TMUX_COLOR_GREEN=color40

# used in window status format
TMUX_WINDOW_FORMAT='#I#F #W,,[],black' # Format: <window index><window flags> <window name>
TMUX_BAR_COLOR=black                     # default status bar background color

left() { # {{{1
    # spacing
    printf ' '

    # host:session
    printf '  #[fg=cyan]#h'

    # uptime
    printf '#[fg=color252] | '
    printf ' #[fg=color171] up %s' "$(plugin uptime)"

    # clock
    printf '#[fg=color252] | '
    printf '#[range=user|clock]'
    printf ' #[fg=yellow,bold]%s#[fg=none]' "$(plugin clock '%a, %d-%b %H:%M')"
    printf '#[norange]'

    # network status
    printf '#[fg=color252] | '
    printf '󰖟 %s' "$(plugin uplink ',#[fg=brightyellow]No DNS ,#[fg=brightred]Down ')"

    # internet POP
    printf '#[fg=color252](%s)' "$(plugin ip_location '%c, %C')"

    # VPN status
    if ip --brief address | grep -q ^jeremy-range; then
        work_vpn=$(plugin vpn_status jeremy-range 10.25.100.1 test.roka.live)
    elif ip --brief address | grep -q ^tng; then
        work_vpn=$(plugin vpn_status tng 172.25.0.1 roka.live)
    fi
    if [ -n "$work_vpn" ]; then
        printf '#[fg=color252] | ' 
        printf '󰖂 [%s#[fg=color252]]' "$work_vpn"
    fi

    # end
    printf '#[fg=color252,bg=black]  '

    # reset
    printf '#[fg=color252,bg=black]'
}

right() { # {{{1
    # leader
    printf '#[fg=color252,bg=black] '

    # memory usage
    printf '  %s' "$(plugin mem_usage '%u/%t')"

    # system load
    printf '#[fg=color252] | '
    printf '  %s' "$(plugin load '%o%/%f%/%F%')"

    # updates
    printf '#[fg=color252] | '
    printf '󰒃 %s' "$(plugin updates '#[fg=brightblue,bold]%t #[fg=brightred]( %s)#[fg=brightblue] updates')"

    # weather
    printf '#[fg=color252] |' # <-- space intentionally skipped
    printf '%s' "$(plugin weather '+%c%C+%t+(%f)')"

    # rpg-cli status
    printf '#[fg=color252] | '
    printf '󱡂 %s' "$(plugin rpg_status '%c-%l: %H hp')"

    # battery
    printf '#[fg=color252] | '
    printf '%s' "$(plugin battery)"

    # reset
    printf '#[fg=color252,bg=black]'

    # TODO: right bar is shifted one space to the left which results in the wrong color there at times
    # spacing (needed to keep the last character on the screen)
    printf ' '
}

window() { # {{{1
    window=$1

    # extract from environment
    format=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f1)
    active=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f2)
    inactive=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f3)
    bar=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f4)

    # set defaults
    format=${format:-#I#F #W}
    active=${active:-()}
    inactive=${inactive:-[]}
    bar=${bar:-black}

    # split character pairs
    preactive=$(echo $active | cut -c1)
    postactive=$(echo $active | cut -c2)
    preinactive=$(echo $inactive | cut -c1)
    postinactive=$(echo $inactive | cut -c2)

    case "$window" in
        # Current window
        *\**) pre=$preactive; post=$postactive
        case $window in
            *Z*) fg=yellow; bg=$bar; other=none ;; # zoomed
            *)   fg=green;  bg=$bar; other=bold ;; # other
        esac ;;

        # Inactive window
        *) pre=$preinactive; post=$postinactive
        case $window in
            *-*)     fg=white;  bg=$bar; other=none ;; # last
            *~*)     fg=green;  bg=$bar; other=none ;; # silent
            *M*)     fg=green;  bg=$bar; other=none ;; # marked
            *\#* | \
            *!*)     fg=red;    bg=$bar; other=none ;; # activity | bell
            *)       fg=brightblack; bg=$bar; other=none ;; # other
        esac ;;
    esac

    printf "#[fg=%s,bg=%s,%s]%s%s%s" "$fg" "$bg" "$other" "$pre" "$format" "$post"
}

# Main {{{1
#
cmd=$1; shift
"$cmd" "$@"

