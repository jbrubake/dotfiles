#!/bin/sh
#
# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

# Setup Environment {{{1
. "$HOME/.env"      # common environment

# Set a flag indicating X is the logon environment so
# .xinitrc can run login related stuff
_xlogin='yes'

# Start gpg and ssh agents {{{1
#
# Start keychain but do not load keys as xsession will hang
# as it cannot get any input
eval $( keychain --eval --nogui --agents ssh,gpg )


# Finish setting up {{{1
. ./.xinitrc

