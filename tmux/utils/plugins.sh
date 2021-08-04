#!/bin/sh

# Get script location (OK even if it is a link because
# support scripts should also be linked here)
# PWD=$(dirname "$0")
# test "$PWD" == "." && PWD=$(pwd)
# source "$PWD/utils/cache.sh"
PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/cache.sh

function plugin() {
    $PLUGINS/plugins/$1.tmux
}

