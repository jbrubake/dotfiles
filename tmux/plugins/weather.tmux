#!/bin/bash

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 60 )) # 1 hour

weather() {
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
    format=${1:-%c%t}

    # u USCS (US default)
    # m metric
    # M metric (wind speed in m/s)
    units=${2:-u}

    r=$(curl "http://wttr.in/?$units&format=$format" 2>/dev/null | tr -s ' ')
    case $r in
        *Sorry*) printf %s "-"  ;;
        *) printf "$r" ;;
    esac
}

