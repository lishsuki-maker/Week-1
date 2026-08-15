#!/usr/bin/env bash
set -euo pipefail

log() {
    printf '%s\n' "$*"
}

die() {
    log "$1" >&2
    exit "$2"
}

if [ "$#" -ne 1 ]; then
    die "Usage: $0 <log_dir>" 2
fi
log_dir=$1
N=0
Scan=0

if [ ! -d "$log_dir" ] || [ ! -r "$log_dir" ]; then
    die "Folder does not exist or cannot be read" 3
fi

for f in "$log_dir"/*.log; do
    count=$(grep -c "ERROR" "$f" || true)
    log "$f: $count errors"
    if [ "$count" -gt 10 ]; then
        mkdir -p "$log_dir/review"
        cp "$f" "$log_dir/review/"
        N=$((N + 1))
    fi
    Scan=$((Scan + 1))
done

log "$Scan files were scanned."
log "$N files were flagged."

if [ "$N" -gt 0 ]; then
    exit 1
fi
exit 0
