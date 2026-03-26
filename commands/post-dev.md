# /post-dev — Post-Development Review

Review what was just built, check goal alignment, update decision log, and verify CI.

## Steps

1. **Get recent changes**:
   - `git log --oneline -5` — last 5 commits
   - `git diff HEAD~1 --stat` — files changed in last commit

2. **Read product goal**:
   - Read `CLAUDE.md` in current directory — extract Product Goal and Anti-goals

3. **Check CI status**:
   - Detect repo from `git remote get-url origin`
   - `gh run list --limit 3` — latest CI runs and their status

4. **Review for drift**:
   - Compare what was changed against the product goal
   - Flag anything that contradicts Anti-goals (over-engineering, unnecessary features, complexity added)
   - Flag any files changed that seem unrelated to the stated task

5. **Code quality check**:
   - Any obvious duplication introduced?
   - Any new files that could have been edits to existing ones?
   - Commit message follows `type: description` format?

6. **Update decision log**:
   - Append to `~/Dev/decisions.jsonl`:
     `{"date":"YYYY-MM-DD","project":"<current project>","prompt":"<what was built>","summary":"<one line summary of changes>"}`

7. **Output report**:

```
📋 *Post-Dev Review — {project} — {date}*

✅ *What was done*
  {summary of changes from git log + diff}

🎯 *Goal alignment*
  {aligned / drifted — explain if drifted}

⚠️ *Issues found*
  {drift, duplication, unnecessary complexity — or "none"}

🔧 *Suggested improvements*
  {specific, actionable — or "none"}

🚦 *CI*
  {pass / fail / pending — with run link}

📝 *Decision log*
  {updated / skipped}
```

8. **Sync setup repo** (if commands/skills were changed this session):
   - Check if any files in `~/.claude/commands/` or `~/.claude/skills/` were modified
   - If yes, run `/sync-setup` to push changes to `YOUR_GITHUB_USER/claude-code-setup`
   - If no config changes, skip this step

## Notes
- If CI is failing, flag it clearly and suggest the fix
- Keep suggestions specific — not "improve code quality" but "extract X into Y"
- If nothing to flag, say so — a clean review is a good result
