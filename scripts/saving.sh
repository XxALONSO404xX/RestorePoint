#!/bin/bash

# Define the source directory (the data you want to save)
SOURCE_DIR=/path/to/source

# Define the backup directory (where data will be saved)
BACKUP_DIR=~/RestorePoint/data

# Copy files from the source to the backup directory
cp -r $SOURCE_DIR/* $BACKUP_DIR/

# Log the saving action
echo "Data saved from $SOURCE_DIR to $BACKUP_DIR at $(date)" >> ~/RestorePoint/logs/save.log

