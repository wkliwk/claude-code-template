# Token Quota Monitoring & Fallback

Automatic mechanism to monitor Claude token usage, alert via Telegram, and switch to a free proxy before hitting the hard quota limit.

## Overview

```
Claude response ends
        ↓
  Stop hook fires
        ↓
   alert.sh runs
        ↓
  reads usage-cache.json
        ↓
  ┌─────────────────────────────────────┐
  │ < 70%   → no action                 │
  │ ≥ 70%   → 🟡 Telegram warning       │
  │ ≥ 90%   → 🔴 Telegram critical      │
  │ ≥ 95%   → 🚨 Telegram + auto-switch │
  └─────────────────────────────────────┘
```

## Files

| File | Purpose |
|------|---------|
| `~/.claude/usage-monitor/capture.sh` | Reads `rate_limits` from statusline stdin, saves to `usage-cache.json` |
| `~/.claude/usage-monitor/alert.sh` | Checks thresholds, sends Telegram alerts, triggers auto-switch at 95% |
| `~/.claude/usage-monitor/claude-start.sh` | (Re)starts `claude-work` tmux session in Claude or proxy mode |
| `~/.claude/usage-monitor/switch-provider.sh` | Switches the proxy backend (OpenRouter/Gemini/Groq/Ollama) |
| `~/.claude/usage-monitor/model-pick.sh` | Interactive TUI to manually pick any model or backend |
| `~/.claude/usage-monitor/usage-cache.json` | Latest rate_limits snapshot (updated every statusline tick) |
| `~/.claude/usage-monitor/alert-state.json` | Tracks last alert level to prevent duplicate messages |
| `~/.claude/usage-monitor/model-override.json` | Active Claude model override |
| `~/.claude/ollama-proxy/.env` | Proxy backend config (PREFERRED_PROVIDER, BIG_MODEL, SMALL_MODEL) |

## Alert Thresholds

| Usage | Action |
|-------|--------|
| ≥ 70% | 🟡 Telegram warning — defer low-priority tasks |
| ≥ 90% | 🔴 Telegram critical — be ready to switch |
| ≥ 95% | 🚨 Telegram alert + **auto-switch to proxy** |
| < 60% | Alert state resets (re-arms all thresholds) |

## Trigger Frequency

`alert.sh` is triggered two ways:

1. **Stop hook** (primary) — fires after every Claude response via `settings.json`. Near-realtime — catches 95% within one response of crossing the threshold.
2. **Cron** (safety net) — runs every 30 min regardless of Claude activity.

## Auto-Switch Flow (at 95%)

1. `alert.sh` detects ≥ 95% usage
2. Sends Telegram message: "🚨 Auto-switched to qwen3-coder-next — work continues"
3. Calls `claude-start.sh free` which:
   - Kills the `claude-work` tmux session
   - Restarts it with `ANTHROPIC_BASE_URL=http://localhost:8082` (local proxy on port 8082)
   - Sets `ANTHROPIC_API_KEY=ollama-local`
   - Resumes the last Claude session ID automatically

## Proxy Backends

The proxy (`~/.claude/ollama-proxy/`) translates Anthropic API calls to other providers.

Default fallback: **OpenRouter → qwen/qwen3-coder**

| Backend | Command | Notes |
|---------|---------|-------|
| OpenRouter (paid) | `switch-provider.sh openrouter:qwen/qwen3-coder` | Best coding quality |
| OpenRouter (free) | `switch-provider.sh openrouter:qwen/qwen3-coder:free` | Rate-limited |
| Gemini | `switch-provider.sh gemini` | Gemini 2.5 Pro |
| Groq | `switch-provider.sh groq` | llama-3.3-70b |
| Ollama (local) | `switch-provider.sh ollama:<model>` | Zero cost, offline |

## Manual Controls

```bash
# Interactive model picker
bash ~/.claude/usage-monitor/model-pick.sh

# Force switch to proxy now
bash ~/.claude/usage-monitor/claude-start.sh free

# Force back to real Claude
bash ~/.claude/usage-monitor/claude-start.sh claude

# Check current usage
cat ~/.claude/usage-monitor/usage-cache.json | python3 -c "
import json,sys; d=json.load(sys.stdin); rl=d['rate_limits']
fh=rl.get('five_hour',{}); sd=rl.get('seven_day',{})
print(f'5hr: {round(fh.get(\"used_percentage\",0))}%  7day: {round(sd.get(\"used_percentage\",0))}%')
"
```
