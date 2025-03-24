#!/bin/bash

# === RestorePoint Restore Script ===

source ~/RestorePoint/scripts/utils.sh

LOG_FILE="restore.log"
RESTORE_TARGET=~/RestorePoint/data

# Ask where to restore from
echo "♻️ Where do you want to restore from?"
select SOURCE in "Local backup" "Google Drive (encrypted)"; do
  case $SOURCE in
    "Local backup"|"Google Drive (encrypted)")
      break
      ;;
    *)
      echo "Invalid option. Try again."
      ;;
  esac
done

# --- Step 1: Restore from Local Borg Archive ---
if [[ "$SOURCE" == "Local backup" ]]; then
  echo "📦 Available backups:"
  borg list "$REPO_DIR"

  echo -n "📥 Enter archive name to restore (e.g. backup-2025-03-23_14-55-10): "
  read ARCHIVE

  echo "📂 Restoring $ARCHIVE to $RESTORE_TARGET..."
  borg extract "$REPO_DIR::$ARCHIVE"
  check_error "Failed to restore archive: $ARCHIVE" "$LOG_FILE"
  log_event "✅ Restored archive: $ARCHIVE" "$LOG_FILE"
fi

# --- Step 2: Restore from Encrypted Google Drive Backup ---
if [[ "$SOURCE" == "Google Drive (encrypted)" ]]; then
  TMP_PATH=~/RestorePoint/tmp_restore
  ENCRYPTED_DIR=~/RestorePoint/backups/encrypted
  PRIVATE_KEY=~/RestorePoint/config/age/private.key

  ensure_dir "$TMP_PATH"

  echo "☁️ Downloading latest encrypted backup from Gdrive..."
  rclone copy Gdrive:/RestorePoint/encrypted "$TMP_PATH" --max-age 30d
  check_error "Download from Google Drive failed" "$LOG_FILE"

  # Find latest .age file
  LATEST_FILE=$(find "$TMP_PATH/encrypted" -name "*.age" | sort | tail -n 1)

  if [ -z "$LATEST_FILE" ]; then
    echo "❌ No encrypted backup found."
    exit 1
  fi

  echo "🔓 Decrypting $LATEST_FILE..."
  mkdir -p "$TMP_PATH/decrypted"
  age --decrypt --identity "$PRIVATE_KEY" -o "$TMP_PATH/backup.tar.gz" "$LATEST_FILE"
  check_error "Failed to decrypt backup" "$LOG_FILE"
  log_event "🔓 Decrypted backup: $LATEST_FILE" "$LOG_FILE"

  echo "📂 Extracting backup to $RESTORE_TARGET..."
  tar -xzf "$TMP_PATH/backup.tar.gz" -C "$RESTORE_TARGET"
  check_error "Failed to extract decrypted backup" "$LOG_FILE"
  log_event "✅ Restored backup from Google Drive" "$LOG_FILE"

  # Cleanup
  rm -rf "$TMP_PATH"
fi

echo "✅ Restore complete!"
log_event "✅ Restore script finished successfully" "$LOG_FILE"
