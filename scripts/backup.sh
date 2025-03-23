#!/bin/bash

# Interactive script to encrypt + backup data
PROJECT_DIR="/home/$(whoami)/RestorePoint"  # Absolute path to project
AGE_PUBLIC_KEY="$PROJECT_DIR/config/age/public.key"
ENCRYPTED_DIR="$PROJECT_DIR/backups/encrypted"
LOG_FILE="$PROJECT_DIR/logs/backup-$(date +%Y%m%d).log"

# Validate data directory
TARGET_DIR="$PROJECT_DIR/data"
if [ ! -d "$TARGET_DIR" ]; then
  echo "[ERROR] No data to back up. Run saving.sh first!" | tee -a "$LOG_FILE"
  exit 1
fi

# Prompt user to confirm backup
read -p "Backup data from $TARGET_DIR to Google Drive? (y/n): " CHOICE
if [[ ! "$CHOICE" =~ [yY] ]]; then
  echo "Backup cancelled." | tee -a "$LOG_FILE"
  exit 0
fi

# Create encrypted backup
mkdir -p "$ENCRYPTED_DIR"
ARCHIVE_NAME="backup-$(date +%Y-%m-%d_%H-%M-%S).borg.age"

echo "Creating encrypted backup..."
borg create --stdout --stats --compression zstd,5 "$TARGET_DIR" | \
age -e -R "$AGE_PUBLIC_KEY" -o "$ENCRYPTED_DIR/$ARCHIVE_NAME" 2>> "$LOG_FILE"

if [ $? -ne 0 ]; then
  echo "[ERROR] Backup failed. Check $LOG_FILE." | tee -a "$LOG_FILE"
  exit 1
fi

# Sync to Google Drive
echo "Syncing to Google Drive..."
rclone sync "$ENCRYPTED_DIR" "Gdrive:/backups" --log-file="$LOG_FILE"

echo "[SUCCESS] Backup completed: $ARCHIVE_NAME" | tee -a "$LOG_FILE"
