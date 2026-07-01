#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


STATE_ROOT = Path.home() / ".local" / "state" / "ai-workflow" / "codex"
SESSIONS_DIR = STATE_ROOT / "sessions"
CODEX_ROOT = Path.home() / ".codex"
CODEX_SESSIONS_DIR = CODEX_ROOT / "sessions"
CODEX_SHELL_SNAPSHOTS_DIR = CODEX_ROOT / "shell_snapshots"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def session_file(session_id: str) -> Path:
    return SESSIONS_DIR / f"{session_id}.json"


def ensure_dirs() -> None:
    SESSIONS_DIR.mkdir(parents=True, exist_ok=True)


def error(message: str, exit_code: int = 1) -> int:
    print(message, file=sys.stderr)
    return exit_code


def read_state_input(path_arg: str | None) -> dict[str, Any]:
    if path_arg in {None, "-"}:
        raw = sys.stdin.read().strip()
        if not raw:
            raise ValueError("missing draft state JSON on stdin")
        data = json.loads(raw)
    else:
        with Path(path_arg).expanduser().open("r", encoding="utf-8") as handle:
            data = json.load(handle)

    if not isinstance(data, dict):
        raise ValueError("draft state must be a JSON object")

    return data


def normalize_repo_entry(repo: Any) -> dict[str, str]:
    if not isinstance(repo, dict):
        raise ValueError("each repo entry must be an object")

    repo_path = str(repo.get("path") or "").strip()
    if not repo_path:
        raise ValueError("repo entry is missing path")

    return {
        "path": str(Path(repo_path).expanduser().resolve()),
        "role": str(repo.get("role") or "").strip(),
        "description": str(repo.get("description") or "").strip(),
    }


def normalize_state(session_id: str, payload: dict[str, Any]) -> dict[str, Any]:
    workspace = payload.get("workspace")
    if not isinstance(workspace, dict):
        raise ValueError("workspace must be an object")

    repos = workspace.get("repos")
    if not isinstance(repos, list) or not repos:
        raise ValueError("workspace.repos must be a non-empty list")

    now = utc_now()
    normalized = {
        "session_name": str(payload.get("session_name") or session_id).strip() or session_id,
        "goal": str(payload.get("goal") or "").strip(),
        "description": str(payload.get("description") or "").strip(),
        "workspace": {
            "name": str(workspace.get("name") or "").strip() or "workspace",
            "repos": [],
        },
        "created_at": str(payload.get("created_at") or now),
        "updated_at": now,
    }

    normalized["workspace"]["repos"] = [normalize_repo_entry(repo) for repo in repos]
    return normalized


def load_state(session_id: str) -> dict[str, Any] | None:
    path = session_file(session_id)
    if not path.exists():
        return None

    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, dict):
        raise ValueError(f"invalid state file: {path}")

    return data


def save_state(session_id: str, state: dict[str, Any]) -> Path:
    ensure_dirs()
    path = session_file(session_id)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2, ensure_ascii=True)
        handle.write("\n")
    return path


def find_rollout_files(session_id: str) -> list[Path]:
    if not CODEX_SESSIONS_DIR.exists():
        return []
    return sorted(CODEX_SESSIONS_DIR.rglob(f"*{session_id}*.jsonl"))


def find_shell_snapshot_files(session_id: str) -> list[Path]:
    if not CODEX_SHELL_SNAPSHOTS_DIR.exists():
        return []
    return sorted(CODEX_SHELL_SNAPSHOTS_DIR.glob(f"{session_id}.*.sh"))


def collect_artifacts(session_id: str) -> dict[str, Any]:
    state_path = session_file(session_id)
    rollout_files = find_rollout_files(session_id)
    shell_snapshot_files = find_shell_snapshot_files(session_id)

    all_files = []
    if state_path.exists():
        all_files.append(state_path)
    all_files.extend(rollout_files)
    all_files.extend(shell_snapshot_files)

    return {
        "session_id": session_id,
        "state_file": str(state_path),
        "state_exists": state_path.exists(),
        "rollout_files": [str(path) for path in rollout_files],
        "shell_snapshot_files": [str(path) for path in shell_snapshot_files],
        "all_files": [str(path) for path in all_files],
    }


def print_json(payload: dict[str, Any]) -> int:
    json.dump(payload, sys.stdout, indent=2, ensure_ascii=True)
    sys.stdout.write("\n")
    return 0


def cmd_show(argv: list[str]) -> int:
    if len(argv) != 2:
        return error("usage: workspace-session.py show <session-id>")

    state = load_state(argv[1])
    if state is None:
        return error(f"missing state for session: {argv[1]}")

    return print_json(state)


def cmd_path(argv: list[str]) -> int:
    if len(argv) != 2:
        return error("usage: workspace-session.py path <session-id>")

    print(session_file(argv[1]))
    return 0


def cmd_artifacts(argv: list[str]) -> int:
    if len(argv) != 2:
        return error("usage: workspace-session.py artifacts <session-id>")

    return print_json(collect_artifacts(argv[1]))


def cmd_init(argv: list[str]) -> int:
    if len(argv) not in {2, 3}:
        return error("usage: workspace-session.py init <session-id> [state-file|-]")

    session_id = argv[1]
    path = session_file(session_id)
    if path.exists():
        return error(f"state already exists for session: {session_id}", exit_code=2)

    try:
        state = normalize_state(session_id, read_state_input(argv[2] if len(argv) == 3 else None))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return error(str(exc))

    save_state(session_id, state)
    return print_json({"status": "created", "path": str(path), "session_id": session_id})


def cmd_save(argv: list[str]) -> int:
    if len(argv) not in {2, 3}:
        return error("usage: workspace-session.py save <session-id> [state-file|-]")

    session_id = argv[1]
    existing_state = load_state(session_id)

    try:
        state = normalize_state(session_id, read_state_input(argv[2] if len(argv) == 3 else None))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        return error(str(exc))

    if existing_state and existing_state.get("created_at"):
        state["created_at"] = str(existing_state["created_at"])

    path = save_state(session_id, state)
    return print_json(
        {
            "status": "saved",
            "path": str(path),
            "session_id": session_id,
            "replaced_existing": existing_state is not None,
        }
    )


def cmd_delete(argv: list[str]) -> int:
    if len(argv) != 2:
        return error("usage: workspace-session.py delete <session-id>")

    artifacts = collect_artifacts(argv[1])
    deleted: list[str] = []

    for file_path in artifacts["all_files"]:
        path = Path(file_path)
        if not path.exists():
            continue
        path.unlink()
        deleted.append(str(path))

    return print_json(
        {
            "status": "deleted",
            "session_id": argv[1],
            "deleted_files": deleted,
            "missing_files_skipped": [
                file_path for file_path in artifacts["all_files"] if file_path not in deleted
            ],
        }
    )


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        return error(
            "usage: workspace-session.py "
            "{show|path|artifacts|init|save|delete}"
        )

    command = argv[1]
    if command == "show":
        return cmd_show(argv[1:])
    if command == "path":
        return cmd_path(argv[1:])
    if command == "artifacts":
        return cmd_artifacts(argv[1:])
    if command == "init":
        return cmd_init(argv[1:])
    if command == "save":
        return cmd_save(argv[1:])
    if command in {"delete", "remove"}:
        return cmd_delete(argv[1:])

    return error(f"unknown command: {command}")


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
