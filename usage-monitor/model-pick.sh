#!/bin/bash
# Unified model picker — choose Claude, free proxy backends, or Ollama.
# Run: bash ~/.claude/usage-monitor/model-pick.sh

OVERRIDE_FILE="$HOME/.claude/usage-monitor/model-override.json"
ENV_FILE="$HOME/.claude/ollama-proxy/.env"
SWITCH_SCRIPT="$HOME/.claude/usage-monitor/switch-provider.sh"

load_env() { grep "^${1}=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- | tr -d '"'; }

# Current state
CURRENT_CLAUDE=$(python3 -c "import json; d=json.load(open('$OVERRIDE_FILE')); print(d.get('model',''))" 2>/dev/null || echo "")
CURRENT_PROVIDER=$(load_env "PREFERRED_PROVIDER")
CURRENT_BIG=$(load_env "BIG_MODEL")

clear
echo ""
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │                    MODEL PICKER                             │"
echo "  └─────────────────────────────────────────────────────────────┘"
echo ""
echo "  Current: ${CURRENT_CLAUDE:-auto (quota-based)}   Proxy: ${CURRENT_PROVIDER:-not set} (${CURRENT_BIG:-none})"
echo ""

# ── Section 1: Claude (Anthropic) ──────────────────────────────────────
echo "  ── Claude (Anthropic quota) ──────────────────────────────────"
ENTRIES=()
ENTRY_TYPES=()  # "claude" or "proxy:<provider>:<model>" or "proxy-custom" or "ollama" or "auto"

add_entry() { ENTRIES+=("$1"); ENTRY_TYPES+=("$2"); }

add_entry "claude-opus-4-6            Claude Opus 4.6   — most capable, high quota" "claude:claude-opus-4-6"
add_entry "claude-sonnet-4-6          Claude Sonnet 4.6 — balanced, default" "claude:claude-sonnet-4-6"
add_entry "claude-haiku-4-5-20251001  Claude Haiku 4.5  — fast, low quota cost" "claude:claude-haiku-4-5-20251001"

for i in "${!ENTRIES[@]}"; do
  label=$(echo "${ENTRIES[$i]}" | awk '{print $1}')
  desc=$(echo "${ENTRIES[$i]}"  | cut -d' ' -f2- | xargs)
  marker="   "; num=$((i+1))
  [[ "$CURRENT_CLAUDE" == "$label" ]] && marker=" ▶ "
  printf "  %s%2d)  %-35s %s\n" "$marker" "$num" "$label" "$desc"
done

# ── Section 2: Proxy backends ───────────────────────────────────────────
echo ""
echo "  ── OpenRouter Paid (recommended) ─────────────────────────────"

PROXY_ENTRIES=(
  "openrouter:qwen/qwen3-coder                         Qwen3 Coder          — best coding, 262k ctx ⭐"
  "openrouter:deepseek/deepseek-chat                   DeepSeek Chat        — general, very cheap ⭐"
  "openrouter:google/gemini-2.5-pro                    Gemini 2.5 Pro       — top reasoning"
  "openrouter:anthropic/claude-sonnet-4-5              Claude Sonnet 4.5    — via OpenRouter"
)

for entry in "${PROXY_ENTRIES[@]}"; do
  provider_model=$(echo "$entry" | awk '{print $1}')
  desc=$(echo "$entry" | cut -d' ' -f2- | xargs)
  provider=$(echo "$provider_model" | cut -d: -f1)
  model=$(echo "$provider_model" | cut -d: -f2-)

  idx=${#ENTRIES[@]}; num=$((idx+1))
  marker="   "
  [[ "$CURRENT_PROVIDER" == "$provider" && "$CURRENT_BIG" == "$model" ]] && marker=" ▶ "
  printf "  %s%2d)  %-35s %s\n" "$marker" "$num" "$model" "$desc"
  add_entry "$provider_model" "proxy:$provider:$model"
done

# ── Section 2b: Free backends ───────────────────────────────────────────
echo ""
echo "  ── OpenRouter Free (fallback) ────────────────────────────────"
FREE_ENTRIES=(
  "openrouter:qwen/qwen3-coder:free                    Qwen3 Coder          — rate-limited"
  "openrouter:nvidia/nemotron-3-super-120b-a12b:free   Nemotron Super 120B  — 262k ctx"
  "openrouter:deepseek/deepseek-chat:free               DeepSeek Chat        — rate-limited"
)
for entry in "${FREE_ENTRIES[@]}"; do
  provider_model=$(echo "$entry" | awk '{print $1}')
  desc=$(echo "$entry" | cut -d' ' -f2- | xargs)
  provider=$(echo "$provider_model" | cut -d: -f1)
  model=$(echo "$provider_model" | cut -d: -f2-)
  idx=${#ENTRIES[@]}; num=$((idx+1))
  marker="   "
  [[ "$CURRENT_PROVIDER" == "$provider" && "$CURRENT_BIG" == "$model" ]] && marker=" ▶ "
  printf "  %s%2d)  %-35s %s\n" "$marker" "$num" "$model" "$desc"
  add_entry "$provider_model" "proxy:$provider:$model"
done

# ── Section 3: Ollama local ─────────────────────────────────────────────
echo ""
echo "  ── Ollama (local, zero quota) ────────────────────────────────"
OLLAMA_START=${#ENTRIES[@]}
while IFS= read -r line; do
  name=$(echo "$line" | awk '{print $1}')
  size=$(echo "$line" | awk '{print $3}')
  [[ "$name" == "NAME" || -z "$name" ]] && continue
  idx=${#ENTRIES[@]}; num=$((idx+1))
  marker="   "
  [[ "$CURRENT_PROVIDER" == "ollama" && "$CURRENT_BIG" == "$name" ]] && marker=" ▶ "
  printf "  %s%2d)  %-35s Ollama local — %s\n" "$marker" "$num" "$name" "$size"
  add_entry "ollama:$name" "proxy:ollama:$name"
done < <(ollama list 2>/dev/null)

# ── Auto ────────────────────────────────────────────────────────────────
echo ""
idx=${#ENTRIES[@]}; num=$((idx+1))
marker="   "; [[ -z "$CURRENT_CLAUDE" && "$CURRENT_PROVIDER" != "openrouter" ]] && marker=" ▶ "
printf "  %s%2d)  %-35s %s\n" "$marker" "$num" "auto" "Quota-based routing (default)"
add_entry "auto" "auto"

echo ""
echo "  ──────────────────────────────────────────────────────────────"
echo ""
read -p "  Pick a number (Enter = keep current): " CHOICE
echo ""

[[ -z "$CHOICE" ]] && echo "  No change." && exit 0

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#ENTRIES[@]}" ]; then
  echo "  Invalid choice." >&2; exit 1
fi

SELECTED_ENTRY="${ENTRIES[$((CHOICE-1))]}"
SELECTED_TYPE="${ENTRY_TYPES[$((CHOICE-1))]}"

case "$SELECTED_TYPE" in
  auto)
    rm -f "$OVERRIDE_FILE"
    echo "  ✓ Switched to auto (quota-based routing)"
    ;;

  claude:*)
    MODEL_ID="${SELECTED_TYPE#claude:}"
    claude config set model "$MODEL_ID" 2>/dev/null
    python3 -c "import json; json.dump({'model': '$MODEL_ID', 'set_at': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}, open('$OVERRIDE_FILE', 'w'))"
    echo "  ✓ Switched to $MODEL_ID (this window)"
    ;;

  proxy:gemini:*)
    MODEL="${SELECTED_TYPE#proxy:gemini:}"
    bash "$SWITCH_SCRIPT" gemini
    # Also update the BIG_MODEL to specific model chosen
    sed -i '' "s|^BIG_MODEL=.*|BIG_MODEL=\"${MODEL}\"|" "$ENV_FILE"
    echo ""
    echo "  ✓ Backend: Gemini ($MODEL)"
    echo "  ✓ Run in a new terminal:  claude-free"
    ;;

  proxy:groq:*)
    bash "$SWITCH_SCRIPT" groq
    echo ""
    echo "  ✓ Backend: Groq"
    echo "  ✓ Run in a new terminal:  claude-free"
    ;;

  proxy:ollama:*)
    MODEL="${SELECTED_TYPE#proxy:ollama:}"
    bash "$SWITCH_SCRIPT" "ollama:$MODEL"
    echo ""
    echo "  ✓ Backend: Ollama ($MODEL)"
    echo "  ✓ Run in a new terminal:  claude-free"
    ;;

  proxy:openrouter:*)
    MODEL="${SELECTED_TYPE#proxy:openrouter:}"
    bash "$SWITCH_SCRIPT" "openrouter:$MODEL"
    echo ""
    echo "  ✓ Backend: OpenRouter ($MODEL)"
    echo "  ✓ Run in a new terminal:  claude-free"
    ;;
esac
