#!/usr/bin/env bash
set -e -o pipefail

if [ ! -s /dev/shm/async-transfer-env.sh ]; then
    echo "Error: Missing env file." >&2
    exit 14
fi

LOCK_FILE="/dev/shm/$(basename "$0").lock"
# Aquire lock
if [ -e "$LOCK_FILE" ]; then
    echo "Error: Already running." >&2
    exit 11
fi
touch "$LOCK_FILE"

function cleanup {
    rm "$LOCK_FILE"
}
trap cleanup EXIT

source /dev/shm/async-transfer-env.sh

if [[ -z "$REMOTE_UPLOAD_DIR" ]]; then
    echo "REMOTE_UPLOAD_DIR is empty, skipping upload." >&2
    exit
fi

echo "Start uploading to \"${REMOTE_UPLOAD_DIR}\""

rclone moveto "/media/async-transfer/outgoing" ":sftp:$REMOTE_UPLOAD_DIR" 2>&1 \
    | sed 's/\s\{2,\}\(:\)/ Upload\1/' >&2
