#!/bin/sh
#
# XXX: Description
#
#
# Usage:
#     install [OPTIONS]
#
# -n, --hostname         Override hostname
# -f, --force            Overwrite existing files and links
# -d, --destination=dest Install to dest instead of ~
# -i, --inifile=file     Use file instead of the default
# -v, --verbose
#
# Exit codes:
#  1 = invalid option
#  2 = inifile not found
#  3 = destdir not found
#
# BUGS:
#     - Does not handle quoted file names
#     - Does not handle relative pathnames in INIFILE
#     - Relative symlinks only work if DOTDIR is under DESTDIR

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
INIFILE=$( pwd )/install.ini
IGNOREFILE=.ignore  # list of files that shouldn't be linked
HOSTIGNORE=$IGNOREFILE.`hostname`    # host-specific ignore file

process_options ()
{
    while getopts "n:fd:i:v" opt; do
        case $opt in
          n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
          f) FORCE='-f' ;;
          d) DESTDIR=$OPTARG ;;
          i) INIFILE=$OPTARG ;;
          v) VERBOSE='-v' ;;
          ?) exit 1 ;;
        esac
    done
}

##
## inifile directive processors
##

dodir ()
{
    set $( eval "echo $line" | sed -e 's/dir\s*=\s*//' )

    cmd="mkdir $1"
    tgt="$1"
}

dolinkdir ()
{
    set $( eval "echo $line" | sed -e 's/link-dir\s*=\s*//' )

    if test -e "$1"
    then
        cmd="ln -s $FORCE $1 $2"
        tgt="$2"
    else
        cmd="mkdir $2"
        tgt="$2"
    fi
}

dofile ()
{
    set $( eval "echo $line" | sed -e 's/file\s*=\s*//' )

    cmd="touch $1"
    tgt="$1"
}

dolinkfile ()
{
    set $( eval "echo $line" | sed -e 's/link-file\s*=\s*//' )

    if test -e "$1"
    then
        cmd="ln -s $FORCE $1 $2"
        tgt="$2"
    else
        cmd="touch $2"
        tgt="$2"
    fi
}

dolink ()
{
    set $( eval "echo $line" | sed -e 's/link\s*=\s*//' )

    cmd="ln -s $FORCE $1 $2"
    tgt="$2"
}

##
## Begin
##

process_options "$@"

if ! test -e "$INIFILE" && ! test -L "$INIFILE"
then
    echo "$INIFILE not found" >&2
    exit 2
fi

DOTDIR=`pwd` # Need to come back here for the second part
if ! test -d "$DESTDIR" && ! mkdir -p "$DESTDIR"
then
    echo "Could not create $DESTDIR" >&2
    exit 3
fi
cd $DESTDIR || exit 3

##
## Process ini file
##
process=0 # = 1 once we find our host's section
inconsts=0  # = 1 when we are in a [CONSTS] section
while read line; do
    test -z "$line" && continue # Skip blank lines

    case "$line" in
      \;* | \#*)                       continue ;; # Comment
      \[CONSTS\])            inconsts=1; continue ;; # Constants
      \[$HOST\])  process=1; inconsts=0; continue ;; # Our host
      \[*\])      process=0; inconsts=0; continue ;; # Another host

      dir*)
            test $process -eq 0 && continue
            dodir $line
            ;;
      link-dir*)
            test $process -eq 0 && continue
            dolinkdir $line
            ;;
      file*)
            test $process -eq 0 && continue
            dofile $line
            ;;
      link-file*)
            test $process -eq 0 && continue
            dolinkfile $line
            ;;
      link*)
            test $process -eq 0 && continue
            dolink $line
            ;;
      *=*)
            if test $inconsts -eq 1
            then
                echo $( echo $line | sed -e 's/\s*=\s*/=/' )
                eval $( echo $line | sed -e 's/\s*=\s*/=/' )
            fi
            continue
            ;;
      *)
            echo "Unknown directive: <$line>" >&2
            continue
            ;;
    esac

    # link commands do nothing if the target doesn't exist
    test -z "$cmd" && continue

    # Action happens here, following these rules:
    #
    # - Always skip directories that exist
    # - file commands just touch(1) the file if it exists
    # - if -f was *not* specified
    # -     Backup existing files
    # -     Skip existing files if backup exists
    # - else -f *was* specified
    # -     Overwrite existing links

    # automatically skip directories that exist
    if test -d "$tgt"
    then
        echo "Directory $tgt already exists. Skipping" >&2
        continue
    fi
        
    # if file exists and -f not specified, make backups
    if test -e "$tgt" || test -L "$tgt" && test -z $FORCE
    then
        # skip existing links
        if test -L "$DESTDIR/$tgt"
        then
            test -n $VERBOSE &&
                echo "Skipping existing link $tgt" >&2
            continue
        fi

        # check for existing backups
        # FIXME: This doesn't work if $tgt contains a path
        if test -e "__$tgt"
        then
            echo "Backup __$tgt already exists. Skipping" >&2
            continue
        else
            test -n $VERBOSE && echo "mv $tgt __$tgt"
            mv "$tgt" "__$tgt"
        fi
    fi

    # run the command
    test -n $VERBOSE && echo "$cmd"
    eval "$cmd"

done < $INIFILE

## Go back to our dotfiles
cd "$DOTDIR"
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
        if test -e "$DESTDIR/__.$f"
        then
            echo "Backup __.$f already exists. Skipping" >&2
            continue
        else
            test -n $VERBOSE &&
                echo "mv $FORCE $DESTDIR/.$f $DESTDIR/__.$f"
            mv $FORCE "$DESTDIR/.$f" "$DESTDIR/__.$f"
        fi
    fi

    # make links
    test -n $VERBOSE && echo "ln -s $FORCE $DOTPATH/$f $DESTDIR/.$f "
    ln -s $FORCE "$DOTPATH/$f" "$DESTDIR/.$f"
done