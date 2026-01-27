# Use the official devcontainer base image
FROM mcr.microsoft.com/devcontainers/base:2.1.3-debian12

# Switch to vscode user
USER vscode

# Copy dotfiles to the container
COPY --chown=vscode:vscode . /home/vscode/.dotfiles

# Run bootstrap to install dependencies and dotfiles
RUN /home/vscode/.dotfiles/bootstrap  --install-dot --install-deps 

# Set the default shell
ENV SHELL=/bin/zsh