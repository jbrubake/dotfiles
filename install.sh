#!/bin/sh
# vim: foldmethod=marker foldmarker={,}
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
# Documentation {
#
# Manpage {
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
#}
print_help() {
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
#}
logmsg () {
    # Output messages
    #
    # Depends on $VERBOSE

    test $VERBOSE = 'yes' && echo "$*"
}
logerror () {
    # Output error messages

    echo "$*" >&2
}
CT_FindRelativePath() {
# Returns relative path to $2 from $1
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

    if test -e $1; then
        local insource=$( cd $1; echo `pwd` )
    else
        local insource=$1
    fi

    if test -e $2; then
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
# Process options {
#
# Flag Variables
#
FORCE='no'
VERBOSE='no'
DESTDIR="$HOME"
HOST=$( hostname )
IGNOREFILE=.ignore  # list of files that shouldn't be linked
HOSTIGNORE=$IGNOREFILE.$HOST    # host-specific ignore file
DRY_RUN=

while getopts "n:fd:Vth" opt; do
    case $opt in
        n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
        f) FORCE='yes' ;;
        d) DESTDIR=$OPTARG ;;
        V) VERBOSE='yes' ;;
        t) DRY_RUN='echo' ;;
        h) print_help; exit ;;
        *) print_help; exit ;;
    esac
done

# Convert flag variables to ln(1) and mkdir options
if test $VERBOSE = 'yes'; then
    verbose='-v' # ln(1) verbose flag
else
    verbose=
fi

if test $FORCE = 'yes'; then
    force='-f'
else
    force='-b' # ln(1) backup
fi

if ! test -d "$DESTDIR" && ! mkdir -p "$DESTDIR"; then
    logerror "FATAL: Could not create $DESTDIR. Exiting!"
    exit
fi
# }
# Replicate directory tree {
#
# Find all non-hidden sub-directories and strip the leading "./"
for d in $(find . -mindepth 1 \( ! -path '*/.*' \) -type d -print | sed -e 's#./##'); do
    $DRY_RUN mkdir -p $verbose "$DESTDIR/.$d"
done
# }
# Link files {
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
for f in $(find . \( ! -path '*/.*' \) -type f -print | sed -e 's#./##'); do
    # skip ignored files
    for p in $(cat $IGNOREFILE $HOSTIGNORE 2>/dev/null); do
        test $f = $p && continue 2 # continue OUTER LOOP
    done

    # get relative path to the file from its new location in DESTDIR
    linkpath=$( CT_FindRelativePath $DESTDIR/$( dirname $f) $( dirname $f ) )

    # create the link name and make it hidden
    if test $( dirname $f ) = '.'; then
        linkname=".$( basename $f )"
    else
        linkname=".$( dirname $f )/$( basename $f )"
    fi

    # Test if an already existing link points
    # to the right file already
    if test -L "$DESTDIR/$linkname"; then
        if test $(realpath $(readlink -f -- "$DESTDIR/$linkname")) = \
                $(realpath $f); then
            logmsg "${linkname} is already linked. Skipping"
            continue
        fi
    fi

    if test $FORCE = 'no' && test -e "$DESTDIR/$linkname~"; then
        # skip if -f not specified and backup exists
        logmsg "Backup ${linkname}~ already exists. Skipping"
        continue
    fi

    # make links
    $DRY_RUN ln -s $verbose $force "$linkpath/$(basename $f)" "$DESTDIR/$linkname"
done
# }
# Custom installation {
# TODO: Add better custom installation framework
if ! test -e ~/.mutt/auth; then
    cat <<END > ~/.mutt/auth
# vi: filetype=muttrc
#
# Gmail application password
set imap_pass = "GOOGLEAPPPWD"
set smtp_pass = "GOOGLEAPPPWD"
END
if ! test -e ~/.mutt/address_book; then
    cat <<END > ~/.mutt/address_book
# vi: filetype=muttrc
#
# Address book for mutt

# Add address book aliases like this:
# alias alias-name "full-name" <email-address>

END
fi
if ! test -e ~/.mutt/mailing_lists; then
    cat <<END > ~/.mutt/mailing_lists
# vi: filetype=muttrc
#
# Mutt mailing lists

# lists       <list@list.com>
# subscribe   <list@list.com>

END
fi
# }
