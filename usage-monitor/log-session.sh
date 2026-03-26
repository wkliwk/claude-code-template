#!/bin/bash
# Log session token usage to ~/Dev/token-baseline.csv
# Manual: log-session.sh '<skill>' '<repo>' '<duration_min>' '<total_tokens>' [input output]
# Auto:   log-session.sh auto  (reads from usage-cache.json, detects repo from $PWD)

CSV_PATH="$HOME/Dev/token-baseline.csv"
CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"
SESSION_START_FILE="$HOME/.claude/usage-monitor/session-start.json"

if [ "${1:-}" = "auto" ]; then
  DATE=$(date +%Y-%m-%d)

  # Detect repo from PWD (use last 2 path components if inside ~/Dev)
  REPO=$(basename "$PWD")
  if [ "$REPO" = "$(whoami)" ] || [ "$REPO" = "$HOME" ]; then
    REPO="unknown"
  fi

  # Read current usage from cache
  if [ ! -f "$CACHE_FILE" ]; then
    exit 0
  fi

  FIVE_PCT=$(python3 -c "
import json
with open('$CACHE_FILE') as f:
    d = json.load(f)
pct = d.get('rate_limits',{}).get('five_hour',{}).get('used_percentage', 0)
print(round(pct))
" 2>/dev/null)

  # Read session start snapshot to calculate delta
  DELTA_TOKENS=0
  DURATION=0
  if [ -f "$SESSION_START_FILE" ]; then
    DELTA_TOKENS=$(python3 -c "
import json, datetime
with open('$CACHE_FILE') as f:
    now = json.load(f)
with open('$SESSION_START_FILE') as f:
    start = json.load(f)

now_pct = now.get('rate_limits',{}).get('five_hour',{}).get('used_percentage', 0)
start_pct = start.get('rate_limits',{}).get('five_hour',{}).get('used_percentage', 0)
# Estimate tokens from % delta (rough: 5hr window ≈ 500k tokens for Max / 200k for Pro)
delta_pct = max(0, now_pct - start_pct)
# Use 88k as conservative estimate for 5hr window
estimated = int(delta_pct / 100 * 88000)
print(estimated)
" 2>/dev/null || echo 0)

    DURATION=$(python3 -c "
import json, datetime
with open('$SESSION_START_FILE') as f:
    start = json.load(f)
start_ts = start.get('session_start','')
if start_ts:
    start_dt = datetime.datetime.fromisoformat(start_ts.replace('Z',''))
    now_dt = datetime.datetime.utcnow()
    diff = int((now_dt - start_dt).total_seconds() / 60)
    print(diff)
else:
    print(0)
" 2>/dev/null || echo 0)
  fi

  TOTAL=$DELTA_TOKENS
  INPUT=$((TOTAL * 70 / 100))
  OUTPUT=$((TOTAL * 30 / 100))

  # Skip if zero tokens (session was too short / no real work)
  if [ "$TOTAL" -eq 0 ]; then
    exit 0
  fi

  SKILL="auto"
  LINE="$DATE,$SKILL,$REPO,$INPUT,$OUTPUT,$TOTAL,$DURATION,0"
  echo "$LINE" >> "$CSV_PATH"

  # Reset session start for next session
  rm -f "$SESSION_START_FILE"
  exit 0
fi

# Manual mode
DATE=$(date +%Y-%m-%d)
SKILL="${1:-manual}"
REPO="${2:-unknown}"
DURATION="${3:-0}"
TOTAL="${4:-0}"
INPUT="${5:-0}"
OUTPUT="${6:-0}"

if [ "$INPUT" -eq 0 ] && [ "$OUTPUT" -eq 0 ]; then
  INPUT=$((TOTAL * 70 / 100))
  OUTPUT=$((TOTAL * 30 / 100))
fi

LINE="$DATE,$SKILL,$REPO,$INPUT,$OUTPUT,$TOTAL,$DURATION,0"
echo "$LINE" >> "$CSV_PATH"
echo "✓ Logged: $SKILL on $REPO — $TOTAL tokens in ${DURATION}m"
