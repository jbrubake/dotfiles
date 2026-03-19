#!/usr/bin/sh

# Seconds until script output cache is stale
INTERVAL=$(( 60 * 60 )) # 1 hour

updates() {
    format=${1:-%t (%s security) updates}

    security=$(dnf --refresh --quiet check-update --security | grep -v '^No security updates needed' | wc -l)
    total=$(dnf --refresh --quiet check-update | wc -l)

    printf %s "$(printf %s "$format" | sed -e "s/%t/$total/" -e "s/%s/$security/")"
}

