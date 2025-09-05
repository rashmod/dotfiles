#!/usr/bin/env bash

strip_ansi() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# List existing tmux sessions
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)


current_session=$(tmux display-message -p '#S' 2>/dev/null)
echo "Current session: '$current_session'"

# List existing sessions with coloring
colored_sessions=$(echo "$sessions" | sed 's/^/session:/' | awk -v current="$current_session" '
{
    name = $0
    gsub(/^session:/,"",name)
    if (name == current) {
        print "\033[33m" $0 "\033[0m"   # yellow for current session
    } else {
        print "\033[32m" $0 "\033[0m"   # green for other sessions
    }
}')

# Combine sessions and dirs, prefix sessions so you can distinguish
selected=$(
  ( echo "$colored_sessions"; echo "$(
  fd . / \
    --type d \
    --min-depth 1 \
    --max-depth 6 \
    --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude __pycache__ \
    --exclude .venv
)") \
    | fzf --ansi --prompt="Sessions/Projects> "
)

[ -z "$selected" ] && exit 0


# Remove ANSI codes first
cleaned=$(echo "$selected" | strip_ansi)

# If user picked an existing session
if [[ "$cleaned" == session:* ]]; then
  session_name=${cleaned#session:}
else
  # Otherwise, treat it as a directory → create/find session
  selected_dir="$cleaned"
  session_name=$(basename "$selected_dir" | tr -c '[:alnum:]' '_')

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
