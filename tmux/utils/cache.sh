#!/bin/sh
#
# Caching function for my tmux statusbar scripts
#
# Usage:
#     source /path/to/cache.sh
#     get_value <command> <interval>
#
#         command is the command or function to cache and print
#         interval is the number of seconds that the cached value is good for
#
#     clear_cache
#         Forcibly clear the cache
#
# Based on the caching function in https://github.com/odedlaz/tmux-status-variables

CACHE="$HOME/var/cache/tmux"

now() { date +"%s"; }
get_cache_fn() { echo "$CACHE/$1.cache"; }
get_cache_time() { stat --format %Y "$(get_cache_fn "$1")" 2>/dev/null || echo "0"; }
set_cache() { "$2" | tee "$(get_cache_fn "$1")"; }
get_cache() { cat "$(get_cache_fn "$1")"; }
clear_cache() { rm -f "$(get_cache_fn)"; }

get_value() {
    cache_miss_fn="$1"
    interval="$2"
    plugin="$(basename "$0" .tmux)"

    [ ! -d "$CACHE" ] && mkdir -p "$CACHE"

    delta="$(( $(now) - $(get_cache_time "$plugin") ))"

    if [ "$delta" -lt "$interval" ]; then
        value="$(get_cache "$plugin")"
    else
        value="$(set_cache "$plugin" "$cache_miss_fn")"
    fi

    echo "$value"
}

