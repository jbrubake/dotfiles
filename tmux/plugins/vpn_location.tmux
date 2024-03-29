#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 15 ))

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

get_ip_location() {
    loc=$(curl -s ipinfo.io/json --connect-timeout 3 |
        tr -d '[[:punct:]]' |
        awk '/city/ {$1=""; print} /country/ {$1=""; print}' |
        paste -d " " - - |
        sed -e 's/^ *//' -e 's/  /, /')
    if [ -z "$loc" ]; then
        loc="Private"
    fi
    echo "$loc"
    }

is_vpn_on() {
    if ip address | grep -Eq '(tun|wg)[[:digit:]]'; then
        return 0
    else
        return 1
    fi
}

if ! is_vpn_on; then
    clear_cache
else
    get_value get_ip_location "$INTERVAL"
fi

