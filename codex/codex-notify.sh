#!/usr/bin/env bash

kind="${1:-unknown}"

# Do not block when script is run manually without stdin.
if [ -t 0 ]; then
  payload=""
else
  payload="$(cat)"
fi

TERMINAL_NOTIFIER="/opt/homebrew/bin/terminal-notifier"
if [ ! -x "$TERMINAL_NOTIFIER" ]; then
  TERMINAL_NOTIFIER="/usr/local/bin/terminal-notifier"
fi

ICON="$HOME/.codex/assets/codex.png"
ITERM_BUNDLE_ID="com.googlecode.iterm2"
NOTIFICATION_SOUND="Glass"
NOTIFICATION_SOUND_VOLUME="${CODEX_NOTIFICATION_SOUND_VOLUME:-${CODEX_APPROVAL_SOUND_VOLUME:-0.05}}"
NOTIFICATION_SOUND_FILE="/System/Library/Sounds/${NOTIFICATION_SOUND}.aiff"

json_field() {
  local field="$1"

  CODEX_NOTIFY_PAYLOAD="$payload" /usr/bin/python3 - "$field" <<'PY'
import json
import os
import sys

field = sys.argv[1]
raw = os.environ.get("CODEX_NOTIFY_PAYLOAD", "")

try:
    data = json.loads(raw or "{}")
except Exception:
    data = {}

def find_value(value, names):
    if isinstance(value, dict):
        for name in names:
            item = value.get(name)
            if isinstance(item, str) and item.strip():
                return item.strip()
        for item in value.values():
            found = find_value(item, names)
            if found:
                return found
    elif isinstance(value, list):
        for item in value:
            found = find_value(item, names)
            if found:
                return found
    return ""

fields = {
    "cwd": [
        "cwd",
        "working_dir",
        "workdir",
        "current_dir",
        "current_directory",
        "workspace",
        "workspace_root",
    ],
    "prompt": [
        "prompt",
        "user_prompt",
        "userPrompt",
        "instruction",
        "instructions",
        "message",
        "text",
    ],
}

print(find_value(data, fields.get(field, [])))
PY
}

latest_prompt() {
  /usr/bin/python3 <<'PY'
import json
import os
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

notification_cwd() {
  local cwd

  cwd="$(json_field cwd)"
  if [ -n "$cwd" ]; then
    printf "%s" "$cwd"
  else
    printf "%s" "$PWD"
  fi
}

notification_prompt() {
  local prompt

  prompt="$(json_field prompt)"
  if [ -z "$prompt" ]; then
    prompt="$(latest_prompt)"
  fi

  printf "%s" "$prompt" | tr '\n' ' ' | cut -c 1-120
}

notification_message() {
  local prompt="$1"
  local cwd="$2"
  local path_label

  path_label="$(short_path "$cwd")"

  if [ -n "$prompt" ]; then
    printf "%s\n%s" "$prompt" "$path_label"
  else
    printf "%s" "$path_label"
  fi
}

notification_context() {
  local cwd prompt

  cwd="$(json_field cwd)"
  prompt="$(json_field prompt)"

  if [ -z "$prompt" ]; then
    prompt="$(latest_prompt)"
  fi

  path_label="$(short_path "$cwd")"
  prompt_label="$(printf '%s' "$prompt" | tr '\n' ' ' | cut -c 1-90)"

  if [ -n "$prompt_label" ]; then
    printf "%s • %s" "$path_label" "$prompt_label"
  else
    printf "%s" "$path_label"
  fi
}

approval_message() {
  CODEX_NOTIFY_PAYLOAD="$payload" /usr/bin/python3 <<'PY'
import json
import os

raw = os.environ.get("CODEX_NOTIFY_PAYLOAD", "")

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
    print((tool + ": " + text)[:180])
else:
    print("Codex needs your approval.")
PY
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
    /usr/bin/osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\"" >/dev/null 2>&1 &
  fi
}

play_notification_sound() {
  if [ -f "$NOTIFICATION_SOUND_FILE" ]; then
    /usr/bin/afplay -v "$NOTIFICATION_SOUND_VOLUME" "$NOTIFICATION_SOUND_FILE" >/dev/null 2>&1 &
  fi
}

case "$kind" in
  task-complete)
    cwd="$(notification_cwd)"
    project="$(project_label "$cwd")"
    prompt="$(notification_prompt)"
    message="$(notification_message "$prompt" "$cwd")"

    notify \
      "Codex completed" \
      "$project" \
      "$message" \
      "codex-task-complete"
    play_notification_sound
    ;;

  approval-required)
    cwd="$(notification_cwd)"
    project="$(project_label "$cwd")"
    prompt="$(notification_prompt)"
    action="$(approval_message)"
    message="$(notification_message "$action${prompt:+ • $prompt}" "$cwd")"

    notify \
      "Codex needs approval" \
      "$project" \
      "$message" \
      "codex-approval-required"
    play_notification_sound
    ;;

  *)
    notify \
      "Codex" \
      "Notification" \
      "Codex needs your attention." \
      "codex-generic"
    play_notification_sound
    ;;
esac

exit 0
