#!/usr/bin/env bash
# Devcontainer setup script
# This script is called by postCreateCommand in devcontainer.json

set -e

echo "==> Setting up devcontainer environment..."

# Fix permissions for mounted volumes
echo "==> Fixing permissions..."
sudo chown -R vscode:vscode ~/.ssh ~/.config/git 2>/dev/null || true

# Clone dotfiles if not exists
if [ ! -d ~/.dotfiles ]; then
    echo "==> Cloning dotfiles..."
    git clone https://github.com/druchtx/dotfiles ~/.dotfiles
fi

cd ~/.dotfiles

# Run bootstrap (installs mise and other dependencies)
echo "==> Running bootstrap..."
./bootstrap

# Link dotfiles
echo "==> Linking dotfiles..."
./bin/dot link --force

# Setup mise PATH (mise is installed to ~/.local/bin by bootstrap)
export PATH="$HOME/.local/bin:$PATH"

# Install mise tools (neovim, lazygit, etc.)
echo "==> Installing mise tools..."
if command -v mise &>/dev/null; then
    # Trust the config file first
    mise trust ~/.config/mise/config.toml 2>/dev/null || true
    # Install tools without activation (avoid shell hook issues)
    mise install --yes
    echo "==> Mise tools installed successfully"
else
    echo "==> Warning: mise not found, skipping tool installation"
fi

# Install Nerd Fonts for terminal icons
echo "==> Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/FiraCodeNerdFont.ttf \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
fc-cache -f 2>/dev/null || true

echo "==> Setup complete!"
echo "    Tools will be available after opening a new terminal (mise activates via .zshrc)"
