#!/bin/sh

function get_load() {
    uptime | awk -F: '{printf $NF}' | tr -d ','
}

function get_mem_usage() {
    free -h | awk 'NR == 2 {printf("%s/%s", $3, $2)}'
}

function is_vpn_on() {
    [ -d /sys/class/net/tun0 ] && echo "VPN"
}

function get_dtg() {
    date +" %a, %d-%b %H:%M"
}
