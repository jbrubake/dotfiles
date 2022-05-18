#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 10 ))

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"
source "$PLUGINS/config/$(basename $0 .tmux).rc"

is_home_network_connected() {
    if ip a | grep -q "$interface" &&
       ping "$server" -c1 2>&1 >/dev/null; then
        return 0
    fi
    return 1
}

get_home_network_name() {
    echo "$name"
}

if ! is_home_network_connected; then
    clear_cache
else
    get_value get_home_network_name "$INTERVAL"
fi

