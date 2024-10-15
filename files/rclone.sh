#!/bin/bash
#
# Rclone script to archive important data to an Amazon S3 bucket.
#
# Basic usage:
#   ./rclone.sh
#
# Script requires valid credentials - set up with `rclone config`.

RCLONE=/usr/local/bin/rclone

# Check if rclone is installed.
if ! [ -x "$(command -v $RCLONE)" ]; then
  echo 'Error: rclone is not installed.' >&2
  exit 1
fi

# Don't run if an instance of rclone is already running.
if ps -ef | grep -v grep | grep rclone ; then
  exit 0
fi

# Variables.
rclone_remote=mm-archive
rclone_s3_bucket=mm-archive
bandwidth_limit=200M

# Make sure bucket exists.
$RCLONE mkdir $rclone_remote:$rclone_s3_bucket

# List of directories to clone. MUST be absolute path, beginning with /.
declare -a dirs=(
  "/ssdpool/backup/jupiter"
)

# Clone each directory. Add `--progress` for nicer (but more verbose) output.
for i in "${dirs[@]}"
do
  echo "Syncing Directory: $i"
  despaced="${i// /_}"
  $RCLONE sync "$i" $rclone_remote:$rclone_s3_bucket"$despaced" --skip-links --bwlimit $bandwidth_limit
done
