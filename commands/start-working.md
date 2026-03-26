# /start-working — Autonomous Work Loop

Check the project boards, pick the highest priority Todo, work on it, then keep going.
Never ask what to work on — always self-direct from the boards.

---

## Step 0 — Check model override and quota

First, check for a manual model override:
```bash
cat ~/.claude/usage-monitor/model-override.json 2>/dev/null
```

- If `model` is a **Claude model** → use that model for all tasks this loop, skip quota routing
- If `model` is an **Ollama model** → force all eligible tasks to Ollama this loop
- If file doesn't exist → fall through to quota-based routing below

Then check quota:
```bash
cat ~/.claude/usage-monitor/usage-cache.json 2>/dev/null
```

Parse `rate_limits.five_hour.used_percentage`:

| Usage | Action |
|---|---|
| < 70% | Proceed normally with Claude |
| 70–89% | Proceed with Claude, but skip any optional/low-priority work this loop |
| ≥ 90% | **Switch to Ollama for all tasks this loop** (see routing rules below) |

### Ollama routing (when quota ≥ 90%)

Only these task types can run on Ollama — all others must be deferred:
- Summarising issues or PRs
- Writing simple scripts / boilerplate
- Generating status reports
- Drafting GitHub issue descriptions

Run them via (use a temp file to avoid shell injection — never pipe raw prompt text with echo):
```bash
PROMPT_FILE=$(mktemp /tmp/ollama-prompt-XXXXXX.txt)
cat > "$PROMPT_FILE" << 'PROMPT_EOF'
<your prompt here>
PROMPT_EOF
bash ~/.claude/usage-monitor/ollama-fallback.sh "$PROMPT_FILE"
rm -f "$PROMPT_FILE"
```

If the task requires complex reasoning, multi-step dev work, or long context — **skip it**, add a GitHub comment `"Deferred: Claude quota at 90%, requires Claude model"`, pick the next task.

---

## Step 1 — Check boards (always do this first)

Check all product boards from `shared/product-registry.md`, plus Company Ops:
```bash
# For each product board in the registry:
gh project item-list <board> --owner YOUR_GITHUB_USER --format json
# Plus Company Ops:
gh project item-list 2 --owner YOUR_GITHUB_USER --format json   # Company Ops
```

Filter for `status: "Todo"` items. Sort by priority: P0 → P1 → P2.

Also read recent context:
```bash
tail -10 ~/Dev/decisions.jsonl 2>/dev/null
```

---

## Step 2 — If Todo items exist

### Parallel Dispatch (Sprint Mode)
Before picking a single task, check if multiple independent tasks can run in parallel:

1. From the Todo list, identify tasks that are:
   - **Not blocked** by any open issue
   - **Not related** to each other (different features/areas)
   - **Assigned to different agent types** (e.g. one frontend, one backend, one ops)

2. If 2-3 independent tasks exist, pick the highest priority one as your **main task** (do it yourself), then dispatch others based on relationship:

   **a) Semi-related tasks → Background Agent (Agent tool)**
   Use when you might need to coordinate or review the result before continuing.
   Worker result (~1-2K tokens) comes back into your context — acceptable overhead.
   ```
   Agent(
     subagent_type = "<agent from issue>",
     model = "<by complexity>",
     isolation = "worktree",
     run_in_background = true,
     prompt = "You are working on issue #<N> in repo YOUR_GITHUB_USER/<repo>.
               Read the issue for acceptance criteria.
               Read CLAUDE.md in the repo.
               Check for related:/parent: tags and read those issues for context.
               Do the work. Commit to a feature branch. Open a PR.
               Leave a structured completion comment on the issue:
               Changes, Decisions, Gotchas, Related context, Next steps."
   )
   ```

   **b) Fully independent tasks → Standalone Session (zero context cost)**
   Use when the task is completely unrelated and you don't need to see the result.
   Launches a separate Claude process — no impact on your context window at all.
   ```bash
   claude -p "You are working on issue #<N> in repo YOUR_GITHUB_USER/<repo>.
     Read the issue for acceptance criteria. Read CLAUDE.md in the repo.
     Check for related:/parent: tags and read those issues for context.
     Do the work. Commit to a feature branch. Open a PR.
     Leave a structured completion comment on the issue.
     Update the project board item to Done." \
     --model <by complexity> \
     --allowedTools "Read,Write,Edit,Bash,Glob,Grep,mcp__github__*" &
   ```
   The `&` runs it in a separate process. Coordination happens via GitHub (issue comments + board status).

   **Decision guide:**
   | Signal | Use |
   |---|---|
   | You might review or re-verify the result | Agent tool (background) |
   | Completely independent, different repo/area | Standalone session |
   | Task spawned reactively (e.g. QA found a bug) | Agent tool (background) |
   | Task from board, no relation to your main work | Standalone session |

