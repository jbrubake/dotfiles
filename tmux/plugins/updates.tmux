#!/usr/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 3600 )) # 1 hour

updates() {
    format=${1:-%t (%s security) updates}

    updates=$(dnf --refresh -q updateinfo list |
        awk '
            BEGIN {
                total = -1 # easier than explicitly skipping the header line
                security = 0
            }
            $2 ~ /security/  { security++ }
                             { total++ }
            END { print security, total }')

    security=$(echo "$updates" | cut -d' ' -f1)
    total=$(echo "$updates" | cut -d' ' -f2)

    printf %s "$(printf %s "$format" | sed -e "s/%t/$total/" -e "s/%s/$security/")"
}

