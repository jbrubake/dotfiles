#!/usr/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 3600 )) # 1 hour

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source "$PLUGINS/utils/cache.sh"

get_updates() {
    dnf --refresh -q updateinfo --list |
        awk '
            BEGIN {
                total = 0
                security = 0
            }
            NF != 3 { next }
            /Sec./  { security++ }
                    { total++ }
            END { print security, total }'
}

get_value get_updates "$INTERVAL"
