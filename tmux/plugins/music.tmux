#!/bin/sh
# Seconds until script output cache is stale
INTERVAL=5

# %t title
# %a artist
# %A album
# %s player status
# %f artist - title
# %FN artist - title (truncated to N chars, default is 30)
#
# [] in format string must be escaped
music() {
    format=${1:-%f}

    pause='⏸  '
    stop=⏹

    status=$(mpc 2>/dev/null | awk '
        /playing/ { print "PLAYING"; exit }
        /paused/  { print "PAUSED"; exit }
        ')

    case $status in
        PLAYING) status= ;;
        PAUSED)  status=$pause ;;
        *)       printf '%s' "$stop"; return ;;
    esac

    format=$(printf '%s' "$format" | sed "
        s/%s */$status/
        s/%t/[%title%]/
        s/%a/[%artist%]/
        s/%A/[%album%]/
        s/%f/[%title% - ][%artist%]/
        ")

    case $format in
        *%F*)
            n=$(printf '%s' "$format" | sed 's/.*%F\([[:digit:]]*\).*/\1/')
            f=$(mpc --format '[%title% - ][%artist%]' 2>/dev/null |
                head -1 | grep -v ^volume | cut -c-"${n:-30}")
            format=$(printf '%s' "$format" | sed "s/%F/$f/")
            ;;
    esac

    mpc --format "$format" 2>/dev/null | head -1 | grep -v ^volume
}

