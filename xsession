#!/bin/sh

# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

#
# Do login shell stuff
#
# My .profile sets $ENV so check that to see if .profile has
# already been sourced
if test -n "$ENV"; then
    . $HOME/.profile
fi

# Finish setting up
. ./.xinitrc

