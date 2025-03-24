#!/bin/bash

# === RestorePoint Utilities ===

# Set base directories (change if structure changes)
LOG_DIR=~/RestorePoint/logs
DATA_DIR=~/RestorePoint/data
BACKUP_DIR=~/RestorePoint/backups
ENCRYPTED_DIR=$BACKUP_DIR/encrypted
REPO_DIR=$BACKUP_DIR/local/borg-repo

# 📜 Log a message to a specific log file
log_event() {
  local MESSAGE=$1
  local FILE=$2
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOG_DIR/$FILE"
}

# ❌ Exit if previous command failed
check_error() {
  local ERROR_MSG=$1
  local LOG_FILE=$2
  if [ $? -ne 0 ]; then
    log_event "ERROR: $ERROR_MSG" "$LOG_FILE"
    echo "❌ $ERROR_MSG. See logs/$LOG_FILE"
    exit 1
  fi
}

# 🧪 Check if a directory exists, or create it
ensure_dir() {
  local DIR=$1
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
  fi
}
