#!/bin/sh

# @requires: jq(1)

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 15 ))

ip_location() {
    format=$(echo "${1:-%c, %r, %C}" | sed \
        -e 's/%c/\\(.city)/' -e 's/%r/\\(.region)/' -e 's/%C/\\(.country)/')

    curl -s ipinfo.io | jq -r "\"$format\""
}

