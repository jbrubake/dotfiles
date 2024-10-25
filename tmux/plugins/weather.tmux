#!/bin/bash

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 60 )) # 1 hour

# Weather format
# c    Weather condition,
# C    Weather condition textual name,
# x    Weather condition, plain-text symbol,
# h    Humidity,
# t    Temperature (Actual),
# f    Temperature (Feels Like),
# w    Wind,
# l    Location,
# m    Moon phase 🌑🌒🌓🌔🌕🌖🌗🌘,
# M    Moon day,
# p    Precipitation (mm/3 hours),
# P    Pressure (hPa),

# D    Dawn*,
# S    Sunrise*,
# z    Zenith*,
# s    Sunset*,
# d    Dusk*,
# T    Current time*,
# Z    Local timezone.

# (*times are shown in the local timezone)
FORMAT="+%c+%t"

# Weather location
location=${LOCATION// /+}

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

get_weather() {
    r=$(curl http://wttr.in/$location?format=$FORMAT 2>/dev/null | tr -s ' ')
    case $r in
        *Sorry*) printf %s "-"  ;;
        *) printf "$r" ;;
    esac
}

get_value get_weather "$INTERVAL"
