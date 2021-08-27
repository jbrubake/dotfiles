#!/bin/sh

# TODO: Pull the colorize piece out from here and load plugin

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_USAGE=50
RED_USAGE=70

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

colorize_usage() {
    if [ $1 -ge $RED_USAGE ]; then
        color="red"
    elif [ $1 -ge $YELLOW_USAGE ]; then
        color="yellow"
    else
        color="green"
    fi

    printf "#[fg=%s]" "$color"
}

get_usage_average() {
    printf "%.0f" $(echo "$1 / $2 * 100" | bc -l)
}

get_usage(){
    # Determine average-based color
    set -- $(free | awk 'NR == 2 {print $2, $3}')
    color=$(colorize_usage $(get_usage_average "$2" "$1"))

    # Get human readable values
    set -- $(free -h | awk 'NR == 2 {print $2, $3}')
    total="$1"
    used="$2"

    printf "%s%s/%s" "$color" "$used" "$total"
}

get_value get_usage "$INTERVAL"

