# GitHub Projects — Task & Project Management

GitHub Projects is the single source of truth for all work across the AI company.
Agents read from it to decide what to work on, and write to it as work progresses.

---

## The 3 Boards

| # | Board | Purpose | Repo |
|---|---|---|---|
| 1 | **Product** (e.g. Your Product) | Active feature/bug/chore tasks | product repo |
| 2 | **Company Ops** | Infrastructure, tooling, agent improvements | ops repo or no repo |
| 3 | **Ideas** | New product idea pipeline | ideas repo |

---

## Board 1 & 2 — Work Boards

### Columns (status field)
```
Todo → In Progress → In Review → Done
```

### Required Fields per Item

| Field | Values | Who sets it |
|---|---|---|
| **Status** | Todo / In Progress / In Review / Done | Agent updates as work progresses |
| **Priority** | P0 / P1 / P2 | PM sets at creation |
| **Agent** | dev / qa / ops / pm / finance / designer | PM assigns |
| **Size** | S / M / L | PM estimates |

### Agent Workflow

Every task starts as a GitHub Issue with acceptance criteria, then gets added to the board.

```bash
# Create issue
gh issue create --repo YOUR_USERNAME/repo --title "feat: X" --body "..."

# Add to project board
gh project item-add 1 --owner YOUR_USERNAME --url <issue-url>

# Update status as work progresses
gh project item-edit --id <item-id> --field-id <status-field-id> \
  --project-id <project-id> --single-select-option-id <option-id>
```

### How `/start-working` Uses the Boards

At the start of every loop:
```bash
gh project item-list 1 --owner YOUR_USERNAME --format json  # Product board
gh project item-list 2 --owner YOUR_USERNAME --format json  # Ops board
```

Filters for `status: "Todo"`, sorts by Priority (P0 first), picks the top item and starts immediately.
After completion, updates status to `Done` and loops back.

---

## Board 3 — Ideas Pipeline

Tracks new product ideas from raw concept through evaluation to approved/dropped.

### Stages (status field)
```
Inbox → CEO Evaluating → PM Researching → Approved → Building → Shipped
                                        ↘ Dropped
```

### Required Fields

| Field | Values |
|---|---|
| **Stage** | Inbox / CEO Evaluating / PM Researching / Approved / Building / Shipped / Dropped |
| **Category** | App / Tool / Service / Integration |
| **Priority** | High / Medium / Low |

### `/new-product` Workflow

```
/new-product <idea description>
    ↓
CEO evaluates (product merit only — never dropped for resource reasons)
    ↓
PM researches market fit, scope, differentiation
    ↓
GitHub issue created (draft, no repo required)
    ↓ added to Board 3 at appropriate stage
```

Ideas are never dropped because "we're busy" — that's the founder's call, not agents'.

---

## Key Rules for Agents

1. **Never start work without a board item** — PM creates the issue + board item first
2. **Always update status** — move Todo → In Progress when starting, Done when finished
3. **Every task gets Priority + Agent + Size** — board is useless without these fields
4. **Board 3 is draft issues only** — no code until idea reaches Approved and a product board is created
5. **`tasks.json` mirrors the board** — PM keeps both in sync

---

## Useful Commands

```bash
# List all Todo items on board 1
gh project item-list 1 --owner YOUR_USERNAME --format json | \
  jq '.items[] | select(.status == "Todo") | {title, priority: .fieldValues}'

# Add a new issue to the board
gh project item-add 1 --owner YOUR_USERNAME --url https://github.com/YOUR_USERNAME/repo/issues/42

# Get project and field IDs (needed for item-edit)
gh project field-list 1 --owner YOUR_USERNAME --format json

# Close a completed issue
gh issue close 42 --repo YOUR_USERNAME/repo --comment "Completed in PR #45"
```

---

## Why GitHub Projects (not Jira, Linear, Notion, etc.)

- **Agents already use `gh` CLI** for issues and PRs — zero extra tooling
- **GitHub MCP** gives Claude direct read/write access to issues and project items
- **Free** — no extra cost at any scale
- **Single source of truth** — issues, PRs, and board items all linked automatically
