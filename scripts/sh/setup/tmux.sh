#!/usr/bin/env bash
set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
    echo "TPM already installed at $TPM_DIR"
    exit 0
fi

echo "Installing TPM..."
git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
echo "TPM installed. Run 'prefix + I' in tmux to install plugins."
