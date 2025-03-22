#!/bin/bash

# Define backup name based on current date
BACKUP_NAME=$(date +"%Y-%m-%d_%H-%M-%S")

# Define data directory
DATA_DIR=~/RestorePoint/data

# Create a BorgBackup
borg create --compression lz4 ~/RestorePoint/backups/local/borg-repo::$BACKUP_NAME $DATA_DIR

# Encrypt the backup using Age
borg extract ~/RestorePoint/backups/local/borg-repo::$BACKUP_NAME --stdout | age -r ~/RestorePoint/config/age/public.key -o ~/RestorePoint/backups/encrypted/$BACKUP_NAME.enc

# Sync the encrypted backup to Google Drive using Rclone
rclone copy ~/RestorePoint/backups/encrypted/ Gdrive:/backup-folder
