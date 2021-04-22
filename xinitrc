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
WINDOWMANAGER=gnome-session

# Basic setup {{{1
# Where my WM init scripts live
#
INIT=~/.config/init.d

# Start WM {{{1
#
case $WINDOWMANAGER in
#
# Any WM/DE that needs specific start up
#
dwm)
    ~/local/bin/dwm & wmpid=$!
    # dwm_statusbar.sh &
    ;;

#
# This accepts any WM/DE that does not need specific start up.
# If WINDOWMANAGER isn't found, twm is run instead
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

# xset options {{{1
#
# Disable repeat for special keys
# TODO: Use some variables to configure this
# xset -r 129 -r 231 # Multimedia keys

# Key bindings {{{1
#
# command -v xbindkeys >/dev/null && xbindkeys &

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

# -layout us                 : US keyboard
# -variant altgr-intl        : enable 3rd level symbols
# -option                    : clear options
# -option lv3:switch         : Control_R = AltGr
# -option keypad:pointerkeys : enable mousekeys
setxkbmap -layout us -variant altgr-intl \
    -option \
    -option keypad:pointerkeys \
    -option shift:both_capslock_cancel

# Keep xmodmap stuff here so all the keyboard
# configuration is in a single file
xmodmap -e "clear lock"
xmodmap -e "clear control"
xmodmap -e "clear mod1"
xmodmap -e "clear mod2"
xmodmap -e "clear mod3"
xmodmap -e "clear mod4"
xmodmap -e "clear mod5"
xmodmap -e "keycode 66 = Control_L"
xmodmap -e "keycode 105 = Multi_key"
xmodmap -e "keycode 37 = ISO_Level3_Shift"
xmodmap -e "keycode 108 = Alt_L"
xmodmap -e "add control = Control_L"
xmodmap -e "add mod1 = Alt_L Meta_L"
xmodmap -e "add mod2 = Num_Lock"
xmodmap -e "add mod4 = Super_L"

# Control_L (Caps_Lock key) = Escape by itself
xcape -e 'Control_L=Escape'

# Merge XResources/XDefaults {{{1
test -r "$HOME/.Xresources" && xrdb -merge "$HOME/.Xresources"
test -r "$HOME/.Xdefaults"  && xrdb -merge "$HOME/.Xdefaults"

# Wait for WM to exit {{{1
wait $wmpid

# Do any necessary clean up