3. If all tasks are related or only 1 exists → proceed with single task as normal.

### Single Task Mode
Pick the single highest priority Todo item.

### Dependency & Context Check
Before starting any task, parse the issue body for linkage tags:

**1. Blocked-by (hard dependency):**
Look for `blocked-by: #<number>` in the issue body.
If found:
1. Check if the blocking issue is closed: `gh issue view <number> --repo <repo> --json state -q .state`
2. If the blocking issue is NOT closed: skip this task, log "Skipped #N — blocked by #M (still open)", and pick the next task from the board
3. If the blocking issue IS closed: proceed normally

**2. Related issues (context gathering):**
Look for `related: #<number>, #<number>` in the issue body.
If found:
1. For each related issue, read its **completion comments** (not the full thread — just the last structured comment):
   ```bash
   gh issue view <number> --repo <repo> --json comments --jq '.comments[-1].body'
   ```
2. Extract relevant context: decisions made, gotchas, patterns used
3. Use this context to inform your approach (e.g. reuse same validation library, avoid known pitfalls)

**3. Parent issue (epic context):**
Look for `parent: #<number>` in the issue body.
If found:
1. Read the parent issue body to understand the bigger picture and overall acceptance criteria
2. Check which sibling tasks are already done (via parent's linked issues or project board)
3. Ensure your work is consistent with completed siblings

**Linkage syntax summary** (for PM/issue creation):
- `blocked-by: #12` — hard dependency, must be done first
- `related: #10, #15` — soft link, read for context
- `parent: #8` — this is a sub-task of a larger epic

### Agent Routing
Check agent assignment:
- `frontend-dev` → frontend implementation (React, UI, styling)
- `backend-dev` → backend implementation (API, database, server)
- `ops` → infra/deployment task
- `qa` → testing or security task
- `finance` → cost report or analysis
- `pm` → planning, PRD, or issue creation
- `ceo` → strategic decision or evaluation
- `designer` → UI review, design system task
- `claude-code-manager` → agent maintenance, prompt updates, tooling
- `dev` (legacy) → treat as `backend-dev`
- No agent assigned → use best judgement

Work the task fully:
1. Read the GitHub issue acceptance criteria
2. Read CLAUDE.md in the relevant repo
3. Do the work
4. Commit + push + open PR if code change
5. **Leave a completion comment on the GitHub issue** before closing/moving to Done:
   ```bash
   gh issue comment <number> --repo <repo> --body "$(cat <<'EOF'
   ## Done

   **Changes:**
   - <list files created/modified and what changed>

   **Decisions:**
   - <any non-obvious choices made and why>

   **Gotchas:**
   - <anything surprising, tricky, or easy to break>

   **Related context for future tasks:**
   - <patterns/libraries chosen that sibling tasks should reuse>
   - <shared state or APIs that related tasks depend on>

   **Next steps (if any):**
   - <follow-up work, tracked in #XX>
   EOF
   )"
   ```
   Keep it concise but useful — focus on things not obvious from the diff.
   This serves as task-level memory for future sessions picking up related work.
6. Update task status to Done on the board: `gh project item-edit ...`
7. Append to decisions log: `echo '{"date":"...","project":"...","summary":"..."}' >> ~/Dev/decisions.jsonl`
8. **Run /post-dev** — after EVERY completed task, before picking the next one:
   - Check goal alignment (compare changes against product goal + anti-goals)
   - Verify CI status (`gh run list --limit 3`)
   - Update decisions.jsonl with what was built
   - Output the post-dev review report
   - Only proceed to the next task after /post-dev completes

**After /post-dev completes — immediately loop back to Step 1 without stopping.**

---

## Step 3 — If NO Todo items exist (board is empty)

Do not stop. Run idle behavior based on what has the most value right now:

### Priority order when idle:
1. **Security/bugs first** — scan for any open issues labeled `security` or `bug`
2. **PM** — market research → generate 3-5 new GitHub issues → add to board → start top one
3. **Frontend Dev** — UI audit, component refactoring, accessibility review
4. **Backend Dev** — API audit, performance profiling, missing specs, tech research
5. **QA** — testing coverage audit, write missing tests
6. **Designer** — screenshot production app, UX audit, competitor research
7. **Ops** — infra health check (Railway, Atlas, Vercel, UptimeRobot)
8. **Finance** — cost trend analysis, optimisation proposals
9. **Claude Code Manager** — agent prompt review, slash command maintenance

Pick the most valuable idle task, do it, then loop back to Step 1.

---

## Step 4 — Log the run

After each loop, append one line to the run log:
```bash
echo "$(date '+%Y-%m-%d %H:%M') | loop | <task completed or idle action>" >> ~/ai-company/history/loop-log.txt
```

---

## Error Handling (applies to all gh commands)
1. Check that critical gh commands succeed (`gh issue create`, `gh project item-edit`, `gh project item-create`)
2. On failure: retry once after 5 seconds
3. If still failing: log to `~/ai-company/history/errors.log` and notify via Telegram
4. Never silently continue with missing data — flag incomplete operations

---

## Circuit Breaker

Track consecutive blocked or failed tasks in the current loop session. A task counts as a failure if:
- It was skipped due to being blocked (missing env var, unclear requirement)
- It resulted in an error that could not be resolved
- It was deferred due to quota and no other work was available

**If 3 consecutive tasks are blocked or fail:**
1. Stop the work loop immediately — do not pick the next task
2. Send a Telegram alert: `"Work loop stopped — 3 consecutive task failures. Manual review needed."`
3. Log the stoppage: `echo "$(date '+%Y-%m-%d %H:%M') | CIRCUIT BREAKER TRIPPED — 3 consecutive failures" >> ~/ai-company/history/loop-log.txt`
4. Do not restart automatically — wait for the founder to review

Reset the consecutive failure counter to 0 whenever a task completes successfully.

---

## Background Worker Spawning

During any task, you can spawn background agents to handle parallel work. This avoids blocking your main flow.

### When to spawn a background worker

| Situation | Action |
|---|---|
| QA finds a bug while verifying | Spawn `backend-dev` or `frontend-dev` in background to fix it; continue verifying other items |
| Dev finishes a feature, needs tests | Spawn `qa` in background to write tests; move to next task |
| Any task needs a quick sub-task that a different agent handles better | Spawn the appropriate agent type in background |
| PM creates issues and top one is ready to build | Spawn `dev` in background; PM continues refining remaining issues |

### How to spawn

```
Agent(
  subagent_type = "backend-dev",      ← match the work type
  model = "haiku",                    ← pick model by complexity (see table below)
  isolation = "worktree",             ← always use worktree for code changes
  run_in_background = true,           ← don't block main flow
  prompt = "Fix the validation bug in #45. Read the issue and its related
            issues for context. Commit to a feature branch, open a PR,
            and leave a completion comment on #45."
)
```

### Model routing for workers

Pick the cheapest model that can handle the task:

| Task complexity | Model | Examples |
|---|---|---|
| Simple / mechanical | `haiku` | One-liner fix, add a label, write boilerplate test, update docs |
| Moderate | `sonnet` | New endpoint with validation, refactor a component, write integration tests |
| Complex / architectural | `opus` (or omit to inherit) | Multi-file refactor, new feature with edge cases, security-sensitive changes |

### Rules for background workers
- **Always use `isolation: "worktree"`** for any agent that writes code — prevents git conflicts with your main work
- **Max 2 background workers at a time** — avoid quota spikes and rate limits
- **Give full context in the prompt** — the worker has no access to your conversation history; include issue number, repo, and what to do
- **Include linkage instructions** — tell the worker to read `related:` issues for context and leave a completion comment when done
- **Don't spawn for trivial fixes** — if it's a 2-line change, just do it yourself
- When a background worker completes, review its output before moving on — don't blindly trust

---

## Rules
- Never ask "what should I work on?" — always figure it out from boards
- Never stop mid-flow — after finishing one task, immediately check for the next
- Never start a task without reading its acceptance criteria
- Never push to main directly — always feature branch + PR
- If blocked on a task (missing env var, unclear requirement) → skip it, pick next Todo, log the blocker as a GitHub comment with details (what's missing, what was tried, suggested fix)
- Always check quota (Step 0) at the start of every loop — never skip it
- If quota ≥ 90%, route eligible tasks to Ollama; defer the rest — never attempt complex work on Ollama
