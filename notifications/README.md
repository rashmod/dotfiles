# Agent notifications

`agent-notify.sh` is the shared macOS notification implementation for Codex CLI
and Claude Code:

```text
agent-notify.sh <codex|claude> <task-complete|approval-required|task-failed>
```

Both CLIs send their hook payload as JSON on standard input. The script keeps
provider-specific payload parsing, titles, icons, and volume overrides separate,
then uses one delivery path for `terminal-notifier`, iTerm activation,
AppleScript fallback, and the Glass sound.

Legacy one-argument calls through `~/.codex/codex-notify.sh` or
`~/.claude/claude-notify.sh` remain supported so sessions that were already
running during migration continue to work.

Global volume can be set with `AGENT_NOTIFICATION_SOUND_VOLUME`. Existing
provider overrides remain supported through `CODEX_NOTIFICATION_SOUND_VOLUME`,
`CODEX_APPROVAL_SOUND_VOLUME`, and `CLAUDE_NOTIFICATION_SOUND_VOLUME`.
