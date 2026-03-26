# AI Company — Agent Directory

## Hierarchy

```
         CEO
          ↓
          PM
        ↙  ↓  ↘
     Dev   QA  Ops

     Finance (reports to CEO, monitors all)
```

## Agent Roster

| Agent | File | Trigger |
|---|---|---|
| CEO | ~/.claude/agents/ceo.md | `/idea` workflow, new strategic decision, priority conflict, challenge review, PoC gate |
| PM | ~/.claude/agents/pm.md | Goal → tasks, GitHub issues, PRD updates |
| Dev | ~/.claude/agents/dev.md | Coding, bug fixes, PRs |
| QA | ~/.claude/agents/qa.md | PR review, security scan, test writing |
| Ops | ~/.claude/agents/ops.md | Deploy, infra, CI/CD, incidents |
| Designer | ~/.claude/agents/designer.md | UI review, design system, screenshot audit |
| Finance | ~/.claude/agents/finance.md | Weekly cost report, model optimization |

## Agent Rules (apply to all)

1. **Read context first** — always load ROADMAP.md + relevant docs before acting
2. **Stay in your lane** — do not do another agent's job
3. **Document decisions** — if you make an architectural decision, write an ADR
4. **Log actions** — write daily summary to ~/ai-company/history/YYYY-MM-DD.md
5. **Escalate don't guess** — if requirements are unclear, stop and ask PM/CEO

## CEO — Challenge Protocol

CEO acts as devil's advocate for high-impact agent actions. Challenges are triggered by:

| Trigger | Examples |
|---------|---------|
| Strategic Impact | New products, major features, roadmap changes |
| High Cost | Model usage or ops exceeding thresholds |
| Architecture / PRD Risk | Schema changes, external API integrations |
| Deployment Risk | Hotfixes, production deploys |
| Conflict / Inconsistency | Agents disagree, or outputs contradict past decisions |
| Failure Recurrence | Repeated CI/CD failures, QA blocks, Sentry alerts |

CEO does **not** challenge routine Dev/QA tasks. Challenges logged in `decisions.jsonl` + GitHub comments.

→ Full protocol: `~/.claude/agents/ceo.md`

## State Machine — Who Acts When

```
IDEA         → CEO evaluates → hands off to PM
RESEARCH     → CEO or PM researches
PRD          → PM writes PRD.md
ARCHITECTURE → PM writes ARCHITECTURE.md
BUILD        → Dev implements → creates PR
TEST         → QA reviews PR → approves or requests changes
DEPLOY       → Ops deploys → monitors
MONITOR      → Finance weekly report + Ops uptime
```

## Model Selection (cost control)

| Agent | Default Model | Reason |
|---|---|---|
| CEO | Sonnet | Strategic but not always complex |
| PM | Sonnet | Planning requires reasoning |
| Dev | Sonnet | Standard coding tasks |
| QA | Sonnet | Review requires judgment |
| Ops | Haiku | Config tasks are routine |
| Finance | Haiku | Report generation is templated |

## Communication Protocol

All inter-agent communication goes through **GitHub Issues** or **~/ai-company/tasks/tasks.json**.
Agents do not "call" each other directly — they produce outputs that the next agent reads.

```
CEO writes decision → PM reads and creates issues
PM creates issue → Dev reads and implements
Dev creates PR → QA reads and reviews
QA approves → Ops reads and deploys
All agents → Finance reads logs and generates cost report
```
