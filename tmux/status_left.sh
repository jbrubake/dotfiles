#!/bin/sh

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PWD/functions.sh

printf "#[fg=white,bg=black] "
printf "#[fg=cyan]#h:#S:[#I] "
printf "#[fg=white] "
