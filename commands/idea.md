# /idea — Evaluate an Idea

Single entry point for all ideas — features, improvements, or entirely new products. Auto-detects the type and routes accordingly.

## Usage
`/idea <description>`

## Steps

### 0. Classify

Read the input and classify:

**Feature** — enhances an existing product (e.g. "add dark mode", "split charts into separate tab")
- Detect which product from CWD or explicit mention (see `shared/product-registry.md`)
- If product is ambiguous, ask

**New product** — a standalone product or app (e.g. "AI wardrobe recommendation app", "coach booking platform")
- If the input is a raw problem, shape it into a product concept first: what product solves this? Who uses it? What's the core mechanic?

**Ambiguous** — could be either (e.g. "receipt scanning")
- Ask: "Is this a feature for [detected product] or a new standalone product?"

### 1. CEO + PM Evaluation

Run the shared evaluation flow from `_evaluate-idea.md`:

**For features:**
- CONCEPT: `<description>`
- CONTEXT: `<context from product registry>`
- TARGET_BOARD: `<product board from registry>`

**For new products:**
- CONCEPT: `<shaped concept>`
- CONTEXT: "new standalone product — evaluate on product merit only, not resource constraints"
- TARGET_BOARD: 3 (Ideas)
- PM should also write a lightweight PRD outline: problem, target user, core features (3–5), out of scope, open questions

### 2. Board Action

**Feature — approved/backlog:**
- Create GitHub issue in the product's repo (frontend vs backend, pick most relevant)
- Add to the product's project board
```bash
gh issue create --repo <repo> --title "..." --body "..."
gh project item-add <board> --owner YOUR_GITHUB_USER --url <issue-url>
```

**New product — approved/backlog:**
- Create draft on Ideas board (Project 3)
```bash
gh project item-create 3 --owner YOUR_GITHUB_USER --title "<title>" --body "<concept + PRD outline>"
```
- Set Stage: Approved or Inbox (backlog)
- When ready to build: run `/launch-product <name>`

**Rejected:** Explain why. Nothing created.

### 3. Report Back

- **Type**: feature for [product] / new product
- **Shaped from**: (only if raw problem was shaped into concept)
- **CEO's take**: verdict + rationale
- **PM's take**: challenge/agreement + PRD outline (new products only)
- **Final decision**: build / backlog / reject
- **Link**: issue or board item URL (if created)

## Notes
- Both CEO and PM always evaluate — never skip the PM challenge
- PM wins on scope/complexity disputes; CEO wins on strategic rejects
- Never reject for resource/timing reasons — the founder controls priority
- When in doubt, default to Backlog
