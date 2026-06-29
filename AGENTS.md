# Repository Guidelines

## Project Structure & Module Organization
This repository is a manifest-driven dotfiles setup for macOS. Core shell config lives in `system/` and `zsh/`. Tool-specific configs live under `tools/<tool>/` such as `tools/neovim/config`, `tools/git/`, and `tools/hammerspoon/`. Custom helper scripts live in `bin/`, including the `./bin/dot` manager. The symlink manifest is `dotfiles.json`; keep it in sync whenever you add or move managed files. Template files use the `.example` suffix and pull values from `.dotenv`.

## Adding New Managed Content
When adding something new, choose the coarsest management unit that
still stays maintainable.

- Use `type: "file"` for a single stable config file.
- Use `type: "dir"` for a small cohesive config directory.
- Use `type: "script"` for fragmented or procedural setup that would be
  awkward as many tiny manifest entries.

Prefer direct manifest entries for simple stable config. Prefer
`script` entries when setup needs multiple links, generated files,
cleanup logic, or conditional behavior.

Keep new source files grouped by domain:

- `system/` for shared shell environment defaults
- `zsh/` for shell startup and interactive config
- `tools/<tool>/` for tool-specific config
- `ai/` for AI-specific config and guidance
- `bin/` for reusable repo-level helper programs

For `script` entries, prefer placing the script near the config it
manages instead of in a central scripts directory.

If a new managed file is a template, store it as `*.example`. The
generated file should be the same path without the `.example` suffix.

Target path conventions:

- Use `~`-relative targets whenever the destination is under `$HOME`.
- Keep real source files in the repo unhidden when practical.
- Let the target carry the leading dot when linking to hidden files,
  for example `source: "zsh/zshrc"` -> `target: "~/.zshrc"`.
- Do not omit `target` for `file` or `dir` entries.
- Omit `target` only for `script` entries.

## Script Entry Contract
Script entries are executed by `./bin/dot` instead of being symlinked.

Manifest shape:

```json
{
  "source": "ai/setup-ai.sh",
  "type": "script"
}
```

Execution contract:

- `dot` checks script entries with `status` before deciding whether
  `link` needs to run
- `dot link` runs the script with argument `link`
- `dot unlink` runs the script with argument `unlink`
- `dot sync` also runs script entries because it calls `dot link`

Environment variables available to scripts:

- `DOTFILES_DIR`
- `DOT_ENTRY_SOURCE`
- `DOT_ENTRY_TYPE`
- `DOT_ACTION`
- `DOT_FORCE`
- `DOT_DEBUG`

Script requirements:

- Use a portable shebang such as `#!/bin/sh` unless there is a clear
  shell requirement.
- Make the script executable.
- Support `status` when the script can verify its managed state.
- Support both `link` and `unlink`.
- Make `link` and `unlink` idempotent.
- Only create or remove files the script owns.
- Exit non-zero on partial or unsafe state.

Recommended shape:

```sh
#!/bin/sh

set -eu

case "${1:-}" in
  status)
    ;;
  link)
    ;;
  unlink)
    ;;
  *)
    echo "usage: $0 {status|link|unlink}" >&2
    exit 1
    ;;
esac
```

## Build, Test, and Development Commands
Use the local CLI instead of ad hoc symlink commands:

- `./bootstrap`: install base dependencies and run `./bin/dot init`.
- `./bin/dot init`: scan templates and update `.dotenv`.
- `./bin/dot link`: apply manifest entries by creating symlinks and
  executing script entries.
- `./bin/dot unlink`: remove symlinks and run script cleanup entries.
- `./bin/dot status`: verify link health and detect conflicts.
- `./bin/dot sync --force`: pull the repo, update Homebrew and mise tools, then relink.
- `./bin/dot --help`: inspect available subcommands before extending the CLI.

## Coding Style & Naming Conventions
Match the surrounding file style instead of reformatting broadly. Python scripts in `bin/` use 4-space indentation, type hints, and standard-library-first imports. Zsh files prefer small, focused exports, aliases, and completion helpers. Lua under `tools/hammerspoon/` follows the existing tab-indented style. Keep tool configs grouped by application directory, and name new files by purpose, for example `alias.zsh`, `env.zsh`, or `path.zsh`.

## Testing Guidelines
There is no dedicated automated test suite in this repo. Validate changes with targeted checks:

- Run `./bin/dot status` after manifest or symlink changes.
- Run `./bin/dot link --force` only when you intend to overwrite conflicting local files.
- For Python script edits, use `python3 -m py_compile bin/dot bin/remote-vsc`.
- For app-specific configs, reload the owning app and confirm behavior manually.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commits, often with a type or scope such as `feat(neovim): improve diffview compare workflows` or `chore(tool): change ghostty config`. Prefer `type(scope): summary` when the scope is clear; keep bulk sync commits separate from functional changes. PRs should state the affected tools or targets, note any `dotfiles.json` updates, and include manual verification steps. Add screenshots only for UI-visible changes such as Hammerspoon, Ghostty, or VS Code settings.
