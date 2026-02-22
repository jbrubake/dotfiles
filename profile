#!/bin/sh
#
# ~/.profile: sh-specific and generic login configuration
#

# This file does non-X login stuff so return
# if some DM decides it should be sourced
if [ -n "$DISPLAY" ]; then
    return 2>/dev/null || exit
fi

# Setup Environment {{{1
. "$HOME/.env" # common environment

# Run setup scripts {{{1
#
# for f in "$XDG_CONFIG_HOME/init.d/"*; do
for f in "$HOME/etc/init.d/"*; do
    [ -x "$f" ] && "$f"
done

command -v keychain >/dev/null && eval $(keychain --eval --agents gpg,ssh)

# MOTD {{{1
#
if [ -e /run/motd.dynamic ]; then
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
        [ -x /usr/sbin/crond ] &&
            sudo /usr/sbin/crond -p 2>/dev/null
        command -v anacron >/dev/null &&
            anacron -s -t "$HOME/etc/anacrontab" -S "$HOME/var/spool/anacron"
        ;;

esac

# vim: foldlevel=0

