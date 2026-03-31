#!/bin/sh
set -eu

SYNC_INTERVAL_SECONDS=${SYNC_INTERVAL_SECONDS:-1800}
RETRY_WAIT_SECONDS=${RETRY_WAIT_SECONDS:-300}
MAX_FAIL_STREAK=${MAX_FAIL_STREAK:-48}
FAIL_STREAK=0
LAST_SYNC=0

# Track process start separately from successful sync heartbeat.
date +%s > /tmp/start_epoch

while true; do
  NOW=$(date +%s)
  if [ $((NOW - LAST_SYNC)) -ge "${SYNC_INTERVAL_SECONDS}" ]; then
    LOG_FILE="/logs/sync_$(date +%Y-%m-%d).log"
    echo "$(date): Checking for Storage.sqlite..." | tee -a "$LOG_FILE"
    if [ -f /data/Storage.sqlite ]; then
      if rclone copy /data gdrive:MaccyBackup --include "Storage.sqlite*" --config /config/rclone/rclone.conf --ask-password=false; then
        date +%s > /tmp/last_success_epoch
        FAIL_STREAK=0
        echo "$(date): Sync successful." | tee -a "$LOG_FILE"
        LAST_SYNC=$NOW
      else
        FAIL_STREAK=$((FAIL_STREAK + 1))
        echo "$(date): Error - rclone sync failed (streak=${FAIL_STREAK}). Retrying in ${RETRY_WAIT_SECONDS}s." | tee -a "$LOG_FILE"
        LAST_SYNC=$((NOW - SYNC_INTERVAL_SECONDS + RETRY_WAIT_SECONDS))
      fi
    else
      FAIL_STREAK=$((FAIL_STREAK + 1))
      echo "$(date): Error - Storage.sqlite not found in /data/ (streak=${FAIL_STREAK}). Retrying in ${RETRY_WAIT_SECONDS}s." | tee -a "$LOG_FILE"
      LAST_SYNC=$((NOW - SYNC_INTERVAL_SECONDS + RETRY_WAIT_SECONDS))
    fi

    if [ "$FAIL_STREAK" -ge "$MAX_FAIL_STREAK" ]; then
      echo "$(date): Max failure streak reached (${MAX_FAIL_STREAK}). Exiting for container restart." | tee -a "$LOG_FILE"
      exit 1
    fi
  fi
  sleep 30
done
