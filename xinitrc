#!/bin/sh
# FIXME: Make this more robust. Set options through
# FIXME: variables at the begining. Maybe have app lists?

# Basic setup {{{1

# Where my WM init scripts live
INIT=~/etc/init.d

# Select Window Manager or Desktop Environment {{{2
#
# Supports:
#   dwm
#   Any WM/DE that is run as a single command with no arguments
#
# Default: run an instance of st
# TODO: Make this run whatever terminal is installed
#
WINDOWMANAGER=cwm

# Set wallpaper {{{1
#
if command -v feh >/dev/null; then
    feh --no-fehbg --bg-center $HOME/.wallpaper0 --bg-center $HOME/.wallpaper1
elif command -v xsetroot >/dev/null; then
    xsetroot \
        -mod "$(xrdb -query | awk '/xsetroot\.modx/ {print $2}')" \
             "$(xrdb -query | awk '/xsetroot\.mody/ {print $2}')" \
        -bg "$(xrdb -query | awk '/xsetroot\.background/ {print $2}')" \
        -fg "$(xrdb -query | awk '/xsetroot\.foreground/ {print $2}')"
fi

# Setup keymap and keybindings {{{1
#
test -x $INIT/keymaps.sh 2>&1 && $INIT/keymaps.sh
test -x $INIT/touchpad-tap.sh 2>&1 && $INIT/touchpad-tap.sh
command -v sxhkd >/dev/null && sxhkd &

# Merge XResources/XDefaults {{{1
test -r "$HOME/.Xresources" && xrdb -merge "$HOME/.Xresources"
test -r "$HOME/.Xdefaults"  && xrdb -merge "$HOME/.Xdefaults"

# xset options {{{1
#
# Turn off audible bell
xset b off

# Start daemons {{{1
#
# Group start:
# (\
# app1 && \
# app2 && \
# ) &
# Use sleep as necessary to sync things up)
command -v xautolock >/dev/null && xautolock &
command -v xbanish >/dev/null && xbanish &

# Start WM {{{1
#
case $WINDOWMANAGER in
dwm)
    while true; do
        xsetroot -name "$(date "+%F %R")"
        sleep 1m
    done &
    ~/src/dwm/dwm & wmpid=$!
    # dwm_statusbar.sh &
    ;;

cwm) ~/src/cwm/cwm & wmpid=$!  ;;

#
# This accepts any WM/DE that does not need specific start up.
# If WINDOWMANAGER isn't found, st is run instead
#
*)
    if command -v $WINDOWMANAGER >/dev/null; then
        $WINDOWMANAGER & wmpid=$!
    else
        st & wmpid=$!
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

if type flatpak >/dev/null 2>&1; then
    if $( flatpak list | grep Signal >/dev/null ); then
        flatpak run org.signal.Signal &
    fi
fi
type teams >/dev/null 2>&1 && teams

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
