#!/bin/sh

# vim: filetype=sh

# FIXME: Make this more robust. Set options through
#        variables at the begining. Maybe have app lists?

#
# Source my environment
#
test -r $HOME/.shenv && . $HOME/.shenv
export PATH=/home/jbrubake/local/bin:/home/jbrubake/bin:$PATH
#
# What WM am I running?
#
# Currently supports:
#   dwm
#   Any WM that is run as a single command with no arguments
#
# Defaults to twm
#
WINDOWMANAGER=dwm

#
# Where my WM init scripts live
#
INIT=~/.config/init.d

#
# Setup keymap and merge XResources/XDefaults
#
test -r "$HOME/.Xmodmap"    && xmodmap     "$HOME/.Xmodmap"
test -r "$HOME/.Xresources" && xrdb -merge "$HOME/.Xresources"
test -r "$HOME/.Xdefaults"  && xrdb -merge "$HOME/.Xdefaults"

#
# xset options
#
# Disable repeat for special keys
# TODO: Use some variables to configure this
# xset -r 129 -r 231 # Multimedia keys

#
# Key bindings
#
# command -v xbindkeys >/dev/null && xbindkeys &

#
# Start daemons
#
# Group start:
# (\
# app1 && \
# app2 && \
# ) &
# Use sleep as necessary to sync things up)
#command -v urxvtd >/dev/null && urxvtd -q -o -f
# command -v unclutter >/dev/null unclutter -root &
# command -v dropbox start >/dev/null &
# command -v gpg-agent >/dev/null gpg-agent --daemon
# if command -v xscreensaver >/dev/null; then
    # xscreensaver &
# elif command -v gnome-screensaver >/dev/null; then
    # gnome-screensaver &
# fi

#
# Start WM
#
case $WINDOWMANAGER in
#
# Any WM that need specific start up
#
dwm)
    ~/local/bin/dwm & wmpid=$!
    # dwm_statusbar.sh &
    ;;

#
# This accepts any WM that don't need specific
# start up. If WINDOWMANAGER isn't found, twm
# is run instead
#
*)
    if command -v $WINDOWMANAGER >/dev/null
    then
        $WINDOWMANAGER & wmpid=$!
    else
        twm & wmpid=$!
    fi
    ;;
esac

#
# Set wallpaper
#
#if command -v Esetroot >/dev/null; then
    #Esetroot "$HOME/pixmaps/wallpaper.jpg"
#elif command -v feh >/dev/null; then
    #feh --bg-scale "$HOME/Misc/pixmaps/Wallpaper/wallpaper.jpg"

#
# Start desktop apps
#
# test -e $INIT/conky.sh      && . $INIT/conky.sh start
# test -e $INIT/tint2.sh      && . $INIT/tint2.sh start
# test -e $INIT/ipager.sh     && . $INIT/ipager.sh start
# test -e $INIT/trayer.sh     && . $INIT/trayer.sh start
# test -e $INIT/bmpanel.sh    && . $INIT/bmpanel.sh start
# test -e $INIT/volumeicon.sh && . $INIT/volumeicon.sh start
# test -e $INIT/keepassx.sh   && . $INIT/keepassx.sh start

#
# Start apps
#
#if command -v urxvt >/dev/null; then
    #urxvt -name main_terminal  -tr -fg white -e sh \
           #-c "screen -c ~/.screenrc -dR MAIN"  &
    #urxvt -name devel_terminal -tr -fg white \
          #-e sh -c "screen -c ~/.screenrc -dR DEVEL" &
#fi

#
# Run this stuff forever
#
# while true; do
    # stuff to run forever
    # e.g. setting variables for scripts to watch
    # such as temperature or IP address
    # sleep 20s # Reasonable CPU cycles
# done &

# Wait for WM to exit
wait $wmpid

# Do any necessary clean up
