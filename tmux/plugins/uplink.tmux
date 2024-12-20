#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 20 ))

uplink() {
    format=${1:-up,no dns, down}

    if getent ahosts www.google.com >/dev/null; then
        echo "$format" | cut -d, -f1
    elif ping -c1 1.1.1.1 >/dev/null 2>&1; then
        echo "$format" | cut -d, -f2
    else
        echo "$format" | cut -d, -f3
    fi
}

