#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_LOAD=50
RED_LOAD=70

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

CORES=$(grep 'model name' /proc/cpuinfo | wc -l)

colorize_load() {
    if [ $1 -ge $RED_LOAD ]; then
        color="red"
    elif [ $1 -ge $YELLOW_LOAD ]; then
        color="yellow"
    else
        color="green"
    fi

    printf "#[fg=%s]%s" "$color" "$1"
}

get_load_average() {
    printf "%.0f" $(echo "$1 / $CORES * 100" | bc -l)
}

get_load(){
    set -- $(uptime | awk -F: '{printf $NF}' | tr -d ',' )

    ave1=$(colorize_load $(get_load_average $1))
    ave5=$(colorize_load $(get_load_average $2))
    ave15=$(colorize_load $(get_load_average $3))

    printf "%s %s%%/%s%%/%s%%" $(emojify :computer:) $ave1 $ave5 $ave15
}

get_value get_load "$INTERVAL"
