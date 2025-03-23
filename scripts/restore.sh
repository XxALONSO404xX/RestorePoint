#!/bin/bash

# Interactive script to restore data
PROJECT_DIR="/home/$(whoami)/RestorePoint"  # Absolute path to project
AGE_PRIVATE_KEY="$PROJECT_DIR/config/age/private.key"
ENCRYPTED_DIR="$PROJECT_DIR/backups/encrypted"
RCLONE_REMOTE="Gdrive"
LOG_FILE="$PROJECT_DIR/logs/restore-$(date +%Y%m%d).log"

# Fetch list of backups from Google Drive
echo "Fetching backups from Google Drive..."
BACKUP_LIST=$(rclone ls "$RCLONE_REMOTE:/backups" | grep ".borg.age")

if [ -z "$BACKUP_LIST" ]; then
  echo "[ERROR] No backups found on Google Drive." | tee -a "$LOG_FILE"
  exit 1
fi

# Let user select a backup
echo "Available backups:"
echo "$BACKUP_LIST" | awk '{print NR ") " $2}'
read -p "Enter the number of the backup to restore: " BACKUP_NUM

BACKUP_FILE=$(echo "$BACKUP_LIST" | sed -n "${BACKUP_NUM}p" | awk '{print $2}')
if [ -z "$BACKUP_FILE" ]; then
  echo "[ERROR] Invalid selection." | tee -a "$LOG_FILE"
  exit 1
fi

# Download backup
echo "Downloading $BACKUP_FILE..."
rclone copy "$RCLONE_REMOTE:/backups/$BACKUP_FILE" "$ENCRYPTED_DIR" --log-file="$LOG_FILE"

# Prompt for restore directory
read -p "Enter restore directory (e.g., /home/$(whoami)/restored-data): " RESTORE_DIR
mkdir -p "$RESTORE_DIR"

# Decrypt and extract
echo "Restoring $BACKUP_FILE to $RESTORE_DIR..."
age -d -i "$AGE_PRIVATE_KEY" "$ENCRYPTED_DIR/$BACKUP_FILE" | \
borg extract --stdin --destination "$RESTORE_DIR" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  echo "[SUCCESS] Restored to $RESTORE_DIR" | tee -a "$LOG_FILE"
else
  echo "[ERROR] Restore failed. Check $LOG_FILE." | tee -a "$LOG_FILE"
  exit 1
fi
