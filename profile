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
eval $( keychain --eval --nogui --agents ssh,gpg )
# Find all SSH public keys and add the corresponding private key
#
# Using basename to remove the extension doesn't work because keychain
# cannot find the key without the entire path
# The --confhost option to keychain is supposed to use IdentityFile
# to find the key path but I cannot get that to work
keychain --quiet --nogui --ignore-missing \
    $(find "$HOME/.ssh" -name '*.pub' | rev | cut -f 2- -d. | rev)

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
    *icrosoft*) # WSL
        sudo /usr/sbin/crond -p 2>/dev/null
        anacron -s -t $HOME/etc/anacrontab -S $HOME/var/spool/anacron
        ;;

esac

#vim: foldlevel=0

