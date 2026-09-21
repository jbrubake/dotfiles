#!/bin/sh
# Seconds until script output cache is stale
INTERVAL=1

# Usage: music [OPTIONS] FORMAT
#
# -S:  prepend pause and stop icon
# -x:  strip (.*) portions of output
#
# %t title
# %a artist
# %A album
music() {
    show_status=
    strip=

    OPTIND=1
    while getopts 'Sx' opt; do
        case $opt in
            S) show_status=1 ;;
            x) strip=1 ;;
        esac
    done
    shift $((OPTIND - 1))
    OPTIND=1

    format=${1:-%t - %a}
    separator=${2:-' | '}

    pause=' '
     play='󰐊 '
     stop='⏹ '

    status=$(mpc 2>/dev/null | awk '
        /playing/ { print "PLAYING"; exit }
        /paused/  { print "PAUSED"; exit }
        ')

    case $status in
        PLAYING) status=$play ;;
        PAUSED)  status=$pause ;;
        *)       printf '%s —' "$stop"; return ;;
    esac

    format=$(printf %s "$format" | sed '
        s/\[/\\[/g
        s/]/\\]/g
        s/%t/[%title%]/
        s/%a/[%artist%]/
        s/%A/[%album%]/
        ')

    # Get full output
    output=$(mpc --format "$format" 2>/dev/null | head -1 | grep -v ^volume)
    [ -n "$strip" ] &&
        output=$(printf %s "$output" | sed 's/[[:blank:]]*([^)]*)[[:blank:]]*/ /')

    # Shorten Pandora ad announcements
    case $output in
        [Aa]dvertisement*) output=Advertisement ;;
    esac

    printf %s "$output"

    [ -n "$show_status" ] && printf %s%s%s "$RS" "$status" "$RS"

}
