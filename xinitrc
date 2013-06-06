#!/bin/bash --login

# vim: filetype=sh

# FIXME: Make this more robust. Set options through
#        variables at the begining. Maybe have app lists?

#
# What windowmanager am I using?
#
# Currently supports:
#   dwm
#   spectrwm
#   echinus
#   wmfs
#   fluxbox
#   twm
#
# Defaults to twm
#
WINDOWMANAGER=dwm

#
# Setup my keymap and merge my XResources
#
[ -r "$HOME/.Xmodmap" ]      && xmodmap "$HOME/.Xmodmap"
[ -r "$HOME/.Xresources" ]   && xrdb -merge "$HOME/.Xresources"
[ -r "$HOME/.Xdefaults" ]    && xrdb -merge "$HOME/.Xdefaults"

#
# xset options
#
# Disable repeat for multimedia keys
# xset -r 129 -r 231

#
# Key bindings
#
command -v xbindkeys >/dev/null && xbindkeys &

#
# Start daemons
#
#command -v urxvtd >/dev/null && urxvtd -q -o -f
command -v unclutter >/dev/null unclutter -root &
command -v dropbox.py >/dev/null dropbox.py start &    
command -v gpg-agent >/dev/null gpg-agent --daemon
if command -v xscreensaver >/dev/null; then
    xscreensaver &
elif command -v gnome-screensaver >/dev/null; then
    gnome-screensaver &
fi

#
# Start WM
#
case $WINDOWMANAGER in
    fluxbox)
        fluxbox & wmpid=$! # Don't remember what this does
        ;;
    dwm)
        ~/src/dwm/dwm & wmpid=$!
        dwm_statusbar.sh &
        ;;
    spectrwm)
        spectrwm & wmpid=$!
        ;;
    echinus)
        echinus & wmpid=$!
        ;;
    wmfs)
        wmfs & wmpid=$!
        ;;
    # Default to twm
    *)
        twm & wmpid=$!
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
#command -v ipager >/dev/null && ipager &
#command -v tint2  >/dev/null && tint2 -c ~/.tintrc &
#command -v trayer >/dev/null && trayer --edge top --align right --margin 0 \
                                       #--widthtype request --height 24 \
                                       #--SetDockType false --transparent true \
                                       #--alpha 255 &
#command -v volumeicon >/dev/null && volumeicon &
#command -v keepassx   >/dev/null && keepassx &
#if [ -x $HOME/.conky/start_conky.sh ]; then
    #$HOME/.conky/start_conky.sh start
#fi

#
# Start apps
#
#command -v pidgin >/dev/null && pidgin &
#if command -v urxvt >/dev/null; then
    #urxvt -name main_terminal  -tr -fg white -e sh \
           #-c "screen -c ~/.screenrc -dR MAIN"  &
    #urxvt -name devel_terminal -tr -fg white \
          #-e sh -c "screen -c ~/.screenrc -dR DEVEL" &
#fi

#
# Set up composite manager (must be after ipager)
#
#command -v xcompmgr >/dev/null && xcompmgr &

# Wait for WM to exit
wait $wmpid

# Do any necessary clean up
