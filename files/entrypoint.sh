#!/usr/bin/env bash
set -e -o pipefail

if [[ -z "$SERVER_URL" ]]; then
    echo "Error: SERVER_URL is not set." >&2
    exit 15
fi

MAX_BANDWIDTH="${MAX_BANDWIDTH:-}"
SFTP_USER="${SERVER_URL#sftp://}"
SFTP_USER="${SFTP_USER%@*}"
SFTP_HOST=${SERVER_URL#*@}
SFTP_HOST=${SFTP_HOST%%:*}
SFTP_PORT=${SERVER_URL##*:}
if [[ "$SFTP_PORT" == "$SERVER_URL" ]]; then
    SFTP_PORT="22"
fi


SSH_KNOWN_HOSTS_FILE=
if [[ -n "$SERVER_IDENTITY" ]]; then
    echo "[${SFTP_HOST}]:${SFTP_PORT} $SERVER_IDENTITY" \
        > /dev/shm/ssh-known-hosts
    chmod 600 /dev/shm/ssh-known-hosts
    SSH_KNOWN_HOSTS_FILE="/dev/shm/ssh-known-hosts"
fi

export MAX_BANDWIDTH SFTP_HOST SSH_KNOWN_HOSTS_FILE SFTP_PORT SFTP_USER

replace-vars.sh /opt/async-transfer-sftp/templates/async-transfer-env.sh \
    > /dev/shm/async-transfer-env.sh
chmod 600 /dev/shm/async-transfer-env.sh

source /dev/shm/async-transfer-env.sh

echo "$SERVER_KEY" > /dev/shm/ssh-key
chmod 600 /dev/shm/ssh-key

mkdir --parents /media/async-transfer/{incoming,outgoing}

if [[ -n "$REMOTE_DOWNLOAD_DIR" ]]; then
    rclone mkdir ":sftp:$REMOTE_DOWNLOAD_DIR"
fi
if [[ -n "$REMOTE_UPLOAD_DIR" ]]; then
    rclone mkdir ":sftp:$REMOTE_UPLOAD_DIR"
fi

echo "$CRON_SCHEDULE root bash --login -c 'run-download.sh &> /proc/1/fd/1'" \
    > /media/cron/async-transfer-download
echo "$CRON_SCHEDULE root bash --login -c 'run-upload.sh &> /proc/1/fd/1'" \
    > /media/cron/async-transfer-upload

exec "$@"
