# RestorePoint Backup System

A secure, automated backup solution using **BorgBackup**, **Age encryption**, and **Rclone** for Google Drive sync.

## Features
- **Data Collection**: Organizes files into `./data` for backup.
- **Encryption**: Uses Age for military-grade encryption.
- **Cloud Sync**: Uploads backups to Google Drive.
- **Monitoring**: Optional Prometheus/Grafana integration.

## Prerequisites
- Ubuntu 20.04+ VM
- Google Drive account (for Rclone)

## Installation
1. **Install Dependencies**:
   ```bash
   sudo apt update && sudo apt install -y borgbackup age rclone docker.io docker-compose
2. Clone This Repository:
   ```bash
git clone https://github.com/yourusername/RestorePoint.git
cd RestorePoint
3.Generate Age Keys:
age-keygen -o config/age/private.key
4.Configure Rclone:
rclone config  # Name the remote "Gdrive"

Usage:
Manual Backup:
./scripts/saving.sh && ./scripts/backup.sh
Restore Data:
./scripts/restore.sh


