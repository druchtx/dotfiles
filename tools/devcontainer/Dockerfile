FROM mcr.microsoft.com/devcontainers/base:2.1.3-debian12

# Install minimal dependencies for dotfiles and AI tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 fzf ripgrep jq unzip \
    && rm -rf /var/lib/apt/lists/*

USER vscode

# Copy dotfiles and run setup
COPY --chown=vscode:vscode . /home/vscode/.dotfiles
WORKDIR /home/vscode/.dotfiles

# Bootstrap (installs mise, runs dot init)
RUN ./bootstrap

# Link dotfiles
RUN ./bin/dot link --force

# Install mise tools (neovim, lazygit, delta, etc.)
ENV PATH="/home/vscode/.local/bin:${PATH}"
RUN mise trust ~/.config/mise/config.toml 2>/dev/null || true \
    && mise install --yes 2>/dev/null || true

ENV SHELL=/bin/zsh
