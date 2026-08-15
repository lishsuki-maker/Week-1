#!/usr/bin/env bash

archive_dir=$1
log_dir=$2for f in $(ls $log_dir/*.log); do
  age=$(find $f -mtime +7)if [ $age ]; thenmv $f $archive_dir/
    count=$count+1fidoneecho "Archived $count files"
