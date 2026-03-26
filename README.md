# Claude Code Template — Autonomous AI Company

> A solo AI company where Claude Code agents handle 24/7 product development.
> The human founder sets direction. Agents execute.

This is a **template** for setting up an autonomous Claude Code development workflow — 7 specialized agents, 15+ slash commands, Telegram integration, token quota monitoring, and a free model proxy fallback.

Fork this repo, fill in your placeholders, and you have a working AI company setup.

---

## Quick Start

### 1. Clone and copy config files

```bash
git clone https://github.com/YOUR_GITHUB_USER/claude-code-template.git
cd claude-code-template

# Copy agent definitions, commands, and skills to ~/.claude/
cp -r agents/ ~/.claude/agents/
cp -r commands/ ~/.claude/commands/
cp -r skills/ ~/.claude/skills/
cp -r usage-monitor/ ~/.claude/usage-monitor/
cp -r ollama-proxy/ ~/.claude/ollama-proxy/
cp shell-aliases.sh ~/.claude/shell-aliases.sh

# Copy company docs to ~/ai-company/
mkdir -p ~/ai-company
cp -r company/* ~/ai-company/
```

### 2. Replace placeholders

Search and replace these across all copied files:

| Placeholder | Replace with |
|---|---|
| `YOUR_GITHUB_USER` | Your GitHub username |
| `YOUR_TELEGRAM_CHAT_ID` | Your Telegram chat ID |
| `YOUR_BOT_TOKEN` | Your Telegram bot token |
| `/YOUR_HOME` | Your home directory path (e.g. `/Users/yourname`) |

### 3. Set up the product registry

Edit `~/.claude/commands/shared/product-registry.md` — add your first product.

### 4. Launch your first product

```
/launch-product my-app
```

This creates repos, a project board, and seed issues.

### 5. Start the autonomous work loop

```
/start-working
```

Agents check boards, pick the top Todo, build it, and loop.

---

## What's Included

### Agents (7 specialized roles)

| Agent | Role | File |
|---|---|---|
| CEO | Strategic decisions, idea evaluation, challenge protocol | `agents/ceo.md` |
| PM | PRDs, task breakdown, GitHub issues, market research | `agents/pm.md` |
| Dev | Full-stack implementation, PRs, code quality | `agents/dev.md` |
| QA | PR review, security scanning, test coverage | `agents/qa.md` |
| Ops | Deployments, CI/CD, infra monitoring | `agents/ops.md` |
| Designer | UI audit, design system, UX research | `agents/designer.md` |
| Finance | Cost reports, model optimization, budget tracking | `agents/finance.md` |

Each agent has defined responsibilities, idle behavior (what to do when there is no assigned task), and a PoC research mandate.

### Slash Commands

| Command | Purpose |
|---|---|
| `/start-working` | Autonomous work loop — check boards, pick tasks, build, loop |
| `/idea` | Evaluate any idea (feature or new product) via CEO + PM |
| `/issue` | Report a bug — QA verifies first, then creates issue |
| `/add-task` | Quick-add a task to any board (no evaluation) |
| `/launch-product` | Set up repos, board, registry for a new product |
| `/status` | Company-wide status report via Telegram |
| `/daily` | Daily standup across all agents via Telegram |
| `/post-dev` | Post-task review — goal alignment, CI check, decision log |
| `/sync-setup` | Sync live `~/.claude/` config to backup repo |
| `/dev-cycle` | Full development cycle guide (PRD, Build, QA, Deploy) |
| `/poc` | Proof of concept workflow (propose, review, build) |
| `/switch-model` | Switch active Claude model or proxy backend |
| `/auto-route` | Control automatic model routing by task complexity |
| `/learn` | Add a topic to the Learning board |
| `/ai-research` | Weekly AI tech research pipeline |

### Infrastructure

