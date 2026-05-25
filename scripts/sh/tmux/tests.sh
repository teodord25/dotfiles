#!/usr/bin/env bash
tests
rc=$?

if [ $rc -eq 0 ]; then
  tmux rename-window -t dev:3 "OK"
  tmux set-window-option -t dev:3 window-status-current-style "fg=green,bold"
  tmux set-window-option -t dev:3 window-status-style "fg=green"
else
  tmux rename-window -t dev:3 "FUCK"
  tmux set-window-option -t dev:3 window-status-current-style "fg=red,bold"
  tmux set-window-option -t dev:3 window-status-style "fg=red"
fi

exit $rc
