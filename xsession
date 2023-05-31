#!/bin/sh
#
# This file should only contain setup required when logging
# directly into X. Setup should be the same after that

# Setup Environment {{{1
. "$HOME/.env"      # common environment

# Set a flag indicating X is the logon environment so
# .xinitrc can run login related stuff
_xlogin='yes'

# Finish setting up {{{1
. $HOME/.xinitrc

