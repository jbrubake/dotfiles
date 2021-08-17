#!/bin/sh

id=$(xinput | grep Touchpad | sed -e 's/.*id=\([^\t]*\).*$/\1/')
prop=$(xinput list-props $id | grep 'Tapping Enabled (' | sed -e 's/^.*(\([^)]*\)).*$/\1/')
xinput set-prop $id $prop 1

