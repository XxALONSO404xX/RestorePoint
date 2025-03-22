#!/bin/bash

# Define backup name
BACKUP_NAME=$RestorePoint

# Download the encrypted backup from Google Drive using Rclone
rclone copy Gdrive:/backup-folder ~/RestorePoint/backups/encrypted/

# Decrypt the backup using Age
age -d -i ~/RestorePoint/config/age/private.key -o ~/RestorePoint/backups/encrypted/$BACKUP_NAME.decrypted ~/RestorePoint/backups/encrypted/$BACKUP_NAME.enc

# Restore the backup using BorgBackup
borg extract ~/RestorePoint/backups/local/borg-repo::$BACKUP_NAME --stdin < ~/RestorePoint/backups/encrypted/$BACKUP_NAME.decrypted
