# AI Company — Company Handbook

> A solo AI company where AI agents handle 24/7 product development.
> The human founder sets direction. Agents execute.

---

## Table of Contents
1. [Vision & Model](#1-vision--model)
2. [Agent Team](#2-agent-team)
3. [How We Work](#3-how-we-work)
4. [Technology Stack](#4-technology-stack)
5. [Cost & Finance](#5-cost--finance)
6. [Products](#6-products)
7. [Roadmap](#7-roadmap)
8. [File Structure](#8-file-structure)
9. [Key Rules](#9-key-rules)

---

## 1. Vision & Model

**Vision:** Build software products autonomously using AI agents, with minimal human intervention.

**Operating Model:**
```
Founder
    ↓ sets direction via Telegram
Claude Code (AI agents)
    ↓ plans, builds, reviews, deploys
GitHub + Cloud
    ↓ version control + production
Running product
```

**Founder's role:** Director — sets goals, approves major decisions, reviews deploys.
**Agents' role:** Everything else — research, plan, code, review, deploy, monitor.

---

## 2. Agent Team

### Hierarchy
```
         CEO
          ↓
          PM  ←── brain of the system
        ↙  ↓  ↘
     Dev   QA  Ops

  Designer        Finance
  (UI review)     (cost control)
```

### Roster

| Agent | Responsibility | When to Use |
|---|---|---|
| **CEO** | Strategy, idea evaluation, prioritization | New idea, major decision, conflict |
| **PM** | PRD, task breakdown, GitHub issues | Goal → concrete tasks |
| **Dev** | Write code, create PRs | Any coding task |
| **QA** | PR review, security, testing | Before every merge |
| **Ops** | Deploy, CI/CD, infra, incidents | Deployment, infra setup |
| **Designer** | UI review, design system, screenshots | UI consistency audit |
| **Finance** | Token cost, cloud spend, optimization | Weekly report, cost spike |

→ Full details: `AGENTS.md`
→ Agent files: `~/.claude/agents/`

---

## 3. How We Work

### Starting a New Session
Before working, read `SESSION_START.md` for context on current state.

### Communication Channel
**Telegram → Claude Code** is the primary interface.
Founder sends instruction via Telegram → Claude acts as the appropriate agent.

### Daily Workflow
```
Founder sends task via Telegram
    ↓
CEO agent evaluates (build now / defer / reject)
    ↓
PM agent creates GitHub issues with acceptance criteria
    + adds to GitHub Project board
    ↓
Dev agent implements on feature branch
    ↓
QA agent reviews PR (security + correctness)
    ↓
Ops agent deploys after merge
    ↓
Telegram notification: deployed / failed
```

### Project Lifecycle States
```
IDEA → RESEARCH → PRD → ARCHITECTURE → BUILD → TEST → DEPLOY → MONITOR
```
Each state has a designated agent. Agents must not skip states.

→ Full state machine: `decisions/ADR-002-state-machine.md`

### Branch Strategy
```
main        ← production (protected, CI required)
develop     ← integration
feature/*   ← Dev agent works here, opens PRs to develop
hotfix/*    ← emergency fixes to main
```

### PR Process
1. Dev creates PR from `feature/*` to `develop`
2. QA agent reviews → APPROVE or REQUEST CHANGES
3. CI must pass (TypeScript + tests)
4. Ops deploys after merge to `main`

### Decision Logging
Every major architectural or product decision is logged as an ADR (Architecture Decision Record).
→ Location: `decisions/ADR-XXX-name.md`

---

## 4. Technology Stack

### Development Tools
| Tool | Role |
|---|---|
| Claude Code | AI coding assistant + agent runtime |
| Telegram | Founder ↔ Claude communication |
| GitHub | Version control, issues, PRs |
| GitHub Actions | CI/CD pipeline |

### Skills (slash commands)
Built-in Claude Code skills available in every session:

| Skill | Trigger | What it does |
|---|---|---|
| `/start-working` | "start working" | Board check → pick top Todo → work autonomously |
| `/new-product` | `/new-product <idea>` | Capture + evaluate idea → CEO → PM → Ideas board |
| `/dev-cycle` | `/dev-cycle` | Full development cycle guide |
| `/post-dev` | `/post-dev` | Post-development review |
| `/poc` | `/poc` | Proof of concept workflow |
| `/daily` | `/daily` | Daily standup report |
| `/status` | `/status` | AI company status report |
| `/idea` | `/idea` | Evaluate a feature idea |
| `/issue` | `/issue` | Report a bug or issue |
| `/switch-model` | `/switch-model` | Switch active Claude model |

### MCP Servers (active)
| Server | Role |
|---|---|
| Figma | Read/write Figma designs → code; used by Designer agent |
| Playwright | Browser screenshots, UI automation |
| GitHub | Issues, PRs, branches, code search |
| Telegram | Founder ↔ agent communication |

### Cloud Infrastructure (all free/low-cost)
| Service | Role | Tier |
|---|---|---|
| Vercel | Frontend hosting | Free |
| Railway | Backend hosting | ~$5/mo |
| MongoDB Atlas | Database | Free M0 |
| Sentry | Error tracking | Free |
| UptimeRobot | Uptime monitoring | Free |

→ Full infra decisions: `decisions/ADR-004-infra-stack.md`

### Agent Memory System
```
L1 Runtime context    — in prompt (short, task-relevant)
L2 Project docs       — ~/ai-company/docs/ + repo /docs/
Claude memory         — ~/.claude/projects/memory/ (user prefs, project context)
[L3 Vector DB]        — deferred to Phase 3
```

**Core rule:** LLM is stateless. All state must be persisted externally.
→ Full memory decisions: `decisions/ADR-003-memory-system.md`

---

## 5. Cost & Finance

### Current Setup
- **Claude Code Pro** ($20/month) — development subscription
- **Target total:** < $35/month (Phase 1)

### Model Selection Strategy
| Task type | Model | Cost |
|---|---|---|
| Routine (Ops, Finance reports) | Haiku API | ~$0.80/1M |
| Standard coding, planning, review | Sonnet (subscription) | included |
| Complex architecture decisions | Sonnet or Opus (sparingly) | included |

**Cost ratio: Haiku is ~19x cheaper than Opus.**

### Token Quota Monitoring & Auto-Fallback
Automatic mechanism to prevent hitting the hard quota limit mid-task.

| Usage | Action |
|---|---|
| >= 70% | Telegram warning |
| >= 90% | Telegram critical alert |
| >= 95% | Auto-switch `claude-work` tmux session to free proxy |

- **Trigger:** Stop hook (after every response) + cron every 30 min as safety net
- **Fallback model:** OpenRouter → `qwen/qwen3-coder` via local proxy on port 8082
- **Session resumes automatically** — no work is lost

→ Full details: `docs/TOKEN-QUOTA-FALLBACK.md`

### Upgrade Rule
> If API-equivalent Claude usage > $80/month for 2 consecutive months → upgrade to Max $100.

### Finance Agent runs weekly
Reports saved to: `history/YYYY-MM-DD-cost-report.md`

→ Full finance decisions: `decisions/ADR-006-finance-agent.md`

---

## 6. Products

<!-- Add your products here after running /launch-product -->

### Your Product (placeholder)
**Description:** Replace with your product description.

**Repos:**
- Frontend: `github.com/YOUR_GITHUB_USER/your-product-frontend`
- Backend: `github.com/YOUR_GITHUB_USER/your-product-backend`

**Design system:** `docs/DESIGN_SYSTEM.md`

---

## 7. Roadmap

→ Full roadmap: `ROADMAP.md`

---

## 8. File Structure

```
~/ai-company/
├── README.md              ← YOU ARE HERE (company handbook)
├── AGENTS.md              ← agent roster + rules + state machine
├── ROADMAP.md             ← phase plan
├── SESSION_START.md       ← agent orientation (read at session start)
│
├── decisions/             ← Architecture Decision Records (ADRs)
│   ├── ADR-001            Agent hierarchy
│   ├── ADR-002            State machine
│   ├── ADR-003            Memory system
│   ├── ADR-004            Infrastructure stack
│   ├── ADR-005            Agent autonomy model
│   └── ADR-006            Finance agent + cost model
│
├── docs/
│   ├── ARCHITECTURE.md          ← system architecture diagram
│   ├── PRD-your-product.md      ← product requirements (create per product)
│   ├── DESIGN_SYSTEM.md         ← UI tokens + component rules
│   └── TOKEN-QUOTA-FALLBACK.md  ← quota monitoring + auto-switch mechanism
│
├── tasks/
│   └── tasks.json         ← task queue with status
│
└── history/               ← daily logs + cost reports

~/Dev/
├── decisions.jsonl        ← append-only log of agent decisions (per task)
├── your-product-frontend/ ← React app (Vercel)
└── your-product-backend/  ← Express API (Railway)

~/.claude/
├── agents/                ← agent definition files
├── commands/              ← slash commands
├── skills/                ← skill definitions
├── ollama-proxy/          ← LiteLLM proxy server (port 8082)
├── usage-monitor/         ← token quota monitoring scripts
├── channels/telegram/     ← Telegram plugin config
└── projects/<project-path>/memory/  ← Claude persistent memory
```

---

## 9. Key Rules

These rules apply to the entire company and all agents:

1. **LLM is stateless — persist everything**
   State, decisions, logs, context must be written to files. Never rely on memory.

2. **Stay in your lane**
   Each agent has a defined role. Do not do another agent's job.

3. **Document every major decision as ADR**
   If you make an architectural decision, write it in `decisions/`.

4. **PM owns the task queue**
   No Dev agent starts work without a GitHub issue from PM with acceptance criteria.

5. **QA reviews every PR**
   No merge without QA approval. CRITICAL issues block merge — no exceptions.

6. **Simplicity over complexity**
   Phase 1 = MVP. Do not over-engineer. Defer Phase 2/3 features.

7. **Max 7 agents**
   Do not add agents without CEO approval and Finance cost assessment.

8. **Finance reviews weekly**
   Cost visibility is non-negotiable for a sustainable AI company.
