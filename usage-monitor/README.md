# Token Quota Monitoring & Auto-Fallback

Keeps Claude Code running smoothly even when the Anthropic quota is running low — auto-alerts via Telegram and switches to a free model proxy before hitting the hard limit.

---

## How It Works

```
Every Claude response (Stop hook) + cron every 30 min
         ↓
  capture.sh → reads statusline stdin → writes usage-cache.json
         ↓
  alert.sh → checks thresholds → sends Telegram alert
         ↓ (at 95%)
  claude-start.sh free → kills tmux session → restarts with proxy
         ↓
  Session resumes automatically on qwen3-coder via OpenRouter
```

---

## Scripts

| Script | Purpose |
|---|---|
| `capture.sh` | Statusline hook — intercepts Claude's `rate_limits` data, saves to `usage-cache.json`, pipes through to claude-hud |
| `alert.sh` | Reads `usage-cache.json`, checks thresholds, sends Telegram DM, auto-switches at 95% |
| `claude-start.sh` | Starts/restarts `claude-work` tmux session — auto-detect, force-free, or force-claude |
| `ollama-fallback.sh` | Run a prompt via local Ollama when quota ≥ 90% (used by `/start-working`) |
| `switch-provider.sh` | Switch the proxy backend: gemini / groq / openrouter / ollama |
| `model-pick.sh` | Interactive TUI to pick Claude model or proxy backend |
| `session-init.sh` | PreToolUse hook — captures quota snapshot at session start |
| `log-session.sh` | Logs session summary to history |

---

## Alert Thresholds

| Usage | Level | Action |
|---|---|---|
| ≥ 70% | 🟡 Warning | Telegram DM — defer low-priority tasks |
| ≥ 90% | 🔴 Critical | Telegram DM — open `claude-free` now |
| ≥ 95% | 🚨 Auto-switch | Telegram DM + restart tmux session on free proxy |
| < 60% | ✅ Reset | Alert state cleared, resumes normal operation |

Alert dedup is tracked in `alert-state.json` — no spam on repeated responses.

---

## Free Proxy Fallback Chain

When quota hits 95%, `claude-start.sh free` restarts the `claude-work` tmux session with:

```
ANTHROPIC_BASE_URL=http://localhost:8082
ANTHROPIC_API_KEY=ollama-local
```

The LiteLLM proxy at port 8082 routes to:
1. `qwen/qwen3-coder:free` via OpenRouter — best for coding, 262k ctx
2. `deepseek/deepseek-chat:free` — general purpose
3. `nvidia/nemotron-3-super:free` — reasoning fallback
4. `ollama/qwen2.5-coder:7b` — local, zero cost, zero quota

---

## Wiring It Up (settings.json hooks)

```json
{
  "hooks": {
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "bash ~/.claude/usage-monitor/session-init.sh 2>/dev/null || true"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "TELEGRAM_BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN ~/.claude/channels/telegram/.env | cut -d= -f2) CHAT_ID=YOUR_TELEGRAM_CHAT_ID bash ~/.claude/usage-monitor/alert.sh >> ~/.claude/usage-monitor/alert.log 2>&1 &"
      }]
    }]
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/usage-monitor/capture.sh"
  }
}
```

---

## Data Files (gitignored — generated at runtime)

| File | Content |
|---|---|
| `usage-cache.json` | Latest `rate_limits` snapshot from statusline |
| `alert-state.json` | Last alerted threshold (prevents duplicate messages) |
| `model-override.json` | Active model override (set by `model-pick.sh`) |
| `session-start.json` | Quota snapshot at start of current session |

---

## Setup

1. Copy this folder to `~/.claude/usage-monitor/`
2. Make all `.sh` files executable: `chmod +x ~/.claude/usage-monitor/*.sh`
3. Add hooks to `~/.claude/settings.json` (see above)
4. Set up Telegram bot token in `~/.claude/channels/telegram/.env`:
   ```
   TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
   ```
5. Set up the LiteLLM proxy (see `../PROXY_CHEATSHEET.md`) for auto-fallback
