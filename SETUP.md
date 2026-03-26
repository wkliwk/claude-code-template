# Setup Guide for AI Agents

> This file is for AI agents (Claude Code, etc.) to read after the template is cloned.
> It tells you exactly what needs to be configured before the system works.

---

## Step 1 — Collect user information

Ask the user for these values. All are required unless marked optional.

| Key | What to ask | Example | Where it's used |
|-----|-------------|---------|-----------------|
| `GITHUB_USER` | "What's your GitHub username?" | `johndoe` | Repo names, gh commands, project boards |
| `GITHUB_OWNER` | "Is your GitHub org the same as your username, or different?" | `johndoe` or `my-org` | Project board owner |
| `HOME_DIR` | Detect automatically via `echo $HOME` | `/Users/john` | File paths in commands |
| `TELEGRAM_CHAT_ID` | "What's your Telegram chat ID? (optional — needed for alerts)" | `123456789` | Status reports, alerts |
| `TELEGRAM_BOT_TOKEN` | "What's your Telegram bot token? (optional)" | `bot123:ABC...` | **Never store in files — set as env var only** |
| `PRODUCT_NAME` | "What's your first product called?" | `my-app` | Product registry, repo names |
| `PRODUCT_DESCRIPTION` | "One-line description of the product" | `A task management app for freelancers` | CEO context for idea evaluation |
| `PRODUCT_REPOS` | "Will it have separate frontend/backend repos, or a monorepo?" | `frontend + backend` | Product registry, issue routing |
| `PRODUCT_STACK` | "What tech stack? (e.g. React + Node, Next.js, etc.)" | `React, Express, MongoDB` | CLAUDE.md in each repo |

---

## Step 2 — Replace placeholders

Search and replace across all files in this repo:

```bash
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.example" -o -name "*.plist" \) -exec sed -i '' \
  -e 's/YOUR_GITHUB_USER/<GITHUB_USER>/g' \
  -e 's|~/|<HOME_DIR>/|g' \
  -e 's/YOUR_TELEGRAM_CHAT_ID/<TELEGRAM_CHAT_ID>/g' \
  -e 's/your-product/<PRODUCT_NAME>/g' \
  -e 's/Your Product/<PRODUCT_DISPLAY_NAME>/g' \
  {} +
```

**Do NOT replace `YOUR_BOT_TOKEN`** — that goes in env vars, not files.

---

## Step 3 — Fill product registry

Edit `commands/shared/product-registry.md`:

```markdown
| Product | CWD match | Repos | Board | Context |
|---------|-----------|-------|-------|---------|
| <PRODUCT_DISPLAY_NAME> | `<PRODUCT_NAME>` | <GITHUB_USER>/<PRODUCT_NAME>-frontend, <GITHUB_USER>/<PRODUCT_NAME>-backend | 1 | <PRODUCT_DESCRIPTION> |
```

---

## Step 4 — Copy to ~/.claude/

```bash
cp -r commands/ ~/.claude/commands/
cp -r skills/ ~/.claude/skills/
cp -r agents/ ~/.claude/agents/ 2>/dev/null
cp -r usage-monitor/ ~/.claude/usage-monitor/ 2>/dev/null
```

---

## Step 5 — Create GitHub Project boards

The system expects these boards:

| Board # | Name | How to create |
|---------|------|---------------|
| 1 | `<PRODUCT_DISPLAY_NAME>` | `gh project create --owner <GITHUB_OWNER> --title "<PRODUCT_DISPLAY_NAME>"` |
| 2 | Company Ops | `gh project create --owner <GITHUB_OWNER> --title "Company Ops"` |
| 3 | Ideas | `gh project create --owner <GITHUB_OWNER> --title "Ideas"` |

Each board needs these custom fields:
- **Status**: Todo, In Progress, Review, Done
- **Priority**: P0 — Critical, P1 — High, P2 — Medium, P3 — Low
- **Agent**: ceo, pm, frontend-dev, backend-dev, qa, ops, designer, finance
- **Size**: S, M, L

---

## Step 6 — Create product repos

```bash
gh repo create <GITHUB_USER>/<PRODUCT_NAME>-frontend --public
gh repo create <GITHUB_USER>/<PRODUCT_NAME>-backend --public
```

Then create a `CLAUDE.md` in each repo with:
- Tech stack
- Key files / architecture
- Product goal + anti-goals
- Build / test / deploy commands
- Link to the other repo

---

## Step 7 — Optional: Telegram setup

If the user provided Telegram credentials:
1. Set env var: `export TELEGRAM_BOT_TOKEN=<token>`
2. The chat ID is already in the config files from Step 2
3. Test: `/status` should send a report to Telegram

---

## Step 8 — Optional: Ollama proxy (free model fallback)

If the user wants local model fallback when Claude quota is high:
1. `brew install ollama && ollama pull qwen2.5-coder:7b`
2. Set up proxy from `ollama-proxy/` directory
3. See `PROXY_CHEATSHEET.md` for details

---

## Verification checklist

After setup, verify:
- [ ] `gh project list --owner <GITHUB_OWNER>` shows boards 1, 2, 3
- [ ] `commands/shared/product-registry.md` has the product row filled in
- [ ] `~/.claude/commands/` has all command files
- [ ] Running `/start-working` checks the boards without errors
- [ ] Running `/idea test feature` triggers CEO + PM evaluation

---

## What NOT to do

- Never store secrets (API keys, tokens) in any config file
- Never commit `.env` files
- Never hardcode absolute paths — use `~` or detect via `$HOME`
