# Dotfiles

Personal dotfiles for macOS, managed through a local manifest-driven
tool: `./bin/dot`.

## Overview

This repository manages two kinds of setup:

- Direct symlinked config files and directories
- Script-driven setup that is too fragmented or procedural to manage
  cleanly as many individual symlinks

The source of truth is [dotfiles.json](/Users/druchtx/.dotfiles/dotfiles.json).
Each entry is applied by `./bin/dot`.

## Repository Layout

- `system/`: shared shell environment and machine defaults
- `zsh/`: shell startup files and interactive config
- `tools/`: tool-specific config such as Git, Neovim, SSH, VS Code, and
  Hammerspoon
- `ai/`: AI-related config for Claude, Codex, shared rules, and future
  script-driven setup
- `bin/`: local management scripts, including `./bin/dot`

## dot

`./bin/dot` is the local dotfiles manager. It supports:

- `file` entries: symlink a single file
- `dir` entries: symlink a directory
- `script` entries: execute a script during `link` and `unlink`
- template files: `.example` sources rendered from `.dotenv`

### Common Commands

```bash
./bootstrap
./bin/dot init
./bin/dot add <source>
./bin/dot add <source> --type script
./bin/dot link
./bin/dot link --force
./bin/dot unlink
./bin/dot status
./bin/dot sync --force
```

### Manifest Format

Normal symlinked file:

```json
{
  "source": "tools/git/gitconfig",
  "target": "~/.config/git/config",
  "type": "file"
}
```

Directory symlink:

```json
{
  "source": "tools/hammerspoon",
  "target": "~/.hammerspoon",
  "type": "dir"
}
```

Script-managed entry:

```json
{
  "source": "ai/setup-ai.sh",
  "type": "script"
}
```

### Script Entry Contract

Use `type: "script"` when a setup is too fragmented to manage well as
many separate manifest entries.

Prefer placing script entries near the config they manage instead of in
a central scripts directory.

Behavior:

- `dot` checks script entries with `status` before deciding whether
  `link` needs to run
- `dot link` executes the script with argument `link`
- `dot unlink` executes the script with argument `unlink`
- `dot sync` also executes script entries because it runs `dot link`

Environment variables passed to script entries:

- `DOTFILES_DIR`
- `DOT_ENTRY_SOURCE`
- `DOT_ENTRY_TYPE`
- `DOT_ACTION`
- `DOT_FORCE`
- `DOT_DEBUG`

To debug a script entry, run `DOT_DEBUG=1 ./bin/dot link` or
`DOT_DEBUG=1 ./bin/dot unlink`.

Recommended script shape:

```sh
#!/bin/sh

set -eu

case "${1:-}" in
  status)
    # exit 0 when current state is already correct
    ;;
  link)
    # create symlinks, generate files, or perform setup
    ;;
  unlink)
    # remove symlinks or cleanup generated state
    ;;
  *)
    echo "usage: $0 {status|link|unlink}" >&2
    exit 1
    ;;
esac
```

Guidelines for script entries:

- Keep them idempotent
- Support `status` when the script can verify its managed state
- Support both `link` and `unlink`
- Prefer creating only the files they own
- Fail loudly on partial or unsafe state
- Use script entries for procedural setup, not as a replacement for
  every simple symlink

## Templates

Files ending with `.example` are treated as templates. `dot init`
scans them, extracts `#{VAR}` placeholders, and updates `.dotenv`.

Typical flow:

```bash
./bin/dot init
$EDITOR .dotenv
./bin/dot link
```

## Validation

There is no full automated test suite for this repository. Validate
changes with targeted checks:

```bash
./bin/dot status
python3 -m py_compile bin/dot bin/remote-vsc
```

Use `./bin/dot link --force` only when you intend to back up and
replace existing files.
