#!/usr/bin/sh

# Seconds until script output cache is stale
INTERVAL=60

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

SEC_PER_WK=604800
SEC_PER_DAY=86400
SEC_PER_HR=3600
SEC_PER_MIN=60

get_uptime() {
    seconds=$(</proc/uptime cut -d'.' -f1)
    wks=$(( seconds / SEC_PER_WK ))
    day=$(( seconds / SEC_PER_DAY ))
    hrs=$(( seconds / SEC_PER_HR ))
    min=$(( seconds / SEC_PER_MIN ))

    if [ "$wks" -gt 1 ]; then
        up="${wks}w"
    elif [ "$day" -gt 1 ]; then
        up="${day}d"
    elif [ "$hrs" -gt 1 ]; then
        up="${hrs}h"
    else
        up="${min}m"
    fi

    printf "Up %s" "$up"
}

get_value get_uptime "$INTERVAL"
