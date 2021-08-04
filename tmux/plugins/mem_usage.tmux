#!/bin/sh

free -h | awk 'NR == 2 {printf("%s/%s", $3, $2)}'

