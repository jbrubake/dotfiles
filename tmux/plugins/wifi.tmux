#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 20 ))

wifi() {
    nmcli -t -f active,ssid dev wifi | grep ^yes | cut -d: -f2
}

