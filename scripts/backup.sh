#!/bin/bash

# === RestorePoint Backup Script ===

source ~/RestorePoint/scripts/utils.sh

LOG_FILE="backup.log"
ARCHIVE_NAME="backup-$(date +%F_%H-%M-%S)"

# Ensure directories
ensure_dir "$LOG_DIR"
ensure_dir "$ENCRYPTED_DIR"

# Ask user for backup destination
echo "📦 Where do you want to back up?"
select DEST in "Local only" "Local + Google Drive"; do
  case $DEST in
    "Local only"|"Local + Google Drive")
      break
      ;;
    *)
      echo "Invalid option. Try again."
      ;;
  esac
done

# --- Step 1: Create Borg backup ---
echo "📁 Creating Borg backup: $ARCHIVE_NAME"
borg create --compression lz4 "$REPO_DIR::$ARCHIVE_NAME" "$DATA_DIR"
check_error "Failed to create Borg backup" "$LOG_FILE"
log_event "✅ Borg backup created: $ARCHIVE_NAME" "$LOG_FILE"

# --- Step 2: Encrypt the Borg repo (optional) ---
if [[ "$DEST" == "Local + Google Drive" ]]; then
  AGE_PUBLIC_KEY=$(cat ~/RestorePoint/config/age/public.key)
  ENCRYPTED_FILE="$ENCRYPTED_DIR/${ARCHIVE_NAME}.age"

  echo "🔐 Encrypting backup with Age..."
  tar -czf - -C "$REPO_DIR" . | age --encrypt -r "$AGE_PUBLIC_KEY" -o "$ENCRYPTED_FILE"
  check_error "Failed to encrypt backup" "$LOG_FILE"
  log_event "🔒 Backup encrypted: $ENCRYPTED_FILE" "$LOG_FILE"

  # --- Step 3: Upload to Google Drive ---
  echo "☁️ Uploading to Google Drive..."
  rclone copy "$ENCRYPTED_FILE" Gdrive:/RestorePoint/encrypted/
  check_error "Upload to Google Drive failed" "$LOG_FILE"
  log_event "☁️ Backup uploaded to Gdrive:/RestorePoint/encrypted/" "$LOG_FILE"
fi

echo "✅ Backup process completed!"
log_event "✅ Backup script finished successfully" "$LOG_FILE"
