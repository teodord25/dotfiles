#!/usr/bin/env bash
set -e

cd "$HOME/dotfiles/" || exit 1

stow .

ln -sf ~/.config/git/.gitconfig ~/.gitconfig

mkdir -p ~/.ssh
chmod 700 ~/.ssh
ln -sf ~/.config/ssh/config ~/.ssh/config
chmod 600 ~/.ssh/config
