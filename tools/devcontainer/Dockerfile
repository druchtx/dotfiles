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

ENV LANG=en_US.UTF-8

USER vscode

# Mise (manages language runtimes like node, python)
RUN curl https://mise.run | sh
ENV PATH="/home/vscode/.local/bin:${PATH}"

ENV SHELL=/bin/zsh
