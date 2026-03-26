# /status — AI Company Status Report

Check the current state of all products, PRs, and tasks. Then send a formatted report to Telegram.

## Steps

1. **Load product registry** — Read `shared/product-registry.md` for all products and their repos.

2. **Fetch open PRs** from all product repos in parallel:
   - For each product in the registry, list open PRs from all its repos

3. **Fetch GitHub Project board status** for all boards:
   - For each product board in the registry, get items with Status, Priority, Agent fields
   - Also check Project 2 (Company Ops) and Project 3 (Ideas)
   - Use `gh project item-list --format json` to get all items

4. **Build the report** in this format:

```
📊 *AI Company Status — {date}*

{for each product:}
🔧 *{Product Name}*
  Open PRs: {count}
  {list each PR: title + url}

📋 *Tasks — {Product Name}*
  ✅ Done: {count}
  🔄 In Progress: {count}
  📝 Todo: {count}
  🚨 Blockers: {any item marked blocked or P0 with no assignee}

{end for each}

📋 *Tasks — Company Operations*
  ✅ Done: {count}
  🔄 In Progress: {count}
  📝 Todo: {count}

🚨 *Blockers / Needs Human*
  {list any P0 tasks still in Todo, or PRs open > 2 days}

⏭ *Suggested Next Action*
  {top priority unstarted task}
```

5. **Send to Telegram** using the reply tool with the formatted report.
   - Use chat_id from memory (founder's Telegram ID: YOUR_TELEGRAM_CHAT_ID)
   - Use Markdown formatting

## Notes
- Always run this fully — don't skip steps even if data looks sparse
- If a PR has been open > 2 days, flag it as needing attention
- Suggest the single most important next action at the end
