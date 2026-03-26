# /launch-product — Set Up a New Product for Development

Take an approved product idea and set up everything needed for development to start.

## Usage
`/launch-product <product name>`

The product should already exist on the Ideas board (Project 3) with Stage: Approved. If not, run `/new-product` first.

## Steps

### 1. Verify Approval

Check Project 3 (Ideas board) for the product:
```bash
gh project item-list 3 --owner YOUR_GITHUB_USER --format json
```
Confirm the product exists and Stage is Approved. If not found or not approved, stop and explain.

### 2. Create GitHub Repos

Ask the founder which repos are needed (e.g. frontend, backend, mobile, monorepo). Then create them:
```bash
gh repo create YOUR_GITHUB_USER/<product-name>-frontend --public --description "<one-liner>"
gh repo create YOUR_GITHUB_USER/<product-name>-backend --public --description "<one-liner>"
```

### 3. Create Project Board

```bash
gh project create --owner YOUR_GITHUB_USER --title "<Product Name>"
```
Note the board number returned.

Add standard fields (Status, Priority, Agent, Size) if not auto-created.

### 4. Update Product Registry

Add the new product to `~/.claude/commands/shared/product-registry.md`:
- Product name
- CWD match pattern (e.g. the repo name prefix)
- Repos (from Step 2)
- Board number (from Step 3)
- Context string for CEO evaluation

This step is critical — all slash commands (`/idea`, `/issue`, `/add-task`, `/status`, `/daily`, `/start-working`) read from this registry.

### 5. Create CLAUDE.md in Each Repo

Create a CLAUDE.md with:
- Tech stack
- Key files / architecture
- Product goal + anti-goals
- Build/test/deploy commands
- Link to the other repo(s)
- Context and decisions.jsonl instructions

### 6. Update Ideas Board

Set the product's Stage on Project 3 to **Launched**:
```bash
gh project item-edit --project-id <ideas-project-id> --id <item-id> \
  --field-id <stage-field-id> --single-select-option-id <launched-option-id>
```

### 7. Seed Initial Issues

Create 3–5 starter issues from the PRD outline (written during `/new-product`):
- Setup tasks (CLAUDE.md, CI, deploy)
- Core MVP features
- Add each to the new project board with priority and agent

### 8. Report Back

- **Product**: name
- **Repos**: links
- **Board**: number + link
- **Registry**: updated
- **Initial issues**: list with links

## Notes
- This is a one-time setup — run once per product
- After this, `/start-working` will automatically pick up tasks from the new board
- Don't forget Step 4 — without it, no command knows about the product
