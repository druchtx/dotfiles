#!/usr/bin/env zsh

alias remote="docker exec -it -u vscode -w /home/vscode devcontainer zsh -c 'tmux attach || tmux new -s remote'"

# Quickly launch the dev container for the user workspace
dev() {
    local host_path="$WORK_ROOT"
    local config_path="$ZSH/tools/devcontainer/devcontainer.json"
    # remote-vsc will generate default simple code-workspace
    # local template_path="$ZSH/tools/devcontainer/remote.code-workspace"
    local open_paths=()

    if [[ $# -gt 0 ]]; then
        for arg in "$@"; do
            if [[ $arg == /* ]]; then
                open_paths+=("$arg")
            else
                if [[ -e "$WORK_ROOT/$arg" ]]; then
                    open_paths+=("$WORK_ROOT/$arg")
                else
                    open_paths+=("$PROJECTS/$arg")
                fi
            fi
        done
    else
        open_paths=("$(pwd)")
    fi

    "$ZSH/bin/remote-vsc" "$host_path" \
        --config "$config_path" \
        --s \
        -o "${open_paths[@]}"
}
