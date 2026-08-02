# Global Codex Rules

This file defines my default Codex behavior across environments.

Follow lightweight global rules by default when they are available.

Do not assume files under `skills/` are always active by default. Treat
them as task-specific guidance.

Global defaults:

- Keep responses concise and implementation-oriented.
- Read local files before proposing code changes.
- Read available local context before making assumptions.
- Prefer minimal edits that match existing repository patterns.
- Prioritize bugs, regressions, and missing tests during reviews.
- Explain blockers and assumptions directly.
- Avoid scanning unrelated directories unless explicitly requested.

Workspace-specific guidance:

- When working under ~/Workspace, also read and follow
  ~/.codex/AGENTS.md.
