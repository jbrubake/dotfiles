#!/bin/bash --login

# vim: filetype=sh

# FIXME: Make this more robust. Set options through
#        variables at the begining. Maybe have app lists?

#
# What windowmanager am I using?
#
# Currently supports:
#   dwm
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
# if [ `which xbindkeys` ]; then
# xbindkeys &
# fi

#
# Start daemons
#
if [ `which urxvtd` ]; then
    urxvtd -q -o -f
fi
if [ `which unclutter` ]; then
    unclutter -root &
fi
if [ `which xscreensaver` ]; then
    xscreensaver &
elif [ `which gnome-screensaver` ]; then
    gnome-screensaver &
fi
if [ `which dropbox` ]; then
    dropbox start &    
fi
#if [ `which gpg-agent` ]; then
    #gpg-agent --daemon
#fi

#
# Start WM
#
case $WINDOWMANAGER in
    fluxbox)
        fluxbox & wmpid=$! # Don't remember what this does
        ;;
    dwm)
        #dwm & wmpid=$!
        ~/src/dwm/dwm & wmpid=$!
        ;;
    # Default to twm
    *)
        twm & wmpid=$!
        ;;
esac

#
# Set wallpaper
#
#Esetroot "$HOME/pixmaps/wallpaper.jpg"
#feh --bg-scale "$HOME/Misc/pixmaps/Wallpaper/wallpaper.jpg"

#
# Start desktop apps
#
#ipager &
#tint2 -c ~/.tintrc &
#trayer --edge top --align right --margin 0 --widthtype request \
#    --height 24 --SetDockType false --transparent true --alpha 255 &
#volumeicon &
#$HOME/.conky/start_conky.sh start
#keepassx &

#
# Start apps
#
#pidgin &
#urxvt -name main_terminal  -tr -fg white \
#    -e sh -c "screen -c ~/.screenrc -dR MAIN"  &
#urxvt -name devel_terminal -tr -fg white \
#    -e sh -c "screen -c ~/.screenrc -dR DEVEL" &

#
# Set up composite manager (must be after ipager)
#
#xcompmgr &

# Wait for WM to exit
wait $wmpid

# Do any necessary clean up
