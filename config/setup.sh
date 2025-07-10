#!/usr/bin/env bash

# This script creates symlinks in .config/ for all subdirs of this dir so as to
# keep all relevant configuration in one place, effectively imitating home
# manager without the overhead of actually using home manager and having to
# rebuild for minor frequent changes.
#
# It also installs tpm for tmux

# Get the directory where the script itself is located
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define the target directory for the symlinks
TARGET_DIR=~/.config

# Find all directories in the source directory and create symlinks in the target directory
for config in $(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;); do
    ln -sfn "$SOURCE_DIR/$config" "$TARGET_DIR/$config"
    echo "Symlink created for $config"
done

echo "All symlinks have been created successfully."

git clone https://github.com/tmux-plugins/tpm ~/dotfiles/other/tmux/plugins/tpm

echo "Installed Tmux Plugin Manager, use prefix + I to install plugins"
