#!/usr/bin/env bash
set -uo pipefail

old_dir="$PWD"
cd "$HOME/dotfiles" || exit 1

nvim .

alejandra nixos/

git diff -U0 "$HOME/dotfiles"

echo "Preparing pre-rebuild commit..."
pre_committed=false
if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "NixOS Rebuild: pre-rebuild snapshot"
  pre_committed=true
fi

echo "NixOS Rebuilding..."
output_file="output.txt"
rm -f "$output_file"
touch "$output_file"

tmux new-session -d -s nixos-rebuild \
  "nixos-rebuild switch --flake '$HOME/dotfiles/nixos#main' --option eval-cache false &> '$output_file'"

file_ready=false
while ! $file_ready; do
  if grep -q "error" "$output_file"; then
    echo "----------------------"
    echo "Config invalid, error:"
    echo "----------------------"
    cat "$output_file"
    # undo pre-rebuild commit if it exists
    if [ "$pre_committed" = true ]; then
      git reset --soft HEAD~1
    fi
    exit 1
  elif grep -q "restarting sysinit" "$output_file"; then
    echo "Finishing."
    file_ready=true
  else
    cat "$output_file"
    sleep 1
  fi
done

gen=$(nixos-rebuild list-generations | grep current | head -n1 | awk '{print $1}')
msg="NixOS Rebuild - Generation ($gen)"

if [ "$pre_committed" = true ]; then
  git commit --amend -m "$msg"
else
  git commit -am "$msg"
fi

cd "$old_dir" || exit 1
