#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

printf "#[fg=white,bg=black]"
printf " #[fg=magenta]Hero HP: %s%%" "$(plugin rpg)"
printf " #[fg=white]| #[fg=yellow]%s %s #[fg=white]|" "$(plugin mem_usage)" "$(plugin load)"
printf " #[fg=green,bold]%s" "$(plugin clock)"
printf "#[fg=white,none]%s" "$(plugin weather)"
printf " "

