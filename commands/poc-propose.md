# /poc-propose — Submit a PoC Proposal

Any agent can propose. See `/poc` for the full PoC workflow overview.

---

**Trigger:** You identified a high-impact problem or inefficiency in your domain and have researched a technology or approach that could solve it.

## Step 1 — Confirm you have done the research

Before proposing, verify:
- [ ] I have identified a real, specific problem (not hypothetical)
- [ ] I have researched at least 1 concrete technology or approach
- [ ] I have evaluated benefit vs risk vs effort honestly
- [ ] This problem is in my domain — I am the right agent to spot it
- [ ] I am NOT proposing to self-implement — this is a proposal only

## Step 2 — Write the proposal

See `agents/shared/poc-template.md` for the full PoC Proposal format.

## Step 3 — Submit as GitHub issue

```bash
gh issue create \
  --title "POC: <short title>" \
  --body "<proposal content>" \
  --label "poc,needs-ceo-review" \
  --assignee YOUR_GITHUB_USER
```

## Step 4 — Add to GitHub Project Board 2 (Company Ops)

```bash
gh project item-add 2 --owner YOUR_GITHUB_USER --url <issue-url>
```

## Step 5 — Notify the founder via Telegram

```
🔬 PoC Proposal: <title>
Agent: <your role>
Problem: <one line>
Proposed: <tech/approach>
Benefit: HIGH/MEDIUM/LOW | Risk: HIGH/MEDIUM/LOW | Effort: S/M/L
GitHub: <issue url>
```

## Error Handling

See `agents/shared/error-handling.md` for standard retry/failure protocol. Apply to all gh commands above.
