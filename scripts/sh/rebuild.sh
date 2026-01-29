#!/usr/bin/env bash
set -uo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 {personal|work}"
  exit 2
fi

if [[ "$1" != "personal" && "$1" != "work" ]]; then
  echo "Usage: $0 {personal|work}"
  echo "  personal|work: Which dotfiles profile to use"
  exit 2
fi

old_dir="$PWD"
cd "$HOME/dotfiles/nixos" || exit 1

nvim .
alejandra .

git add -N .  # add untracked files to index without staging
git diff -U0 .  # show diff with no context but including new files

read -r -p "Commit message (optional): " commit_msg

# create snapshot
echo "Preparing pre-rebuild commit..."
pre_committed=false
if ! git diff-index --quiet HEAD -- .; then
  git add .
  git commit -m "NixOS Rebuild: pre-rebuild snapshot"
  pre_committed=true
fi

echo "NixOS Rebuilding..."
output_file="output.txt"
rm -f "$output_file"

if ! sudo nixos-rebuild switch \
    --flake "$HOME/dotfiles/nixos#$1" \
    --option eval-cache false \
    2>&1 | tee "$output_file"; then
  echo "----------------------"
  echo "Build failed!"
  echo "----------------------"
  [[ "$pre_committed" == true ]] && git reset --soft HEAD~1
  exit 1
fi

gen=$(nixos-rebuild list-generations | awk '$NF == "True" {print $1}')

if [[ -n "$commit_msg" ]]; then
  msg="NixOS Generation ($gen) - $commit_msg"
else
  msg="NixOS Generation ($gen)"
fi

if [ "$pre_committed" = true ]; then
  git commit --amend -m "$msg"
else
  git add .
  git commit -m "$msg"
fi

cd "$old_dir" || exit 1
