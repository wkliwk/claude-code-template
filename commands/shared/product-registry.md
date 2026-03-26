# Product Registry

Shared reference for all commands that need to know about products. Add new rows as products launch via `/launch-product`.

## Products

| Product | CWD match | Repos (frontend, backend) | Board | Context |
|---------|-----------|---------------------------|-------|---------|
| *(add via /launch-product)* | | | | |

## Boards

| Board | Purpose |
|-------|---------|
| 1 | *(your first product)* |
| 2 | Company Ops |
| 3 | Ideas |
| 4 | Learning |

## Product Detection Rules

1. **Explicit prefix** — user specifies product name (e.g. `/idea my-app ...`)
2. **Working directory** — match `$PWD` against CWD match column
3. **Ambiguous** — ask the user which product

## All Product Repos (for cross-product commands)

To iterate over all products, use all repos from the table above. Example:
```bash
# For each product's repos, run the relevant gh commands
```
