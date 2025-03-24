#!/bin/bash

# === RestorePoint Saving Script ===

source ~/RestorePoint/scripts/utils.sh

LOG_FILE="save.log"
TIMESTAMP=$(date +%F_%H-%M-%S)
SAVE_DIR="$DATA_DIR/saved_configs"
ARCHIVE_PATH="$DATA_DIR/state-$TIMESTAMP.tar.gz"

# Ensure save directory exists
ensure_dir "$SAVE_DIR"

echo "📁 Saving critical configurations to $SAVE_DIR..."

# Save Rclone config
cp ~/RestorePoint/config/rclone/rclone.conf "$SAVE_DIR/rclone.conf"
check_error "Failed to copy rclone.conf" "$LOG_FILE"

# Save Prometheus config
cp ~/RestorePoint/config/prometheus/prometheus.yml "$SAVE_DIR/prometheus.yml"
check_error "Failed to copy prometheus.yml" "$LOG_FILE"

# Save Age keys (optional, depends on use case)
cp ~/RestorePoint/config/age/public.key "$SAVE_DIR/public.key"
cp ~/RestorePoint/config/age/private.key "$SAVE_DIR/private.key"
check_error "Failed to copy age keys" "$LOG_FILE"

log_event "✅ Configuration files saved to $SAVE_DIR" "$LOG_FILE"

# --- Compress saved data ---
echo "📦 Compressing saved configs into $ARCHIVE_PATH..."
tar -czf "$ARCHIVE_PATH" -C "$DATA_DIR" saved_configs
check_error "Failed to create archive" "$LOG_FILE"
log_event "📦 Created archive: $ARCHIVE_PATH" "$LOG_FILE"

# --- Sync archive to Google Drive ---
echo "☁️ Syncing archive to Google Drive..."
rclone copy "$ARCHIVE_PATH" Gdrive:/RestorePoint/saved-states/
check_error "Failed to upload archive to Google Drive" "$LOG_FILE"
log_event "☁️ Synced archive to Gdrive:/RestorePoint/saved-states/" "$LOG_FILE"

echo "✅ Save process complete!"
log_event "✅ Saving script completed successfully" "$LOG_FILE"
