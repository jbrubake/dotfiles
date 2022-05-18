#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

network_status() {
    vpn="$(plugin vpn_location)"
    status="$(plugin uplink)"

    if [ -n "$vpn" ]; then
        location="$vpn"
        color="#[fg=brightgreen]"
    else
        location="No VPN"
        color="#[fg=brightyellow]"
    fi

    case $status in
        [nN]*)
            color="#[fg=red]"
            location="No network"
            ;;
    esac

    echo "$color$location"
}

set -- $(plugin updates)
sec=$1
tot=$2
if [ $tot -gt 0 ]; then
    updates="$tot updates"
    if [ $sec -gt 0 ]; then
        updates="#[fg=blue,bold][$tot#[fg=red]($sec) #[fg=blue]updates]#[none] "
    fi
fi

home_network=$(plugin home-network)

printf "#[fg=white,bg=black]"
printf "#[fg=cyan]#h:#[fg=magenta]#S"
printf "#[fg=yellow]:up %s" "$(plugin uptime)"
printf " %s%s" "$(emojify :earth_americas:)" "$(network_status)"
if [ -n "$home_network" ]; then
    printf "#[fg=green] [%s]" "$home_network"
fi
printf "#[fg=white]  "

