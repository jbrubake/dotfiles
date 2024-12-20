#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60
YELLOW_THRESH=50
RED_THRESH=70

CORES=$(grep 'model name' /proc/cpuinfo | wc -l)
get_load_average() {
    printf "%.0f" $(echo "$1 / $CORES * 100" | bc -l)
}

load(){
    format=${1:-%o/%f/%F}

    set -- $(uptime | awk -F: '{printf $NF}' | tr -d ',' )

    ave1=$(get_load_average $1)
    ave5=$(get_load_average $2)
    ave15=$(get_load_average $3)

    ave1=$(colorize "$((100-ave1))" "$RED_THRESH" "$YELLOW_THRESH")$ave1
    ave5=$(colorize "$((100-ave5))" "$RED_THRESH" "$YELLOW_THRESH")$ave5
    ave15=$(colorize "$((100-ave15))" "$RED_THRESH" "$YELLOW_THRESH")$ave15

    printf %s "$(printf %s "$format" | sed -e "s/%o/$ave1/" -e "s/%f/$ave5/" -e "s/%F/$ave15/")"
}

