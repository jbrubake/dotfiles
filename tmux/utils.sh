#!/bin/sh
#
[ -n "$TMUX_PLUGIN_DIR" ] && return
# Base plugin directory
export TMUX_PLUGIN_DIR=$(tmux show-option -gqv @plugin_dir)

# plugin {{{1
#
# @description Execute a plugin and return its (possibly cached) output
#
# @arg $1 str Name of the plugin to load
# @arg $@ ?   Arguments to pass to the plugin
#
# @stdout Plugin output
#
plugin() {
    plugin=$1; shift
    . $TMUX_PLUGIN_DIR/plugins/$plugin.tmux

    # Default INTERVAL is 5 minutes
    get_value "$plugin" "${INTERVAL:-300}" "$@"
}

# Cache functions {{{1
#
# Usage:
#     get_value <command> <interval> <args>
#
#         <command> is the command to run, cache and print. <command> is used as
#         the name of the cache
#         <interval> is the number of seconds until the cache is invalid
#         <args> are passed to <command>
#
#     clear_cache <name>
#         Forcibly clear the cache <name>
#
# Based on the caching function in https://github.com/odedlaz/tmux-status-variables

TMUX_PLUGIN_CACHE=${XDG_CACHE_HOME:-~/.cache}/tmux
[ ! -d "$TMUX_PLUGIN_CACHE" ] && mkdir -p "$TMUX_PLUGIN_CACHE"

# get_value {{{2
#
# @description Get a cached value if available, otherwise get and cache a new value
#
# @arg $1 str command to run if cache is invalid
# @arg $2 int interval in seconds until cache is invalid
# @arg $@ ?   arguments to pass to 
#
# @stdout cached or new value
#
get_value() {
    case $# in
        0) return ;;                           # no plugin to run
        1) plugin=$1; interval=300; shift 1 ;; # use default interval
        *) plugin=$1; interval=$2;  shift 2 ;;
    esac

    delta="$(( $(now) - $(get_cache_time "$plugin") ))"

    if [ "$delta" -lt "$interval" ]; then
        get_cache "$plugin"
    else
        set_cache "$plugin" "$@"
    fi
}

# get_cache {{{2
#
# @description Get a cached value
#
# @arg $1 str cache name
#
# @stdout Cached value
#
get_cache() { cat "$(get_cache_fn "$1")"; }

# set_cache {{{2
#
# @description Set and print a cached value
#
# @arg $1 cache name to set
# @arg $2 command to run and cache
#
# @stdout new cached value
#
set_cache() {
    function=$1; shift
    "$function" "$@" | tee "$(get_cache_fn "$function")"
}

# get_cache_fn {{{2
#
# @description Get the file path of a cache
#
# @arg $1 str Cache name
#
# @stdout Path to cache
#
get_cache_fn() { echo "$TMUX_PLUGIN_CACHE/$1.cache"; }

# get_cache_time {{{2
#
# @desccription Get the time the cache was last updated
#
# @arg $1 cache name
#
# @stdout Time of last update in seconds since the epoch
#
get_cache_time() {
    __cache_fn=$(get_cache_fn "$1")
    stat --format %Y "$__cache_fn" 2>/dev/null &&
        [ -s "$__cache_fn" ] ||
        echo "0"
}

# clear_cache {{{2
#
# @ Clear a cache
#
# @arg $1 str Name of cache to clear
#
clear_cache() { rm -f "$(get_cache_fn)"; }

# Other functions {{{1
#
# now {{{2
#
# @description Print the time in seconds from the epoch (not POSIX-compliant)
#
# @noarg
#
# @stdout Seconds since the epoch
#
now() { date +%s; }

# colorize {{{2
#
# Colorize stuff
colorize() {
    [ -n "$TMUX_NOCOLOR" ] && return

    # Discard any decimal
    n=$(echo "$1" | sed 's/\.*$//')

    if [ $n -lt $2 ]; then
        color=${TMUX_COLOR_RED:-red}
    elif [ $n -lt $3 ]; then
        color=${TMUX_COLOR_YELLOW:-yellow}
    else
        color=${TMUX_COLOR_GREEN:-green}
    fi

    printf "#[fg=%s]" "$color"
}

