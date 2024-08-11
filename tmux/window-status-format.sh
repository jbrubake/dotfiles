#!/bin/sh

bar="black"

case "$1" in
    *Z*)  fg=yellow; bg=$bar; other=none; pre='['; post=']' ;; # zoomed
    *\**) fg=green;  bg=$bar; other=bold; pre=''; post='' ;; # current
    *#*)  fg=red;    bg=$bar; other=none; pre='['; post=']' ;; # activity
    *!*)  fg=yellow; bg=$bar; other=none; pre='['; post=']' ;; # bell
    *-*)  fg=white;  bg=$bar; other=none; pre='['; post=']' ;; # last
    *~*)  fg=green;  bg=$bar; other=none; pre='['; post=']' ;; # silent
    *M*)  fg=green;  bg=$bar; other=none; pre='['; post=']' ;; # marked
    *)    fg=grey;   bg=$bar; other=none; pre='['; post=']' ;; # other
esac

printf "#[fg=%s,bg=%s,%s]%s#I#F #W%s" "$fg" "$bg" "$other" "$pre" "$post"

