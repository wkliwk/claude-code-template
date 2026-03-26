# /dev-cycle — Development Cycle Guide

Every feature moves through this cycle. All agents must follow it. Do not skip steps.

```
IDEA → PRD → UI DESIGN → TECH SPEC → BUILD → DESIGN QA → CODE QA → MERGE → DEPLOY → MONITOR
 CEO    PM    Designer     Dev+PM      Dev     Designer     QA        Ops      Ops     Finance
```

**Key principle: Design before code. Never the reverse.**

UI features follow the full cycle. Backend/infra features skip UI DESIGN and DESIGN QA, going straight PRD → TECH SPEC → BUILD → CODE QA.

---

## Phase Files

Each phase has a dedicated file with full instructions:

| Phase | File | Agents |
|---|---|---|
| Idea → PRD → UI Design → Tech Spec | `/dev-cycle-prd` | CEO, PM, Designer, Dev |
| Build → Design QA | `/dev-cycle-build` | Dev, Designer |
| Code QA → Merge → Deploy → Monitor | `/dev-cycle-qa` | QA, Ops, Finance |

---

## Quick Reference

| Situation | Agent | Action |
|---|---|---|
| New idea from founder | CEO | Evaluate → BUILD/DEFER/REJECT |
| PRD unclear | Dev | Stop, ask PM — never guess |
| PRD approved, UI feature | Designer | Write UI Design doc before any coding |
| UI Design done | PM + Dev | Review and approve design before Tech Spec |
| Implementation done | Designer | Screenshot via Playwright, verify matches design |
| Designer finds CRITICAL mismatch | Designer | Block Code QA, Dev fixes first |
| QA finds CRITICAL bug | QA | Block merge, notify the founder |
| Deploy fails | Ops | Rollback immediately, notify the founder |
| Cost spike | Finance | Alert immediately, identify cause |
| PR open > 2 days | PM | Flag in daily standup |

---

## File Locations

```
Ideas/decisions     → ~/ai-company/decisions/ADR-XXX.md
PRDs                → ~/ai-company/docs/PRD-<feature>.md
Tech specs          → ~/ai-company/specs/TECH-SPEC-<feature>.md
Task queue          → GitHub Project Boards (see shared/product-registry.md)
Daily logs          → ~/ai-company/history/YYYY-MM-DD.md
Agent definitions   → ~/.claude/agents/<agent>.md
```
