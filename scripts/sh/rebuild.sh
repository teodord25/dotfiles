#!/usr/bin/env bash
set -uo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 {personal|work} [commit_message]"
  exit 2
fi

if [[ "$1" != "personal" && "$1" != "work" ]]; then
  echo "Usage: $0 {personal|work} [commit_message]"
  echo "  personal|work: Which dotfiles profile to use"
  echo "  commit_message: Optional custom commit message"
  exit 2
fi

old_dir="$PWD"
cd "$HOME/dotfiles/nixos" || exit 1

nvim .

alejandra .

# print to stdout
# -U0 = 0 lines around changes (no context)
git diff -U0 "$HOME/dotfiles/nixos"

# create snapshot
echo "Preparing pre-rebuild commit..."
pre_committed=false
if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "NixOS Rebuild: pre-rebuild snapshot"
  pre_committed=true
fi

echo "NixOS Rebuilding..."
output_file="output.txt"

# remove old if present
rm -f "$output_file"
touch "$output_file"

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

gen=$(nixos-rebuild list-generations | grep current | head -n1 | awk '{print $1}')
msg="NixOS Generation ($gen) - $2"

if [ "$pre_committed" = true ]; then
  git commit --amend -m "$msg"
else
  git commit -am "$msg"
fi

cd "$old_dir" || exit 1
