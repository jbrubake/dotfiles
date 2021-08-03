#!/bin/sh

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PWD/functions.sh

printf "#[fg=white,bg=black] "
printf "#[fg=yellow]%s " "$(get_mem_usage)"
printf "#[fg=green,bold]%s " "$(get_dtg)"
