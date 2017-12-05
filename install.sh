#!/bin/sh
#
# Create symlinks to all files in DESTDIR (defaults to $HOME).
# excluding any files in .ignore and .ignore.<hostname>.
# The ignore files support shell globbing. All link names have
# a '.' prepended.
#
#
# Usage:
#     install.sh [OPTIONS]
#
# -n, --hostname         Override hostname
# -f, --force            Overwrite existing files and links
# -d, --destination=dest Install to dest instead of ~
# -v, --verbose
#
# Exit codes:
   ERR_INVALID_OPTION=1
   ERR_DESTDIR_NOT_FOUND=2
#

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

while getopts "n:fd:v" opt; do
    case $opt in
        n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
        f) FORCE='-f' ;;
        d) DESTDIR=$OPTARG ;;
        v) VERBOSE='-v' ;;
        ?) exit $ERR_INVALID_OPTION ;;
    esac
done

if ! test -d "$DESTDIR" && ! mkdir -p "$DESTDIR"
then
    echo "Could not create $DESTDIR" >&2
    exit $ERR_DESTDIR_NOT_FOUND
fi

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
    for p in $(cat $IGNOREFILE $HOSTIGNORE 2>/dev/null); do
        test $f = $p && continue
    done

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
            mv $VERBOSE $FORCE "$DESTDIR/.$f" "$DESTDIR/__$f"
        fi
    fi

    # make links
    # XXX: Is there an 'install' equivalent?
    ln $VERBOSE -s $FORCE "$DOTPATH/$f" "$DESTDIR/.$f"
done
