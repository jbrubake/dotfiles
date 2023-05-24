#!/bin/sh

# -layout us                          : US keyboard
# -variant altgr-intl                 : enable 3rd level symbols
# -option                             : clear options
# -option keypad:pointerkeys          : enable mousekeys
# -option shift:both_caps_lock_cancel : L_Shift+R_Shift = CapsLock; any Shift cancels
# -option compose:rctrl               : R_Ctrl = Compose
# -option ctrl:nocaps                 : CapsLock = L_Ctrl
setxkbmap -layout us -variant altgr-intl \
    -option \
    -option keypad:pointerkeys \
    -option shift:both_capslock_cancel \
    -option compose:rctrl \
    -option ctrl:nocaps

# Keep xmodmap stuff here so all the keyboard
# configuration is in a single file

# 37 (Left Ctrl) = ISO_level3_Shift
# 108 (Right Alt) = Left Alt
#
xmodmap -e "clear lock"
xmodmap -e "clear control"
xmodmap -e "clear mod1"
xmodmap -e "clear mod2"
xmodmap -e "clear mod3"
xmodmap -e "clear mod4"
xmodmap -e "clear mod5"
xmodmap -e "keycode 37 = ISO_Level3_Shift"
xmodmap -e "keycode 108 = Alt_L"
xmodmap -e "add control = Control_L"
xmodmap -e "add mod1 = Alt_L Meta_L"
xmodmap -e "add mod2 = Num_Lock"
xmodmap -e "add mod4 = Super_L"

if command -v xcape 2>&1 >/dev/null; then
    xcape -e 'Control_L=Escape' # Control_L (Caps_Lock key) = Escape by itself
    xcape -e 'Super_L=Super_R' # Super_L = Super_R by itself
fi

if command -v sxhkd >/dev/null 2>&1; then
    # Start sxhkd in $HOME, otherwise everything it
    # starts will start in /
    cd "$HOME"
    sxhkd &
fi

