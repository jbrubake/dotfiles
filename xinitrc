#!/bin/sh
# FIXME: Make this more robust. Set options through
# FIXME: variables at the begining. Maybe have app lists?

# Select Window Manager or Desktop Environment {{{1
#
# Supports:
#   dwm
#   Any WM/DE that is run as a single command with no arguments
#
# Default: twm
# TODO: Actual default should then be just an xterm in case twm isn't installed
#
WINDOWMANAGER=cwm

# Basic setup {{{1
# Where my WM init scripts live
#
INIT=~/etc/init.d

# Start WM {{{1
#
case $WINDOWMANAGER in
#
# Any WM/DE that needs specific start up
#
dwm)
    while true
    do
        xsetroot -name "$(date "+%F %R")"
        sleep 1m
    done &
    ~/src/dwm/dwm & wmpid=$!
    # dwm_statusbar.sh &
    ;;

cwm)
    cwm & wmpid=$!
    ;;

#
# This accepts any WM/DE that does not need specific start up.
# If WINDOWMANAGER isn't found, st is run instead
#
*)
    if command -v $WINDOWMANAGER >/dev/null
    then
        $WINDOWMANAGER & wmpid=$!
    else
        st & wmpid=$!
    fi
    ;;
esac

# xset options {{{1
#
# Disable repeat for special keys
# TODO: Use some variables to configure this
# xset -r 129 -r 231 # Multimedia keys

# Set wallpaper {{{1
#
#if command -v Esetroot >/dev/null; then
    #Esetroot "$HOME/pixmaps/wallpaper.jpg"
#elif command -v feh >/dev/null; then
    #feh --bg-scale "$HOME/Misc/pixmaps/Wallpaper/wallpaper.jpg"
#elif GNOME SETTINGS

# Start daemons {{{1
#
# Group start:
# (\
# app1 && \
# app2 && \
# ) &
# Use sleep as necessary to sync things up)
# command -v urxvtd >/dev/null && urxvtd -q -o -f
# command -v unclutter >/dev/null unclutter -root &
# command -v dropbox start >/dev/null &
# command -v gpg-agent >/dev/null gpg-agent --daemon
# if command -v xscreensaver >/dev/null; then
    # xscreensaver &
# elif command -v gnome-screensaver >/dev/null; then
    # gnome-screensaver &
# fi

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
#if command -v urxvt >/dev/null; then
    #urxvt -name main_terminal  -tr -fg white -e sh \
           #-c "screen -c ~/.screenrc -dR MAIN"  &
    #urxvt -name devel_terminal -tr -fg white \
          #-e sh -c "screen -c ~/.screenrc -dR DEVEL" &
#fi

type 2>&1 >/dev/null xfortune && xfortune ~/share/games/fortunes

# Run this stuff forever {{{1
#
# while true; do
    # stuff to run forever
    # e.g. setting variables for scripts to watch
    # such as temperature or IP address
    # sleep 20s # Reasonable CPU cycles
# done &

# Setup keymap {{{1
#
# The delay is needed in Fedora under Gnome or these don't take effect
sleep 3
test -x $INIT/keymaps.sh 2>&1 && $INIT/keymaps.sh

# Key bindings {{{1
#
command -v xbindkeys >/dev/null && xbindkeys &

# Merge XResources/XDefaults {{{1
test -r "$HOME/.Xresources" && xrdb -merge "$HOME/.Xresources"
test -r "$HOME/.Xdefaults"  && xrdb -merge "$HOME/.Xdefaults"

# Wait for WM to exit {{{1
wait $wmpid

# Do any necessary clean up
