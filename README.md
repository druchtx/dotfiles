# Dotfiles

Dotfiles are how you personalize your system. These are mine.

I personally install everything that does not need version management using [`Homebrew`](https://brew.sh), and the others using [`mise`](https://github.com/jdx/mise) for easily switching toolchain versions.

The repository is cloned from [**holman/dotfiles**](https://github.com/holman/dotfiles), **please read the README file in the original repository**.

Below are only the parts I extracted for reference when adding content.


## Components

There's a few special files in the hierarchy.

- `bin/`: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.

- `topic/*.zsh`: Any files ending in `.zsh` get loaded into your environment.

- `topic/path.zsh`: Any file named `path.zsh` is loaded first and is expected to setup `$PATH` or similar.

- `topic/completion.zsh`: Any file named `completion.zsh` is loaded last and is expected to setup autocomplete.

- `topic/install.sh`: Any file named `install.sh` contains functions `install_self`, `update_self`, `install_tool`. Always runs all three functions to handle install and upgrade.

- `topic/*.symlink`: Any file ending in `*.symlink` gets symlinked into your` $HOME`. This is so you can keep all of those versioned in your dotfiles but still keep those autoloaded files in your home directory. These get symlinked in when you run `script/bootstrap`.


## Install

⚠️ **WARNING**: Be aware of what will happen before running the command, or you may mess up your system.

These dotfiles support multiple operating systems including macOS and Linux. Follow the instructions for your platform.

### Prerequisites

#### macOS
- [Homebrew](https://brew.sh) installed

#### Linux/Debian
- Debian-based system (e.g., Ubuntu, Debian)
- `apt` package manager
- `sudo` access for package installation

### macOS Installation

Install Homebrew if not already installed.

Then run:

```shell
./script/bootstrap
```

### Linux/Debian Installation

Run the Linux-specific install script to install required packages:

```shell
./os/linux/install.sh
```

Then, bootstrap the dotfiles:

```shell
./script/bootstrap
```

### Devcontainers (Linux/Debian)

For Debian-based devcontainers, use the provided `tools/devcontainer/devcontainer.json`. The devcontainer configuration will automatically clone the repository and run the bootstrap process during container creation, including the Linux installation scripts.

To use:
1. Open the project folder in VS Code with the Dev Containers extension installed.
2. When prompted, select "Reopen in Container" to build and enter the devcontainer.

## Maintenance

To keep your dotfiles and tools up-to-date, run the maintenance script periodically:

```shell
./bin/dot
```

This updates dotfiles, system packages, tools managed by mise, and runs bootstrap --install-deps to upgrade tools installed via install.sh scripts.

Consider adding this to a cron job or alias for automated updates.

### Cross-platform Compatibility

The dotfiles are designed to work across macOS and Linux environments. Scripts and configurations include conditional logic to handle OS-specific differences. Package management uses Homebrew on macOS and apt on Linux/Debian. Toolchain management with `mise` provides cross-platform support for development tools.