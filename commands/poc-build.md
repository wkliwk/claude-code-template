# /poc-build — Scope and Build an Approved PoC

PM scopes, Dev builds. See `/poc` for the full PoC workflow overview.

---

**Trigger:** GitHub issue has label `approved-poc`.

---

## PM: Scope the PoC

The goal of a PoC is to **validate the idea with minimum effort** — not to build production-ready code.

Define the minimal experiment:
```
POC SCOPE: <title> — Issue #N

Hypothesis: <what we are trying to prove or disprove>

Minimal experiment:
- [ ] Step 1: <smallest thing to build/configure to test the idea>
- [ ] Step 2: ...

Success criteria: <how will we know if this PoC worked?>
Failure criteria: <how will we know it's not worth pursuing?>

Time-box: <hard limit — S=1 day, M=3 days, L=5 days>
Branch: poc/<short-name>
Assigned to: Dev (or relevant agent)
```

Add scoped tasks to GitHub Project Board 2 (Company Ops) with label `poc` and status Todo.

---

## Dev: Build the PoC

Rules for PoC builds:
- Work on branch `poc/<short-name>` — never merge to `develop` without CEO sign-off
- Do the minimum needed to validate — not production-ready code
- Document findings as you go in `~/ai-company/history/YYYY-MM-DD-poc-<name>.md`
- Time-box strictly — if you hit the limit, stop and report findings anyway
- Do NOT refactor or improve surrounding code while building PoC

**PoC Findings Report (write at the end):**
```
POC FINDINGS: <title>
Date: <YYYY-MM-DD>
Time spent: <actual hours>

Hypothesis: <restated>
Result: VALIDATED / INVALIDATED / INCONCLUSIVE

What worked:
- ...

What didn't work:
- ...

Recommendation:
  ADOPT → integrate into main codebase (CEO approves, PM scopes as feature)
  DISCARD → delete poc branch, close issue, document learnings
  ITERATE → more research needed (specify what)

Evidence: <screenshot / benchmark / test result>
```

Save to: `~/ai-company/history/YYYY-MM-DD-poc-<name>.md`
Comment findings on the GitHub issue.

Notify the founder via Telegram:
```
🔬 PoC Complete: <title>
Result: VALIDATED / INVALIDATED / INCONCLUSIVE
Recommendation: ADOPT / DISCARD / ITERATE
Details: <issue url>
```
