#!/bin/bash
# Shell aliases for the Claude Code AI company setup.
# Add to ~/.zshrc or ~/.bashrc:
#   source ~/.claude/shell-aliases.sh

# ── Persistent tmux session ──────────────────────────────────────────────────
# Starts Claude Code in a "claude-work" tmux session (survives terminal close).
# auto mode: uses real Claude unless quota >= 90%, then switches to free proxy.
alias work="bash ~/.claude/usage-monitor/claude-start.sh && tmux attach -t claude-work"
alias work-free="bash ~/.claude/usage-monitor/claude-start.sh free && tmux attach -t claude-work"
alias work-claude="bash ~/.claude/usage-monitor/claude-start.sh claude && tmux attach -t claude-work"
alias work-attach="tmux attach -t claude-work"
alias work-status="tmux ls 2>/dev/null | grep claude-work || echo 'No session running'"

# ── Free model proxy (LiteLLM on port 8082) ──────────────────────────────────
alias proxy-start="launchctl start com.ollama-proxy && echo '✓ Proxy started'"
alias proxy-stop="launchctl stop com.ollama-proxy && echo '✓ Proxy stopped'"
alias proxy-restart="launchctl stop com.ollama-proxy; sleep 2; launchctl start com.ollama-proxy && echo '✓ Proxy restarted'"
alias proxy-status="curl -s http://localhost:8082/ && echo '' || echo '❌ Proxy not running'"
alias proxy-log="tail -f /tmp/ollama-proxy2.log | grep --line-buffered -E '→|✓|⚠|fallback|Used|failed'"
alias proxy-model="grep '^BIG_MODEL=' ~/.claude/ollama-proxy/.env | cut -d= -f2 | tr -d '\"'"

# ── Launch Claude directly on free proxy (no tmux) ───────────────────────────
alias claude-free="ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY=ollama-local claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions"

# ── Switch proxy backend model ───────────────────────────────────────────────
alias switch-provider="bash ~/.claude/usage-monitor/switch-provider.sh"
alias use-qwen="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:qwen/qwen3-coder-next && proxy-restart"
alias use-deepseek="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:deepseek/deepseek-chat && proxy-restart"
alias use-nemotron="bash ~/.claude/usage-monitor/switch-provider.sh openrouter:nvidia/nemotron-3-super-120b-a12b:free && proxy-restart"
alias use-ollama="bash ~/.claude/usage-monitor/switch-provider.sh ollama:qwen2.5-coder:7b && proxy-restart"
alias model-pick="bash ~/.claude/usage-monitor/model-pick.sh"

# ── Monitoring ────────────────────────────────────────────────────────────────
alias or-usage="open https://openrouter.ai/activity"   # OpenRouter dashboard (macOS)
