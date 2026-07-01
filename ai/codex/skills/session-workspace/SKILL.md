---
name: session-workspace
description: Maintain lightweight Codex session workspace state. Use when the user wants the agent to remember which repositories are associated with the current session, plus short roles and descriptions for those repositories.
---

# Session Workspace State

Use this skill when the task is about maintaining lightweight session
state outside conversation history.

This state is intentionally narrow:

- store associated repository paths
- store a short `role` for each repository
- store a longer repository `description` when needed
- store a session-level `session_name`
- store a session-level `goal`
- store a session-level `description`

Do not store:

- `current_focus`
- `next_step`
- transient task plans
- large notes that belong in normal conversation history

## Storage

State files live outside dotfiles and outside repositories:

- `~/.local/state/ai-workflow/codex/sessions/<session-id>.json`

The helper script is:

- `~/.codex/skills/session-workspace/scripts/workspace-session.py`

## State Shape

```json
{
  "session_name": "dotfiles",
  "goal": "refactor the workspace session skill",
  "description": "",
  "workspace": {
    "name": "Workspace",
    "repos": [
      {
        "path": "/absolute/path/to/repo",
        "role": "dotfiles",
        "description": ""
      }
    ]
  }
}
```

## Default Workflow

1. Identify the current `session_id` from hook context or existing state.
2. For `init`, ask the user for missing freeform inputs such as `goal`
   and related repos.
3. For `save`, infer a draft from the current conversation and existing
   state, then show the full draft to the user.
4. Require explicit user confirmation before running `init`, `save`, or
   `delete`.
5. Keep repo `role` short and repo `description` factual.

## Helper Commands

Show state:

```bash
~/.codex/skills/session-workspace/scripts/workspace-session.py show <session-id>
```

Show all files that belong to the session before deletion:

```bash
~/.codex/skills/session-workspace/scripts/workspace-session.py artifacts <session-id>
```

Create a new state file from a confirmed draft:

```bash
cat draft.json | ~/.codex/skills/session-workspace/scripts/workspace-session.py init <session-id> -
```

Save an updated state from a confirmed draft:

```bash
cat draft.json | ~/.codex/skills/session-workspace/scripts/workspace-session.py save <session-id> -
```

Delete the saved state and matching Codex session artifacts:

```bash
~/.codex/skills/session-workspace/scripts/workspace-session.py delete <session-id>
```

## Notes

- New state files default `session_name` to the `session_id` because
  Codex does not currently expose a separate user-defined session
  label.
- This workflow is manual by design. There is no automatic hook-based
  load or save step.
- `init` fails if the state file already exists. The agent should ask
  whether to overwrite, then use `save` if the user confirms.
- `delete` removes the state file, matching rollout JSONL files, and
  matching shell snapshot files for the same session id.
