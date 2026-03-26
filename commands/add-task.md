# /add-task — Add a Task to GitHub Project Board

Add one or more tasks to the correct GitHub Project board with all required fields set.

Usage:
- `/add-task <description>` — add a single task (Claude infers board, priority, agent, size)
- `/add-task` — interactive mode, Claude asks for details if ambiguous

---

## Step 1 — Parse input

Extract from the user's message:
- **Title** — the task description (required)
- **Board** — infer from context (see `shared/product-registry.md` for full mapping):
  - Product features/bugs → use the product's board and repos from the registry (detect product from CWD or explicit mention)
  - Company Ops / infra / setup / agents / scripts → Project 2 (owner: YOUR_GITHUB_USER, number: 2), draft item (no repo)
  - New product ideas → Project 3 (owner: YOUR_GITHUB_USER, number: 3), draft item
- **Priority** — infer from keywords:
  - "critical", "broken", "security", "data loss" → P0
  - "blocker", "important", "need" → P1
  - "improve", "optimize", "refactor" → P2
  - "nice to have", "polish", "low" → P3
  - Default: P2
- **Agent** — infer from task type:
  - UI/frontend/design → dev or designer
  - Backend/API/infra/scripts/ops → ops or dev
  - Planning/PRD/research → pm
  - Review/testing/security → qa
  - Cost/billing/spend → finance
  - Strategy/decisions → ceo
- **Size** — infer from scope:
  - One-liner fix, config change → S
  - New feature, moderate refactor → M
  - Major feature, multi-file work → L
  - Default: M

- **Linkage** — infer from context or user input:
  - `blocked-by: #<number>` — if the task cannot start until another issue is done
  - `related: #<number>, #<number>` — if the task touches the same feature/area as existing issues
  - `parent: #<number>` — if this is a sub-task of a larger epic
  - To find related issues, check the board for open issues in the same area:
    ```bash
    gh issue list --repo YOUR_GITHUB_USER/<repo> --state open --json number,title --jq '.[] | "\(.number) \(.title)"'
    ```
  - If no linkage is obvious, omit — don't force it

If any field is genuinely ambiguous, ask the user before proceeding.

---

## Step 2 — Get project ID

```bash
gh project list --owner YOUR_GITHUB_USER --format json
```

Pick the matching project by number.

---

## Step 3 — Create the item

For Project 1 or 3 (repo-linked), create a GitHub issue first.

The issue body MUST include linkage tags (if any) at the top, followed by acceptance criteria:
```markdown
blocked-by: #12
related: #10, #15
parent: #8

## Acceptance Criteria
- [ ] ...
```

```bash
gh issue create --repo YOUR_GITHUB_USER/<repo> --title "<title>" --body "<body>" --label ""
```
Then add the issue to the project:
```bash
gh project item-add <number> --owner YOUR_GITHUB_USER --url <issue-url>
```

For Project 2 (Company Ops, draft items):
```bash
gh project item-create 2 --owner YOUR_GITHUB_USER --title "<title>"
```

Capture the item ID from output.

---

## Step 4 — Set fields

Get field and option IDs:
```bash
gh project field-list <number> --owner YOUR_GITHUB_USER --format json
```

Then set Status, Priority, Agent, Size:
```bash
gh project item-edit --project-id <project-id> --id <item-id> \
  --field-id <status-field-id> --single-select-option-id <todo-option-id>

gh project item-edit --project-id <project-id> --id <item-id> \
  --field-id <priority-field-id> --single-select-option-id <priority-option-id>

gh project item-edit --project-id <project-id> --id <item-id> \
  --field-id <agent-field-id> --single-select-option-id <agent-option-id>

gh project item-edit --project-id <project-id> --id <item-id> \
  --field-id <size-field-id> --single-select-option-id <size-option-id>
```

For Project 3 (Ideas board), also set Stage=Inbox and Category if inferable.

---

## Step 5 — Confirm

Reply with a one-line confirmation:
```
✓ Added to Project <N>: "<title>" — <Priority> · <Agent> · <Size>
```

Include the item URL if available.

---

## Multiple tasks

If the user provides a list, repeat Steps 3–4 for each item in sequence. Confirm all at the end with a summary table.
