#!/bin/sh

bar="black"

case "$1" in
    *Z*) fg=yellow;   bg=$bar; other=none ;; # zoomed
    *\**) fg=green;   bg=$bar; other=bold ;; # current
    *#*) fg=red;    bg=$bar; other=none ;; # activity
    *!*) fg=yellow; bg=$bar; other=none ;; # bell
    *-*) fg=white;  bg=$bar; other=none ;; # last
    *~*) fg=green;   bg=$bar; other=none ;; # silent
    *M*) fg=green;   bg=$bar; other=none ;; # marked
    *)   fg=grey;   bg=$bar; other=none ;; # other
esac

printf "#[fg=$fg,bg=$bg,$other]#I#F #W"
