# Architecture

## System Overview

```
User (Telegram)
      ↓
Claude Code (CEO/PM/Dev/QA/Ops agents)
      ↓
GitHub (issues, PRs, branches)
      ↓
GitHub Actions (CI/CD)
      ↓
Vercel (frontend) + Railway (backend) + MongoDB Atlas (DB)
```

## Agent Hierarchy

```
CEO Agent
   ↓ (strategy → goal)
PM Agent
   ↓ (PRD → tasks → GitHub issues)
Dev Agent    QA Agent    Ops Agent
   ↓              ↓           ↓
 code           review     deploy
   ↓              ↓
  PR  →  CI  →  merge  →  production
```

## Memory Architecture

```
L1: Runtime context (in prompt — short, task-relevant)
L2: Project docs (~/ai-company/docs/, repo /docs/)
[L3: Vector DB — deferred to Phase 3]

Claude-specific: ~/.claude/projects/<project-path>/memory/
```

## State Machine (Phase 1: manual enforcement)

```
IDEA → RESEARCH → PRD → ARCHITECTURE → BUILD → TEST → DEPLOY
```

## File Structure

```
~/ai-company/
├── ROADMAP.md
├── AGENTS.md
├── decisions/          ← ADR files
├── docs/               ← ARCHITECTURE.md, PRD.md
├── tasks/              ← tasks.json
└── history/            ← daily logs
```

## Current Products

<!-- Add your products here after running /launch-product -->
