#!/usr/bin/bash

RED_THRESH=50
YELLOW_THRESH=75

get_percent() { printf "%.0f" $(echo "$1 / $2 * 100" | bc -l); }

# %c class
# %l level
# %h current HP
# %H current/max HP
# %m current MP
# %M current/max MP
# %x current XP
# %X current/needed XP
# %a attack
# %m magic
# %d defense
# %s speed
# %g gold
rpg_status() {
    format=${1:-%c[%l] %H hp}

    set -- $(rpg-cli stat --plain)

    class=$(echo "$1" | sed 's/\[.*//')
    level=$(echo "$1" | sed 's/.*\[\(.*\)\].*/\1/')
    hp=$(echo "$3" | cut -d: -f2 | cut -d'/' -f1)
    max_hp=$(echo "$3" | cut -d: -f2 | cut -d'/' -f2)
    mp=$(echo "$4" | cut -d: -f2 | cut -d'/' -f1)
    max_mp=$(echo "$4" | cut -d: -f2 | cut -d'/' -f2)
    xp=$(echo "$5" | cut -d: -f2 | cut -d'/' -f1)
    need_xp=$(echo "$5" | cut -d: -f2 | cut -d'/' -f2)
    atk=$6
    mag=$7
    def=$8
    spd=$9
    gold=${12}

    hp_clr=$(colorize "$(get_percent "$hp" "$max_hp")" "$RED_THRESH" "$YELLOW_THRESH")
    mp_clr=$(colorize "$(get_percent "$mp" "$max_mp")" "$RED_THRESH" "$YELLOW_THRESH")

    HP="$hp_clr$hp/$max_hp#[fg=default]"
    MP="$mp_clr$mp/$max_mp#[fg=default]"
    XP="$xp/$need_xp"

    hp="$hp_clr$hp#[fg=default]"
    mp="$mp_clr$mp#[fg=default]"


    echo "$format" | sed  \
        -e "s@%c@$class@" \
        -e "s@%l@$level@" \
        -e "s@%h@$hp@" \
        -e "s@%H@$HP@" \
        -e "s@%m@$mp@" \
        -e "s@%M@$MP@" \
        -e "s@%x@$xp@" \
        -e "s@%X@$XP@" \
        -e "s@%a@$atk@" \
        -e "s@%m@$mag@" \
        -e "s@%d@$def@" \
        -e "s@%s@$spd@" \
        -e "s@%g@$gold@"
}

