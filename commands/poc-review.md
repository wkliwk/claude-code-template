# /poc-review — Review PoC Proposals (CEO only)

CEO-only phase. See `/poc` for the full PoC workflow overview.

---

**Trigger:** There are open GitHub issues tagged `poc` + `needs-ceo-review`.

## Step 1 — Load all pending proposals

```bash
gh issue list --label "poc,needs-ceo-review" --state open
```

## Step 2 — For each proposal, evaluate

```
POC REVIEW: <title> — Issue #N

1. Is this a real problem at our current scale?
   → If no: REJECT

2. Is the timing right for our current phase?
   → Phase 1: only approve if it directly unblocks MVP or reduces critical risk
   → Phase 2+: more latitude for experimentation

3. Is the benefit/risk ratio worth it?
   → HIGH benefit + LOW risk → strong APPROVE signal
   → HIGH benefit + HIGH risk → DEFER until phase is more stable
   → LOW benefit → REJECT regardless of risk

4. Does Finance need to assess cost impact first?
   → If proposed tech has ongoing cost → tag Finance before approving

5. Final decision:
```

```
POC DECISION — Issue #N: <title>

VERDICT: APPROVE / DEFER TO PHASE X / REJECT

Reason: <1–2 sentences — be direct>

Next:
  APPROVE → tag PM to scope into tasks, add label approved-poc
  DEFER   → add label deferred-poc, comment with target phase
  REJECT  → close issue with reason
```

## Step 3 — Update issue

```bash
# Approve
gh issue edit #N --add-label "approved-poc" --remove-label "needs-ceo-review"
gh issue comment #N --body "APPROVED. PM to scope into tasks."

# Defer
gh issue edit #N --add-label "deferred-poc" --remove-label "needs-ceo-review"
gh issue comment #N --body "DEFERRED to Phase X. Reason: ..."

# Reject
gh issue close #N --comment "REJECTED. Reason: ..."
```

## Step 4 — Notify the founder via Telegram

```
✅ PoC APPROVED: <title>   OR   ❌ PoC REJECTED: <title>
Issue: #N                        Reason: <one line>
Next: PM to scope
```
