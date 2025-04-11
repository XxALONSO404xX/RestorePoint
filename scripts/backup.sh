#!/bin/bash

# === RestorePoint Backup Script ===

source ~/RestorePoint/scripts/utils.sh

LOG_FILE="backup.log"
LOCAL_BACKUP_DIR=~/RestorePoint/backups/local

# Ensure logs directory exists
ensure_dir "$LOG_DIR"

# --- STEP 1: Ask source directory ---
echo "📂 Enter the full path of the directory to backup: "
read SOURCE_DIR
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "❌ Source directory does not exist."
  exit 1
fi

# --- STEP 2: Ask backup type ---
echo "♻️ Backup to:"
select BACKUP_TYPE in "Local backup (rsync)" "Google Drive backup (encrypted)"; do
  case $BACKUP_TYPE in
    "Local backup (rsync)"|"Google Drive backup (encrypted)")
      break;;
    *) echo "❌ Invalid option. Try again.";;
  esac
done

# --- STEP 3: Perform Local Backup with rsync ---
if [[ "$BACKUP_TYPE" == "Local backup (rsync)" ]]; then
  # Create a timestamped directory for the backup
  BACKUP_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  BACKUP_DEST="$LOCAL_BACKUP_DIR/backup-$BACKUP_TIMESTAMP"

  echo "⚡ Starting local backup with rsync to $BACKUP_DEST"

  # Run rsync to copy the directory contents to the backup destination
  rsync -av --progress "$SOURCE_DIR" "$BACKUP_DEST"
  check_error "Local backup failed" "$LOG_FILE"
  log_event "✅ Local backup created: $BACKUP_DEST" "$LOG_FILE"
fi

# --- STEP 4: Perform Google Drive Backup ---
if [[ "$BACKUP_TYPE" == "Google Drive backup (encrypted)" ]]; then
  TMP_DIR=~/RestorePoint/tmp_backup
  PRIVATE_KEY=~/RestorePoint/config/age/private.key
  BACKUP_ENCRYPTED_DIR=~/RestorePoint/backups/encrypted

  ensure_dir "$TMP_DIR"

  echo "☁️ Starting Google Drive backup (encrypted)..."

  # Step 1: Sync files to temporary backup folder (unencrypted)
  rsync -av --progress "$SOURCE_DIR" "$TMP_DIR"
  check_error "Local backup to temporary folder failed" "$LOG_FILE"
  log_event "✅ Local backup to temporary folder completed" "$LOG_FILE"

  # Step 2: Encrypt the backup using age (the temporary backup folder)
  BACKUP_NAME="backup-$(date +"%Y-%m-%d_%H-%M-%S")"  # Automatically generate the backup name
  echo "🔒 Encrypting backup to $BACKUP_NAME.age..."
  age --encrypt --recipient-file "$PRIVATE_KEY" -o "$BACKUP_ENCRYPTED_DIR/$BACKUP_NAME.age" "$TMP_DIR"
  check_error "Google Drive encryption failed" "$LOG_FILE"
  log_event "✅ Encrypted backup created: $BACKUP_ENCRYPTED_DIR/$BACKUP_NAME.age" "$LOG_FILE"

  # Step 3: Upload to Google Drive
  echo "☁️ Uploading encrypted backup to Google Drive..."
  rclone copy "$BACKUP_ENCRYPTED_DIR" Gdrive:/RestorePoint/encrypted --create-empty-src-dirs
  check_error "Upload to Google Drive failed" "$LOG_FILE"
  log_event "✅ Uploaded encrypted backup to Google Drive" "$LOG_FILE"

  # Clean up temporary backup folder
  rm -rf "$TMP_DIR"
  log_event "🧹 Cleaned up temporary backup folder" "$LOG_FILE"
fi

echo "✅ Backup complete!"
log_event "✅ Backup script finished successfully" "$LOG_FILE"

