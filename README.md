# Dotfiles

Personal dotfiles for macOS, managed through a local manifest-driven
tool: `./bin/dfm`.

## Overview

This repository manages two kinds of setup:

- Direct symlinked config files and directories
- Script-driven setup that is too fragmented or procedural to manage
  cleanly as many individual symlinks

The source of truth is [dotfiles.json](/Users/druchtx/.dotfiles/dotfiles.json).
Each entry is applied by `./bin/dfm`.

## Repository Layout

- `system/`: shared shell environment and machine defaults
- `zsh/`: shell startup files and interactive config
- `tools/`: tool-specific config such as Git, Neovim, SSH, VS Code, and
  Hammerspoon
- `ai/`: AI-related config for Claude, Codex, shared rules, and future
  script-driven setup
- `bin/`: local management scripts, including `./bin/dfm`

## dfm

`./bin/dfm` is the local dotfiles manager. It supports:

- `file` entries: symlink a single file
- `dir` entries: symlink a directory
- `script` entries: execute a script during `link` and `unlink`
- template files: `.example` sources rendered from `.dotenv`

### Common Commands

```bash
./bootstrap
./bin/dfm init
./bin/dfm add <source>
./bin/dfm add <source> --type script
./bin/dfm link
./bin/dfm link --force
./bin/dfm unlink
./bin/dfm status
./bin/dfm sync --force
```

`bootstrap` is intended for macOS: it installs Homebrew and mise, installs
the repository runtimes from the root `.mise.toml`, and runs `dfm init` with
the pinned Python runtime. Fill in `.dotenv` before running `dfm link`; in
containers, copy the repository and run `dfm init` and `dfm link` directly.
`sync` pulls the repository and updates Homebrew packages.

After editing `.dotenv`, use `dfm sync --force` for the first full setup. It
pulls the repository, installs or updates Homebrew and mise tools, and links
managed configurations. The `--force` option backs up conflicting existing
files before replacing them. Use `dfm sync` without `--force` for subsequent
updates.

## Anchor

`./bin/anchor` keeps personal project knowledge and local helper scripts
outside the source repositories managed by worktrees. The Anchor knowledgebase
is a normal Git working tree configured through `~/.anchor/config`.

On first use, provide the personal knowledgebase remote:

```bash
./bin/anchor init --remote git@github.com:your-name/anchor.git
```

The default local path is `~/.anchor/knowledgebase`. On another machine,
`~/.anchor/config` can be restored by dotfiles and initialized without passing
the remote again:

```bash
./bin/anchor init
```

From a project worktree:

```bash
./bin/anchor create
./bin/anchor link
./bin/anchor status
./bin/anchor push -m "Record local test setup"
```

The knowledgebase keeps repository-specific knowledge under
`knowledgebase/repository/<remote-host>/<organization>/<repository>`. Shared
knowledge lives in top-level categories such as `architecture`, `testing`,
`release`, `deployment`, `policies`, and `team`. Each repository directory
starts with a small personal `README.md` and `CHANGELOG.md`; the project's
`.anchor` link is created at the bare repository container root and is not
added to the source repository. `anchor push` stages only the current
project's knowledge and the Anchor catalog.

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

- `dfm` checks script entries with `status` before deciding whether
  `link` needs to run
- `dfm link` executes the script with argument `link`
- `dfm unlink` executes the script with argument `unlink`
- `dfm sync` also executes script entries because it runs `dfm link`

Environment variables passed to script entries:

- `DOTFILES_DIR`
- `DOT_ENTRY_SOURCE`
- `DOT_ENTRY_TYPE`
- `DOT_ACTION`
- `DOT_FORCE`
- `DOT_DEBUG`

To debug a script entry, run `DOT_DEBUG=1 ./bin/dfm link` or
`DOT_DEBUG=1 ./bin/dfm unlink`.

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

Files ending with `.example` are treated as templates. `dfm init`
scans them, extracts `#{VAR}` placeholders, and updates `.dotenv`.
Variables are grouped by the rendered local file so their purpose remains
visible when multiple templates are added:

```dotenv
# .dotenv: variables used to render local configuration files.
# Each section below corresponds to a rendered local file.
# Edit values before running dfm link.

# tools/git/config.local
GIT_AUTHOREMAIL=
GIT_AUTHORNAME=
GIT_CREDENTIAL_HELPER=
GIT_SIGNING_KEY=
```

Typical flow:

```bash
./bin/dfm init
$EDITOR .dotenv
./bin/dfm link
```

## Validation

There is no full automated test suite for this repository. Validate
changes with targeted checks:

```bash
./bin/dfm status
python3 -m py_compile bin/dfm bin/remote-vsc
```

Use `./bin/dfm link --force` only when you intend to back up and
replace existing files.
