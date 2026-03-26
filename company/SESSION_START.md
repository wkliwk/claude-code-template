# SESSION_START — Agent Orientation Guide

> Read this at the start of every new Claude Code session before doing any work.

---

## 1. Who You Are

You are an AI agent in a solo AI company. The founder's GitHub is YOUR_GITHUB_USER.
Your role depends on the task — check which agent persona applies (CEO / PM / Dev / QA / Ops / Designer / Finance).
Agent definitions: `~/.claude/agents/`

---

## 2. Current Product

<!-- Fill in after running /launch-product -->
**Your Product** — description here.
- Frontend: `github.com/YOUR_GITHUB_USER/your-product-frontend`
- Backend: `github.com/YOUR_GITHUB_USER/your-product-backend`
- Phase: **Phase 1 MVP** — ship working product, no over-engineering

---

## 3. Load Context In This Order

```
1. ~/ai-company/ROADMAP.md         ← current phase + goals
2. ~/ai-company/AGENTS.md          ← agent rules + state machine
3. ~/ai-company/tasks/tasks.json   ← current task queue
4. ~/ai-company/decisions/         ← ADRs (skim titles, read relevant ones)
5. ~/.claude/projects/memory/      ← persistent memory (user prefs, project context)
```

---

## 4. Check Task Queue Before Starting

```bash
cat ~/ai-company/tasks/tasks.json
```

Pick the highest-priority task that is `"status": "todo"` and matches your agent role.
Do not start work without a task. If no tasks exist, ask PM to create them.

---

## 5. Branch Strategy

```
main        ← production (never push directly)
develop     ← integration branch
feature/*   ← your working branch (open PRs to develop)
hotfix/*    ← emergency fixes to main only
```

Always create a `feature/<short-name>` branch. Never commit to main directly.

---

## 6. Key Constraints

| Rule | Detail |
|---|---|
| No hardcoded secrets | Use env vars. Never commit `.env` |
| No `any` types | TypeScript strict mode on |
| No custom CSS | Use MUI v5 components only |
| No skipping QA | Every PR needs QA review before merge |
| No guessing requirements | Stop and ask PM/CEO if unclear |

---

## 7. When You Finish a Task

1. Update `~/ai-company/tasks/tasks.json` → set status to `"done"`
2. Write daily log to `~/ai-company/history/YYYY-MM-DD.md`
3. If architectural decision made → write ADR to `~/ai-company/decisions/`
4. Open PR → assign QA for review

---

## 8. Communication

- All agent outputs go to GitHub Issues or `tasks/tasks.json`
- Agents do not call each other directly
- Notify the founder via Telegram for: PR ready for review, deploy complete, blocker found

---

## 9. Auto-Start Loops (run at every session start)

These crons are session-only — they must be re-registered on every new Claude session.
Run these immediately after reading this file:

### Work loop (every 30 min)
```
/loop 30m /start-working
```
Checks board → picks top Todo → works → loops. Keeps agents active between your messages.

### Daily standup (9:03am)
```
/loop 24h /daily
```
Sends per-agent standup report to Telegram every morning.

### Token monitor (every 2h)
Check loop-log.txt every 2 hours and alert if run frequency is too high:
Use CronCreate with cron `7 */2 * * *` and prompt:
"Count START entries in ~/ai-company/history/loop-log.txt from last 2 hours.
If >3 runs/hour consistently, send Telegram alert to YOUR_TELEGRAM_CHAT_ID: 'Token Monitor: loop running too frequently — consider adjusting interval'.
Log result to loop-log.txt."
