#!/usr/bin/env bash
# hdr.sh — HDR switch for the gaming monitor (Hyprland color management).
#
# Usage: hdr.sh [on|off|toggle]        (default: toggle)
#
# Adjust MODE_SDR / MODE_HDR once you know the monitor's best mode —
# "highrr" picks the highest refresh mode; change to an explicit WxH@Hz if needed.
# Override the target monitor with HDR_MONITOR=DP-1 if needed.
#
# Note: this switches the *desktop* to HDR. For in-game HDR, Steam launch
# options `gamescope --hdr-enabled -f -- %command%` is the reliable path.

set -euo pipefail

MON="${HDR_MONITOR:-$(hyprctl -j monitors | jq -r '.[0].name')}"
MODE_SDR="highrr, auto, 1, bitdepth, 10, cm, srgb"
MODE_HDR="highrr, auto, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98"

STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-hdr-state"

apply() { # $1 = on|off, $2 = mode line
    hyprctl keyword monitor "$MON, $2" >/dev/null
    echo "$1" >"$STATE"
    command -v notify-send >/dev/null && notify-send -t 2000 "HDR $1" "$MON" || true
}

want="${1:-toggle}"
cur="$(cat "$STATE" 2>/dev/null || echo off)"
if [[ "$want" == "toggle" ]]; then
    if [[ "$cur" == "on" ]]; then want=off; else want=on; fi
fi

case "$want" in
    on) apply on "$MODE_HDR" ;;
    off) apply off "$MODE_SDR" ;;
    *)
        echo "usage: hdr.sh [on|off|toggle]"
        exit 2
        ;;
esac
