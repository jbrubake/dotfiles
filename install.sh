#!/bin/sh
#
# Create symlinks to all files in DESTDIR (defaults to $HOME).
# excluding any files in .ignore and .ignore.<hostname>.
# The ignore files support shell globbing. All link names have
# a '.' prepended.
#
#
# TODO: Only install if dest is older
show_help() {
    cat <<EOF
Usage: install.sh [OPTION]
Install scripts and binaries to DESTDIR (default is ~/bin).

    -n, --hostname         Override hostname
    -f, --force            Overwrite existing files and links
    -d, --destination=dest Install to dest instead of ~/bin
    -v, --verbose
    -h, --help

Exit status:
 0  if OK,
 1  if minor problems (e.g., invalid option).
 2  if serious trouble (e.g., cannot create destination directory).
EOF
    exit
}

## Reset just in case
# No other security precautions. This is a trusting script
IFS='
 	'

ERR_MINOR=1
ERR_MAJOR=2

## Reset just in case
# No other security precautions. This is a trusting script
# Write the ini file correctly...or else
IFS='
 	'

##
## Command line options
##
BACKUP=-b           # backup existing files
VERBOSE=            # empty means not verbose
DESTDIR="$HOME"     # where to install everything
HOST=`hostname`
IGNOREFILE=.ignore  # list of files that shouldn't be linked
HOSTIGNORE=$IGNOREFILE.$HOST    # host-specific ignore file

while getopts "n:fd:vh" opt; do
    case $opt in
        n) HOST=$OPTARG; HOSTIGNORE="$IGNOREFILE.$h" ;;
        f) BACKUP='-f' ;;
        d) DESTDIR=$OPTARG ;;
        v) VERBOSE='-v' ;;
        h) show_help ;;
        ?) exit $ERR_MINOR ;;
    esac
done

if ! test -d "$DESTDIR" && ! mkdir -p "$DESTDIR"
then
    echo "Could not create $DESTDIR" >&2
    exit $ERR_MAJOR
fi

# FIXME: This is an ugly hack
# strip trailing '/' from DESTDIR
DESTDIR=$( echo $DESTDIR | sed -e 's@/$@@' )
# make relative links into DOTPATH
DOTPATH=$( pwd | sed -e "s#$DESTDIR/\?##" ) # make relative links

# if we can't strip $DESTDIR from $DOTPATH, relative
# links are harder
if test $DOTPATH = $( pwd ); then
    # how many levels up do we need to go?
    count=$( echo "$DESTDIR" | sed -e 's@/$@@' | \
        sed -e 's@[^/]*@ @g' | sed -e 's@\n@@g' | \
        wc -w )
    # prepend '../' for each level
    for i in $( seq 1 $count ); do
        DOTPATH="../$DOTPATH"
    done
    # remove the double '//'
    DOTPATH=$( echo $DOTPATH | sed -e 's@//@/@' )
fi

# Action happens here, following these rules:
#
# - skip files in .ignore and .ignore.<host>
# - if -f was *not* specified
# -     Skip if backup exists
# -     Backup existing files
# - else -f *was* specified
# -     Overwrite existing links and files
#
for f in *
do
    # skip ignored files
    for p in $(cat $IGNOREFILE $HOSTIGNORE 2>/dev/null); do
        test $f = $p && continue 2 # continue OUTER LOOP
    done

    # skip if -f not specified and backup exists
    if test $BACKUP = '-b' && test -e "$DESTDIR/$f~"
    then
        echo "Backup $f~ already exists. Skipping" >&2
        continue
    fi

    # make links
    ln $VERBOSE $BACKUP "$DOTPATH/$f" "$DESTDIR/.$f" 
done

