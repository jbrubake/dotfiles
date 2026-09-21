#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_THRESH=50
RED_THRESH=30

mem_usage(){
    format=${1:-%u/%t}

    # Determine average-based color
    set -- $(free | awk 'NR == 2 {print $2, $3}')
    color=$(colorize "$(get_pct_remaining "$2" "$1")" "$RED_THRESH" "$YELLOW_THRESH")

    # Get human readable values
    set -- $(free -h | awk 'NR == 2 {print $2, $3}')
    printf %s%s "$color" "$format" | sed -e "s/%t/$1/" -e "s/%u/$2/"
}

