FROM mcr.microsoft.com/devcontainers/base:debian-12

# Essential tools for AI agent sandbox
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 python3-pip \
       git curl wget \
       ripgrep fd-find fzf \
       jq bc unzip \
       zsh locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

# Install latest Neovim (Debian repo version is too old for modern plugins)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz \
    && tar xzf nvim-linux-arm64.tar.gz -C /opt/ \
    && ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux-arm64.tar.gz

# Install latest Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name | sed 's/v//') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz" \
    && tar xf lazygit.tar.gz -C /usr/local/bin lazygit \
    && rm lazygit.tar.gz

ENV LANG=en_US.UTF-8

USER vscode

# Mise (manages language runtimes like node, python)
RUN curl https://mise.run | sh
ENV PATH="/home/vscode/.local/bin:${PATH}"

ENV SHELL=/bin/zsh
