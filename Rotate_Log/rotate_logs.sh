#!/usr/bin/env bash

set -euo pipefail 

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <archive_dir> <log_dir>" >&2
    exit 1
fi

archive_dir=$1
log_dir=$2
count=0

for f in "$log_dir"/*.log; do
	age=$(find "$f" -mtime +7)
	if [ "$age" ]; then
	mv "$f" "$archive_dir"/
	count=$((count+1))
fi
done
echo "Archived $count files"
