# /issue — Report a Bug or Issue

Report a bug: QA verifies it first, then logs it as a GitHub issue if confirmed.

## Usage
`/issue <describe the bug or problem>`

## Steps

### 0. Detect Product

Determine which product this bug is for. See `shared/product-registry.md` for detection rules:
1. **Explicit prefix** — `/issue your-product the modal is broken`
2. **Working directory** — match `$PWD` against product registry
3. **Ambiguous** — ask the user

### 1. QA Verification

Use the `qa` subagent to assess whether the reported behaviour is actually a bug:
- Give QA the description and relevant codebase context (use repos from product registry)
- QA should read the relevant code and determine: is this a real bug, expected behaviour, or a misunderstanding?
- QA returns: confirmed bug / not a bug / needs more info — with reasoning

### 2. If QA confirms it's a bug

Create a GitHub issue:
- Determine the repo from the product registry (frontend for UI/display, backend for API/data). Default to frontend if unclear.
- ```
  gh issue create --repo <repo> --title "<clear bug title>" --body "<body>" --label "bug"
  ```
- Body format:
  ```
  ## What happened
  <user's description>

  ## Expected behaviour
  <what should happen>

  ## Actual behaviour
  <what is happening instead>

  ## Root cause (if identified by QA)
  <file:line or component where the bug lives>

  ## Steps to reproduce
  <inferred from description>
  ```
- Add to the product's project board: `gh project item-add <board> --owner YOUR_GITHUB_USER --url <issue-url>`

### 3. If QA says not a bug

Explain why, no issue created. Optionally suggest what the user might be misunderstanding.

### 4. Report back

- **Product**: which product
- **QA's verdict**: reasoning
- If confirmed: issue title and URL

## Notes
- Always run QA first — don't create issues without verification
- QA should read actual code, not just guess
- Keep issue titles short and specific
- Always add the `bug` label
