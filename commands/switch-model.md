# /switch-model — Switch active model

Switch the active model for this session and the agent loop.

Usage: `/switch-model <model>` where model is one of:

**Claude (this window):**
- `opus` — Claude Opus 4.6 (most capable)
- `sonnet` — Claude Sonnet 4.6 (default)
- `haiku` — Claude Haiku 4.5 (cheap, full tool support)

**Alt backends via proxy (open a new terminal after switching):**
- `gemini` — Gemini 2.5 Pro (free tier, recommended alt)
- `groq` — Groq llama-3.3-70b (free tier, fast)
- `ollama` — Local Ollama llama3.1:8b (zero quota, unreliable tools)

**Agent loop only:**
- `ollama-loop` — Force agent loop tasks to Ollama
- `auto` — Quota-based routing (default)

**Arguments:** $ARGUMENTS

Run the following based on the argument:

```bash
ARG=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | xargs)

OVERRIDE_FILE="$HOME/.claude/usage-monitor/model-override.json"

case "$ARG" in
  opus)
    MODEL="claude-opus-4-6"
    claude config set model "$MODEL"
    python3 -c "import json; json.dump({'model': '$MODEL', 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, open('$OVERRIDE_FILE', 'w'))"
    # Lock auto-route for 4 hours
    AR_CONFIG="$HOME/.claude/usage-monitor/auto-route-config.json"
    LOCK_UNTIL=$(python3 -c "from datetime import datetime, timedelta, timezone; print((datetime.now(timezone.utc) + timedelta(hours=4)).strftime('%Y-%m-%dT%H:%M:%SZ'))" 2>/dev/null)
    [ -f "$AR_CONFIG" ] && python3 -c "import json,os; c=json.load(open('$AR_CONFIG')); c['lock_until']='$LOCK_UNTIL'; tmp='$AR_CONFIG'+'.tmp'; json.dump(c,open(tmp,'w'),indent=2); os.replace(tmp,'$AR_CONFIG')" 2>/dev/null
    echo "✓ Switched to Claude Opus 4.6 (auto-route paused 4h)"
    ;;
  sonnet)
    MODEL="claude-sonnet-4-6"
    claude config set model "$MODEL"
    python3 -c "import json; json.dump({'model': '$MODEL', 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, open('$OVERRIDE_FILE', 'w'))"
    AR_CONFIG="$HOME/.claude/usage-monitor/auto-route-config.json"
    LOCK_UNTIL=$(python3 -c "from datetime import datetime, timedelta, timezone; print((datetime.now(timezone.utc) + timedelta(hours=4)).strftime('%Y-%m-%dT%H:%M:%SZ'))" 2>/dev/null)
    [ -f "$AR_CONFIG" ] && python3 -c "import json,os; c=json.load(open('$AR_CONFIG')); c['lock_until']='$LOCK_UNTIL'; tmp='$AR_CONFIG'+'.tmp'; json.dump(c,open(tmp,'w'),indent=2); os.replace(tmp,'$AR_CONFIG')" 2>/dev/null
    echo "✓ Switched to Claude Sonnet 4.6 (auto-route paused 4h)"
    ;;
  haiku)
    MODEL="claude-haiku-4-5-20251001"
    claude config set model "$MODEL"
    python3 -c "import json; json.dump({'model': '$MODEL', 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, open('$OVERRIDE_FILE', 'w'))"
    AR_CONFIG="$HOME/.claude/usage-monitor/auto-route-config.json"
    LOCK_UNTIL=$(python3 -c "from datetime import datetime, timedelta, timezone; print((datetime.now(timezone.utc) + timedelta(hours=4)).strftime('%Y-%m-%dT%H:%M:%SZ'))" 2>/dev/null)
    [ -f "$AR_CONFIG" ] && python3 -c "import json,os; c=json.load(open('$AR_CONFIG')); c['lock_until']='$LOCK_UNTIL'; tmp='$AR_CONFIG'+'.tmp'; json.dump(c,open(tmp,'w'),indent=2); os.replace(tmp,'$AR_CONFIG')" 2>/dev/null
    echo "✓ Switched to Claude Haiku 4.5 (auto-route paused 4h)"
    ;;
  gemini)
    bash "$HOME/.claude/usage-monitor/switch-provider.sh" gemini
    echo ""
    echo "Now open a new terminal tab and run:"
    echo "  ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY=ollama-local claude"
    ;;
  groq)
    bash "$HOME/.claude/usage-monitor/switch-provider.sh" groq
    echo ""
    echo "Now open a new terminal tab and run:"
    echo "  ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY=ollama-local claude"
    ;;
  ollama)
    bash "$HOME/.claude/usage-monitor/switch-provider.sh" ollama
    echo ""
    echo "Now open a new terminal tab and run:"
    echo "  ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY=ollama-local claude"
    ;;
  ollama-loop)
    python3 -c "import json; json.dump({'model': 'qwen2.5-coder:7b', 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, open('$OVERRIDE_FILE', 'w'))"
    echo "✓ Agent loop will use Ollama (qwen2.5-coder:7b)"
    ;;
  auto)
    rm -f "$OVERRIDE_FILE"
    # Clear any auto-route lock
    AR_CONFIG="$HOME/.claude/usage-monitor/auto-route-config.json"
    if [ -f "$AR_CONFIG" ]; then
      python3 -c "
import json, os
c = json.load(open('$AR_CONFIG'))
c['enabled'] = True
c['lock_until'] = None
tmp = '$AR_CONFIG' + '.tmp'
json.dump(c, open(tmp, 'w'), indent=2)
os.replace(tmp, '$AR_CONFIG')
" 2>/dev/null
    fi
    echo "✓ Switched to auto — auto-routing enabled"
    ;;
  "")
    CURRENT=$(python3 -c "import json; d=json.load(open('$OVERRIDE_FILE')); print(d.get('model',''))" 2>/dev/null || echo "auto")
    PROXY_PROVIDER=$(grep "^PREFERRED_PROVIDER=" "$HOME/.claude/ollama-proxy/.env" 2>/dev/null | cut -d= -f2 | tr -d '"')
    echo "Window model: $CURRENT"
    echo "Proxy provider: ${PROXY_PROVIDER:-not set}"
    echo ""
    echo "Usage: /switch-model <opus|sonnet|haiku|gemini|groq|ollama|ollama-loop|auto>"
    ;;
  *)
    echo "Unknown model: $ARG"
    echo "Options: opus | sonnet | haiku | gemini | groq | ollama | ollama-loop | auto"
    ;;
esac
```

After running the bash above, confirm to the user which model is now active and what it means. For proxy-based backends (gemini/groq/ollama), remind them to open a new terminal tab with the `ANTHROPIC_BASE_URL` command shown.
