#!/usr/bin/env zsh

gg() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    local full_paths display_line selected_display selected

    full_paths=$(find "$PROJECTS" -maxdepth 3 -type d -name '.git' 2>/dev/null | sed 's|/\.git$||')

    selected_display=$(echo "$full_paths" | sed "s|^$PROJECTS/||" | fzf --prompt="Select project > " --height=40% --reverse)

    if [ -z "$selected_display" ]; then
      return
    fi

    selected="$PROJECTS/$selected_display"

    cd "$selected" || return
  fi
  lazygit -p .
}
