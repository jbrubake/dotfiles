#!/bin/sh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2014 Jeremy Brubaker <jbru362@gmail.com>
#
# Files and directories that are not dotfiles
#
NO_DOT='
    lib
    '

# Directories that should be linked directly
#
JUST_LINK='
    XDG_CONFIG_HOME/git/templates
    '

# Template file extension
TMPL_EXT=template

# Path to variables file for jinja templates
PRIVATE_VARS=private.yaml

# Repo directory containing files that should be linked from the user's Firefox
# profile
FIREFOX_PROFILE=XDG_CONFIG_HOME/firefox

# Documentation {{{1
#
# Manpage {{{2
# NAME:
#      install.sh
#
# SYNOPSIS:
#     install.sh [OPTION] [SUBCOMMAND]
#         (see print_help() below for more)
#
# DESCRIPTION:
#     Install dotfile directory tree and symlinks
#
#     Duplicate the directory structure in the local directory into
#     DESTDIR (defaults to $HOME) and create symlinks in DESTDIR to
#     all files in the local directory structure. Ignore any files
#     in .ignore and .ignore.<hostname>. The ignore files support
#     shell globbing.
#
#     All top-level directories and files have a '.' prepended to
#     their name.
#
# SUBCOMMANDS:
#     The optional SUBCOMMAND can be used to execute tasks short of a full
#     installation. Supported SUBCOMMANDS are:
#
#     ./install.sh expand [FILE.template...]
#
#     Expand and install the listed template files
#
#     ./install.sh expand [FILE.template...]
#
#     Successively open each listed template and its expanded version in
#     vimdiff. The intent is to facilitate changes made in the expanded file
#     back into VCS
#
# BUGS:
#     - None so far

print_help() { # {{{2
    cat <<EOF
Usage: install.sh [OPTION] [SUBCOMMAND]

Install symlinks into DEST (default is $HOME).  

 -n HOST       use HOST as the hostname
 -f            overwrite existing files and links
 -d DEST       install to DEST instead of $HOME
 -V            explain what is being done
 -t            print what would be done
 -h            display this help and exit

The optional SUBCOMMAND can be used to execute tasks short of a full
installation. Supported SUBCOMMANDS are:

    ./install.sh expand [FILE.template...]

    Expand and install the listed template files

    ./install.sh expand [FILE.template...]

    Successively open each listed template and its expanded version in vimdiff.
    The intent is to facilitate changes made in the expanded file back into VCS
EOF
}

# Functions {{{1
#
# logmsg: Output messages {{{2
#
# Depends on $VERBOSE
logmsg () {
    [ $VERBOSE = yes ] && echo "$*"
}
# logerror: Output error messages {{{2
#
logerror () {

    echo "$*" >&2
}

# CT_FindRelativePath: Returns relative path to $2 from $1 {{{2
#
# This function was taken from a Stack Overflow answer
#
# Question: https://stackoverflow.com/q/2564634
# Answer: https://stackoverflow.com/a/30778999
# Answer by: Ray Donnelly (https://stackoverflow.com/users/3257826/ray-donnelly)

# CHANGE:
# If $1 or $2 exist they can be specified as relative
# paths which will be converted to absolute paths
# If $1 or $2 do not exist they must be specified
# as absolute paths
#
# Jeremy Brubaker, November 2018
CT_FindRelativePath() {

    if [ -e $1 ]; then
        local insource=$( cd $1; echo `pwd` )
    else
        local insource=$1
    fi

    if [ -e $2 ]; then
        local intarget=$( cd $2; echo `pwd` )
    else
        local intarget=$2
    fi

    # Ensure both source and target end with /
    # This simplifies the inner loop.
    case "$insource" in
        */) ;;
        *) source="$insource"/ ;;
    esac

    case "$intarget" in
        */) ;;
        *) target="$intarget"/ ;;
    esac

    local common_part=$source # for now

    local result=""

    while [ "${target#$common_part}" = "${target}" -a "${common_part}" != "//" ]; do
        # no match, means that candidate common part is not correct
        # go up one level (reduce common part)
        common_part=$(dirname "$common_part")/
        # and record that we went back
        if [ -z "${result}" ]; then
            result="../"
        else
            result="../$result"
        fi
    done

    if [ "${common_part}" = "//" ]; then
        # special case for root (no common path)
        common_part="/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    forward_part="${target#$common_part}"

    if [ -n "${result}" -a -n "${forward_part}" ]; then
        result="$result$forward_part"
    elif [ -n "${forward_part}" ]; then
        result="$forward_part"
    fi

    # if a / was added to target and result ends in / then remove it now.
    if [ "$intarget" != "$target" ]; then
        case "$result" in
            */) result=$(echo "$result" | awk '{ string=substr($0, 1, length($0)-1); print string; }' ) ;;
        esac
    fi

    echo $result

    return 0
}

