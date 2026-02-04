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

# Setup mise and install tools
echo "==> Installing mise tools (including neovim, lazygit)..."
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"
mise install --yes

# Install Nerd Fonts for terminal icons
echo "==> Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/FiraCodeNerdFont.ttf \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
fc-cache -f 2>/dev/null || true

echo "==> Setup complete!"
echo "    - neovim: $(mise which nvim 2>/dev/null || echo 'will be available after shell restart')"
echo "    - lazygit: $(mise which lazygit 2>/dev/null || echo 'will be available after shell restart')"
