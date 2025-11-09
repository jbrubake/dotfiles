#!/bin/sh

# Basic setup {{{1

# xset options {{{1
#
command -v xset >/dev/null && xset b off # Turn off audible bell

# Merge XResources {{{1
command -v xrdb >/dev/null &&
    if [ -r "$HOME/.Xresources" ]; then
        unset colorscheme
        [ -r "$HOME/.Xresources.$COLORSCHEME" ] &&
            colorscheme="-DCOLORSCHEME=<$HOME/.Xresources.$COLORSCHEME>"
        xrdb -merge "$HOME/.Xresources" $colorscheme
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
command -v xautolock >/dev/null && xautolock &
command -v xbanish   >/dev/null && xbanish &
command -v mopidy    >/dev/null && mopidy &

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
    if command -v $WINDOWMANAGER >/dev/null; then
        $WINDOWMANAGER & wmpid=$!
    else
        term="st gnome-terminal rxvt xterm"
        for t in $term; do
            if command -v "$t" >/dev/null; then
                $t & wmpid=$!
                break
            fi
        done
    fi
    ;;
esac

# Run custom X init scripts {{{1
#
# for f in "$XDG_CONFIG_HOME/init.d/"*; do
for f in "$HOME/etc/init.d/"*; do
    [ -x "$f" ] && "$f"
done

# Show login related things {{{1
#
# These are tasks that would be run in ~/.xsession except that
# they need to run *after* the window manager is launched
#
# Simple test to see if startx was executed
if ! ps x | grep [s]tartx; then
    command -v xfortune >/dev/null && xfortune "$HOME/share/games/fortunes"
fi

# Start desktop apps {{{1
#
command -v signal-desktop >/dev/null && signal-desktop
command -v discord        >/dev/null && discord
command -v firefox        >/dev/null && firefox &

# Run this stuff forever {{{1
#
# while true; do
    # stuff to run forever
    # e.g. setting variables for scripts to watch
    # such as temperature or IP address
    # sleep 20s # Reasonable CPU cycles
# done &

# Cleanup {{{1
wait $wmpid # wait for WM to exit

# Gracefully shutdown virtual machines {{{2
#
command -v virsh >/dev/null &&
    virsh list | awk '/[[:digit:]]/ {print $2}' | xargs virsh shutdown
command -v vboxmanage >/dev/null &&
    vboxmanage list runningvms | sed 's/.*{\(.*\)}/\1/' | xargs -I{} vboxmanage controlvm '{}' acpipowerbutton
command -v vmrun >/dev/null &&
    vmrun -T ws list | sed 1d | xargs vmrun -T ws stop

