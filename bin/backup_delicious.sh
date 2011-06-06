#!/bin/sh

#
# Backup your delicious.com bookmarks
#

password="criznap7"
username="jbru362"
backup_file="$HOME/.sync/Dropbox/delicious.xml"
backup_url="https://api.del.icio.us/v1/posts/all"

if [ `which wget` ]; then
    wget --no-check-certificate --user=$username --password=$password \
        -O"$backup_file" "$backup_url"
elif [ `which curl` ]; then
    curl -k --user "$username:$password" -o "$backup_file" \
        -O "$backup_url"
else
    echo "You don't have curl or wget. Exiting..."
fi