# list2regex: Convert lists into grep ERE # {{{2
#
# Converts the list in $1 into an alternation regex
#
# LIST='foo bar baz'
# list2regex "$LIST" => ^\<foo\>|\<bar\>|\<baz\>
#
list2regex() {
    printf '%s' "$1" | tr -s '\n' ' ' | sed '
        s/^[[:blank:]]*//
        s/[[:blank:]]*$//
        s/[[:blank:]][[:blank:]]*/|/g
        s/^/^\\</
        s/$/\\>/
        s/|/\\>|\\</g
    '
}

# isignored: Return true if path should be ignored {{{2
#
# Return true if $1 ends in $TMPL_EXT or is found in $IGNOREFILE or $HOSTIGNORE
#
isignored() {
    case $1 in
        *.$TMPL_EXT) return 0 ;;
    esac

    local f
    for f in "$IGNOREFILE" "$HOSTIGNORE"; do
        [ -r "$f" ] || continue

        while read -r regex; do
            case $regex in
                \#*) continue ;;
            esac
            printf '%s' "$1" | grep -qE "^$regex$" && return 0
        done <"$f"
    done
    return 1
}

# adddot: Prepend a '.' unless ignored by NO_DOT {{{2
#
# Adds a leading '.' to the path in $1 unless the first element of that path is
# found in $NO_DOT
#
adddot() {
    if ! printf '%s' "$1" | grep -qE "$NO_DOT_REGEX"; then
        printf '.%s' "$1"
    else
        printf '%s' "$1"
    fi
}

# getdest: Convert $1 into a destination path {{{2
#
# - Expand directories named XDG_* into the value of the corresponding variable
# (or appropriate default)
# - Adds a leading '.' to the path in $1 unless the first element of that path
# is found in $NO_DOT
#
getdest() {
    case $1 in
        XDG_*)
            case $(printf '%s' "$1" | sed s@/.*@@) in
                XDG_CONFIG_HOME) XDG=${XDG_CONFIG_HOME:-"$HOME/.config"} ;;
                XDG_DATA_HOME)   XDG=${XDG_DATA_HOME:-"$HOME/.local/share"} ;;
                XDG_CACHE_HOME)  XDG=${XDG_CACHE_HOME:-"$HOME/.cache"} ;;
                XDG_STATE_HOME)  XDG=${XDG_STATE_HOME:-"$HOME/.local/state"} ;;
                XDG_LOCAL_HOME)  XDG=${XDG_LOCAL_HOME:-"$HOME/.local"} ;;
                XDG_BIN_HOME)    XDG=${XDG_BIN_HOME:-"$HOME/.local/bin"} ;;
                XDG_LIB_HOME)    XDG=${XDG_LIB_HOME:-"$HOME/.local/lib"} ;;
                XDG_GAMES_HOME)  XDG=${XDG_GAMES_HOME:-"$HOME/games"} ;;
                XDG_OPT_HOME)    XDG=${XDG_OPT_HOME:-"$HOME/.local/opt"} ;;
                XDG_SRC_HOME)    XDG=${XDG_SRC_HOME:-"$HOME/src"} ;;
            esac
            XDG=$(printf '%s' "$XDG" | sed "s@$HOME/@@")
            printf '%s' "$1" | sed  "s@[^/]*@$XDG@"
            ;;
        *)
            # Make dot directory unless listed in NO_DOT
            adddot "$1"
            ;;
    esac
}

# isjustlinkdir: {{{2
#
# Return true if $1 exactly matches a path in $JUST_LINK
#
isjustlinkdir() {
    printf '%s' "$1" | grep -qE "$JUST_LINK_REGEX"
}

# isjustlinkfile: {{{2
#
# Return true if $1 is a child of a directory in $JUST_LINK
#
isjustlinkfile() {
    printf '%s' "$1" | grep -qE "$JUST_LINK_REGEX/.*"
}

