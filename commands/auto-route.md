# /auto-route — Dynamic Model Routing Control

Control the auto-routing system that selects models based on task complexity.

**Arguments:** $ARGUMENTS

Run the following based on the argument:

```bash
ARG=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | xargs)

CONFIG_FILE="$HOME/.claude/usage-monitor/auto-route-config.json"
STATE_FILE="$HOME/.claude/usage-monitor/auto-route-state.json"
OVERRIDE_FILE="$HOME/.claude/usage-monitor/model-override.json"

case "$ARG" in
  on|enable)
    python3 -c "
import json, os
c = json.load(open('$CONFIG_FILE'))
c['enabled'] = True
c['lock_until'] = None
tmp = '$CONFIG_FILE' + '.tmp'
json.dump(c, open(tmp, 'w'), indent=2)
os.replace(tmp, '$CONFIG_FILE')
"
    echo "✓ Auto-routing enabled"
    echo "  Models will be selected automatically based on task complexity:"
    echo "  • Simple questions → Haiku (fast, cheap)"
    echo "  • Standard coding  → Sonnet (balanced)"
    echo "  • Complex tasks    → Opus (most capable)"
    ;;

  off|disable)
    python3 -c "
import json, os
c = json.load(open('$CONFIG_FILE'))
c['enabled'] = False
tmp = '$CONFIG_FILE' + '.tmp'
json.dump(c, open(tmp, 'w'), indent=2)
os.replace(tmp, '$CONFIG_FILE')
"
    echo "✓ Auto-routing disabled"
    ;;

  lock|lock\ *)
    LOCK_MODEL=$(echo "$ARG" | sed 's/^lock *//')
    if [ -z "$LOCK_MODEL" ]; then
      echo "Usage: /auto-route lock <opus|sonnet|haiku>"
      exit 0
    fi
    # Lock for 4 hours
    LOCK_UNTIL=$(python3 -c "from datetime import datetime, timedelta, timezone; print((datetime.now(timezone.utc) + timedelta(hours=4)).strftime('%Y-%m-%dT%H:%M:%SZ'))")
    case "$LOCK_MODEL" in
      opus)   MODEL_ID="claude-opus-4-6" ;;
      sonnet) MODEL_ID="claude-sonnet-4-6" ;;
      haiku)  MODEL_ID="claude-haiku-4-5-20251001" ;;
      *)      echo "Unknown model: $LOCK_MODEL"; exit 1 ;;
    esac
    python3 -c "
import json, os
c = json.load(open('$CONFIG_FILE'))
c['lock_until'] = '$LOCK_UNTIL'
tmp = '$CONFIG_FILE' + '.tmp'
json.dump(c, open(tmp, 'w'), indent=2)
os.replace(tmp, '$CONFIG_FILE')
"
    claude config set model "$MODEL_ID" 2>/dev/null
    python3 -c "
import json, os
d = {'model': '$MODEL_ID', 'tier': '$LOCK_MODEL', 'auto_routed': False, 'locked': True, 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}
tmp = '$OVERRIDE_FILE' + '.tmp'
json.dump(d, open(tmp, 'w'))
os.replace(tmp, '$OVERRIDE_FILE')
"
    echo "✓ Locked to $LOCK_MODEL for 4 hours (until $(date -v+4H +%l:%M%p | xargs))"
    echo "  Run /auto-route unlock to resume auto-routing"
    ;;

  unlock)
    python3 -c "
import json, os
c = json.load(open('$CONFIG_FILE'))
c['lock_until'] = None
tmp = '$CONFIG_FILE' + '.tmp'
json.dump(c, open(tmp, 'w'), indent=2)
os.replace(tmp, '$CONFIG_FILE')
"
    echo "✓ Lock cleared — auto-routing resumed"
    ;;

  status|"")
    echo ""
    echo "  ┌─────────────────────────────────────────┐"
    echo "  │          AUTO-ROUTE STATUS               │"
    echo "  └─────────────────────────────────────────┘"
    echo ""
    ENABLED=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('enabled', True))" 2>/dev/null)
    LOCK=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('lock_until', 'None'))" 2>/dev/null)
    DEFAULT=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('default_model', 'claude-sonnet-4-6'))" 2>/dev/null)

    if [ "$ENABLED" = "True" ]; then
      echo "  Enabled:  ✓ yes"
    else
      echo "  Enabled:  ✗ no"
    fi

    if [ "$LOCK" != "None" ] && [ "$LOCK" != "null" ]; then
      echo "  Locked:   until $LOCK"
    else
      echo "  Locked:   no"
    fi

    echo "  Default:  $DEFAULT"
    echo ""

    if [ -f "$STATE_FILE" ]; then
      LAST_TIER=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('tier', '?'))" 2>/dev/null)
      LAST_REASON=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('reason', '?'))" 2>/dev/null)
      LAST_AT=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('at', '?'))" 2>/dev/null)
      echo "  Last routing:"
      echo "    Tier:   $LAST_TIER"
      echo "    Reason: $LAST_REASON"
      echo "    At:     $LAST_AT"
    else
      echo "  Last routing: none yet"
    fi

    echo ""
    if [ -f "$OVERRIDE_FILE" ]; then
      CURRENT=$(python3 -c "import json; print(json.load(open('$OVERRIDE_FILE')).get('model', '?'))" 2>/dev/null)
      echo "  Active model: $CURRENT"
    fi
    echo ""
    echo "  Commands:"
    echo "    /auto-route on          Enable auto-routing"
    echo "    /auto-route off         Disable auto-routing"
    echo "    /auto-route lock opus   Lock to a model (4h)"
    echo "    /auto-route unlock      Resume auto-routing"
    ;;

  *)
    echo "Unknown argument: $ARG"
    echo "Usage: /auto-route <on|off|lock <model>|unlock|status>"
    ;;
esac
```

After running, confirm the result to the user.
