#!/usr/bin/env zsh

# Quick shell access to running container
alias remote='docker exec -it -u vscode -w /home/vscode/Workspace devcontainer zsh -l'

# Dev container management
#   dev           Open new tmux window and enter container
#   dev --vsc     Open VS Code attached to container
dev() {
    local config_path="$ZSH/tools/devcontainer/devcontainer.json"
    local container_name="devcontainer"
    local action="shell"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --vsc) action="vscode"; shift ;;
            *)     shift ;;
        esac
    done

    if [[ -f /.dockerenv ]]; then
        echo "Already inside container."
        return 1
    fi

    # Start container if not running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Starting container..."
        devcontainer up --workspace-folder "$WORK_ROOT" --config "$config_path" 2>&1
    fi

    case "$action" in
        vscode)
            "$ZSH/bin/remote-vsc" "$WORK_ROOT" \
                --config "$config_path" \
                --s \
                -o "$(pwd)"
            ;;
        shell)
            if [[ -n "$TMUX" ]]; then
                tmux new-window -n "sandbox" "docker exec -it -u vscode -w /home/vscode/Workspace $container_name zsh -l"
            else
                docker exec -it -u vscode -w /home/vscode/Workspace "$container_name" zsh -l
            fi
            ;;
    esac
}
