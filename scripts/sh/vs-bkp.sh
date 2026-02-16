#!/usr/bin/env bash

PI_USER="joe"
PI_IP="192.168.1.11"
SOURCE_PATH="/home/joe/VSDATA/Saves/default.vcdbs"
DEST_DIR="/home/$(whoami)/pi-backups/"
SSH_KEY="$HOME/.ssh/raspberry"
LOG_FILE="$HOME/.local/share/vs-bkp.log"

SERVER_STOP="PATH=/home/joe/.dotnet:\$PATH /home/joe/VS/server.sh stop"
SERVER_START="PATH=/home/joe/.dotnet:\$PATH /home/joe/VS/server.sh start"

SSH_OPTS="-i $SSH_KEY -o ConnectTimeout=10 -o BatchMode=yes"

# create dirs
mkdir -p "$DEST_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

start_server() {
    log "Starting VS server..."
    if ssh $SSH_OPTS "$PI_USER@$PI_IP" "$SERVER_START"; then
        log "VS server started successfully"
    else
        log "ERROR: Failed to start VS server!"
    fi
}

# set trap to make server start even if script fails
trap start_server EXIT

# check connection
if ! ping -c 1 -W 5 "$PI_IP" > /dev/null 2>&1; then
    log "Pi unreachable at $PI_IP"
    trap - EXIT  # remove trap if pi is unreachable
    exit 1
fi

log "Stopping VS server..."
if ssh $SSH_OPTS "$PI_USER@$PI_IP" "$SERVER_STOP"; then
    log "VS server stopped successfully"
else
    log "ERROR: Failed to stop VS server"
    trap - EXIT  # remove trap if failed to stop
    exit 1
fi

# wait for server to fully stop
sleep 60

log "Starting backup..."

# make copy of current version with timestamp
if [ -f "$DEST_DIR$(basename "$SOURCE_PATH")" ]; then
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    cp "$DEST_DIR$(basename "$SOURCE_PATH")" "$DEST_DIR$(basename "$SOURCE_PATH" .vcdbs)_${TIMESTAMP}.vcdbs"
    log "Archived current backup: $(basename "$SOURCE_PATH" .vcdbs)_${TIMESTAMP}.vcdbs"
fi

# rsync the latest version
if rsync -avz --info=progress2 -e "ssh $SSH_OPTS" "$PI_USER@$PI_IP:$SOURCE_PATH" "$DEST_DIR"; then
    log "Successfully pulled $(basename "$SOURCE_PATH") from Pi"
    BACKUP_SUCCESS=true
else
    log "Failed to pull $(basename "$SOURCE_PATH") from Pi"  
    BACKUP_SUCCESS=false
fi


# if stop and rsync succeeded, remove trap and start server manually
trap - EXIT

start_server

if [ "$BACKUP_SUCCESS" = true ]; then
    log "Backup completed successfully"
    exit 0
else
    log "Backup failed"
    exit 1
fi
