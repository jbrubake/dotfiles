#!/bin/sh

# Basic setup {{{1

# Where my WM init scripts live
# init_dir="$XDG_CONFIG_HOME/init.d"
init_dir="$HOME/etc/init.d"

# xset options {{{1
#
command -v xset >/dev/null && xset b off # Turn off audible bell

# Run custom X init scripts {{{1
#
for f in $init_dir/*; do
    [ -x "$f" ] && $f
done

# Merge XResources {{{1
command -v xrdb >/dev/null &&
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
command -v mopidy >/dev/null     && mopidy &

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

# Show login related things {{{1
#
# These are tasks that would be run in ~/.xsession except that
# they need to run *after* the window manager is launched
#
# Simple test to see if startx was executed
if ! ps x | grep [s]tartx; then
    command -v xfortune >/dev/null && xfortune "$HOME/share/games/fortunes"

    if command -v keychain >/dev/null; then
        if command -v my >/dev/null; then
            t=$(my -v terminal)
        else
            t=xterm
        fi
        # Find all SSH public keys and add the corresponding private key
        #
        # Using basename to remove the extension doesn't work because keychain
        # cannot find the key without the entire path
        # The --confhost option to keychain is supposed to use IdentityFile
        # to find the key path but I cannot get that to work
        $t -e keychain --quiet --nogui --ignore-missing \
            $(find "$HOME/.ssh" -name '*.pub' | rev | cut -f 2- -d. | rev)
    fi
fi

# Start desktop apps {{{1
#
command -v signal-desktop >/dev/null && signal-desktop

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
command -v virsh >/dev/null &&
    virsh list | awk '/[[:digit:]]/ {print $2}' | xargs virsh shutdown

