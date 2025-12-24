#!/bin/zsh

if command -v docker >/dev/null 2>&1; then
  source <(docker completion zsh)
fi
