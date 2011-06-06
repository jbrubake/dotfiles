#!/bin/sh

#
# Presents a dialog box to verify that
# you really want to logout of X
#
# FIXME: Make it work under any window manager
#

#
# Message to print
#
message="Logout?"

pid=""

if xmessage -nearmouse -buttons no:1,yes:0 "$message"; then
    kill -TERM $(xprop -root _BLACKBOX_PID | awk '{print $3}')
fi
