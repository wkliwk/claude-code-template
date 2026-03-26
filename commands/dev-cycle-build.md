# /dev-cycle-build — Build Phase

Part of the development cycle. See `/dev-cycle` for the full cycle overview.

---

## Step 5 — BUILD (Dev Agent)

**Trigger:** Tech Spec approved
**Agent:** Dev

Rules:
1. Always create a `feature/<name>` branch from `develop`
2. One PR per logical unit of work (not one PR per file)
3. Every commit message follows: `type: description` (feat/fix/chore/docs)
4. No `any` types. No hardcoded secrets. No `console.log` left in production code.
5. Update GitHub Project board item to `In Progress` when starting
6. Add item to GitHub Project board before starting

**PR must include:**
- Summary of changes
- Env vars required (if any)
- Test plan (checkboxes)
- Screenshot (if UI change)

---

## Step 6 — DESIGN QA (Designer Agent)

**Trigger:** Dev opens PR with UI changes
**Agent:** Designer
**Skip if:** PR is purely backend, infra, or config (no UI changes)

Designer verifies the implementation matches the approved UI Design doc.
Uses Playwright MCP to screenshot the running app (local dev server).

Designer uses Playwright MCP to screenshot the running app (local dev or staging), then checks:

### Consistency checklist
- [ ] Colors match design system (primary #1976d2, no random hex)
- [ ] Typography uses MUI variants (h4, h6, body1, body2) — no arbitrary font sizes
- [ ] Spacing follows 8px grid
- [ ] Buttons: `variant="contained"` for primary, `variant="outlined"` for secondary
- [ ] All inputs use MUI TextField with `label` prop (not just placeholder)
- [ ] Icons from @mui/icons-material only

### UX checklist
- [ ] Loading states shown (CircularProgress or Skeleton)
- [ ] Error states visible with helpful messages (not silent)
- [ ] Empty states designed (not just blank white)
- [ ] Form validation feedback immediate and clear
- [ ] Success actions have confirmation (Snackbar)

### Responsive checklist
- [ ] Layout works at 375px (mobile)
- [ ] No horizontal scroll on mobile
- [ ] Touch targets ≥ 44px

**Output format:**
```
DESIGN VERDICT: APPROVE | REQUEST CHANGES

UI ISSUE — [component/page]
Severity: CRITICAL / HIGH / MEDIUM / LOW
Problem: [what's wrong]
Expected: [what it should look like]
Fix: [specific MUI fix]
```

CRITICAL/HIGH → fix before QA reviews
MEDIUM/LOW → open as follow-up GitHub issue, do not block
