#!/usr/bin/env bash

strip_ansi() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

if [[ "${1:-}" == "__filter" ]]; then
  query="${2:-}"
  shift 2

  for section_file in "$@"; do
    if [ -z "$query" ]; then
      cat "$section_file"
    else
      plain_matches=$(strip_ansi < "$section_file" | fzf --filter "$query")

      while IFS= read -r plain_match; do
        [ -z "$plain_match" ] && continue

        while IFS= read -r colored_line; do
          if [ "$(printf "%s\n" "$colored_line" | strip_ansi)" = "$plain_match" ]; then
            printf "%s\n" "$colored_line"
            break
          fi
        done < "$section_file"
      done <<< "$plain_matches"
    fi
  done

  exit 0
fi

scan_mode="${1:-personal}"

# Function to colorize sessions
color_session() {
    local session="$1"
    local current="$2"

    if [[ "$session" == "$current" ]]; then
        # Yellow for current session
        printf "\033[33msession:%s\033[0m\n" "$session"
    else
        # Green for other sessions
        printf "\033[32msession:%s\033[0m\n" "$session"
    fi
}

color_path() {
    local kind="$1"
    local path="$2"
    local color="$3"

    printf "\033[%sm%s:%s\033[0m\n" "$color" "$kind" "$path"
}

# List existing tmux sessions
sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

# Get current tmux session
current_session=$(tmux display-message -p '#S' 2>/dev/null)

# Colorize sessions: yellow for current, green for others
colored_sessions=$(
  if [ -n "$sessions" ]; then
    while IFS= read -r s; do
        color_session "$s" "$current_session"
    done <<< "$sessions"
  fi
)

case "$scan_mode" in
  personal)
    search_root="$HOME/personal"
    max_depth=4
    prompt="Sessions/Personal> "
    ;;
  all)
    search_root="/"
    max_depth=6
    prompt="Sessions/Projects> "
    ;;
  *)
    printf 'Unknown scan mode: %s\n' "$scan_mode" >&2
    exit 1
    ;;
esac

colored_repos=""
colored_worktrees=""
colored_dirs=""
if [ -d "$search_root" ]; then
  repo_dirs=$(
    fd --glob ".git" "$search_root" \
      --hidden \
      --max-depth "$((max_depth + 1))" \
      | while IFS= read -r git_path; do
          dirname "$git_path"
        done \
      | sed 's#/*$##'
  )

  worktree_dirs=$(
    fd --glob ".worktrees" "$search_root" \
      --type d \
      --hidden \
      --no-ignore \
      --max-depth "$((max_depth - 1))" \
      --exec fd --glob ".git" {} \
        --hidden \
        --no-ignore \
        --max-depth 2 \
      | while IFS= read -r git_path; do
          dirname "$git_path"
        done \
      | sed 's#/*$##'
  )

  dirs=$(
    fd . "$search_root" \
      --type d \
      --min-depth 1 \
      --max-depth "$max_depth" \
      --hidden \
      --exclude .git \
      --exclude node_modules \
      --exclude __pycache__ \
      --exclude .venv \
      | sed 's#/*$##' \
      | grep -vxF -f <(printf "%s\n%s\n" "$repo_dirs" "$worktree_dirs" | sed '/^$/d') \
      | sort -u
  )

  colored_repos=$(
    printf "%s\n" "$repo_dirs" \
      | sed '/^$/d' \
      | sort -u \
      | while IFS= read -r path; do
          color_path "repo" "$path" "36"
        done
  )

  colored_worktrees=$(
    printf "%s\n" "$worktree_dirs" \
      | sed '/^$/d' \
      | sort -u \
      | while IFS= read -r path; do
          color_path "worktree" "$path" "35"
        done
  )

  colored_dirs=$(
    printf "%s\n" "$dirs" \
      | sed '/^$/d' \
      | sort -u \
      | while IFS= read -r path; do
          color_path "dir" "$path" "37"
        done
  )
fi

script_path="${BASH_SOURCE[0]}"
if [[ "$script_path" != */* ]]; then
  script_path=$(command -v "$script_path")
fi

section_dir=$(mktemp -d)
trap 'rm -rf "$section_dir"' EXIT

session_file="$section_dir/sessions"
repo_file="$section_dir/repos"
worktree_file="$section_dir/worktrees"
dir_file="$section_dir/dirs"

printf "%s\n" "$colored_sessions" | sed '/^$/d' > "$session_file"
printf "%s\n" "$colored_repos" | sed '/^$/d' > "$repo_file"
printf "%s\n" "$colored_worktrees" | sed '/^$/d' > "$worktree_file"
printf "%s\n" "$colored_dirs" | sed '/^$/d' > "$dir_file"

filter_cmd=$(printf "%q __filter {q} %q %q %q %q" \
  "$script_path" \
  "$session_file" \
  "$repo_file" \
  "$worktree_file" \
  "$dir_file")

# Filter each section independently so fuzzy sorting stays within section priority.
selected=$(
  fzf --ansi \
    --disabled \
    --prompt="$prompt" \
    --bind "start:reload:$filter_cmd" \
    --bind "change:reload:$filter_cmd"
)

[ -z "$selected" ] && exit 0


# Remove ANSI codes first
cleaned=$(echo "$selected" | strip_ansi)

# If user picked an existing session
if [[ "$cleaned" == session:* ]]; then
  session_name=${cleaned#session:}
else
  # Otherwise, treat it as a directory → create/find session
  selected_dir=${cleaned#repo:}
  selected_dir=${selected_dir#worktree:}
  selected_dir=${selected_dir#dir:}
  session_name=$(basename "$selected_dir" | tr -d '\n' | tr -c '[:alnum:]' '_')

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
