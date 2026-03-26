# Memory

Claude Code auto-memory files go here. These are personal and per-user — not tracked in the template.

## What Goes Here

Claude Code automatically creates memory files in `~/.claude/projects/<project-path>/memory/` as you work. These capture:

- **User profile** — who you are, communication style, preferences
- **Project context** — current product status, decisions, architecture
- **Feedback** — how you like to work, what to avoid
- **References** — setup details for integrations (Telegram, GitHub Projects, etc.)

## Setup

1. Copy `MEMORY.md.example` to `MEMORY.md`
2. Fill in the index as Claude creates memory files
3. Claude will update these automatically during sessions

## Note

Memory files contain personal context and should not be committed to public repos. The `.gitignore` excludes everything except `README.md` and `MEMORY.md.example`.