# mklink: Create a symlink {{{2
#
# Create a symlink from $2 to $DESTDIR/$1
#
# $1 Path to link relative to $DESTDIR
# $2 Relative path to directory of link target from $1
# $3 Full path to link target
#
mklink() {
    local link_name=$1
    local target_path=$2
    local target_name=$3

    # Test if an already existing link points to the right file already
    if [ -L "$DESTDIR/$link_name" ]; then
        if [ "$(realpath "$(readlink -f -- "$DESTDIR/$link_name")")" = \
                "$(realpath "$target_name")" ]; then
            logmsg "Symbolic link '$DESTDIR/$link_name' already points to '$target_name'. Skipping"
            return
        fi
    fi

    if [ $FORCE = no -a -e "$DESTDIR/$link_name~" ]; then
        # skip if -f not specified and backup exists
        logmsg "Failed to create backup $DESTDIR/$link_name~: File exists"
        return 1
    fi

    # make links
    $DRY_RUN ln -s $verbose $force "$target_path/$(basename $target_name)" "$DESTDIR/$link_name"
}

# expand_template: Expand a jinja template {{{2
#
# Uses the variables in $PRIVATE_VARS to expand the template in $1 to the proper
# destination in $DESTDIR
#
expand_template() {
    src=$1

    if ! [ -r "$src" ]; then
        logerror "Cannot find template: $src: Skipping"
        return 1
    fi

    # Convert src to dest by removing TMPL_EXT and converting to dotfile
    dest=$(getdest "$src" | sed "s/.$TMPL_EXT$//")
    if [ -f "$DESTDIR/$dest" ]; then
        if [ $FORCE = no ]; then
            logmsg "Template destination $DESTDIR/$dest already exists. Skipping"
            return
        elif [ -f "$DESTDIR/$dest~" ]; then
            logmsg "Failed to create backup $DESTDIR/$dest~: File exists"
            return 1
        else
            $DRY_RUN cp $force "$DESTDIR/$dest" "$DESTDIR/$dest~"
        fi
    fi

    # Expand the template
    [ -z "$DRY_RUN" ] && logmsg "jinja2 --outfile '$DESTDIR/$dest' '$src' '$PRIVATE_VARS'"                        
    $DRY_RUN jinja2 --outfile "$DESTDIR/$dest" "$src" "$PRIVATE_VARS"
}

# diff_template: Use vimdiff to merge template and destination {{{2
#
# Opens the template in $1 and its expanded version in vimdiff
#
# The purpose is to allow a user to merge changes made in the expanded version
# back into VCS
#
diff_template() {
    src=$1

    if ! [ -r "$src" ]; then
        logerror "Cannot find template: $src: Skipping"
        return 1
    fi

    # Convert src to dest by removing TMPL_EXT and converting to dotfile
    dest=$(printf '%s' "$(adddot "$src")" | sed "s/.$TMPL_EXT$//")

    vimdiff "$src" "$DESTDIR/$dest"
}

# get_firefox_profile_path {{{2
#
# Get path to the default Firefox profile (creating if necessary)
#
get_firefox_profile_path() {
    local firefox
    local d

    # Remove $HOME from $XDG_CONFIG_HOME and then prepend $DESTDIR so you could
    # install to a Firefox profile in /weird/path/.config/mozilla
    #
    xdg_cfg=$(printf '%s' "${XDG_CONFIG_HOME:-.config}" | sed "s@$HOME/@@")
    for d in "$DESTDIR/.mozilla" "$DESTDIR/$xdg_cfg/mozilla"; do
        if [ -f "$d/firefox/profiles.ini" ]; then
            firefox=$d/firefox
            break
        fi
    done

    if [ -z "$firefox" ]; then
        firefox -no-remote -CreateProfile default --headless 2>&2 >/dev/null
        for d in "$DESTDIR/.mozilla" "$DESTDIR/$xdg_config/mozilla"; do
            if [ -f "$d/firefox/profiles.ini" ]; then
                firefox=$d/firefox
            fi
        done
    fi

    printf '%s/%s\n' "$firefox" "$(< "$firefox/profiles.ini" sed -n '/\[Profile0\]/,/^$/!d; /Path/s/Path=//p')"
}

# Process options {{{1
#
# Flag Variables
#
FORCE=no
VERBOSE=no
DESTDIR="$HOME"
HOST=$( hostname )
IGNOREFILE=.ignore  # list of files that shouldn't be linked
HOSTIGNORE=$IGNOREFILE.$HOST    # host-specific ignore file
DRY_RUN=

while getopts "n:fd:Vth" opt; do
    case $opt in
        n) HOSTIGNORE=$IGNOREFILE.$OPTARG ;;
        f) FORCE=yes ;;
        d) DESTDIR=$OPTARG ;;
        V) VERBOSE=yes ;;
        t) DRY_RUN=echo ;;
        h) print_help; exit ;;
        *) print_help; exit ;;
    esac
