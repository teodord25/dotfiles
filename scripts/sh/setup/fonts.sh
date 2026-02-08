#!/usr/bin/env bash
set -e

FONT_DIR="$HOME/.local/share/fonts"
DOTFILES_FONTS="$HOME/dotfiles/fonts"

mkdir -p "$FONT_DIR"

# check if already installed
if ls "$FONT_DIR"/*.{ttf,otf} &>/dev/null; then
    echo "Fonts already installed, skipping..."
    exit 0
fi

echo "Installing fonts..."
cp -v "$DOTFILES_FONTS"/*.{ttf,otf} "$FONT_DIR" 2>/dev/null || true

fc-cache -fv
echo "Fonts installed and cache updated."
