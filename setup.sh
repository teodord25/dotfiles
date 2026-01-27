#!/usr/bin/env bash

# this is broken idk
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

bash "$ROOT_DIR/other/setup.sh" # what was this

mkdir -p "$SYSTEMD_USER_DIR"

ln -sf "$ROOT_DIR/services/shutdown-warning.service" "$SYSTEMD_USER_DIR/shutdown-warning.service"
ln -sf "$ROOT_DIR/services/shutdown-warning.timer"   "$SYSTEMD_USER_DIR/shutdown-warning.timer"

systemctl --user daemon-reload
systemctl --user enable --now shutdown-warning.timer
