#!/bin/sh

# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

#
# Do login shell stuff
#
if test -r $HOME/.bash_profile; then
    . $HOME/.bash_profile
else
    . $HOME/.profile
fi

# Finish setting up
source .xsession

