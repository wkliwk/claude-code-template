#!/bin/bash
# Ollama fallback for low-priority tasks when Claude quota >= 90%.
#
# Usage:
#   echo "your prompt here" | bash ollama-fallback.sh
#   bash ollama-fallback.sh "your prompt here"
#   bash ollama-fallback.sh --force "prompt"   # skip quota check, always use Ollama
#
# Exit codes:
#   0 - ran successfully (via Ollama or Claude quota is fine)
#   1 - error
#   2 - quota is fine, caller should use Claude instead

CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"
OVERRIDE_FILE="$HOME/.claude/usage-monitor/model-override.json"
LOG_FILE="$HOME/.claude/usage-monitor/ollama.log"
ENV_FILE="$HOME/.claude/channels/telegram/.env"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"
THRESHOLD=90
FORCE=0

# Resolve model: env var > override file > default
if [ -n "$OLLAMA_MODEL" ]; then
  MODEL="$OLLAMA_MODEL"
elif [ -f "$OVERRIDE_FILE" ]; then
  OVERRIDE_MODEL=$(python3 -c "import json; d=json.load(open('$OVERRIDE_FILE')); print(d.get('model',''))" 2>/dev/null)
  if [[ "$OVERRIDE_MODEL" == claude-* ]]; then
    # Claude model manually selected — skip Ollama entirely, exit 2
    echo "Manual override: $OVERRIDE_MODEL — use Claude." >&2
    exit 2
  fi
  MODEL="${OVERRIDE_MODEL:-qwen2.5-coder:7b}"
else
  MODEL="qwen2.5-coder:7b"
fi

# Parse args
if [ "$1" = "--force" ]; then
  FORCE=1
  shift
fi

PROMPT="$1"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT=$(cat)
fi

if [ -z "$PROMPT" ]; then
  echo "Usage: echo 'prompt' | ollama-fallback.sh  OR  ollama-fallback.sh 'prompt'" >&2
  exit 1
fi

# Check quota unless forced
if [ "$FORCE" -eq 0 ]; then
  if [ ! -f "$CACHE_FILE" ]; then
    echo "No usage cache found — cannot check quota. Use --force to bypass." >&2
    exit 2
  fi

  FIVE_HOUR_PCT=$(python3 -c "
import json
with open('$CACHE_FILE') as f:
    d = json.load(f)
pct = d.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
print(round(pct) if pct is not None else -1)
" 2>/dev/null)

  if [ "$FIVE_HOUR_PCT" -lt "$THRESHOLD" ] 2>/dev/null; then
    echo "Quota OK (5hr: ${FIVE_HOUR_PCT}%) — use Claude instead." >&2
    exit 2
  fi

  # Quota is at/above threshold — notify via Telegram once
  NOTIFIED_FILE="$HOME/.claude/usage-monitor/.ollama-notified"
  if [ ! -f "$NOTIFIED_FILE" ]; then
    if [ -f "$ENV_FILE" ]; then
      source "$ENV_FILE"
      MSG="⚠️ Switched to local model (Ollama) — Claude 5hr quota at ${FIVE_HOUR_PCT}%25. Low-priority tasks running on qwen2.5-coder:7b."
      curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$MSG" \
        -d "parse_mode=Markdown" > /dev/null
    fi
    touch "$NOTIFIED_FILE"
  fi
fi

# Ensure Ollama is running
if ! ollama list &>/dev/null; then
  echo "Starting Ollama..." >&2
  ollama serve &>/tmp/ollama-serve.log &
  sleep 3
fi

# Run prompt through Ollama and log output
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
{
  echo "=== $TIMESTAMP ==="
  echo "PROMPT: $PROMPT"
  echo "---"
} >> "$LOG_FILE"

OUTPUT=$(echo "$PROMPT" | ollama run "$MODEL" 2>/dev/null)
# Strip ANSI escape codes before logging
echo "$OUTPUT" | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\x1b\[[0-9]*[JKmsu]//g' >> "$LOG_FILE"
echo "$OUTPUT"

# Clear notified flag when quota drops (handled by alert.sh state reset)
# Optionally re-check after run
CURRENT_PCT=$(python3 -c "
import json
try:
    with open('$CACHE_FILE') as f:
        d = json.load(f)
    pct = d.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
    print(round(pct) if pct is not None else -1)
except: print(-1)
" 2>/dev/null)

if [ "$CURRENT_PCT" -lt 60 ] 2>/dev/null && [ -f "$HOME/.claude/usage-monitor/.ollama-notified" ]; then
  rm -f "$HOME/.claude/usage-monitor/.ollama-notified"
fi
