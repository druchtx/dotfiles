#!/bin/zsh

codex() {
    command codex -C "${WORK_ROOT:-$HOME/Workspace}" "$@"
}
