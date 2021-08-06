#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

printf "#[fg=white,bg=black]"
printf " #[fg=yellow]%s" "$(plugin mem_usage)"
printf " %s" "$(plugin load)"
printf " #[fg=green,bold]%s" "$(plugin clock)"
