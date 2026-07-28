#!/usr/bin/env bash

provider="${1:-}"
kind="${2:-unknown}"

if [ "$provider" != "codex" ] && [ "$provider" != "claude" ]; then
  kind="${1:-unknown}"
  case "$0" in
    */.codex/codex-notify.sh) provider="codex" ;;
    */.claude/claude-notify.sh) provider="claude" ;;
    *)
      printf "Usage: %s <codex|claude> <task-complete|approval-required|task-failed>\n" "$0" >&2
      exit 2
      ;;
  esac
fi

if [ -t 0 ]; then
  payload=""
else
  payload="$(cat)"
fi

TERMINAL_NOTIFIER="/opt/homebrew/bin/terminal-notifier"
if [ ! -x "$TERMINAL_NOTIFIER" ]; then
  TERMINAL_NOTIFIER="/usr/local/bin/terminal-notifier"
fi

ITERM_BUNDLE_ID="com.googlecode.iterm2"
NOTIFICATION_SOUND="Glass"
NOTIFICATION_SOUND_FILE="/System/Library/Sounds/${NOTIFICATION_SOUND}.aiff"

case "$provider" in
  codex)
    PROVIDER_NAME="Codex"
    ICON="$HOME/.codex/assets/codex.png"
    NOTIFICATION_SOUND_VOLUME="${AGENT_NOTIFICATION_SOUND_VOLUME:-${CODEX_NOTIFICATION_SOUND_VOLUME:-${CODEX_APPROVAL_SOUND_VOLUME:-0.05}}}"
    ;;
  claude)
    PROVIDER_NAME="Claude"
    ICON="$HOME/.claude/assets/claude.png"
    NOTIFICATION_SOUND_VOLUME="${AGENT_NOTIFICATION_SOUND_VOLUME:-${CLAUDE_NOTIFICATION_SOUND_VOLUME:-0.05}}"
    ;;
esac

json_field() {
  local field="$1"

  AGENT_NOTIFY_PAYLOAD="$payload" /usr/bin/python3 - "$field" <<'PY'
import json
import os
import sys

field = sys.argv[1]
raw = os.environ.get("AGENT_NOTIFY_PAYLOAD", "")

try:
    data = json.loads(raw or "{}")
except Exception:
    data = {}

value = data.get(field, "")
if isinstance(value, str):
    print(value.strip())
PY
}

latest_codex_prompt() {
  /usr/bin/python3 <<'PY'
import json
from pathlib import Path

history = Path.home() / ".codex" / "history.jsonl"
if not history.exists():
    raise SystemExit

try:
    lines = history.read_text(errors="ignore").splitlines()
except Exception:
    raise SystemExit

for line in reversed(lines[-250:]):
    try:
        data = json.loads(line)
    except Exception:
        continue
    text = data.get("text")
    if isinstance(text, str) and text.strip():
        print(" ".join(text.split()))
        break
PY
}

codex_approval_message() {
  AGENT_NOTIFY_PAYLOAD="$payload" /usr/bin/python3 <<'PY'
import json
import os

raw = os.environ.get("AGENT_NOTIFY_PAYLOAD", "")

try:
    data = json.loads(raw or "{}")
except Exception:
    print("Codex needs your approval.")
    raise SystemExit

tool = data.get("tool_name") or data.get("tool") or "Codex"
tool_input = data.get("tool_input") or data.get("input") or {}

text = ""
if isinstance(tool_input, dict):
    text = (
        tool_input.get("command")
        or tool_input.get("cmd")
        or tool_input.get("description")
        or ""
    )

if text:
    print(tool + ": " + text)
else:
    print("Codex needs your approval.")
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
      AGENT_NOTIFY_TITLE="$title" \
      AGENT_NOTIFY_SUBTITLE="$subtitle" \
      AGENT_NOTIFY_MESSAGE="$message" \
      /usr/bin/osascript <<'APPLESCRIPT'
set notificationTitle to system attribute "AGENT_NOTIFY_TITLE"
set notificationSubtitle to system attribute "AGENT_NOTIFY_SUBTITLE"
set notificationMessage to system attribute "AGENT_NOTIFY_MESSAGE"
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
group_prefix="$(printf "%s" "$provider" | tr '[:upper:]' '[:lower:]')"

case "$kind" in
  task-complete)
    summary="$(json_field last_assistant_message)"
    if [ -z "$summary" ] && [ "$provider" = "codex" ]; then
      summary="$(json_field prompt)"
      if [ -z "$summary" ]; then
        summary="$(latest_codex_prompt)"
      fi
    fi
    summary="$(clean_text "$summary" 180)"
    message="$(notification_message "$summary" "$cwd")"

    notify \
      "$PROVIDER_NAME completed" \
      "$project" \
      "$message" \
      "$group_prefix-task-complete"
    play_notification_sound
    ;;

  approval-required)
    if [ "$provider" = "codex" ]; then
      action="$(codex_approval_message)"
    else
      action="$(json_field message)"
      if [ -z "$action" ]; then
        action="Claude needs your approval."
      fi
    fi
    action="$(clean_text "$action" 180)"
    message="$(notification_message "$action" "$cwd")"

    notify \
      "$PROVIDER_NAME needs approval" \
      "$project" \
      "$message" \
      "$group_prefix-approval-required"
    play_notification_sound
    ;;

  task-failed)
    error="$(clean_text "$(json_field error)" 60)"
    details="$(json_field last_assistant_message)"
    if [ -z "$details" ]; then
      details="$(json_field error_details)"
    fi
    if [ -z "$details" ]; then
      details="$PROVIDER_NAME could not complete the response."
    fi
    details="$(clean_text "$details" 180)"
    if [ -n "$error" ]; then
      details="$error • $details"
    fi
    message="$(notification_message "$details" "$cwd")"

    notify \
      "$PROVIDER_NAME failed" \
      "$project" \
      "$message" \
      "$group_prefix-task-failed"
    play_notification_sound
    ;;

  *)
    notify \
      "$PROVIDER_NAME" \
      "$project" \
      "$(notification_message "$PROVIDER_NAME needs your attention." "$cwd")" \
      "$group_prefix-generic"
    play_notification_sound
    ;;
esac

exit 0
