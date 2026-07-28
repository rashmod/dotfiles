#!/usr/bin/env bash

kind="${1:-unknown}"

if [ -t 0 ]; then
  payload=""
else
  payload="$(cat)"
fi

TERMINAL_NOTIFIER="/opt/homebrew/bin/terminal-notifier"
if [ ! -x "$TERMINAL_NOTIFIER" ]; then
  TERMINAL_NOTIFIER="/usr/local/bin/terminal-notifier"
fi

ICON="$HOME/.claude/assets/claude.png"
ITERM_BUNDLE_ID="com.googlecode.iterm2"
NOTIFICATION_SOUND="Glass"
NOTIFICATION_SOUND_VOLUME="${CLAUDE_NOTIFICATION_SOUND_VOLUME:-0.05}"
NOTIFICATION_SOUND_FILE="/System/Library/Sounds/${NOTIFICATION_SOUND}.aiff"

json_field() {
  local field="$1"

  CLAUDE_NOTIFY_PAYLOAD="$payload" /usr/bin/python3 - "$field" <<'PY'
import json
import os
import sys

field = sys.argv[1]
raw = os.environ.get("CLAUDE_NOTIFY_PAYLOAD", "")

try:
    data = json.loads(raw or "{}")
except Exception:
    data = {}

value = data.get(field, "")
if isinstance(value, str):
    print(value.strip())
PY
}

clean_text() {
  local text="$1"
  local limit="${2:-180}"

  printf "%s" "$text" | tr '\n' ' ' | tr -s ' ' | cut -c "1-$limit"
}

short_path() {
  local path="$1"

  if [ -z "$path" ]; then
    path="$PWD"
  fi

  case "$path" in
    "$HOME") printf "~" ;;
    "$HOME"/*) printf "~/%s" "${path#"$HOME"/}" ;;
    *) printf "%s" "$path" ;;
  esac
}

project_label() {
  local path="$1"
  local base parent

  if [ -z "$path" ]; then
    path="$PWD"
  fi

  base="$(basename "$path")"
  parent="$(basename "$(dirname "$path")")"

  if [ "$parent" = ".worktrees" ]; then
    printf "%s" "$base"
  elif [ "$base" = ".worktrees" ]; then
    printf "%s/.worktrees" "$(basename "$(dirname "$path")")"
  else
    printf "%s" "$base"
  fi
}

notification_message() {
  local text="$1"
  local cwd="$2"
  local path_label

  path_label="$(short_path "$cwd")"

  if [ -n "$text" ]; then
    printf "%s\n%s" "$text" "$path_label"
  else
    printf "%s" "$path_label"
  fi
}

notify() {
  local title="$1"
  local subtitle="$2"
  local message="$3"
  local group="$4"

  if [ -x "$TERMINAL_NOTIFIER" ]; then
    args=(
      -title "$title"
      -subtitle "$subtitle"
      -message "$message"
      -activate "$ITERM_BUNDLE_ID"
      -group "$group-$(date +%s)"
    )

    if [ -f "$ICON" ]; then
      args+=(-appIcon "$ICON" -contentImage "$ICON")
    fi

    "$TERMINAL_NOTIFIER" "${args[@]}" >/dev/null 2>&1 &
  else
    (
      CLAUDE_NOTIFY_TITLE="$title" \
      CLAUDE_NOTIFY_SUBTITLE="$subtitle" \
      CLAUDE_NOTIFY_MESSAGE="$message" \
      /usr/bin/osascript <<'APPLESCRIPT'
set notificationTitle to system attribute "CLAUDE_NOTIFY_TITLE"
set notificationSubtitle to system attribute "CLAUDE_NOTIFY_SUBTITLE"
set notificationMessage to system attribute "CLAUDE_NOTIFY_MESSAGE"
display notification notificationMessage with title notificationTitle subtitle notificationSubtitle
APPLESCRIPT
    ) >/dev/null 2>&1 &
  fi
}

play_notification_sound() {
  if [ -f "$NOTIFICATION_SOUND_FILE" ]; then
    /usr/bin/afplay -v "$NOTIFICATION_SOUND_VOLUME" "$NOTIFICATION_SOUND_FILE" >/dev/null 2>&1 &
  fi
}

cwd="$(json_field cwd)"
if [ -z "$cwd" ]; then
  cwd="$PWD"
fi
project="$(project_label "$cwd")"

case "$kind" in
  task-complete)
    summary="$(clean_text "$(json_field last_assistant_message)" 180)"
    message="$(notification_message "$summary" "$cwd")"

    notify \
      "Claude completed" \
      "$project" \
      "$message" \
      "claude-task-complete"
    play_notification_sound
    ;;

  approval-required)
    action="$(clean_text "$(json_field message)" 180)"
    if [ -z "$action" ]; then
      action="Claude needs your approval."
    fi
    message="$(notification_message "$action" "$cwd")"

    notify \
      "Claude needs approval" \
      "$project" \
      "$message" \
      "claude-approval-required"
    play_notification_sound
    ;;

  task-failed)
    error="$(clean_text "$(json_field error)" 60)"
    details="$(clean_text "$(json_field last_assistant_message)" 180)"
    if [ -z "$details" ]; then
      details="$(clean_text "$(json_field error_details)" 180)"
    fi
    if [ -z "$details" ]; then
      details="Claude could not complete the response."
    fi
    if [ -n "$error" ]; then
      details="$error • $details"
    fi
    message="$(notification_message "$details" "$cwd")"

    notify \
      "Claude failed" \
      "$project" \
      "$message" \
      "claude-task-failed"
    play_notification_sound
    ;;

  *)
    notify \
      "Claude Code" \
      "$project" \
      "$(notification_message "Claude needs your attention." "$cwd")" \
      "claude-generic"
    play_notification_sound
    ;;
esac

exit 0
