#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

system="$(emojify :computer:)"
calendar="$(emojify :calendar:)"

printf "#[fg=white,bg=black]"
printf " #[fg=yellow]%s %s #[fg=white]| %s#[fg=white]" "$system" "$(plugin mem_usage)" "$(plugin load)"
printf " |#[fg=green,bold] %s %s" "$calendar" "$(plugin clock)"
printf "#[fg=white,none] | %s" "$(plugin weather)"
printf " "

