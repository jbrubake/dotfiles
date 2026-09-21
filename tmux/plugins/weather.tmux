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
    # F    Temperature (Feels Like) [if different], Temperature [if the same]
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
    do_feels=0

    # Get actual and feels-like for %F
    case $format in
        *%F*)
            format=$(printf %s "$format" | sed 's/%F/?%t?%f?/')
            do_feels=1
            ;;
    esac

    # u USCS (US default)
    # m metric
    # M metric (wind speed in m/s)
    units=${2:-u}

    weather=$(curl --silent --compressed --connect-timeout 5 --max-time 5 \
        "http://wttr.in/?$units&format=$format")

    # Format actual and feels-like for %F
    if [ "$do_feels" = 1 ]; then
        temp=$(printf %s "$weather" | sed 's/^[^?]*?//; s/?[^?]*$//')
        real=$(printf %s "$temp" | cut -d'?' -f1)
        feel=$(printf %s "$temp" | cut -d'?' -f2)

        if [ "$real" = "$feel" ]; then
            temp=$real
        else
            temp="$real ($feel)"
        fi

        weather=$(printf %s "$weather" | sed "s/?\(.*\)?/$temp/")
    fi

    case $r in
        *Sorry*) printf '' ;;
        *)       printf %s "$weather" ;;
    esac
}

