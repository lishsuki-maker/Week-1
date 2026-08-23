#!/bin/sh
set -eu
echo "The container started at $(date '+%H:%M:%S')"
exec nginx -g "daemon off;"
