#!/bin/bash
# Called via PreToolUse hook — captures usage snapshot at session start
# Only writes if session-start.json doesn't exist yet (first tool call of session)
SESSION_START_FILE="$HOME/.claude/usage-monitor/session-start.json"
CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"

if [ ! -f "$SESSION_START_FILE" ] && [ -f "$CACHE_FILE" ]; then
  TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  python3 -c "
import json
with open('$CACHE_FILE') as f:
    d = json.load(f)
d['session_start'] = '$TS'
with open('$SESSION_START_FILE', 'w') as f:
    json.dump(d, f)
" 2>/dev/null || true
fi
