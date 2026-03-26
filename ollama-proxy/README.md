# Ollama Proxy — LiteLLM Bridge

A FastAPI server that translates Anthropic API calls to OpenRouter / Gemini / Groq / Ollama via LiteLLM. Runs on port 8082.

Claude Code connects to it via:
```bash
ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY=ollama-local claude
```

## Setup

```bash
# 1. Install uv (if needed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Copy and fill in .env
cp .env.example .env

# 3. Run the server
uv run uvicorn server:app --host 0.0.0.0 --port 8082
```

## Auto-start on macOS boot (launchd)

Copy `../launchd/com.ollama-proxy.plist` to `~/Library/LaunchAgents/` then:
```bash
launchctl load ~/Library/LaunchAgents/com.ollama-proxy.plist
```

The proxy will start automatically on login and restart if it crashes.

## Model Mapping

Requests for Claude `sonnet` → `BIG_MODEL`, `haiku` → `SMALL_MODEL`.

| Provider | Example BIG_MODEL |
|---|---|
| OpenRouter | `qwen/qwen3-coder-next` (262k ctx, free) |
| OpenRouter | `deepseek/deepseek-chat` (general, free) |
| Google | `gemini-2.5-pro-preview-03-25` |
| Groq | `llama-3.3-70b-versatile` |
| Ollama | `qwen2.5-coder:7b` (local, zero cost) |

Switch provider without restart: `bash ~/.claude/usage-monitor/switch-provider.sh openrouter:qwen/qwen3-coder-next`

## Control

```bash
proxy-start    # launchctl start com.ollama-proxy
proxy-stop     # launchctl stop com.ollama-proxy
proxy-restart  # stop + start (after .env changes)
proxy-status   # curl http://localhost:8082/
proxy-log      # tail live log
```
