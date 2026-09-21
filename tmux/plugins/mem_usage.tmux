#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_THRESH=50
RED_THRESH=30

mem_usage(){
    long=
    while getopts 'l' opt; do
        case $opt in
            l) long=1 ;;
        esac
    done
    shift $((OPTIND - 1))

    format=${1:-%u/%t}

    # Determine average-based color
    set -- $(free | awk 'NR == 2 {print $2, $3}')
    color=$(colorize "$(get_pct_remaining "$2" "$1")" "$RED_THRESH" "$YELLOW_THRESH")

    # Get human readable values
    set -- $(free -h | awk 'NR == 2 {print $2, $3}')
    tot=$1; mem=$2

    if [ -z "$long" ]; then
        tot=${tot%?}
        mem=${mem%?}
    fi

    tot=$color$tot
    mem=$color$mem

    printf %s "$format" | sed -e "s/%t/$tot/" -e "s/%u/$mem/"
}

