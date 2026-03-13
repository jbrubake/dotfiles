#!/bin/sh
# Seconds until script output cache is stale
INTERVAL=60

# 10% to 100%
unplugged=󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹
# 10% to 100%
charging=󰢜󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂅
# number of icons
icon_len=10
# No battery found
no_battery=

# Colorization threshholds
RED_THRESH=50
YELLOW_THRESH=75

# Get the battery name
get_battery() { upower --enumerate | grep battery; }

# Is the AC adapter plugged in?
is_plugged_in() {
    [ $(upower -i $(upower -e | grep AC) | awk '/online:/ {print $2}') = 'yes' ]
}

get_charge() {
    upower -i "$1" | awk '/percentage:/ {print $2}' | sed 's/%//'
}

get_time_to_empty() {
    upower -i "$1" | awk '/time to empty/ {$1 = "" $2 = "" $3 = "" print }'
}

# -t option adds time remaining to full charge
#
battery() {
    battery=$(get_battery)

    if [ -z "$battery" ]; then
        printf '#[fg=%s]%s' "$TMUX_COLOR_RED" "$no_battery"
        return
    fi

    # Get current % charge
    charge=$(get_charge "$battery")

    i=$((charge / icon_len + 1))            # convert charge to index into $unplugged / $charging
    [ "$i" -gt "$icon_len" ] && i=$icon_len # max of $icon_len

    # Which icon set to use?
    if is_plugged_in; then
        icons=$charging
    else
        icons=$unplugged
    fi

    # Get time to full charge
    if [ "$1" = '-t' ]; then
        time=" ($(get_time_to_empty "$battery") remaining)"
    fi

    # <icon> <charge>%
    printf '%s%s %s%%%s' \
        "$(colorize "$charge" "$RED_THRESH" "$YELLOW_THRESH")" \
        "$(echo "$icons" | cut -c"$i")" \
        "$charge" "$time"
}