| Component | Purpose |
|---|---|
| **Model proxy** | Free Ollama/OpenRouter fallback when Claude quota hits 95% |
| **Token monitoring** | Usage alerts at 70/90/95% via Telegram, auto-switch at 95% |
| **Telegram integration** | Status reports, alerts, task control, founder ↔ agent communication |
| **Shell aliases** | `work`, `work-free`, `proxy-start`, `model-pick`, etc. |
| **launchd plist** | Auto-start proxy on macOS login |
| **settings.json hooks** | Stop hook for quota monitoring, statusline for usage capture |

---

## Project Boards

| Board | Purpose |
|---|---|
| 1 | Your first product (features, bugs, chores) |
| 2 | Company Ops (infra, tooling, agent improvements) |
| 3 | Ideas (new product pipeline) |
| 4 | Learning |

All boards use GitHub Projects with Status, Priority, Agent, and Size fields.

---

## How It Works

```
/idea "feature or product idea"
  → auto-classifies → CEO evaluates → PM challenges → issue created

/start-working
  → checks all boards → picks top Todo → builds → merges → loops

/launch-product "new app"
  → creates repos → project board → registry entry → seed issues
```

### Development Cycle

```
IDEA → PRD → UI DESIGN → TECH SPEC → BUILD → DESIGN QA → CODE QA → MERGE → DEPLOY → MONITOR
 CEO    PM    Designer     Dev+PM      Dev     Designer     QA        Ops      Ops     Finance
```

### Autonomous Loop

The `/start-working` command runs continuously:
1. Check token quota → route to Ollama if above 90%
2. Read all GitHub Project boards → find highest priority Todo
3. Check for blocked/related issues → gather context
4. Execute the task fully (feature branch → PR → done)
5. Run `/post-dev` review
6. Loop back to step 1

---

## File Structure

```
claude-code-template/
├── agents/                  ← 7 agent definition files
├── commands/                ← 15+ slash commands
│   └── shared/              ← product registry (shared across commands)
├── skills/                  ← skill definitions (idea evaluation)
├── company/                 ← company docs (copy to ~/ai-company/)
│   ├── README.md            ← company handbook
│   ├── AGENTS.md            ← agent directory
│   ├── ROADMAP.md           ← phase plan
│   ├── SESSION_START.md     ← agent orientation guide
│   ├── decisions/           ← ADR templates
│   ├── docs/                ← architecture, design system, quota fallback
│   └── tasks.json.example   ← task queue format
├── memory/                  ← memory file templates
├── usage-monitor/           ← token quota scripts
├── ollama-proxy/            ← free model proxy (LiteLLM)
├── launchd/                 ← macOS auto-start plist
├── settings.json.example    ← Claude Code settings with hooks
├── mcp.json.example         ← MCP server config
├── shell-aliases.sh         ← shell aliases for tmux, proxy, monitoring
├── RUNNING-24-7.md          ← guide for persistent 24/7 operation
├── PROXY_CHEATSHEET.md      ← quick reference for model proxy
└── GITHUB-PROJECTS.md       ← GitHub Projects setup and usage
```

---

## Requirements

- [Claude Code](https://claude.ai/code) (Pro or Max subscription)
- GitHub account with `gh` CLI authenticated
- Telegram bot (optional but recommended — for alerts and communication)
- macOS recommended (launchd for auto-start; Linux works with systemd adaptation)

---

## Customization

### Stack

The template defaults to React + Express + MongoDB + MUI v5, but the agent system is stack-agnostic. To use a different stack:

1. Update `agents/dev.md` with your tech stack
2. Update `agents/designer.md` with your UI framework
3. Update `company/docs/DESIGN_SYSTEM.md`
4. Update the product registry after running `/launch-product`

### Agents

Each agent file in `agents/` can be customized:
- Responsibilities and boundaries
- Idle behavior (what to do when no tasks exist)
- PoC research domains
- Model selection preferences

### Adding MCP Servers

Edit `mcp.json.example` to add servers. Common additions:
- Gmail, Google Calendar (for scheduling)
- Vercel (deployment management)
- Notion (knowledge base)

---

## License

MIT
