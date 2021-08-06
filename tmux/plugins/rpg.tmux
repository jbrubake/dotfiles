#!/usr/bin/bash

RED_THRESH=50
YELLOW_THRESH=75

colorize_hp() {
    if [ $1 -lt $RED_THRESH ]; then
        color="red"
    elif [ $1 -lt $YELLOW_THRESH ]; then
        color="yellow"
    else
        color="green"
    fi

    printf "#[fg=%s]%s" "$color" "$1"
}

get_hp_percent() {
    printf "%.0f" $(echo "$1 / $2 * 100" | bc -l)
}

set -- $(rpg-cli --plain | cut -f3 | cut -d':' -f2 | tr '/' ' ')

colorize_hp $(get_hp_percent $1 $2)

