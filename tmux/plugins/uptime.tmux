#!/bin/sh

# Seconds until script output cache is stale
INTERVAL=60

uptime() { command uptime -p | cut -d' ' -f2- | cut -d, -f1; }

