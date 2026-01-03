# Personal Dotfiles

These are my personal dotfiles for setting up a consistent development environment on macOS and Linux systems. They include shell configurations, tool setups, Git configurations, and various scripts.

## Repository Structure

- `bin/`: Executable scripts added to `$PATH`
- `functions/`: Zsh functions
- `langs/`: Language-specific configurations (Go, Node.js, Python, Rust, Swift)
- `os/`: OS-specific configurations
  - `mac/`: macOS-specific scripts and configs (Homebrew, Xcode, etc.)
  - `linux/`: Linux-specific scripts (apt packages, Debian)
- `system/`: General system configurations (aliases, env, keys)
- `tools/`: Tool-specific configurations (AWS, Docker, Git, VS Code, etc.)
- `zsh/`: Zsh shell configurations (aliases, completion, prompt, etc.)
- `bootstrap`: Main setup script
- `functions/`: Additional Zsh functions

## Installation

⚠️ **Caution**: These scripts modify system configurations. Review them before running.

### Prerequisites

#### macOS
- None (Homebrew will be installed if missing)

#### Linux (Debian-based)
- `sudo` access
- `apt` package manager

### Quick Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/druchtx/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   ./bootstrap
   ```

This will:
- Set up Git configuration (name, email, SSH key)
- Create symbolic links for dotfiles (`.symlink` files to `~/.*`)
- Install system dependencies (Homebrew on macOS, apt packages on Linux)
- Install tool dependencies via `install.sh` scripts

### Selective Installation

You can run specific parts:
- `./bootstrap --setup-git`: Only Git setup
- `./bootstrap --install-dot`: Only dotfile symlinks
- `./bootstrap --install-deps`: Only dependencies

### Devcontainers

For development containers, use `tools/devcontainer/devcontainer.json`. The container will auto-clone and run bootstrap.

## Usage

After installation, configurations load automatically in your shell.

### Available Scripts

- `./bootstrap`: Full setup
- `./bin/dot`: Update dotfiles and dependencies
- `./bin/dot -e`: Open dotfiles directory in editor
- Various scripts in `bin/` for specific tasks

## Customization

### Adding Configurations

Organize by topic:
- `.zsh` files: Shell configs
- `.symlink` files: Symlinked to home directory
- `install.sh`: Tool installation scripts
- Custom paths: Add `# DOTFILE_CONFIG_PATH: ~/.config/app/config` in symlink files

### Tool-Specific Setup

Many tools have their own directories in `tools/` with:
- Environment variables
- Aliases
- Completion scripts
- Installation scripts

## Maintenance

Run `./bin/dot` periodically to:
- Update the dotfiles repository
- Update system packages
- Upgrade tools

## Notes

- Based on [holman/dotfiles](https://github.com/holman/dotfiles)
- Supports macOS and Debian-based Linux
- Git setup is skipped in devcontainers
- Logs available in `.tmp/dotfiles.log`