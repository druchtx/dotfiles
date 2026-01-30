# Dotfiles Project

Personal dotfiles managed with a custom symlink-based tool.

## Overview

This repository contains configuration files for development tools,
shell environment, and macOS applications. The `dot` tool manages
symlinks automatically, keeping the home directory clean while
allowing version control of configurations.

## Project Structure

```
.
├── ai/                  # AI assistant rules and context
│   ├── core/           # Core AI instructions
│   └── rules/          # Language and formatting rules
├── bin/                 # Executable scripts
│   └── dot             # Main dotfiles manager
├── tools/               # Tool configurations
│   ├── tmux/           # Terminal multiplexer
│   ├── vim/            # Text editors (vim/neovim)
│   ├── git/            # Version control
│   ├── claude/         # Claude Code settings
│   ├── ghostty/        # Terminal emulator
│   ├── hammerspoon/    # macOS automation
│   ├── mise/           # Runtime version manager
│   └── [25+ more]      # Other tools
├── zsh/                 # Zsh shell configuration
├── functions/           # Shell functions
├── system/              # System-level configs
├── langs/               # Language-specific configs
├── dotfiles.json        # Symlink mapping configuration
├── Brewfile             # Homebrew package list
└── bootstrap            # Initial setup script
```

## The `dot` Tool

Custom Python script for managing dotfile symlinks.

### Key Features

- **Symlink management**: Creates links from repo to home directory
- **Template support**: `.example` files with variable substitution
- **Validation**: Auto-cleans invalid entries
- **Sync command**: Updates repo, packages, and symlinks in one go

### Common Commands

```bash
# Initialize and setup
dot init                 # Setup dotfiles directory, scan templates

# Add files to management
dot add <source>         # Add file/dir (auto-detects type)
dot add tools/vim/vimrc ~/.vimrc  # Custom target

# Manage symlinks
dot link                 # Create all symlinks
dot link --force         # Backup and overwrite conflicts
dot unlink               # Remove all symlinks
dot status               # Check symlink status

# Sync everything
dot sync                 # git pull + brew + mise + link
dot                      # Same as sync (default command)
```

### Configuration

**dotfiles.json**: Maps source files to target locations

```json
{
  "dotfiles": [
    {
      "source": "tools/tmux/tmux.conf",
      "target": "~/.tmux.conf",
      "type": "file"
    }
  ]
}
```

**Templates**: Files ending in `.example`

- Use `#{VARIABLE}` placeholders
- Variables defined in `.dotenv`
- Run `dot init` to scan and update `.dotenv`

## Conventions

### File Organization

- **tools/**: Group by tool name (e.g., `tools/tmux/`)
- **Descriptive names**: `tmux.conf` not just `config`
- **Templates**: Use `.example` suffix for files with secrets

### Symlink Strategy

- Symlinks point to this repo (source of truth)
- Edit files in repo, changes reflect immediately
- Templates generate non-.example files (gitignored)

### Git Workflow

- **Branch**: `main` (primary branch)
- **Commits**: Conventional commit format preferred
  - `feat:` new features
  - `fix:` bug fixes
  - `chore:` maintenance
  - `docs:` documentation
- **Sync**: Run `dot sync` regularly to stay updated

### Code Style

- **Shell scripts**: Use `#!/usr/bin/env bash` shebang
- **Python**: Follow PEP 8, use type hints
- **Comments**: Explain why, not what
- **Line length**: 80 characters for markdown (see ai/rules)

## AI Assistant Rules

Located in `ai/rules/`:

- **language-learning.md**: English learning support
  - Restate questions naturally (not literal translations)
  - Correct meaningful errors only
- **markdown-standards.md**: Markdown formatting rules
  - 80 char line length
  - Blank lines around headers/lists
  - Language tags on code blocks

## Tool-Specific Notes

### Tmux

- Config: `tools/tmux/tmux.conf`
- Prefix: `Ctrl+Space` (not default `Ctrl+b`)
- Auto-restore sessions with tmux-resurrect
- Vim-aware pane navigation

### Git

- Config: `tools/git/gitconfig`
- Local overrides: `~/.gitconfig.local` (from template)
- Global gitignore: `tools/git/gitignore`

### Ghostty

- Config: `tools/ghostty/config`
- Auto-launches tmux on startup
- Check terminal compatibility: `/terminal-setup` in Claude Code

### Hammerspoon

- Config: `tools/hammerspoon/`
- macOS automation and keybindings
- Window management and app launcher

### Claude Code

- Settings: `tools/claude/settings.json`
- Custom statusline showing context usage
- Task tracking enabled (Ctrl+T to toggle)

### Mise

- Config: `tools/mise/mise.toml`
- Manages runtime versions (node, python, etc.)
- Auto-installed by `dot sync`

## Setup (New Machine)

```bash
# Clone repository
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap
./bootstrap

# Initialize dotfiles manager
dot init

# Edit .dotenv for template variables
vim .dotenv

# Create symlinks
dot link

# Install packages
brew bundle install
mise install
```

## Task Management

**Active tasks** are tracked in `TODO.md` (gitignored, local only).

Use format:
- `- [ ]` for pending tasks
- `- [x]` for completed tasks

For team collaboration, use GitHub Issues instead.

## Maintenance

### Regular Updates

```bash
dot sync    # Update everything
```

### Adding New Tools

```bash
# 1. Create tool directory
mkdir -p tools/newtool

# 2. Add config files
cp ~/.newtoolrc tools/newtool/config

# 3. Add to dotfiles management
dot add tools/newtool/config ~/.newtoolrc

# 4. Commit changes
git add dotfiles.json tools/newtool/
git commit -m "feat: add newtool configuration"
```

### Template Management

```bash
# After adding .example files
dot init    # Scans and updates .dotenv

# Edit variables
vim .dotenv

# Regenerate and link
dot link
```

## Troubleshooting

### Symlink conflicts

```bash
dot link --force    # Backs up existing files to .dot/backup/
```

### Broken symlinks

```bash
dot status          # Check status
dot init            # Clean invalid entries
```

### Template errors

```bash
dot init            # Update .dotenv with missing variables
vim .dotenv         # Fill in values
dot link            # Retry
```

### Brew issues

```bash
brew bundle cleanup # Remove packages not in Brewfile
brew bundle install --upgrade  # Update all packages
```

## Resources

- Dotfiles directory: `~/.dotfiles`
- Claude Code settings: `~/.claude/settings.json`
- Task tracking: `TODO.md` (local)
- Backups: `.dot/backup/`
