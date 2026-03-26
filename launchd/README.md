# launchd — macOS Auto-Start Services

These plist files keep background services running persistently on macOS — starting on login and auto-restarting on crash.

## com.ollama-proxy.plist — Free Model Proxy

Keeps the LiteLLM proxy (port 8082) running at all times so `claude-free` and auto-fallback work without manual intervention.

### Install

```bash
# 1. Copy and edit the plist — replace /YOUR_HOME with your actual home directory
cp launchd/com.ollama-proxy.plist.example ~/Library/LaunchAgents/com.ollama-proxy.plist
nano ~/Library/LaunchAgents/com.ollama-proxy.plist  # replace /YOUR_HOME

# 2. Load it
launchctl load ~/Library/LaunchAgents/com.ollama-proxy.plist

# 3. Verify it started
curl http://localhost:8082/
```

### Control

```bash
launchctl start com.ollama-proxy   # start
launchctl stop com.ollama-proxy    # stop
launchctl unload ~/Library/LaunchAgents/com.ollama-proxy.plist  # disable
```

Or use the shell aliases: `proxy-start`, `proxy-stop`, `proxy-restart`

### Logs

```bash
tail -f /tmp/ollama-proxy2.log
```
