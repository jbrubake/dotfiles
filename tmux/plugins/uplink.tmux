#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 20 ))

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

uplink_status() {
    if getent ahosts www.google.com >/dev/null; then
        echo "Y"
    else
        echo "N"
    fi
}

get_value uplink_status "$INTERVAL"
