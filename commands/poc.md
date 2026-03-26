# /poc — Proof of Concept Workflow

Manages the full PoC lifecycle: PROPOSE → REVIEW → BUILD.
Any agent can propose. Only CEO approves. PM scopes. Dev builds.

---

## How to Use

```
/poc            — auto-detect what to do based on context
/poc propose    — submit a new PoC proposal (any agent) → see /poc-propose
/poc review     — review all pending proposals (CEO only) → see /poc-review
/poc build #N   — scope an approved PoC into tasks (PM only) → see /poc-build
/poc list       — list all PoCs by status
```

---

## Phase Files

| Phase | Who | File |
|-------|-----|------|
| Propose | Any agent | `/poc-propose` |
| Review | CEO only | `/poc-review` |
| Build | PM (scope) + Dev (build) | `/poc-build` |

---

## PoC Status Labels

| Label | Meaning |
|-------|---------|
| `poc` + `needs-ceo-review` | Submitted, awaiting CEO decision |
| `approved-poc` | CEO approved, PM to scope |
| `deferred-poc` | Good idea, wrong phase |
| `poc-in-progress` | Dev actively building |
| `poc-validated` | PoC succeeded — adopt decision pending |
| `poc-discarded` | PoC failed or rejected — closed |

---

## File Locations

```
PoC proposals    → GitHub issues (labeled poc)
PoC findings     → ~/ai-company/history/YYYY-MM-DD-poc-<name>.md
PoC branches     → poc/<short-name> (never merged without CEO sign-off)
```

---

## Quick Reference

| Who | When | Action |
|-----|------|--------|
| Any agent | Spots high-impact problem | `/poc propose` |
| CEO | Sees `needs-ceo-review` issues | `/poc review` |
| PM | Sees `approved-poc` issue | `/poc build #N` |
| Dev | Assigned PoC task | Build on `poc/` branch, time-boxed |
| Dev | PoC complete | Write findings report, notify founder |
| CEO | Reads findings | Decide ADOPT / DISCARD / ITERATE |
