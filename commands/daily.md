# /daily — Daily Standup Report

Generate a daily standup for the founder covering every agent: what they did, what they're doing now, and what's next. Send to Telegram.

---

## Steps

### 1. Gather data (run all in parallel)

**Git activity — last 24h (for each product in `shared/product-registry.md`):**
```bash
# For each repo in the product registry:
gh api repos/<owner>/<repo>/commits?per_page=10
gh pr list --repo <owner>/<repo> --state all --limit 10
```

**Project boards (all product boards + Company Ops):**
```bash
# For each product board in the registry:
gh project item-list <board> --owner YOUR_GITHUB_USER --format json
# Plus Company Ops:
gh project item-list 2 --owner YOUR_GITHUB_USER --format json   # Company Ops
```

**PoC proposals (new since yesterday, across all product repos):**
```bash
# For each repo in the product registry:
gh issue list --repo <owner>/<repo> --label "poc" --state open
```

**Recent agent activity logs:**
```bash
ls -t ~/ai-company/history/ | head -10
# Read the most recent history files (last 24h) for agent activity
```

**Recent decisions:**
```bash
tail -10 ~/Dev/decisions.jsonl 2>/dev/null || echo "no decisions log"
```

---

### 2. Build the report

For each agent, determine:
- **Done**: what they completed in the last 24h (from commits, closed issues, history files)
- **Now**: what they are actively working on (in_progress tasks, open PRs)
- **Next**: their top planned task (highest priority Todo assigned to them)
- **Idle work**: if no assigned task, what idle research/audit they ran

```
🌅 Daily Standup — {YYYY-MM-DD}
━━━━━━━━━━━━━━━━━━━━━━━━━━━

👑 CEO
  Done: {decisions made, PoCs reviewed}
  Now:  {any pending PoC reviews or conflicts}
  Next: {strategic reviews queued}

🧠 PM
  Done: {PRDs written, issues created, market research}
  Now:  {active planning work}
  Next: {next planning task or market research topic}

💻 Dev
  Done: {commits, PRs opened/merged}
  Now:  {current feature branch or audit in progress}
  Next: {next Todo issue assigned to dev}

🔍 QA
  Done: {PRs reviewed, tests written, security scans}
  Now:  {PR under review or testing framework work}
  Next: {next PR to review or test coverage target}

🎨 Designer
  Done: {UI audits, design docs, competitor research}
  Now:  {current audit or design work}
  Next: {next screen to audit or UX research topic}

⚙️ Ops
  Done: {deployments, infra changes, CI fixes}
  Now:  {infra health status}
  Next: {next infra task}

💰 Finance
  Done: {cost reports, alerts configured}
  Now:  {cost monitoring}
  Next: {next weekly report date}

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Board Summary
  {for each product board}: {X} Todo / {Y} In Progress / {Z} Done
  Company Ops (Project 2): {X} Todo / {Y} In Progress / {Z} Done

🔬 PoC Pipeline
  Pending CEO review: {list or "none"}
  Approved / In progress: {list or "none"}

🚨 Blockers & Needs Your Action
  {anything requiring the founder's manual input}
  {P0 issues, failed CI, infra limits approaching}

💰 Cost Pulse
  Budget: <$35/month | Claude Pro: $20/mo fixed
  {any alerts or approaching limits}
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 3. Send to Telegram

Send to chat_id `YOUR_TELEGRAM_CHAT_ID` with Markdown formatting.

```python
# Use mcp__plugin_telegram_telegram__reply tool
# chat_id: YOUR_TELEGRAM_CHAT_ID
# Format: use *bold* for section headers, plain text for content
```

---

### 4. Save report locally

```bash
# Save to history
cat > ~/ai-company/history/{YYYY-MM-DD}-standup.md << 'EOF'
{full report content}
EOF
```

---

## Error Handling (applies to all gh commands)
1. Check that critical gh commands succeed (`gh issue create`, `gh project item-edit`, `gh project item-create`)
2. On failure: retry once after 5 seconds
3. If still failing: log to `~/ai-company/history/errors.log` and notify via Telegram
4. Never silently continue with missing data — flag incomplete operations

## Tone & Format Rules
- Concise — this is a standup, not a novel
- If an agent has nothing to show: `Idle — running [audit type]`
- If an agent is blocked: flag it clearly with 🚨
- If a board is empty: note it — that's a signal PM/CEO should generate work
- Always include the PoC pipeline — this is how the founder sees innovation moving
- Always flag anything needing manual action from the founder

## Schedule
Run every day at 09:00 via cron.
