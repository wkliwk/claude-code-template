#!/bin/bash
# Launch Claude Code in a persistent tmux session.
# Auto-selects claude-free if quota >= 90%, otherwise uses real Claude.
#
# Usage:
#   bash ~/.claude/usage-monitor/claude-start.sh          # auto-detect
#   bash ~/.claude/usage-monitor/claude-start.sh free     # force proxy
#   bash ~/.claude/usage-monitor/claude-start.sh claude   # force real Claude

SESSION="claude-work"
CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"
SESSION_ID_FILE="$HOME/.claude/usage-monitor/last-session-id.txt"
MODE="${1:-auto}"

# Kill existing session if running
tmux has-session -t "$SESSION" 2>/dev/null && tmux kill-session -t "$SESSION"

# Determine mode
if [ "$MODE" = "free" ]; then
  USE_FREE=1
elif [ "$MODE" = "claude" ]; then
  USE_FREE=0
else
  # Auto: check quota
  USE_FREE=0
  if [ -f "$CACHE_FILE" ]; then
    PCT=$(python3 -c "
import json
try:
  d = json.load(open('$CACHE_FILE'))
  rl = d.get('rate_limits', {})
  fh = rl.get('five_hour', {}) or {}
  used = fh.get('used', 0)
  limit = fh.get('limit', 1)
  print(int(used / limit * 100) if limit else 0)
except:
  print(0)
" 2>/dev/null)
    [ "${PCT:-0}" -ge 90 ] && USE_FREE=1
  fi
fi

CLAUDE_FLAGS="--channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions"

# Find most recent Claude session ID from project files
RESUME_FLAG=""
LAST_SESSION=$(python3 -c "
import os, glob
files = glob.glob(os.path.expanduser('~/.claude/projects/**/*.jsonl'), recursive=True)
if files:
    latest = max(files, key=os.path.getmtime)
    print(os.path.splitext(os.path.basename(latest))[0])
" 2>/dev/null)
[ -n "$LAST_SESSION" ] && RESUME_FLAG="--resume $LAST_SESSION"

# Start tmux session
if [ "$USE_FREE" = "1" ]; then
  echo "Starting claude-free session (proxy → qwen3-coder-next)..."
  [ -n "$RESUME_FLAG" ] && echo "  Resuming session: $LAST_SESSION"
  tmux new-session -d -s "$SESSION" -x 220 -y 50 \
    "export ANTHROPIC_BASE_URL=http://localhost:8082; export ANTHROPIC_API_KEY=ollama-local; claude $CLAUDE_FLAGS $RESUME_FLAG; exec zsh"
  tmux rename-window -t "$SESSION:0" "claude-free"
else
  echo "Starting Claude session (Anthropic)..."
  [ -n "$RESUME_FLAG" ] && echo "  Resuming session: $LAST_SESSION"
  tmux new-session -d -s "$SESSION" -x 220 -y 50 \
    "claude $CLAUDE_FLAGS $RESUME_FLAG; exec zsh"
  tmux rename-window -t "$SESSION:0" "claude"
fi

echo "✓ Session '$SESSION' started (mode: $([ "$USE_FREE" = "1" ] && echo 'free' || echo 'claude'))"
echo "  Attach: tmux attach -t $SESSION"
