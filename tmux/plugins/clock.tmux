#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60

clock() {
    if [ -n "$1" ]; then
        date "+$1"
    else
        date
    fi
}

