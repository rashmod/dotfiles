#!/usr/bin/env bash

HOME_SESSION="home"
HOME_DIR="$HOME"

# If already inside tmux, do nothing
if [ -n "$TMUX" ]; then
  exit 0
fi

# Ensure home session exists
if ! tmux has-session -t "$HOME_SESSION" 2>/dev/null; then
  tmux new-session -ds "$HOME_SESSION" -c "$HOME_DIR" -s "$HOME_SESSION"
fi

# Just run attach with no -t → tmux will use the last used session
tmux attach || tmux attach -t "$HOME_SESSION"
