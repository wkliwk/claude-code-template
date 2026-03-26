#!/bin/bash
# Switch the alt-model proxy backend and (re)start it.
# Usage: bash switch-provider.sh <provider>
# Providers: gemini | groq | ollama | ollama:<model>

PROVIDER="${1:-}"
ENV_FILE="$HOME/.claude/ollama-proxy/.env"
PROXY_PID_FILE="/tmp/ollama-proxy2.pid"
PROXY_LOG="/tmp/ollama-proxy2.log"
PROXY_DIR="$HOME/.claude/ollama-proxy"
PROXY_PORT=8082

load_env() {
  # Read key from .env without sourcing (avoid polluting shell)
  grep "^${1}=" "$ENV_FILE" | cut -d= -f2- | tr -d '"'
}

set_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i '' "s|^${key}=.*|${key}=\"${val}\"|" "$ENV_FILE"
  else
    echo "${key}=\"${val}\"" >> "$ENV_FILE"
  fi
}

restart_proxy() {
  kill "$(cat "$PROXY_PID_FILE" 2>/dev/null)" 2>/dev/null
  sleep 1
  source "$HOME/.local/bin/env"
  cd "$PROXY_DIR"
  nohup uv run uvicorn server:app --host 0.0.0.0 --port "$PROXY_PORT" > "$PROXY_LOG" 2>&1 &
  echo $! > "$PROXY_PID_FILE"
  sleep 4
  if curl -s "http://localhost:${PROXY_PORT}/" | grep -q "message\|Proxy"; then
    echo "✓ Proxy restarted on port $PROXY_PORT"
  else
    echo "❌ Proxy failed to start — check $PROXY_LOG"
    exit 1
  fi
}

case "$PROVIDER" in
  gemini)
    GEMINI_KEY=$(load_env "GEMINI_API_KEY")
    if [ -z "$GEMINI_KEY" ]; then
      echo "❌ GEMINI_API_KEY not set in $ENV_FILE"
      echo "   Add it then re-run: switch-provider gemini"
      exit 1
    fi
    set_env "PREFERRED_PROVIDER" "google"
    set_env "BIG_MODEL" "gemini-2.5-pro-preview-03-25"
    set_env "SMALL_MODEL" "gemini-2.0-flash"
    restart_proxy
    echo "✓ Switched to Gemini 2.5 Pro (free tier)"
    ;;

  groq)
    GROQ_KEY=$(load_env "GROQ_API_KEY")
    if [ -z "$GROQ_KEY" ]; then
      echo "❌ GROQ_API_KEY not set in $ENV_FILE"
      echo "   Add it then re-run: switch-provider groq"
      exit 1
    fi
    set_env "PREFERRED_PROVIDER" "groq"
    set_env "BIG_MODEL" "llama-3.3-70b-versatile"
    set_env "SMALL_MODEL" "llama-3.1-8b-instant"
    sed -i '' '/^OPENAI_BASE_URL=/d' "$ENV_FILE"
    restart_proxy
    echo "✓ Switched to Groq (llama-3.3-70b)"
    ;;

  openrouter|openrouter:*)
    OR_KEY=$(load_env "OPENROUTER_API_KEY")
    if [ -z "$OR_KEY" ]; then
      echo "❌ OPENROUTER_API_KEY not set in $ENV_FILE"
      exit 1
    fi
    MODEL="${PROVIDER#openrouter:}"
    [ "$MODEL" = "openrouter" ] && MODEL="deepseek/deepseek-r1:free"
    set_env "PREFERRED_PROVIDER" "openrouter"
    set_env "BIG_MODEL" "$MODEL"
    set_env "SMALL_MODEL" "meta-llama/llama-3.3-70b-instruct:free"
    sed -i '' '/^OPENAI_BASE_URL=/d' "$ENV_FILE"
    restart_proxy
    echo "✓ Switched to OpenRouter ($MODEL)"
    ;;

  ollama|ollama:*)
    MODEL="${PROVIDER#ollama:}"
    [ "$MODEL" = "ollama" ] && MODEL="llama3.1:8b"
    set_env "PREFERRED_PROVIDER" "ollama"
    set_env "BIG_MODEL" "$MODEL"
    set_env "SMALL_MODEL" "$MODEL"
    set_env "OPENAI_API_KEY" "ollama-local"
    # Remove Groq base URL if set
    sed -i '' '/^OPENAI_BASE_URL=/d' "$ENV_FILE"
    restart_proxy
    echo "✓ Switched to Ollama ($MODEL)"
    ;;

  "")
    CURRENT=$(load_env "PREFERRED_PROVIDER")
    BIG=$(load_env "BIG_MODEL")
    echo "Current provider: $CURRENT ($BIG)"
    echo ""
    echo "Usage: switch-provider <gemini|groq|ollama|ollama:model>"
    ;;

  *)
    echo "Unknown provider: $PROVIDER"
    echo "Options: gemini | groq | ollama | ollama:<model>"
    exit 1
    ;;
esac
