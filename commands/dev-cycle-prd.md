# /dev-cycle-prd — PRD Phase

Part of the development cycle. See `/dev-cycle` for the full cycle overview.

---

## Step 1 — IDEA (CEO Agent)

**Trigger:** The founder sends a new idea via Telegram or GitHub issue
**Agent:** CEO

CEO must answer:
1. Does this solve a real problem for our user?
2. Does it fit Phase 1 scope? (MVP — no gold-plating)
3. Priority vs existing tasks?
4. Estimated size: S / M / L

**Output:** CEO Decision written to `~/ai-company/decisions/` or as GitHub issue comment
**Format:**
```
DECISION: BUILD NOW | DEFER TO PHASE 2 | REJECT
PRIORITY: P0 / P1 / P2
REASON: <one paragraph>
NEXT: Tag PM to write PRD
```

---

## Step 2 — PRD (PM Agent)

**Trigger:** CEO decision = BUILD NOW
**Agent:** PM

PM must write to `~/ai-company/docs/PRD-<feature>.md`:
- Problem statement
- User story: "As a [user], I want to [action] so that [outcome]"
- Acceptance criteria (checklist, testable)
- What is explicitly OUT of scope
- Open questions (resolved before dev starts)

**Output:** PRD file + GitHub issue with acceptance criteria
**Checklist before handoff to Dev:**
- [ ] All acceptance criteria are testable
- [ ] No open questions remain
- [ ] CEO has reviewed + approved

---

## Step 3 — UI DESIGN (Designer Agent)

**Trigger:** PRD approved (UI features only)
**Agent:** Designer
**Skip if:** Feature is purely backend/infra/config with zero UI changes

Designer produces design decisions BEFORE any code is written. Since we don't have Figma in Phase 1, Designer works from:
- PRD acceptance criteria
- Existing MUI v5 component library
- Design system tokens (docs/DESIGN_SYSTEM.md)

**Output — write to `~/ai-company/docs/UI-DESIGN-<feature>.md`:**

```
# UI Design — <feature name>

## Screens / States
List every screen and state that needs to exist:
- Screen: Login page (unauthenticated)
- Screen: Register page (unauthenticated)
- State: Loading (spinner while API call in progress)
- State: Error (wrong password)
- State: Success (redirect to dashboard)

## Component Breakdown
Which MUI components to use for each element:
- Form container: MUI Card with sx={{ maxWidth: 400, mx: 'auto', mt: 8 }}
- Email input: TextField fullWidth label="Email" type="email"
- Password input: TextField fullWidth label="Password" type="password"
- Submit: Button variant="contained" fullWidth
- Error: Alert severity="error"
- Link to register: MUI Link component

## Layout
Describe layout at desktop (1280px) and mobile (375px):
- Desktop: centred card, 400px wide, vertically centred
- Mobile: full-width card, 24px horizontal padding

## User Flow
Step by step what the user sees and does:
1. User arrives at /login
2. Enters email + password
3. Clicks Login
4. Loading spinner on button
5. Success → redirect to /
6. Error → red Alert shown above form, form stays

## Design Decisions
Why each decision was made:
- No sidebar navigation on login/register — user not authenticated yet
- Error shown as Alert (not inline on field) — simpler for MVP
```

**Review gate — PM + Dev must both approve before TECH SPEC starts:**
- PM checks: does this design meet all PRD acceptance criteria?
- Dev checks: is this implementable with MUI v5 in Phase 1 scope?

If either rejects → Designer revises → re-review.

---

## Step 4 — TECH SPEC (Dev + PM)

**Trigger:** PRD approved
**Agent:** Dev (with PM review)

Dev writes to `~/ai-company/specs/TECH-SPEC-<feature>.md`:
- API contract (endpoints, request/response shapes)
- TypeScript types
- Component breakdown (frontend)
- Data model changes
- Implementation order (numbered steps)
- Environment variables needed

**Checklist before coding:**
- [ ] API contract agreed with PM
- [ ] No TypeScript `any` types in spec
- [ ] Implementation order is unambiguous
- [ ] PM reviewed and signed off
