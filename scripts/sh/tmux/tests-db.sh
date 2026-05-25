#!/usr/bin/env bash
tests-db --exclude-perf
rc=$?

if [ $rc -eq 0 ]; then
  tmux rename-window -t dev:4 "OK"
  tmux set-window-option -t dev:4 window-status-current-style "fg=green,bold"
  tmux set-window-option -t dev:4 window-status-style "fg=green"
else
  tmux rename-window -t dev:4 "FUCK"
  tmux set-window-option -t dev:4 window-status-current-style "fg=red,bold"
  tmux set-window-option -t dev:4 window-status-style "fg=red"
fi

exit $rc
