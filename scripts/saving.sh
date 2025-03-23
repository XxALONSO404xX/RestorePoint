#!/bin/bash

# Interactive script to collect data into ./data
PROJECT_DIR="/home/$(whoami)/RestorePoint"  # Absolute path to project
LOG_FILE="$PROJECT_DIR/logs/saving-$(date +%Y%m%d).log"

# Prompt user for source directory
echo "--------------------------------------------------"
echo "WHERE IS YOUR DATA LOCATED?"
echo "Example: /home/$(whoami)/Documents"
read -p "Enter the full path: " SOURCE_DIR

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
  echo "[ERROR] Directory '$SOURCE_DIR' does not exist." | tee -a "$LOG_FILE"
  exit 1
fi

# Copy data
TARGET_DIR="$PROJECT_DIR/data"
mkdir -p "$TARGET_DIR"
rm -rf "${TARGET_DIR:?}/"* 2>/dev/null

echo "Copying files from $SOURCE_DIR to $TARGET_DIR..."
rsync -avh --progress "$SOURCE_DIR/" "$TARGET_DIR/" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  echo "[SUCCESS] Data saved to $TARGET_DIR" | tee -a "$LOG_FILE"
else
  echo "[ERROR] Failed to save data." | tee -a "$LOG_FILE"
  exit 1
fi
