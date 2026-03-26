# /sync-setup — Sync Claude Code Config to Git Repo

Push the current `~/.claude/` config to `YOUR_GITHUB_USER/claude-code-setup` so the repo stays in sync with the live system.

## Usage
`/sync-setup`

## Steps

### 1. Diff

Compare live config vs repo:
```bash
# Commands
diff -rq ~/.claude/commands/ ~/Dev/claude-code-setup/commands/ 2>/dev/null
# Skills
diff -rq ~/.claude/skills/ ~/Dev/claude-code-setup/skills/ 2>/dev/null
# Memory (structure only, not content — memory is personal)
ls ~/.claude/projects/*/memory/ > /tmp/live-memory-list.txt
ls ~/Dev/claude-code-setup/memory/ > /tmp/repo-memory-list.txt 2>/dev/null
diff /tmp/live-memory-list.txt /tmp/repo-memory-list.txt
# Settings
diff ~/.claude/settings.json ~/Dev/claude-code-setup/settings.json.example 2>/dev/null
```

If no differences, report "Already in sync" and stop.

### 2. Copy changed files

```bash
# Commands (full sync)
rsync -av --delete ~/.claude/commands/ ~/Dev/claude-code-setup/commands/

# Skills (full sync)
rsync -av --delete ~/.claude/skills/ ~/Dev/claude-code-setup/skills/

# Settings (as example, strip secrets)
cp ~/.claude/settings.json ~/Dev/claude-code-setup/settings.json.example
# Remove any secret values from the example file

# MCP config (as example, strip secrets)
cp ~/.claude/mcp.json ~/Dev/claude-code-setup/mcp.json.example 2>/dev/null
# Remove any secret values
```

Do NOT sync:
- Memory content (personal, session-specific)
- `.claude/projects/` (per-project state)
- Any files containing secrets/tokens

### 3. Commit and push

```bash
cd ~/Dev/claude-code-setup
git add -A
git diff --cached --stat
git commit -m "sync: update commands and skills from live config"
git push
```

### 4. Report

- Files added/modified/deleted
- Commit URL

## Notes
- This is a one-way sync: live `~/.claude/` → repo. Never the other direction.
- Memory files are excluded — they contain personal context
- Settings are copied as `.example` files with secrets stripped
