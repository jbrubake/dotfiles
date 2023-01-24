#!/bin/sh

PLUGINS=$(tmux show-option -gqv @plugin_dir)
source $PLUGINS/utils/plugins.sh

printf "#[fg=white,bg=black]"
printf " #[fg=yellow]%s %s #[fg=white]| %s#[fg=white]" "$(emojify :computer:)" "$(plugin mem_usage)" "$(plugin load)"
printf " |#[fg=green,bold] %s %s" "$(emojify :calendar:)" "$(plugin clock)"
printf "#[fg=white,none] | %s" "$(plugin weather)"
printf " "

