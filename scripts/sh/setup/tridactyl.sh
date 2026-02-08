#!/usr/bin/env bash
set -e

echo "Setting up Tridactyl native messenger for Zen Browser..."

NATIVE_DIR="$HOME/.mozilla/native-messaging-hosts"
mkdir -p "$NATIVE_DIR"

ln -sf /run/current-system/sw/lib/mozilla/native-messaging-hosts/tridactyl.json \
    "$NATIVE_DIR/tridactyl.json"

echo "Tridactyl native messenger symlinked"
echo "Restart Zen Browser if running"
