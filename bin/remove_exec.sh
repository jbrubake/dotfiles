#!/bin/sh

# Remove executable bit from ALL files under
# current directory
find . -type f -exec chmod ogu-x '{}' \;
