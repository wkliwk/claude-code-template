#!/bin/bash
# Reads usage-cache.json and sends Telegram alerts at 70% and 90% thresholds.
# Tracks last-alerted level to avoid duplicate messages.

CACHE_FILE="$HOME/.claude/usage-monitor/usage-cache.json"
STATE_FILE="$HOME/.claude/usage-monitor/alert-state.json"
ENV_FILE="$HOME/.claude/channels/telegram/.env"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# Load bot token
if [ ! -f "$ENV_FILE" ]; then
  echo "No Telegram .env found at $ENV_FILE" >&2
  exit 1
fi
source "$ENV_FILE"

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "TELEGRAM_BOT_TOKEN not set" >&2
  exit 1
fi

# Read usage cache
if [ ! -f "$CACHE_FILE" ]; then
  echo "No usage cache found — statusline hasn't run yet" >&2
  exit 0
fi

# Parse usage data and determine alert level
python3 << 'PYEOF'
import json, os, sys, subprocess, datetime

cache_path = os.path.expanduser("~/.claude/usage-monitor/usage-cache.json")
state_path = os.path.expanduser("~/.claude/usage-monitor/alert-state.json")

with open(cache_path) as f:
    cache = json.load(f)

rate_limits = cache.get("rate_limits", {})
five_hour = rate_limits.get("five_hour", {}) or {}
seven_day = rate_limits.get("seven_day", {}) or {}

five_pct = five_hour.get("used_percentage")
seven_pct = seven_day.get("used_percentage")
five_reset = five_hour.get("resets_at")
seven_reset = seven_day.get("resets_at")

updated_at = cache.get("updated_at", "unknown")

# Load alert state
try:
    with open(state_path) as f:
        state = json.load(f)
except Exception:
    state = {"last_five_alert": 0, "last_seven_alert": 0}

def reset_time_str(ts):
    if not ts:
        return "unknown"
    try:
        dt = datetime.datetime.fromtimestamp(ts).strftime("%H:%M")
        return dt
    except Exception:
        return "unknown"

messages = []
new_state = dict(state)

auto_switched = False

def auto_switch_to_free():
    """Kill claude tmux session and restart with claude-free proxy."""
    global auto_switched
    try:
        import subprocess
        session = "claude-work"
        # Check if tmux session exists
        check = subprocess.run(["tmux", "has-session", "-t", session],
                               capture_output=True)
        if check.returncode == 0:
            subprocess.run(
                ["bash", os.path.expanduser("~/.claude/usage-monitor/claude-start.sh"), "free"],
                capture_output=True
            )
            auto_switched = True
    except Exception as e:
        print(f"Auto-switch failed: {e}", file=sys.stderr)

def check_threshold(pct, last_alert_key, window_label, reset_ts):
    if pct is None:
        return
    pct = round(pct)
    last = state.get(last_alert_key, 0)

    if pct >= 95 and last < 95:
        auto_switch_to_free()
        switch_msg = "\n✅ *Auto-switched to qwen3-coder-next* — work continues." if auto_switched else "\n⚠️ Open `claude-free` in a new terminal."
        messages.append(
            f"🚨 *QUOTA EXHAUSTED* — {window_label} at *{pct}%*\n"
            f"Resets at: {reset_time_str(reset_ts)}"
            f"{switch_msg}"
        )
        new_state[last_alert_key] = 100
    elif pct >= 90 and last < 90:
        messages.append(
            f"🔴 *CRITICAL* — {window_label} usage at *{pct}%*\n"
            f"Resets at: {reset_time_str(reset_ts)}\n"
            f"⚡ Open `claude-free` now to be ready."
        )
        new_state[last_alert_key] = 90
    elif pct >= 70 and last < 70:
        messages.append(
            f"🟡 *WARNING* — {window_label} usage at *{pct}%*\n"
            f"Resets at: {reset_time_str(reset_ts)}\n"
            f"Consider deferring low-priority tasks."
        )
        new_state[last_alert_key] = 70
    elif pct < 60 and last >= 70:
        # Reset alert state when usage drops back below 60%
        new_state[last_alert_key] = 0

check_threshold(five_pct, "last_five_alert", "5-hour window", five_reset)
check_threshold(seven_pct, "last_seven_alert", "7-day window", seven_reset)

if new_state != state:
    with open(state_path, "w") as f:
        json.dump(new_state, f)

if messages:
    bot_token = os.environ.get("TELEGRAM_BOT_TOKEN", "")
    chat_id = os.environ.get("CHAT_ID", "YOUR_TELEGRAM_CHAT_ID")

    for msg in messages:
        full_msg = (
            f"🤖 *Claude Usage Alert*\n\n{msg}\n\n"
            f"_5hr: {round(five_pct) if five_pct is not None else 'N/A'}% (resets {reset_time_str(five_reset)}) | "
            f"7day: {round(seven_pct) if seven_pct is not None else 'N/A'}% (resets {reset_time_str(seven_reset)})_"
        )
        result = subprocess.run([
            "curl", "-s", "-X", "POST",
            f"https://api.telegram.org/bot{bot_token}/sendMessage",
            "-d", f"chat_id={chat_id}",
            "-d", f"text={full_msg}",
            "-d", "parse_mode=Markdown"
        ], capture_output=True, text=True)
        print(f"Alert sent: {msg[:50]}...")
else:
    five_str = f"{round(five_pct)}%" if five_pct is not None else "N/A"
    seven_str = f"{round(seven_pct)}%" if seven_pct is not None else "N/A"
    print(f"No alert needed — 5hr: {five_str}, 7day: {seven_str} (updated: {updated_at})")
PYEOF