done
shift $((OPTIND-1))
OPTIND=1

# Convert flag variables to ln(1) and mkdir options
if [ $VERBOSE = yes ]; then
    verbose=-v # mkdir(1) and ln(1) verbose flag
else
    verbose=
fi

if [ $FORCE = yes ]; then
    force=-f # ln(1) force flag
else
    force=-b # ln(1) backup flag
fi

if ! [ -d "$DESTDIR" ] && ! mkdir -p "$DESTDIR"; then
    logerror "FATAL: Could not create $DESTDIR. Exiting!"
    exit
fi

# Convert lists to regex
NO_DOT_REGEX=$(list2regex "$NO_DOT")
JUST_LINK_REGEX=$(list2regex "$JUST_LINK")

case $1 in
    expand)
        shift
        for f in "$@"; do
            expand_template "$f"
        done
        exit
        ;;
    diff)
        shift
        for f in "$@"; do
            diff_template "$f"
        done
        exit
        ;;
esac

# Replicate directory tree {{{1
#
# Find all non-hidden sub-directories and strip the leading "./"
logmsg 'Creating destination directory tree...'
for d in $(find . -mindepth 1 ! -path './.*' -type d | cut -c3-); do
    # Do not create directories that must be directly linked
    isjustlinkdir "$d" && continue

    d=$(getdest "$d")

    [ -d "$DESTDIR/$d" ] || $DRY_RUN mkdir -p $verbose "$DESTDIR/$d"
done

# Link files {{{1
#  following these rules:
#
# - skip files in .ignore and .ignore.<host>
# - skip if link exists and already points to the correct file
# - if -f was *not* specified
# -     Skip if backup exists
# -     Backup existing files
# - else -f *was* specified
# -     Overwrite existing links and files
#
# Find all non-hidden files in current and non-hidden
# sub-directories and strip the leading "./"
logmsg 'Creating links...'
# NOTE: Explicity include $JUST_LINK so those directories are also linked
for target in $JUST_LINK $(find . -mindepth 1 ! -path './.*' -type f | cut -c3-); do
    # skip ignored files
    isignored "$target" && continue

    # ignore files in directories that will be directly linked
    isjustlinkfile "$target" && continue

    # get relative path to the file from its new location in DESTDIR
    linkpath=$(CT_FindRelativePath "$DESTDIR/$(dirname "$target")" "$(dirname "$target" )")

    linkname=$(getdest "$target")

    mklink "$linkname" "$linkpath" "$target"
done

# Expand templates {{{1
#
logmsg 'Expanding template files...'
if ! [ -r "$PRIVATE_VARS" ]; then
    logerror "Cannot find variables file: $PRIVATE_VARS: Aborting template expansion!"
    exit 1
fi

for src in $(find . -type f -name "*.$TMPL_EXT" | cut -c3-); do
    expand_template "$src"
done

# Install Firefox Profile {{{1
#
firefox_profile_path=$(get_firefox_profile_path)

logmsg 'Installing Firefox profile files...'
for d in $(find "$FIREFOX_PROFILE" -mindepth 1 -type d); do
    d=$(printf '%s' $d | sed "s@^$FIREFOX_PROFILE/@@")

    [ -d "$firefox_profile_path/$d" ] || $DRY_RUN mkdir -p $verbose "$firefox_profile_path/$d"
done

# These links are a bit different so there is some annoying path manipulation
# that goes on here:
#
# Loop through all files in $FIREFOX_PROFILE and
#   1. Strip $FIREFOX_PROFILE from the file path:
#       FIREFOX_PROFILE/foo/bar.css => foo/bar.css
#   2. Get relative path from the where that file would be in the user's firefox
#      profile to the target file:
#       $firefox_profile_path/foo => ./$FIREFOX_PROFILE/foo/bar.css
#   3. Set DESTDIR to where that file would be in the user's profile:
#       DESTDIR=$firefox_profile_path/foo
#   4. Set the linkname to just the target file:
#       linkname=bar.css
#   5. Make the link
for target in $(find "$FIREFOX_PROFILE" -mindepth 1 -type f); do
    linkname=$(printf '%s' "$target" | sed "s@^$FIREFOX_PROFILE/@@")
    linkpath=$(CT_FindRelativePath "$firefox_profile_path/$(dirname "$linkname")" "$(dirname "$target")")

    # $firefox_profile_path already has $DESTDIR prepended
    DESTDIR=$firefox_profile_path/$(dirname "$linkname")
    linkname=$(basename "$linkname")

    mklink "$linkname" "$linkpath" "$target"
done

