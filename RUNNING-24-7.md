# Running Claude Agents 24/7

How to keep Claude Code agents running continuously — persistent tmux session, work loop, daily standups, and auto-restart on quota exhaustion.

---

## Architecture

```
tmux session: "claude-work"
    ↓ persistent, survives terminal close
Claude Code (with Telegram plugin)
    ↓ receives messages from Telegram, executes tasks
/loop 30m /start-working
    ↓ every 30 min: check boards → pick top Todo → execute → loop
Stop hook (after every response)
    ↓ alert.sh → check quota → Telegram alert if high
    ↓ at 95%: auto-kill session → restart on free proxy
```

---

## Step 0 — Ensure the Proxy Auto-Starts on Boot

The free model proxy must be running before any quota-based fallback can work.
Use a macOS LaunchAgent so it starts on login and restarts on crash:

```bash
# Copy and edit the plist (replace /YOUR_HOME with your real home path)
cp launchd/com.ollama-proxy.plist.example ~/Library/LaunchAgents/com.ollama-proxy.plist
# Edit: replace /YOUR_HOME → e.g. /Users/yourname

# Load it
launchctl load ~/Library/LaunchAgents/com.ollama-proxy.plist

# Verify
curl http://localhost:8082/
```

Once loaded, the proxy survives reboots and restarts automatically if it crashes.
See `launchd/README.md` for full details.

---

## Step 1 — Start a Persistent Session

Claude runs inside a named tmux session so it survives terminal close.

```bash
# Start (auto-detect: real Claude or free proxy based on quota)
work

# Force real Claude
work-claude

# Force free proxy (OpenRouter / Ollama)
work-free

# Re-attach to existing session (no restart)
work-attach

# Check if session is running
work-status
```

These aliases call `~/.claude/usage-monitor/claude-start.sh` which:
1. Kills any existing `claude-work` session
2. Checks quota (if `auto` mode) — switches to proxy if ≥ 90%
3. Finds most recent Claude session ID → passes `--resume` so work continues
4. Starts a new tmux session with `--dangerously-skip-permissions` and Telegram plugin

**Shell aliases** (from `shell-aliases.sh` — add to `~/.zshrc`):
```bash
alias work="bash ~/.claude/usage-monitor/claude-start.sh && tmux attach -t claude-work"
alias work-free="bash ~/.claude/usage-monitor/claude-start.sh free && tmux attach -t claude-work"
alias work-claude="bash ~/.claude/usage-monitor/claude-start.sh claude && tmux attach -t claude-work"
alias work-attach="tmux attach -t claude-work"
alias work-status="tmux ls 2>/dev/null | grep claude-work || echo 'No session running'"
```

---

## Step 2 — Register the Work Loop

Once inside the Claude session, register the autonomous work loop:

```
/loop 30m /start-working
```

This tells Claude to run `/start-working` every 30 minutes:
1. Check token quota → route to Ollama if ≥ 90%
2. Read GitHub Project boards → find highest priority `Todo`
3. Execute the task fully (feature branch → PR → done)
4. Append to `loop-log.txt`
5. Sleep 30 min → repeat

**The loop never stops on its own.** It runs until you kill it or the session ends.

---

## Step 3 — Register Daily Standup

```
/loop 24h /daily
```

Sends a per-agent standup to Telegram every morning with:
- What was completed in the last 24h
- What's in progress
- Any blockers

---

## Step 4 — Register Token Monitor (optional)

Checks if the work loop is running too frequently and alerts via Telegram:

Use the `CronCreate` tool with:
- Cron: `7 */2 * * *`
- Prompt: `"Count START entries in ~/ai-company/history/loop-log.txt from last 2 hours. If >3 runs/hour consistently, send Telegram alert: '⚠️ Loop running too frequently — consider adjusting interval'. Log result to loop-log.txt."`

---

## Step 5 — cron Safety Net

The alert system also has a cron fallback (in case the Stop hook misses a check):

```bash
# Add to crontab: crontab -e
*/30 * * * * TELEGRAM_BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN ~/.claude/channels/telegram/.env | cut -d= -f2) CHAT_ID=YOUR_TELEGRAM_CHAT_ID bash ~/.claude/usage-monitor/alert.sh >> ~/.claude/usage-monitor/alert.log 2>&1
```

---

## Auto-Restart on Quota Exhaustion

When the Stop hook detects quota ≥ 95%:

1. `alert.sh` calls `claude-start.sh free`
2. Kills the current `claude-work` tmux session
3. Restarts it with `ANTHROPIC_BASE_URL=http://localhost:8082`
4. Resumes the most recent Claude session ID automatically
5. Sends Telegram: `"🚨 Auto-switched to qwen3-coder-next — work continues."`

**No work is lost** — the session resumes where it left off.

---

## Full Startup Sequence (from scratch)

```bash
# 1. Start the free model proxy (always keep this running)
proxy-start

# 2. Start Claude in persistent tmux session
work

# 3. Inside Claude, register the loops
/loop 30m /start-working
/loop 24h /daily

# 4. Detach from tmux (Claude keeps running)
Ctrl+B, D

# 5. Monitor via Telegram — Claude will message you on task completion,
#    quota alerts, and deploy notifications
```

---

## Monitoring

| Command | What it shows |
|---|---|
| `work-status` | Is the tmux session alive? |
| `work-attach` | Re-attach to see what Claude is doing |
| `proxy-log` | Live model routing (which model is being used) |
| `proxy-status` | Is the LiteLLM proxy running? |
| `tail -f ~/ai-company/history/loop-log.txt` | Live task completion log |
| Telegram | Quota alerts, CI results, deploy notifications |

---

## Proxy Model Aliases

Force a specific model for the free proxy session:

```bash
alias use-qwen="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:qwen/qwen3-coder-next && proxy-restart"
alias use-deepseek="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:deepseek/deepseek-chat && proxy-restart"
alias use-nemotron="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:nvidia/nemotron-3-super-120b-a12b:free && proxy-restart"
alias use-ollama="bash ~/.claude/usage-monitor/switch-provider.sh ollama:qwen2.5-coder:7b && proxy-restart"
```

---

## What Keeps It Going

| Component | Role | Survives restart? |
|---|---|---|
| tmux `claude-work` | Persistent shell session | ✅ survives terminal close |
| `/loop` skill | Recurring task execution | ❌ re-register per session |
| cron (alert) | Quota check safety net | ✅ system-level |
| Stop hook | Per-response quota check | ✅ in settings.json |
| `claude-start.sh` | Auto-resume last session | ✅ reads session ID from file |

**Important:** `/loop` registrations are session-only. If the tmux session is killed and restarted, re-run `/loop 30m /start-working` and `/loop 24h /daily` inside the new session.
