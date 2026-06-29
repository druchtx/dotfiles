# Workspace Claude Rules

This file defines workspace-level rules for directories under this
workspace.

Also follow:

- The global `~/.claude/CLAUDE.md`
- Any lightweight rules available under this workspace's `.claude/rules/`

Workspace defaults:

- Treat this workspace as a multi-project container.
- Do not scan the entire workspace by default.
- Focus on the directory that matches the current task or session.
- Avoid touching unrelated projects unless explicitly requested.
- Prefer keeping temporary outputs inside the workspace, not in project
  roots.
- Treat workspace `skills/` content as optional, task-specific guidance.
