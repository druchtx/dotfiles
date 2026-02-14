#!/bin/zsh

# Load mise completions (requires 'usage' CLI tool)
if command -v mise &>/dev/null; then
  eval "$(mise completion zsh 2>/dev/null)" && compdef m=mise
fi
