#!/usr/bin/env bash

set -e

echo "Setting up Tridactyl native messenger for Zen Browser..."

mkdir -p ~/.mozilla/native-messaging-hosts/

ln -sf /run/current-system/sw/lib/mozilla/native-messaging-hosts/tridactyl.json \
    ~/.mozilla/native-messaging-hosts/tridactyl.json

echo "Tridactyl native messenger manifest symlinked"
echo "Restart Zen Browser if running for changes to take effect"
