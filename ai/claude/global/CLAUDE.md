# Global Claude Rules

This file defines my default Claude Code behavior across environments.

Follow any global rules under `~/.claude/rules/` when relevant.

Do not assume files under `skills/` are always active by default. Treat
them as task-specific guidance.

Global defaults:

- Keep responses concise and practical.
- Read local context before proposing changes.
- Prefer minimal, reversible changes unless broader refactoring is requested.
- State assumptions clearly when local context is incomplete.
- Avoid scanning unrelated directories unless explicitly asked.
