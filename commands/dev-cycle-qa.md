# /dev-cycle-qa — QA, Merge, Deploy & Monitor Phases

Part of the development cycle. See `/dev-cycle` for the full cycle overview.

---

## Step 7 — CODE QA (QA Agent)

**Trigger:** Dev opens PR
**Agent:** QA

QA reviews every PR against:

### Security (OWASP Top 10 relevant items)
- [ ] No SQL/NoSQL injection risk (inputs validated before DB query)
- [ ] No secrets committed
- [ ] Auth required on all protected routes
- [ ] No sensitive data in logs

### Correctness
- [ ] Acceptance criteria from PRD are all met
- [ ] TypeScript compiles (no errors)
- [ ] Edge cases handled (empty input, 404, network error)
- [ ] Error states shown to user (not silent failures)

### Code Quality
- [ ] No `any` types
- [ ] No dead code
- [ ] No hardcoded values that should be env vars

**Output format:**
```
VERDICT: APPROVE | REQUEST CHANGES

Severity: CRITICAL | HIGH | MEDIUM | LOW
Issue: <description>
Fix: <specific suggestion>
```

CRITICAL → blocks merge, must fix
HIGH → should fix before merge
MEDIUM/LOW → can be follow-up issue

---

## Step 8 — MERGE (Ops Agent)

**Trigger:** QA approves, CI passes
**Agent:** Ops

Steps:
1. Merge `feature/*` → `develop`
2. Run smoke test on develop (if staging env exists)
3. Merge `develop` → `main`
4. Tag release if major feature: `git tag v0.x.0`
5. Update task status to Done on GitHub Project board

---

## Step 9 — DEPLOY (Ops Agent)

**Trigger:** Merge to main
**Agent:** Ops

Backend (Railway):
1. Railway auto-deploys on push to main
2. Watch deploy logs for errors
3. Hit `GET /health` — expect `{ status: "ok" }`
4. Check Sentry for new errors (wait 5 min)

Frontend (Vercel):
1. Vercel auto-deploys on push to main
2. Watch build logs
3. Open production URL — verify page loads
4. Click through core user journey: Login → Add → List → Edit → Delete

**Notify the founder via Telegram:**
```
✅ Deployed: <feature name>
URL: <production url>
Health: OK
Sentry: no new errors
```

If deploy fails:
```
❌ Deploy failed: <feature name>
Error: <error summary>
Action taken: <rolled back / investigating>
```

---

## Step 10 — MONITOR (Finance + Ops)

**Ongoing — not per-feature**

- Ops: UptimeRobot alerts if downtime > 5 min
- Ops: Sentry weekly error summary
- Finance: Weekly cost report every Monday
  - Claude API token usage (if any)
  - Railway spend
  - Total vs $35/month budget
