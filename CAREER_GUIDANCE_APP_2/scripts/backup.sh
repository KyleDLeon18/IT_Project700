#!/bin/bash

# Configuration
DB_PATH="/workspaces/IT_Project700/CAREER_GUIDANCE_APP_2/resource/users.db"
BACKUP_DIR="/workspaces/IT_Project700/CAREER_GUIDANCE_APP_2/backups"
LOG_FILE="/workspaces/IT_Project700/CAREER_GUIDANCE_APP_2/backup.log"
DATE=$(date +'%Y-%m-%d')
CONFIG_FILES=("/workspaces/IT_Project700/CAREER_GUIDANCE_APP_2/venv" )  # Add any additional config files
BACKUP_FILE_NAME="users_backup.db"


# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"
mkdir -p "$LAST_GOOD_BACKUP_DIR"  # Directory for last known good backup

# Step 1: Remove backups older than 4 days
echo "[$(date)] - Starting backup process..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -name "users_backup_*.db" -mtime +4 -exec rm -fv {} \; | tee -a "$LOG_FILE"
echo "[$(date)] - Old backups removed." | tee -a "$LOG_FILE"

# Step 2: Rename existing backup with today's date if it exists
if [ -f "$BACKUP_DIR/$BACKUP_FILE_NAME" ]; then
    mv "$BACKUP_DIR/$BACKUP_FILE_NAME" "$BACKUP_DIR/users_backup_$DATE.db"
    echo "[$(date)] - Existing backup renamed to users_backup_$DATE.db." | tee -a "$LOG_FILE"
fi

# Step 3: Set journal mode to WAL for better backup performance
sqlite3 "$DB_PATH" "PRAGMA journal_mode=WAL;" | tee -a "$LOG_FILE"

# Step 4: Perform Integrity Check
echo "[$(date)] - Performing integrity check..." | tee -a "$LOG_FILE"
sqlite3 "$DB_PATH" "PRAGMA integrity_check;" | tee -a "$LOG_FILE"
if [ "$(sqlite3 "$DB_PATH" "PRAGMA integrity_check;")" != "ok" ]; then
    echo "[$(date)] - Database integrity check failed. Aborting backup." | tee -a "$LOG_FILE"
    exit 1
else
    echo "[$(date)] - Database integrity check passed." | tee -a "$LOG_FILE"
fi

# Step 5: Perform Backup using .backup command
echo "[$(date)] - Creating new backup..." | tee -a "$LOG_FILE"
sqlite3 "$DB_PATH" ".backup '$BACKUP_DIR/$BACKUP_FILE_NAME'"
if [ $? -eq 0 ]; then
    echo "[$(date)] - New backup created successfully as $BACKUP_FILE_NAME." | tee -a "$LOG_FILE"
else
    echo "[$(date)] - Backup failed." | tee -a "$LOG_FILE"
    exit 1
fi

# Step 6: Backup and compress configuration files
echo "[$(date)] - Backing up configuration files..." | tee -a "$LOG_FILE"
TAR_FILE="$BACKUP_DIR/config_backup_$DATE.tar.gz"
tar -czf "$TAR_FILE" "${CONFIG_FILES[@]}"
if [ $? -eq 0 ]; then
    echo "[$(date)] - Configuration files backed up and compressed to $TAR_FILE." | tee -a "$LOG_FILE"
else
    echo "[$(date)] - Configuration file backup failed." | tee -a "$LOG_FILE"
    exit 1
fi

echo "[$(date)] - Backup process completed." | tee -a "$LOG_FILE"
