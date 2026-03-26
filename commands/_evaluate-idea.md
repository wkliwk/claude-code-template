# _evaluate-idea — Shared CEO + PM Evaluation Flow

Internal shared flow used by `/idea` and `/new-product`. Not invoked directly.

Parameters passed by the calling command:
- `CONCEPT`: the shaped product/feature concept to evaluate
- `CONTEXT`: context for CEO (e.g. "Your Product feature" or "new standalone product")
- `TARGET_BOARD`: GitHub Project board to add approved items to (see shared/product-registry.md for board mapping)

---

## Step 1 — CEO Evaluation

Use the `ceo` subagent to make an initial build/backlog/reject decision.

CEO should assess:
- Is there a real user problem being solved?
- Strategic fit: revenue, reputation, community, or morale value?
- Phase alignment (Phase 1/2/3)?
- For features: implementation complexity vs user value
- For products: market potential and differentiation

CEO returns: decision (build/backlog/reject) + 2–3 sentence rationale.

**Token efficiency:** CEO reasons only — no files written, no GitHub issues created yet.

---

## Step 2 — PM Challenge

Use the `pm` subagent. Show PM the concept AND the CEO's decision + rationale.

PM should ask:
- Does the CEO's reasoning hold up?
- Are there user needs being overlooked?
- Is complexity being over- or under-estimated?
- Is there a simpler version worth building?

PM returns: agree/disagree with CEO + revised recommendation if different.

**Token efficiency:** PM reasons only — no files written, no GitHub issues created yet.

---

## Step 3 — Final Decision

Resolve by dispute rule:
- If CEO and PM agree → use that decision
- If they disagree → **PM wins on scope/complexity disputes; CEO wins on strategic rejects**
  - Example: CEO says "build", PM says "too complex" → PM wins
  - Example: CEO says "reject", PM says "valuable" → CEO wins

---

## Step 4 — Board Action

The calling command handles the board action based on final decision. This step is command-specific — see the calling command file for exact behavior.

---

## Notes

- Always run both CEO and PM. Never skip the PM challenge.
- PM must genuinely challenge CEO, not rubber-stamp.
- Do NOT factor in parallel development concerns or resource constraints — the founder controls priority.
- When in doubt about merit, default to Backlog — preserving the idea is better than dropping it.
