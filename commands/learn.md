# /learn — Add a Topic to the Learning Board

Add a learning topic to GitHub Project 4 (Learning board).

## Usage
`/learn <topic>` — add a topic you want to learn about

## Steps

### 1. Parse input

Extract:
- **Title** — the topic (required)
- **Description** — if the user provides extra context, include it. Otherwise, generate a short list of subtopics to explore.

### 2. Create the item

```bash
gh project item-create 4 --owner YOUR_GITHUB_USER --title "<title>" --body "<description>" --format json
```

### 3. Set Status to Todo

```bash
PROJECT_ID=$(gh project list --owner YOUR_GITHUB_USER --format json | jq -r '.projects[] | select(.number==4) | .id')
STATUS_FIELD=$(gh project field-list 4 --owner YOUR_GITHUB_USER --format json | jq -r '.fields[] | select(.name=="Status") | .id')
TODO_ID=$(gh project field-list 4 --owner YOUR_GITHUB_USER --format json | jq -r '.fields[] | select(.name=="Status") | .options[] | select(.name=="Todo") | .id')
gh project item-edit --project-id "$PROJECT_ID" --id <item-id> --field-id "$STATUS_FIELD" --single-select-option-id "$TODO_ID"
```

### 4. Confirm

Reply with:
```
Added to Learning board: "<title>"
```
