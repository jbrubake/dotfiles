#!/bin/bash
#
# Display ANSI colours.
#
esc="\033["

echo "                                     BG Codes"
echo "  FG    -----------------------------------------------------------------------------"
echo " Codes  40m      41m      42m      43m      44m      45m      46m      47m      48m"
echo "-------------------------------------------------------------------------------------"

# considuer using the seq command to make this cleaner
for fore in 30 31 32 33 34 35 36 37 38 39; do
    line1="   ${fore}m"
    line2=" 1;${fore}m"

    for back in 40 41 42 43 44 45 46 47 49; do
        line1="${line1}${esc}${back};${fore}m Normal ${esc}0m "
        line2="${line2}${esc}${back};${fore};1m  Bold  ${esc}0m "
    done

    echo -e "$line1\n$line2"
done

echo
echo " Additional Formatting Codes"
echo "-----------------------------"

echo -en "3m : ${esc}3mItalic${esc}0m    "
echo -en "4m : ${esc}4mUnderline${esc}0m\n"
echo
echo -en "5m : ${esc}5mBlink${esc}0m     "
echo -en "7m : ${esc}7mReverse${esc}0m"

echo -e "${esc}0m"

