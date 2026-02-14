#!/usr/bin/env zsh
# Container-specific shell customization
# Auto-sourced when running inside a devcontainer

# Only run if we're inside a container
if [[ ! -f /.dockerenv ]]; then
  return
fi

# ============================================================================
# Container-specific Environment
# ============================================================================

# Set container indicator for other scripts
export IN_CONTAINER=1
export CONTAINER_NAME="sandbox"

# Background tint for terminal - makes container visually distinct
# Cool teal/blue - clearly noticeable and pleasant
echo -ne "\e]11;#1f3540\e\\"
trap 'echo -ne "\e]111\e\\"' EXIT  # Reset to default on exit

# Helpful reminder on first shell
if [[ ! -f ~/.container-welcome-shown ]]; then
  echo ""
  echo "🐳 Welcome to the SANDBOX devcontainer!"
  echo "   Your dotfiles are synced from the host."
  echo ""
  touch ~/.container-welcome-shown
fi
