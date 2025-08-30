# #!/usr/bin/env bash

# selected=$(
#   fd . / \
#     --type d \
#     --min-depth 1 \
#     --max-depth 6 \
#     --hidden \
#     --exclude .git \
#     --exclude node_modules \
#     --exclude __pycache__ \
#     --exclude .venv \
#   | fzf
# )

# [ -z "$selected" ] && exit 0

# session_name=$(basename "$selected" | tr ' .:' '__')

# if ! tmux has-session -t="$session_name" 2>/dev/null; then
#   tmux new-session -ds "$session_name" -c "$selected"
# fi

# if [ -n "$TMUX" ]; then
#   tmux switch-client -t "$session_name"
# else
#   tmux attach -t "$session_name"
# fi

# List existing tmux sessions
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# List directories with fd
dirs=$(
  fd . / \
    --type d \
    --min-depth 1 \
    --max-depth 6 \
    --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude __pycache__ \
    --exclude .venv
)

# Combine sessions and dirs, prefix sessions so you can distinguish
selected=$(
  (echo "$sessions" | sed 's/^/session:/'; echo "$dirs") \
    | fzf --prompt="Sessions/Projects> "
)

[ -z "$selected" ] && exit 0

# If user picked an existing session
if [[ "$selected" == session:* ]]; then
  session_name=${selected#session:}
else
  # Otherwise, treat it as a directory → create/find session
  selected_dir="$selected"
  session_name=$(basename "$selected_dir" | tr ' .:' '__')

  if ! tmux has-session -t="$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$selected_dir"
  fi
fi

# Attach or switch depending on whether we're inside tmux
if [ -n "$TMUX" ]; then
  tmux switch-client -t "$session_name"
else
  tmux attach -t "$session_name"
fi
