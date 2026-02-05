FROM mcr.microsoft.com/devcontainers/base:2.1.3-debian12

# Tools used by AI assistants for code search and analysis
RUN apt-get update && apt-get install -y --no-install-recommends \
    ripgrep fzf jq \
    && rm -rf /var/lib/apt/lists/*

# Node.js (required by Claude Code, Codex)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

USER vscode
ENV SHELL=/bin/zsh
