#!/usr/bin/env bash
if tmux has-session -t dev 2>/dev/null; then
  echo "Error: tmux session 'dev' already exists"
  echo "Attach with: tmux attach-session -t dev"
  exit 1
fi

if ! command -v entr &> /dev/null; then
  echo "Error: entr is not installed"
  exit 1
fi

if ! command -v delta &> /dev/null; then
  echo "Error: delta is not installed"
  exit 1
fi

SCRIPTS="$HOME/dotfiles/scripts/sh/tmux"
REPO_DIR="$(pwd)"
FLAKE_URL="git+file://${REPO_DIR}?ref=build/dev-nix-flake"

# window 1: main layout
tmux new-session -d -s dev -n main
tmux split-window -h -t dev:main
tmux split-window -h -t dev:main.2
tmux resize-pane -t dev:main.1 -x 80
tmux resize-pane -t dev:main.3 -x 64
tmux set-hook -t dev client-resized \
  'if-shell "[ #{window_width} -ge 162 ]" \
    "resize-pane -t dev:main.1 -x 80 ; resize-pane -t dev:main.3 -x 64"'

# show git delta left
tmux send-keys -t dev:main.1 "$SCRIPTS/delta-watch.sh" C-m

# init dev server window
tmux new-window -t dev -n server
tmux send-keys -t dev:server.1 "nix develop '$FLAKE_URL'" C-m

# init tests window
tmux new-window -t dev -n tests
tmux send-keys -t dev:tests.1 "nix develop '$FLAKE_URL'" C-m

# select the main window and pane
tmux select-window -t dev:main
tmux select-pane -t dev:main.2

# run delayed commands in background
(
  tmux send-keys -t dev:server.1 "dev" C-m
  tmux send-keys -t dev:tests.1 "git ls-files | entr -rcs 'cd app && poetry run pytest'" C-m
) &

# attach immediately
tmux attach-session -t dev
