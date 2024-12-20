#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 10 ))

vpn_status() {
    echo $@ >&2
    interface=$1; server=$2; name=$3

    if ip --brief address | grep -q "^$interface"; then
        if ping -c1 "$server" >/dev/null 2>&1; then
            echo "#[fg=${TMUX_COLOR_GREEN:-green}]$name"
        else
            echo "#[fg=${TMUX_COLOR_YELLOW:-yellow}]$name"
        fi
    else
        echo "#[fg=${TMUX_COLOR_RED:-red}]$name"
    fi
}

