#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_THRESH=50
RED_THRESH=70

get_remaining_pct() { echo "$((100 - $2 / $1 * 100))"; }

mem_usage(){
    format=${1:-%u/%t}

    # Determine average-based color
    set -- $(free | awk 'NR == 2 {print $2, $3}')
    color=$(colorize "$(get_remaining_pct "$1" "$2")" "$RED_THRESH" "$YELLOW_THRESH")

    # Get human readable values
    set -- $(free -h | awk 'NR == 2 {print $2, $3}')
    printf %s%s "$color" "$(printf %s "$format" | sed -e "s/%t/$1/" -e "s/%u/$2/")"
}

