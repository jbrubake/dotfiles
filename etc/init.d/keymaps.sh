#!/bin/sh

# -layout us                 : US keyboard
# -variant altgr-intl        : enable 3rd level symbols
# -option                    : clear options
# -option lv3:switch         : Control_R = AltGr
# -option keypad:pointerkeys : enable mousekeys
setxkbmap -layout us -variant altgr-intl \
    -option \
    -option keypad:pointerkeys \
    -option shift:both_capslock_cancel

# Keep xmodmap stuff here so all the keyboard
# configuration is in a single file
xmodmap -e "clear lock"
xmodmap -e "clear control"
xmodmap -e "clear mod1"
xmodmap -e "clear mod2"
xmodmap -e "clear mod3"
xmodmap -e "clear mod4"
xmodmap -e "clear mod5"
xmodmap -e "keycode 66 = Control_L"
xmodmap -e "keycode 105 = Multi_key"
xmodmap -e "keycode 37 = ISO_Level3_Shift"
xmodmap -e "keycode 108 = Alt_L"
xmodmap -e "add control = Control_L"
xmodmap -e "add mod1 = Alt_L Meta_L"
xmodmap -e "add mod2 = Num_Lock"
xmodmap -e "add mod4 = Super_L"

# Control_L (Caps_Lock key) = Escape by itself
type xcape 2>&1 >/dev/null && xcape -e 'Control_L=Escape'

