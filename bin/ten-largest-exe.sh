#!/bin/sh

#
# Prints names of ten largest executables
#
# FIXME: Make this more useful. Maybe use $PATH?
#

ls -l /bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin \
    | awk '{ print $5" "$8 }' | sort -n -k 1 -r | head
