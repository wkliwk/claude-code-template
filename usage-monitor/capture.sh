#!/bin/bash
# Captures Claude Code rate_limits from statusline stdin and saves to cache,
# then pipes stdin through to claude-hud as normal.

CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"
STDIN_CACHE="$HOME/.claude/usage-monitor/stdin-cache.json"

# Read all stdin
STDIN_DATA=$(cat)

# Extract and save rate_limits + timestamp
echo "$STDIN_DATA" | python3 -c "
import json, sys, datetime
try:
    data = json.load(sys.stdin)
    rate_limits = data.get('rate_limits')
    if rate_limits:
        output = {
            'rate_limits': rate_limits,
            'updated_at': datetime.datetime.utcnow().isoformat() + 'Z'
        }
        import os
        cache_path = os.path.expanduser('~/.claude/usage-monitor/usage-cache.json')
        with open(cache_path, 'w') as f:
            json.dump(output, f)
except Exception:
    pass
" 2>/dev/null

# Pipe stdin to the original claude-hud command
PLUGIN_DIR=$(ls -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | awk -F/ '{ print $(NF-1) "\t" $(0) }' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -1 | cut -f2-)
echo "$STDIN_DATA" | exec "bun" --env-file /dev/null "${PLUGIN_DIR}src/index.ts"
