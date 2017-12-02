#!/bin/sh
#
# XXX: Description
#
#
# Usage:
#     install [OPTIONS]
#
<<<<<<< HEAD
# TODO: Add an option to update only
=======
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70
# -n, --hostname         Override hostname
# -f, --force            Overwrite existing files and links
# -d, --destination=dest Install to dest instead of ~
# -v, --verbose
#
<<<<<<< HEAD
# TODO: Make these constants
=======
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70
# Exit codes:
#  1 = invalid option
#  2 = destdir not found
#
<<<<<<< HEAD
=======
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70

## Reset just in case
# No other security precautions. This is a trusting script
# Write the ini file correctly...or else
IFS='
 	'

##
## Command line options
##
FORCE=              # empty means do not overwrite files
VERBOSE=            # empty means not verbose
DESTDIR="$HOME"     # where to install everything
HOST=`hostname`
IGNOREFILE=.ignore  # list of files that shouldn't be linked
HOSTIGNORE=$IGNOREFILE.`hostname`    # host-specific ignore file

<<<<<<< HEAD
while getopts "n:fd:v" opt; do
    case $opt in
        n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
        f) FORCE='-f' ;;
        d) DESTDIR=$OPTARG ;;
        v) VERBOSE='-v' ;;
        ?) exit 1 ;;
=======
while getopts "n:fd:i:v" opt; do
    case $opt in
        n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
	f) FORCE='-f' ;;
	d) DESTDIR=$OPTARG ;;
	i) INIFILE=$OPTARG ;;
	v) VERBOSE='-v' ;;
	?) exit 1 ;;
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70
    esac
done

# FIXME: This only works if DOTDIR is under DESTDIR
DOTPATH=`pwd |sed -e "s#$DESTDIR/\?##"` # make relative links

# Action happens here, following these rules:
#
# - skip files in .ignore
# - skip files in .ignore.<host> if hostname = <host>
# - if -f was *not* specified
# -     Skip existing links
# -     Backup existing files
# -     Skip existing files if backup exists
# - else -f *was* specified
# -     Overwrite existing links and files
#
for f in *
do
    # skip ignored files
    test -e "$IGNOREFILE" &&
        grep "$f$" "$IGNOREFILE" >/dev/null && continue
    test -e "$HOSTIGNORE" &&
        grep "$f$" "$HOSTIGNORE" >/dev/null && continue

    # if file exists and -f not specified, make backups
    if test -e "$DESTDIR/.$f" || test -L "$DESTDIR/.$f" &&
        test -z $FORCE
    then
        # skip existing links
        if test -L "$DESTDIR/.$f"
        then
            test -n $VERBOSE &&
                echo "Skipping existing link .$f" >&2
            continue
        fi

        # backup existing files
        # FIXME: This doesn't work if $tgt contains a path
        if test -e "$DESTDIR/__$f"
        then
            echo "Backup __$f already exists. Skipping" >&2
            continue
        else
<<<<<<< HEAD
            mv $VERBOSE $FORCE "$DESTDIR/.$f" "$DESTDIR/__$f"
=======
            echo mv $VERBOSE $FORCE "$DESTDIR/.$f" "$DESTDIR/__$f"
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70
        fi
    fi

    # make links
<<<<<<< HEAD
    ln $VERBOSE -s $FORCE "$DOTPATH/$f" "$DESTDIR/.$f"
=======
    echo ln $VERBOSE -s $FORCE "$DOTPATH/$f" "$DESTDIR/.$f"
>>>>>>> 47ef6998f7fb47b6187a9ba565aa9617cd73ea70
done
