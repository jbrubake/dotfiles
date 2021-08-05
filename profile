#!/bin/sh
#
# ~/.profile: sh-specific and generic login configuration
#

# This file does non-X login stuff so return
# if some DM decides it should be sourced
if test -n "$DISPLAY"; then
    return 2>/dev/null || exit
fi

# Setup Environment {{{1
. "$HOME/.env"      # common environment

# Start gpg and ssh agents {{{1
#
# Keys are loaded in ~/.bashrc to make sure all terminals in X load keys
eval $( keychain --eval --agents ssh,gpg )

# MOTD {{{1
if test  -e /run/motd.dynamic; then
    cat /run/motd.dynamic
else
    uname -npsr
    printf "%s\n\n" "Uptime: $( uptime )"
fi

# System-specific Configuration {{{1
case "$(uname -o)" in
    *) ;;
esac
case "$(uname -r)" in
    *Microsoft*) # WSL
        sudo /usr/sbin/crond -p
        ;;

esac

#vim: foldlevel=0
