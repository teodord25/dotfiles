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

cmd="nixos-rebuild switch --flake '$HOME/dotfiles/nixos#$1' " \
"--option eval-cache false &> '$output_file'"

# -d detach
# -s set name
tmux new-session -d -s nixos-rebuild "$cmd"

echo "Monitoring rebuild..."

# tail temp file to stdout
tail -f "$output_file" 2>/dev/null & # suppress "no file (yet) err"
tail_pid=$! # save last background job pid

while true; do
  if grep -q "error" "$output_file" 2>/dev/null; then
    kill $tail_pid 2>/dev/null
    echo -e "\n----------------------"
    echo "Build failed!"
    [[ "$pre_committed" == true ]] && git reset --soft HEAD~1
    exit 1
  elif grep -q "restarting sysinit" "$output_file" 2>/dev/null; then
    kill $tail_pid 2>/dev/null
    echo -e "\nBuild complete!"
    break
  fi
  sleep 0.5
done

echo "---- Final Logs ----"
cat "$output_file"

gen=$(nixos-rebuild list-generations | grep current | head -n1 | awk '{print $1}')
msg="NixOS Generation ($gen) - $2"

if [ "$pre_committed" = true ]; then
  git commit --amend -m "$msg"
else
  git commit -am "$msg"
fi

cd "$old_dir" || exit 1
