#!/bin/bash

# === RestorePoint Restore Script ===

source ~/RestorePoint/scripts/utils.sh

LOG_FILE="restore.log"
DEFAULT_BACKUP_DIR=~/RestorePoint/backups/local   # Directory where backups are stored
RESTORE_DIR=~/RestorePoint/data  # Directory to restore to

# Ensure directories exist
ensure_dir "$LOG_DIR"

# Debugging: List contents of backup directory
echo "🔍 Listing files in backup directory $DEFAULT_BACKUP_DIR:"
ls -l $DEFAULT_BACKUP_DIR

# Ask user where to restore from
echo "📦 Where do you want to restore from?"
select SOURCE in "Local only" "Local + Google Drive"; do
  case $SOURCE in
    "Local only"|"Local + Google Drive")
      break
      ;;
    *)
      echo "❌ Invalid option. Try again."
      ;;
  esac
done

# Ask where to restore (which directory)
echo "📂 Enter the directory to restore to: "
read -r RESTORE_DIR
if [[ ! -d "$RESTORE_DIR" ]]; then
  echo "❌ Directory does not exist!"
  exit 1
fi

# --- Step 1: Automatically select the latest backup from the backup directory ---
echo "📦 Searching for the latest backup in $DEFAULT_BACKUP_DIR..."
LATEST_BACKUP=$(ls -t $DEFAULT_BACKUP_DIR | grep -E "^backup-.*" | head -n 1)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No backup archives found in $DEFAULT_BACKUP_DIR."
  exit 1
fi

echo "🔍 Latest backup found: $LATEST_BACKUP"

# --- Step 2: Download Backup from Google Drive (if needed) ---
if [[ "$SOURCE" == "Local + Google Drive" ]]; then
  echo "☁️ Downloading backup from Google Drive..."
  
  # Ensure the correct archive is downloaded from Google Drive
  rclone copy Gdrive:/RestorePoint/backups/"$LATEST_BACKUP" "$DEFAULT_BACKUP_DIR/"
  check_error "Failed to download from Google Drive" "$LOG_FILE"
  log_event "☁️ Downloaded backup from Google Drive: $LATEST_BACKUP" "$LOG_FILE"
fi

# --- Step 3: Restore from the Local Backup Directory ---
if [[ -d "$DEFAULT_BACKUP_DIR/$LATEST_BACKUP" ]]; then
  echo "📁 Restoring backup from $DEFAULT_BACKUP_DIR/$LATEST_BACKUP to $RESTORE_DIR"
  
  # Use rsync to restore the files from the local backup location
  rsync -av --delete "$DEFAULT_BACKUP_DIR/$LATEST_BACKUP/" "$RESTORE_DIR/"
  check_error "Failed to restore backup" "$LOG_FILE"
  log_event "✅ Backup restored from $DEFAULT_BACKUP_DIR/$LATEST_BACKUP to $RESTORE_DIR" "$LOG_FILE"
else
  echo "❌ Backup archive $LATEST_BACKUP does not exist in the backup directory."
  exit 1
fi

echo "✅ Restore process completed!"
log_event "✅ Restore script finished successfully" "$LOG_FILE"

