#!/usr/bin/env bash

strip_ansi() {
    sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

filter_sections() {
  local query="${1:-}"
  local section_file plain_matches plain_match colored_line

  shift

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
}

if [[ "${1:-}" == "__filter" ]]; then
  query="${2:-}"
  shift 2

  filter_sections "$query" "$@"
  exit 0
fi

if [[ "${1:-}" == "__info" ]]; then
  info="${FZF_INFO:-}"
  hint="${2:-}"
  columns="${FZF_COLUMNS:-80}"

  if ! [[ "$columns" =~ ^[0-9]+$ ]]; then
    columns=80
  fi

  # fzf reserves a small amount of space around the info row; keep the hint
  # clear of the right edge so it does not get ellipsized.
  columns=$((columns - 8))
  [ "$columns" -lt 1 ] && columns=1

  gap=$((columns - ${#info} - ${#hint}))
  [ "$gap" -lt 1 ] && gap=1

  printf "%s%*s%s" "$info" "$gap" "" "$hint"
  exit 0
fi

force_cache_refresh=0
refresh_query=""
refresh_section_files=()

if [[ "${1:-}" == "__refresh" ]]; then
  refresh_query="${2:-}"
  scan_mode="${3:-personal}"
  refresh_section_files=("${@:4}")
  force_cache_refresh=1
else
  scan_mode="${1:-personal}"
fi

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

default_session_name() {
  basename "$1" | tr -d '\n' | tr -c '[:alnum:]' '_'
}

confirm_session_name() {
  local selected_dir="$1"
  local default_name="$2"
  local session_name

  if [ -t 0 ] && [ -w /dev/tty ] && [ -r /dev/tty ]; then
    clear > /dev/tty
    printf "Selected:\n" > /dev/tty
    printf "  %s\n\n" "$selected_dir" > /dev/tty
    printf "Session name:\n" > /dev/tty

    read -r -e -i "$default_name" -p "> " session_name < /dev/tty
  else
    session_name="$default_name"
  fi

  [ -n "$session_name" ] || return 1
  printf "%s\n" "$session_name" | tr -d '\n' | tr -c '[:alnum:]' '_'
}

cache_base="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-sessionizer"
cache_ttl_minutes="${TMUX_SESSIONIZER_CACHE_TTL_MINUTES:-10}"

cache_file_for_mode() {
  printf "%s/%s.paths" "$cache_base" "$scan_mode"
}

cache_is_fresh() {
  local cache_file="$1"

  [ -f "$cache_file" ] || return 1
  find "$cache_file" -mmin "-$cache_ttl_minutes" -print -quit | grep -q . || return 1

  ! fd --glob ".worktrees" "$search_root" \
    --type d \
    --hidden \
    --no-ignore \
    --max-depth "$((max_depth - 1))" \
    --changed-after "@$(stat -f %m "$cache_file")" \
    --quiet
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
  cache_file=$(cache_file_for_mode)

  if [ "$force_cache_refresh" -eq 0 ] && cache_is_fresh "$cache_file"; then
    repo_dirs=$(awk -F '\t' '$1 == "repo" { print $2 }' "$cache_file")
    worktree_dirs=$(awk -F '\t' '$1 == "worktree" { print $2 }' "$cache_file")
    dirs=$(awk -F '\t' '$1 == "dir" { print $2 }' "$cache_file")
  else
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

    mkdir -p "$cache_base"
    {
      printf "%s\n" "$repo_dirs" | sed '/^$/d' | sort -u | sed 's/^/repo\t/'
      printf "%s\n" "$worktree_dirs" | sed '/^$/d' | sort -u | sed 's/^/worktree\t/'
      printf "%s\n" "$dirs" | sed '/^$/d' | sort -u | sed 's/^/dir\t/'
    } > "$cache_file"
  fi

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

if [ "$force_cache_refresh" -eq 1 ]; then
  if [ "${#refresh_section_files[@]}" -ne 4 ]; then
    printf 'Refresh requires session, repo, worktree, and dir section files.\n' >&2
    exit 1
  fi

  session_file="${refresh_section_files[0]}"
  repo_file="${refresh_section_files[1]}"
  worktree_file="${refresh_section_files[2]}"
  dir_file="${refresh_section_files[3]}"

  printf "%s\n" "$colored_sessions" | sed '/^$/d' > "$session_file"
  printf "%s\n" "$colored_repos" | sed '/^$/d' > "$repo_file"
  printf "%s\n" "$colored_worktrees" | sed '/^$/d' > "$worktree_file"
  printf "%s\n" "$colored_dirs" | sed '/^$/d' > "$dir_file"

  filter_sections "$refresh_query" "$session_file" "$repo_file" "$worktree_file" "$dir_file"
  exit 0
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

refresh_filter_cmd=$(printf "%q __refresh {q} %q %q %q %q %q" \
  "$script_path" \
  "$scan_mode" \
  "$session_file" \
  "$repo_file" \
  "$worktree_file" \
  "$dir_file")

refresh_hint="ctrl-r: refresh cache"
refresh_info_cmd=$(printf "%q __info %q" "$script_path" "$refresh_hint")

# Filter each section independently so fuzzy sorting stays within section priority.
selected=$(
  fzf --ansi \
    --disabled \
    --prompt="$prompt" \
    --no-separator \
    --info=default \
    --info-command="$refresh_info_cmd" \
    --bind "start:reload:$filter_cmd" \
    --bind "change:reload:$filter_cmd" \
    --bind "ctrl-r:reload:$refresh_filter_cmd"
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
  default_name=$(default_session_name "$selected_dir")
  session_name=$(confirm_session_name "$selected_dir" "$default_name") || exit 0

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
