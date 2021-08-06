#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

vpn="$(plugin vpn_location)"
if [ -n "$vpn" ]; then
    ip="#[fg=green]$vpn"
else
    ip="#[fg=red]No VPN"
fi

set -- $(plugin updates)
sec=$1
tot=$2
if [ $tot -gt 0 ]; then
    updates="$tot updates"
    if [ $sec -gt 0 ]; then
        updates="#[fg=blue,bold][$tot#[fg=red]($sec) #[fg=blue]updates]#[none] "
    fi
fi


printf "#[fg=white,bg=black]"
printf "%s" "$updates"
printf "#[fg=cyan]#h:#[fg=magenta]#S"
printf "#[fg=yellow]:%s " "$(plugin uptime)"
printf "%s%s" "$(emojify :earth_americas:)" "$ip "
printf "#[fg=white] "
