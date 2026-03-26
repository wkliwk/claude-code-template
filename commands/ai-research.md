---
description: "Weekly AI tech research scan and evaluation pipeline"
---

# AI Tech Research Pipeline

Run the full weekly AI research pipeline:

## Step 1: AI Researcher — Scan & Brief
Use the `ai-researcher` agent to:
1. Search for AI news, tool releases, model updates, and relevant papers from the past week
2. Filter for relevance to our system (multi-agent, Claude/MCP ecosystem, developer tools, cost optimization)
3. Write a brief to `~/ai-company/research/ai-brief-{{date}}.md`
4. Create GitHub issues on Project 3 (Ideas) for any "Adopt" recommendations, tagged `ai-research`

## Step 2: CC Manager — Evaluate & Decide
Use the `claude-code-manager` agent to:
1. Read the latest brief from `~/ai-company/research/`
2. Evaluate each "Adopt" and "Watch" item against current system internals
3. For items worth integrating: create GitHub issues on Project 2 (Company Ops) with integration plans
4. Update the watchlist at `~/ai-company/research/watchlist.md`

## Step 3: Notify
Send a Telegram summary to the founder with:
- Top findings this week
- Items marked for adoption
- Items on the watchlist
- Link to the full brief

Run both agents sequentially — AI Researcher first, then CC Manager reviews the output.
