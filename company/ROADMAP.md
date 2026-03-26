# AI Company Roadmap

## Vision
Solo AI company where AI agents handle 24/7 product development.
The human founder acts as director — sets direction via Telegram, approves decisions.

## First Product
<!-- Fill in after running /launch-product -->
Your Product — description here.
Repos: YOUR_GITHUB_USER/your-product-frontend, YOUR_GITHUB_USER/your-product-backend

---

## Phase 1: Foundation
**Goal:** Stable base. Ship your first product MVP.

### Agent Setup
- [ ] Create 7 custom agents: CEO, PM, Dev, QA, Ops, Designer, Finance
- [ ] Create ~/ai-company/ folder structure
- [ ] Write ADRs for all major decisions
- [ ] Write CLAUDE.md in product repos
- [ ] Create SESSION_START.md (agent orientation guide)

### Infrastructure
- [ ] MongoDB Atlas M0 cluster
- [ ] Deploy backend to Railway
- [ ] Deploy frontend to Vercel
- [ ] GitHub Actions CI (notify Telegram)
- [ ] Sentry SDK installed
- [ ] /health endpoint live

### Product MVP
- [ ] Implement backend (Express + MongoDB)
- [ ] CRUD API routes
- [ ] JWT auth (backend + frontend)
- [ ] Core UI components
- [ ] Full QA pass

### What Phase 1 Does NOT Include
- L3 vector memory (Pinecone/Weaviate)
- State machine as code
- Self-improving agents
- Fully autonomous agent loop
- Command Router automation

---

## Phase 2: Automation
**Goal:** Reduce human touchpoints. Agents self-chain on GitHub events.

- GitHub webhooks trigger agents on issue creation
- Auto-merge when CI passes
- PM agent creates issues from Telegram ideas automatically
- State machine implemented in tasks.json
- Telegram command router (/idea, /build, /status, /deploy)
- Figma MCP for Designer agent

---

## Phase 3: Self-Improvement
**Goal:** Agents optimize themselves.

- Agents analyze own performance logs
- Agents refine their own prompts
- Near-fully autonomous development loop
- L3 vector memory for cross-project learning
- Marketing agent

---

## Key Rules (All Phases)
1. LLM is stateless — system must persist state externally
2. Max 7 agents — no new agents without CEO + Finance approval
3. Document every major decision as ADR
4. One orchestrator (PM), multiple workers
5. Ship first, optimize second
