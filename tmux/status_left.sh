#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

vpn="$(plugin vpn_location)"
if [ -n "$vpn" ]; then
    ip="#[fg=green]$vpn"
else
    ip="#[fg=red]No VPN"
fi

printf "#[fg=white,bg=black] "
printf "#[fg=cyan]#h:#S:[#I] "
printf "%s%s" "$(emojify :earth_americas:)" "$ip "
printf "#[fg=white] "
