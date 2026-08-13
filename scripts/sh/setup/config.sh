#!/usr/bin/env bash
set -e

cd "$HOME/dotfiles/" || exit 1

stow .

# NOTE: no ~/.gitconfig symlink needed — git reads ~/.config/git/config
# natively (XDG).

mkdir -p ~/.ssh
chmod 700 ~/.ssh
ln -sf ~/.config/ssh/config ~/.ssh/config
chmod 600 ~/.ssh/config

# pick the per-host hyprland config (sourced by hyprland.conf)
case "$(hostname)" in
    teodor-work-nixos) hypr_host=work ;;
    teodor-gaming-nixos) hypr_host=gaming ;;
    *)
        echo "unknown host '$(hostname)' — link ~/.config/hypr/host.conf manually"
        exit 0
        ;;
esac
ln -sfn "hosts/$hypr_host.conf" "$HOME/.config/hypr/host.conf"
echo "hypr host config -> $hypr_host"
