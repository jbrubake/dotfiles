#!/bin/sh

# Global configuration {{{1

# used by colorize()
TMUX_COLOR_RED=color203
TMUX_COLOR_YELLOW=color214
TMUX_COLOR_GREEN=color42
TMUX_FG_NONE=color252
TMUX_BG_NONE=color233

TMUX_STATUS_BAR_FG=$TMUX_FG_NONE
TMUX_STATUS_BAR_BG=$TMUX_BG_NONE
# Format string, active surround, inactive surround, background color
#   Format string: <window index><window flags> <window name>
TMUX_WINDOW_FORMAT="#I#F #W,,[],$TMUX_STATUS_BAR_BG"

separator() { 
    printf '#[fg=%s,bg=%s] | ' "$1" "$2"
}

start_range() {
    [ -n "$1" ] && printf '#[range=user|%s]' "$1"
}

end_range() {
    printf '#[norange]'
}

left() { # {{{1
    fg=$TMUX_STATUS_BAR_FG
    bg=$TMUX_STATUS_BAR_BG

    # default color {{{2
    printf '#[bg=%s,bold]' "$bg"

    # spacing {{{2
    printf ' '

    # session:host {{{2
    start_range new
    printf '  #[fg=color44]#{client_user}#[fg=%s,nobold]:#[fg=color171,bold]#h' "$TMUX_FG_NONE"
    end_range

    # uptime {{{2
    separator "$fg" "$bg"
    printf ' #[fg=color171] up %s' "$(plugin uptime)"

    # clock {{{2
    separator "$fg" "$bg"
    start_range clock
    printf ''
    printf '#[fg=%s] %s#[fg=%s]'              "$TMUX_COLOR_YELLOW" "$(date +'%a, %d-%b %H:%M:%S')" "$TMUX_FG_NONE"
    printf '#[fg=%s] UTC:#[nobold] %s#[bold]' "$TMUX_FG_NONE"      "$(TZ=UTC date '+%H:%M')"
    end_range

    # network status and internet POP {{{2
    case $(plugin uplink) in
        'up')     color=$TMUX_COLOR_GREEN ;;
        'no dns') color=$TMUX_COLOR_YELLOW ;;
        'down')   color=$TMUX_COLOR_RED ;;
    esac

    ssid=$(plugin wifi)
    [ -n "$ssid" ] && ssid=" ($ssid)"

    separator "$fg" "$bg"
    start_range network
    printf '󰖟 [#[fg=%s]%s#[fg=%s]%s]' "$color" "$(plugin ip_location '%c, %R')" "$fg" "$ssid"
    end_range

    # VPN status {{{2
    if ip --brief address | grep -q ^jeremy-range; then
        work_vpn=$(plugin vpn_status jeremy-range 10.25.100.1 test.roka.live)
    elif ip --brief address | grep -q ^tng; then
        work_vpn=$(plugin vpn_status tng 172.25.0.1 roka.live)
    fi

    if [ -n "$work_vpn" ]; then
        separator "$fg" "$bg"
        start_range vpn
        printf '󰖂 [%s#[fg=%s]]' "$work_vpn" "$fg"
        end_range
    fi

    # end {{{2
    printf '#[fg=%s,bg=%s]  ' "$fg" "$bg"
}

right() { # {{{1
    fg=$TMUX_STATUS_BAR_FG
    bg=$TMUX_STATUS_BAR_BG

    # default color {{{2
    printf '#[bg=%s,bold]' "$bg"

    # leader {{{2
    printf ' '

    # memory usage {{{2
    start_range memory
    printf '  %s' "$(plugin mem_usage '%u/%t')"
    end_range

    # system load {{{2
    separator "$fg" "$bg"
    start_range load
    printf '  %s' "$(plugin load '%o%/%f%/%F%')"
    end_range

    # updates {{{2
    separator "$fg" "$bg"
    start_range updates
    printf '󰒃 %s' "$(plugin updates "#[fg=color033]%t #[fg=$TMUX_COLOR_RED]( %s)#[fg=color033] updates")"

    # music {{{2
    separator "$fg" "$bg"
    start_range music
    # Remove '(.*)' album and song qualifiers
    track=$(plugin music '%s%F' | sed 's/([^)]*)[[:space:]]*//')
    # If player is stopped, music.tmux just outputs a single "stopped" emoji and
    # the sed command above adds another character
    if [ "$(echo "$track" | wc -m)" -gt 2 ]; then
        printf '%s' "$track"
    else
        printf '%s  No track' "$track"
    fi

    # weather {{{2
    weather=$(plugin weather '+%c%C+%t+(%f)')
    if [ -n "$weather" ]; then
        separator "$fg" "$bg"
        start_range weather
        printf '%s' "$weather"
        end_range
    fi

    # rpg-cli status {{{2
    if command -v atwork >/dev/null && ! atwork; then
        separator "$fg" "$bg"
        printf '󱡂 %s' "$(plugin rpg_status '%c-%l: %H hp')"
    fi

    # battery {{{2
    separator "$fg" "$bg"
    printf '%s' "$(plugin battery)"

    # reset {{{2
    printf '#[fg=%s,bg=%s]' "$fg" "$bg"

    # provide some separation from the terminal's edge {{{2
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

