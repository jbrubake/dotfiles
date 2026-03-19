#!/bin/sh

# Global configuration {{{1

# used by colorize()
TMUX_COLOR_RED=color203
TMUX_COLOR_YELLOW=color214
TMUX_COLOR_GREEN=color42
# Brighter colors
# TMUX_COLOR_RED=color196
# TMUX_COLOR_YELLOW=color226
# TMUX_COLOR_GREEN=color40

TMUX_STATUS_BAR_FG=color252
TMUX_STATUS_BAR_BG=color233
# Format string, active surround, inactive surround, background color
#   Format string: <window index><window flags> <window name>
TMUX_WINDOW_FORMAT="#I#F #W,,[],$TMUX_STATUS_BAR_BG"

separator() { 
    if [ "$1" = nospace ]; then
        trail=
    else
        trail=' '
    fi

    printf '#[fg=%s,bg=%s] |%s' "$TMUX_STATUS_BAR_FG" "$TMUX_STATUS_BAR_BG" "$trail"
}

left() { # {{{1
    fg=$TMUX_STATUS_BAR_FG
    bg=$TMUX_STATUS_BAR_BG

    # default color
    printf '#[bg=%s,bold]' "$bg"

    # spacing
    printf ' '

    # host:session
    printf '#[range=user|new]'
    printf '  #[fg=color44]#{client_user}@#[fg=color171]#h'
    printf '#[norange]'

    # uptime
    separator
    printf ' #[fg=color171] up %s' "$(plugin uptime)"

    # clock
    separator
    printf '#[range=user|clock]'
    printf ' #[fg=color214]%s#[fg=none]' "$(date +'%a, %d-%b %H:%M:%S')"
    printf '#[norange]'

    # network status and internet POP
    case $(plugin uplink) in
        'up')     color=$TMUX_COLOR_GREEN ;;
        'no dns') color=$TMUX_COLOR_YELLOW ;;
        'down')   color=$TMUX_COLOR_RED ;;
    esac
    ssid=$(plugin wifi)
    [ -n "$ssid" ] && ssid=" ($ssid)"
    separator
    printf '#[range=user|network]'
    printf '󰖟 [#[fg=%s]%s#[fg=%s]%s]' "$color" "$(plugin ip_location '%c, %R')" "$fg" "$ssid"
    printf '#[norange]'

    # VPN status
    if ip --brief address | grep -q ^jeremy-range; then
        work_vpn=$(plugin vpn_status jeremy-range 10.25.100.1 test.roka.live)
    elif ip --brief address | grep -q ^tng; then
        work_vpn=$(plugin vpn_status tng 172.25.0.1 roka.live)
    fi
    if [ -n "$work_vpn" ]; then
        separator
        printf '#[range=user|vpn]'
        printf '󰖂 [%s#[fg=%s]]' "$work_vpn" "$fg"
        printf '#[norange]'
    fi

    # end
    printf '#[fg=%s,bg=%s]  ' "$fg" "$bg"
}

right() { # {{{1
    fg=$TMUX_STATUS_BAR_FG
    bg=$TMUX_STATUS_BAR_BG

    # default color
    printf '#[bg=%s,bold]' "$bg"

    # leader
    printf ' '

    # memory usage
    printf '#[range=user|memory]'
    printf '  %s' "$(plugin mem_usage '%u/%t')"
    printf '#[norange]'

    # system load
    separator
    printf '#[range=user|load]'
    printf '  %s' "$(plugin load '%o%/%f%/%F%')"
    printf '#[norange]'

    # updates
    separator
    printf '#[range=user|updates]'
    printf '󰒃 %s' "$(plugin updates "#[fg=color033]%t #[fg=$TMUX_COLOR_RED]( %s)#[fg=color033] updates")"

    # music
    separator
    printf '#[fg=color252] | '
    printf '#[range=user|music]'
    # Remove '(.*)' album and song qualifiers
    track=$(plugin music '%s%F' | sed 's/([^)]*)[[:space:]]*//')
    # If player is stopped, music.tmux just outputs a single "stopped" emoji and
    # the sed command above adds another character
    if [ "$(echo "$track" | wc -m)" -gt 2 ]; then
        printf '%s' "$track"
    else
        printf '%s  No track' "$track"
    fi

    # weather
    weather=$(plugin weather '+%c%C+%t+(%f)')
    if [ -n "$weather" ]; then
        separator nospace
        printf '#[range=user|weather]'
        printf '%s' "$(plugin weather '+%c%C+%t+(%f)')"
        printf '#[norange]'
    fi

    # rpg-cli status
    if command -v atwork >/dev/null && ! atwork; then
        separator
        printf '󱡂 %s' "$(plugin rpg_status '%c-%l: %H hp')"
    fi

    # battery
    separator
    printf '%s' "$(plugin battery)"

    # reset
    printf '#[fg=%s,bg=%s]' "$fg" "$bg"

    # provide some separation from the terminal's edge
    printf '  '
}

window() { # {{{1
    window=$1

    # extract from environment
    format=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f1)
    active=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f2)
    inactive=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f3)
    bar=$(echo "$TMUX_WINDOW_FORMAT" | cut -d, -f4)

    # set defaults
    format=${format:-'#I#F #W'}
    active=${active:-'()'}
    inactive=${inactive:-'[]'}
    bar=${bar:-'color233'}

    # split character pairs
    preactive=$(echo $active | cut -c1)
    postactive=$(echo $active | cut -c2)
    preinactive=$(echo $inactive | cut -c1)
    postinactive=$(echo $inactive | cut -c2)

    case "$window" in
        # Current window
        *\**) pre=$preactive; post=$postactive
        case $window in
            *Z*) fg=color130; bg=$bar; other=none ;; # zoomed
            *)   fg=color042; bg=$bar; other=bold ;; # other
        esac ;;

        # Inactive window
        *) pre=$preinactive; post=$postinactive
        case $window in
            *-*)     fg=color255; bg=$bar; other=none ;; # last
            *~*)     fg=color042; bg=$bar; other=none ;; # silent
            *M*)     fg=color042; bg=$bar; other=none ;; # marked
            *\#* | \
            *!*)     fg=color203; bg=$bar; other=none ;; # activity | bell
            *)       fg=color201; bg=$bar; other=none ;; # other
        esac ;;
    esac

    printf "#[fg=%s,bg=%s,%s]%s%s%s" "$fg" "$bg" "$other" "$pre" "$format" "$post"
}

