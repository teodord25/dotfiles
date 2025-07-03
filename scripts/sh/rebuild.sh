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

echo "Waiting for rebuild logs..."
file_ready=false
while ! $file_ready; do
  # Print separator and timestamp
  echo "---- $(date '+%Y-%m-%d %H:%M:%S') ----"
  if [[ -s "$output_file" ]]; then
    # Show last 20 lines to keep output manageable
    tail -n 20 "$output_file"
  else
    echo "No output yet..."
  fi

  if grep -q "error" "$output_file"; then
    echo "----------------------"
    echo "Config invalid, error:"
    echo "----------------------"
    cat "$output_file"
    if [ "$pre_committed" = true ]; then
      git reset --soft HEAD~1
    fi
    exit 1
  elif grep -q "restarting sysinit" "$output_file"; then
    echo "Finishing."
    file_ready=true
  else
    sleep 1
  fi
done

echo "---- Final Logs ----"
cat "$output_file"

gen=$(nixos-rebuild list-generations | grep current | head -n1 | awk '{print $1}')
msg="NixOS Rebuild - Generation ($gen)"

if [ "$pre_committed" = true ]; then
  git commit --amend -m "$msg"
else
  git commit -am "$msg"
fi

cd "$old_dir" || exit 1
