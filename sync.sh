#!/bin/sh
set -eu

LAST_SYNC=0
RETRY_WAIT=300  # retry after 5 min on failure

while true; do
  NOW=$(date +%s)
  if [ $((NOW - LAST_SYNC)) -ge 1800 ]; then
    LOG_FILE="/logs/sync_$(date +%Y-%m-%d).log"
    echo "$(date): Checking for Storage.sqlite..." | tee -a "$LOG_FILE"
    if [ -f /data/Storage.sqlite ]; then
      if rclone copy /data/Storage.sqlite gdrive:MaccyBackup --config /config/rclone/rclone.conf --ask-password=false; then
        echo "$(date): Sync successful." | tee -a "$LOG_FILE"
        LAST_SYNC=$NOW
      else
        echo "$(date): Error - rclone sync failed. Retrying in ${RETRY_WAIT}s." | tee -a "$LOG_FILE"
        LAST_SYNC=$((NOW - 1800 + RETRY_WAIT))
      fi
    else
      echo "$(date): Error - Storage.sqlite not found in /data/. Retrying in ${RETRY_WAIT}s." | tee -a "$LOG_FILE"
      LAST_SYNC=$((NOW - 1800 + RETRY_WAIT))
    fi
  fi
  sleep 30
done
