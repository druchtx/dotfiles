#!/usr/bin/env zsh

# Quickly launch the dev container for the user workspace
dev() {
    local host_path="$WORK"
    local config_path="$ZSH/tools/devcontainer/devcontainer.json"
    local template_path="$ZSH/tools/devcontainer/remote.code-workspace"
    local open_paths=()

    if [[ $# -gt 0 ]]; then
        for arg in "$@"; do
            if [[ $arg == /* ]]; then
                open_paths+=("$arg")
            else
                open_paths+=("$WORK/$arg")
            fi
        done
    else
        open_paths=("$(pwd)")
    fi

    "$ZSH/bin/remote-vsc" "$host_path" \
        --config "$config_path" \
        --template "$template_path" \
        --s \
        -o "${open_paths[@]}"
}