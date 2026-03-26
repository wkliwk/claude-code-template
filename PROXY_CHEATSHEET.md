# Free Model Proxy — Quick Reference

## Start claude-free
```bash
claude-free
```
Opens Claude Code using the free model proxy (OpenRouter → Ollama fallback).

---

## If proxy didn't auto-start

### Normal way
```bash
proxy-start
ollama serve &
```

### Force start (if launchd broken)
```bash
source ~/.zshrc
cd ~/.claude/ollama-proxy && nohup uv run uvicorn server:app --host 0.0.0.0 --port 8082 > /tmp/ollama-proxy2.log 2>&1 &
ollama serve &
```

### Check both are running
```bash
proxy-status          # → {"message":"Anthropic Proxy for LiteLLM"}
curl localhost:11434  # → Ollama is running
```

---

## Proxy control
```bash
proxy-start      # start
proxy-stop       # stop
proxy-restart    # restart (after config changes)
proxy-status     # check if running
proxy-log        # live log — see which model is being used
```

---

## Switch model manually
```bash
model-pick       # interactive picker — choose primary model
```
Or force a specific one:
```bash
use-qwen         # qwen3-coder (best for coding)
use-deepseek     # deepseek-chat (general)
use-nemotron     # nemotron-3-super (reasoning)
use-ollama       # qwen2.5-coder local
```

---

## Check token usage
OpenRouter dashboard: https://openrouter.ai/activity

---

## Fallback chain (auto, no action needed)
1. qwen/qwen3-coder:free        — best coding, 262k ctx
2. deepseek/deepseek-chat:free  — general purpose
3. nvidia/nemotron-3-super:free — reasoning fallback
4. openrouter/free              — dynamic free router
5. ollama/qwen2.5-coder:7b      — local offline
6. ollama/phi3:mini             — ultra-light last resort
