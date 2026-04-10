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
    etc
    '

# Directories that should be linked directly
#
JUST_LINK='
    config/git/templates
    '

# Documentation {{{1
#
# Manpage {{{2
# NAME:
#      install.sh
#
# SYNOPSIS:
#     install.sh [OPTION] 
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
# BUGS:
#     - None so far

print_help() { # {{{2
    cat <<EOF
Usage: install.sh [OPTION]
Install symlinks into DEST (default is $HOME).  
 -n HOST       use HOST as the hostname
 -f            overwrite existing files and links
 -d DEST       install to DEST instead of $HOME
 -V            explain what is being done
 -t            print what would be done
 -h            display this help and exit
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

# Replicate directory tree {{{1
#
# Find all non-hidden sub-directories and strip the leading "./"
for d in $(find . -mindepth 1 \( ! -path '*/.*' \) -type d -print | sed -e 's#./##'); do
    # Do not create directories that must be directly linked
    isjustlinkdir "$d" && continue

    # Make dot directory unless listed in NO_DOT
    d=$(adddot "$d")
    $DRY_RUN mkdir -p $verbose "$DESTDIR/.$d" ;;
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
#
# NOTE: Explicity include $JUST_LINK so those directories are also linked
for f in $JUST_LINK $(find . \( ! -path '*/.*' \) -type f -print | sed -e 's#./##'); do
    # skip ignored files
    isignored "$f" && continue

    # ignore files in directories that will be directly linked
    isjustlinkfile "$f" && continue

    # get relative path to the file from its new location in DESTDIR
    linkpath=$( CT_FindRelativePath $DESTDIR/$( dirname $f) $( dirname $f ) )

    linkname=$(adddot "$f")

    # Test if an already existing link points to the right file already
    if [ -L "$DESTDIR/$linkname" ]; then
        if [ $(realpath $(readlink -f -- "$DESTDIR/$linkname")) = \
                $(realpath $f) ]; then
            logmsg "${linkname} is already linked. Skipping"
            continue
        fi
    fi

    if [ $FORCE = no -a -e "$DESTDIR/$linkname~" ]; then
        # skip if -f not specified and backup exists
        logmsg "Backup ${linkname}~ already exists. Skipping"
        continue
    fi

    # make links
    $DRY_RUN ln -s $verbose $force "$linkpath/$(basename $f)" "$DESTDIR/$linkname"
done

