# AI Config Overview

This directory contains AI-related configuration, prompts, rules,
skills, and agent scaffolding for Claude and Codex.

## Current Structure

```text
ai/
  README.md
  shared/
    rules/
    skills/
    prompts/
  claude/
    alias.zsh
    settings.json
    statusline-command.sh
    global/
      CLAUDE.md
    workspace/
      CLAUDE.md
    agents/
  codex/
    alias.zsh
    hooks.json
    global/
      AGENTS.md
    scripts/
    skills/
    workspace/
      AGENTS.md
    agents/
    rules/
```

## Confirmed Decisions

- `ai/` is the root for AI-related config.
- Non-AI tool config should stay under `tools/`.
- `shared/rules/` is for lightweight default rules.
- `shared/skills/` is for task-specific guidance and heavier
  programming workflows.
- `agents/` is for explicitly invoked role-based specialists.
- Global and workspace entry files should stay thin.
- English-learning behavior stays in rules instead of being duplicated
  in global entry files.

## Rules, Skills, Agents

### Rules

Use `rules/` for lightweight defaults that can apply broadly.

Current example:

- `shared/rules/language-learning.md`

### Skills

Use `skills/` for reusable task guidance that should not always be
active by default.

Current examples:

- `shared/skills/architecture.md`
- `shared/skills/code-review.md`
- `shared/skills/markdown-standards.md`
- `shared/skills/testing.md`
- `shared/skills/workflow.md`

### Agents

Use `agents/` for specialist roles that should be explicitly invoked.

Examples we may add later:

- `db-architect`
- `api-designer`
- `ui-reviewer`
- `reviewer`

## Claude Layout

Claude is currently organized into:

- `claude/global/CLAUDE.md`
- `claude/workspace/CLAUDE.md`
- `claude/agents/`
- `claude/alias.zsh`
- `claude/settings.json`
- `claude/statusline-command.sh`

Managed targets:

- Global file maps to `~/.claude/CLAUDE.md`
- Workspace file maps to `~/Workspace/.claude/CLAUDE.md`
- Global and workspace rules may live under `.claude/rules/`

Notes:

- Global `CLAUDE.md` should only contain stable personal defaults.
- Workspace `CLAUDE.md` should contain directory-scope and workspace
  behavior.
- Heavy programming guidance should stay in `shared/skills/`.

## Codex Layout

Codex is currently organized into:

- `codex/global/AGENTS.md`
- `codex/workspace/AGENTS.md`
- `codex/agents/`
- `codex/alias.zsh`
- `codex/skills/session-workspace/`

Managed targets:

- Global file maps to `~/.codex/AGENTS.md`
- Workspace file maps to `~/Workspace/AGENTS.md`
- Skill maps to `~/.codex/skills/session-workspace`

Notes:

- Global `AGENTS.md` should remain thin.
- Workspace `AGENTS.md` should focus on multi-project workspace
  behavior.
- Rules should stay lightweight.
- Skills should be optional and task-specific.
- Persistent session state should live under
  `~/.local/state/ai-workflow/codex/`, not inside dotfiles or repos.
- Session state should only record lightweight directory memory such as
  associated repos, short roles, and longer descriptions.
- Session state is managed manually, not through Codex hooks.

## Codex Session Workspace State

Codex now has a lightweight state workflow for multi-repo sessions.

Design:

- Session transcript history remains the primary source of task context.
- Extra persisted state only stores a session goal plus associated
  directories and their role/description metadata.
- Session state is updated explicitly when needed.
- State files live under `~/.local/state/ai-workflow/codex/sessions/`.
- The skill now follows manual lifecycle actions such as `init`,
  `show`, `save`, and `delete`.

Current state shape:

```json
{
  "session_name": "019f...",
  "goal": "",
  "description": "",
  "workspace": {
    "name": "Workspace",
    "repos": [
      {
        "path": "/absolute/path/to/repo",
        "role": "",
        "description": ""
      }
    ]
  }
}
```

Notes:

- `session_name` defaults to `session_id` until you set a better label.
- `current_focus` and `next_step` are intentionally not persisted.
- Dotfiles only manage the skill and its local helper script.
- `delete` can also remove matching Codex rollout and shell snapshot
  artifacts for the same session id.

## Shell Wrappers

Current wrappers:

- `claude/alias.zsh`
- `codex/alias.zsh`

Current behavior:

- Start from `${WORK_ROOT:-$HOME/Workspace}`
- They are sourced by the existing `zsh/zshrc` recursive `**/*.zsh`
  loading pattern, so no extra shell wiring is needed.

## Current Status

- Claude config files were moved from `tools/claude/` to `ai/claude/`.
- Old `ai/rules/` content was reorganized into `shared/rules/` and
  `shared/skills/`.
- `dotfiles.json` now also manages global and workspace entry files for
  Claude and Codex.
- The manifest has been applied and the active links now point to:
  - `~/.claude/settings.json` -> `ai/claude/settings.json`
  - `~/.claude/CLAUDE.md` -> `ai/claude/global/CLAUDE.md`
  - `~/Workspace/.claude/CLAUDE.md` -> `ai/claude/workspace/CLAUDE.md`
  - `~/.claude/rules` -> `ai/shared/rules`
  - `~/.codex/AGENTS.md` -> `ai/codex/global/AGENTS.md`
  - `~/Workspace/AGENTS.md` -> `ai/codex/workspace/AGENTS.md`
- Shell wrappers are already loaded through the existing recursive zsh
  config loading pattern.

## Remaining Work

1. Keep `global/` and `workspace/` entry files thin and move heavier
   reusable guidance into `shared/skills/`.
2. Decide whether Codex needs real content under `codex/rules/` or if
   that directory should remain empty for now.
3. Decide whether shared prompts should live under `shared/prompts/` or
   whether that directory should be removed until there is real content.
4. Add the first real specialist agents only after the global/workspace
   entry model is stable in daily use.
