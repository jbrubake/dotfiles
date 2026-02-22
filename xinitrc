#!/bin/sh

command -v have >/dev/null || have() { command -v "$1" >/dev/null; }

# Basic setup {{{1

# xset options {{{1
#
have xset && xset b off # Turn off audible bell

# Merge XResources {{{1
have xrdb &&
    if [ -r "$HOME/.Xresources" ]; then
        unset colorscheme
        [ -r "$HOME/.Xresources.$COLORSCHEME" ] &&
            colorscheme="-DCOLORSCHEME=<$HOME/.Xresources.$COLORSCHEME>"
        xrdb -merge "$HOME/.Xresources" "$colorscheme"
        unset colorscheme
    fi

# Start daemons {{{1
#
# Group start:
# (\
# app1 && \
# app2 && \
# ) &
# Use sleep as necessary to sync things up)
have xautolock && xautolock &
have xbanish   && xbanish &
have mopidy    && mopidy &
have atworkd   && atworkd &

# Start WM {{{1
#
case $WINDOWMANAGER in
dwm)
    while true; do
        xsetroot -name "$(date "+%F %R")"
        sleep 1m
    done &
    "$HOME/src/dwm/dwm" & wmpid=$!
    # dwm_statusbar.sh &
    ;;

#
# This accepts any WM/DE that does not need specific start up.
# If WINDOWMANAGER isn't found, a terminal emulator is run instead
#
*)
    if have "$WINDOWMANAGER"; then
        "$WINDOWMANAGER" & wmpid=$!
    else
        term="st gnome-terminal rxvt xterm"
        for t in $term; do
            if have "$t"; then
                $t & wmpid=$!
                break
            fi
        done
    fi
    ;;
esac

# Setup scripts {{{1
#
# Because we need to run X-related scripts this will also
# pull in non-X scripts that will have already run if we
# logged in via the console. Any such scripts that should
# not be run again need to be guarded appropriately
#
# for f in "$XDG_CONFIG_HOME/init.d/"*; do
for f in "$HOME/etc/init.d/"*; do
    [ -x "$f" ] && "$f"
done

command -v keychain >/dev/null && eval $(keychain --eval --agents gpg,ssh)

# Load tmuxp sessions
have tmuxp &&
    for s in $(tmuxp ls); do
        tmuxp load -d "$s"
    done

# Show login related things {{{1
#
# These are tasks that would be run in ~/.xsession except that
# they need to run *after* the window manager is launched
#
# Simple test to see if startx was executed
if ! pgrep startx; then
    have xfortune && xfortune "${XDG_DATA_HOME:-"$HOME/.local/share"}/games/fortunes"
fi

# Start desktop apps {{{1
#
have signal-desktop && signal-desktop
have discord        && discord
have firefox        && firefox &
have launchterm     && launchterm main

# Run this stuff forever {{{1
#
# while true; do
    # stuff to run forever
    # e.g. setting variables for scripts to watch
    # such as temperature or IP address
    # sleep 20s # Reasonable CPU cycles
# done &

# Cleanup {{{1
wait "$wmpid" # wait for WM to exit

# Gracefully shutdown virtual machines {{{2
#
have virsh &&
    virsh list | awk '/[[:digit:]]/ {print $2}' | xargs virsh shutdown
have vboxmanage &&
    vboxmanage list runningvms | sed 's/.*{\(.*\)}/\1/' | xargs -I{} vboxmanage controlvm '{}' acpipowerbutton
have vmrun &&
    vmrun -T ws list | sed 1d | xargs vmrun -T ws stop

