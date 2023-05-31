#!/bin/sh

# Basic setup {{{1

# Where my WM init scripts live
INIT=~/etc/init.d

# xset options {{{1
#
xset b off # Turn off audible bell

# Setup displays, keymap and keybindings {{{1
#
test -x $INIT/displays.sh     && $INIT/displays.sh
test -x $INIT/keymaps.sh      && $INIT/keymaps.sh
test -x $INIT/touchpad-tap.sh && $INIT/touchpad-tap.sh
test -x $INIT/wallpaper.sh    && $INIT/wallpaper.sh

# Merge XResources {{{1
if [ -r "$HOME/.Xresources" ]; then
    test -r "$HOME/.Xresources.$COLORSCHEME" &&
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
command -v xautolock >/dev/null  && xautolock &
command -v xbanish >/dev/null    && xbanish &
command -v streamdeck >/dev/null && streamdeck &
command -v mopidy >/dev/null     && mopidy &

# Show login related things {{{1
#
# This has to be done here instead of in .xsession
# because it needs to be done *after* setting up the display and keyboard
#
if [ $_xlogin == 'yes' ]; then
    type >/dev/null 2>&1 xfortune && xfortune "$HOME/share/games/fortunes"
    if type >/dev/null 2>&1 my; then
        t=$(my -v terminal)
    else
        t=xterm
    fi
    $t -e keychain --quiet --nogui --ignore-missing $(cat "$HOME/.keychain/keylist")
    unset _xlogin
fi

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

# Start desktop apps {{{1
#
# test -e $INIT/conky.sh      && . $INIT/conky.sh start
# test -e $INIT/tint2.sh      && . $INIT/tint2.sh start
# test -e $INIT/ipager.sh     && . $INIT/ipager.sh start
# test -e $INIT/trayer.sh     && . $INIT/trayer.sh start
# test -e $INIT/bmpanel.sh    && . $INIT/bmpanel.sh start
# test -e $INIT/volumeicon.sh && . $INIT/volumeicon.sh start
# test -e $INIT/keepassx.sh   && . $INIT/keepassx.sh start

test -e $INIT/cassowary   && . $INIT/cassowary start

if type flatpak 2>&1 >/dev/null; then
    flatpak list | grep Signal >/dev/null && flatpak run org.signal.Signal &
fi
# type teams 2>&1 >/dev/null && teams

# Start other apps {{{1
#

# Run this stuff forever {{{1
#
# while true; do
    # stuff to run forever
    # e.g. setting variables for scripts to watch
    # such as temperature or IP address
    # sleep 20s # Reasonable CPU cycles
# done &

# Wait for WM to exit {{{1
wait $wmpid

# Do any necessary clean up
if command -v virsh >/dev/null; then
    virsh list | awk '/[[:digit:]]/ {print $2}' | xargs virsh shutdown
fi

