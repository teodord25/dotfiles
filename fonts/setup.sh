#!/bin/bash

FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"  # ensures the directory exists

cp -v *.ttf *.otf "$FONT_DIR" 2>/dev/null

fc-cache -fv

echo "Fonts copied and cache updated."
