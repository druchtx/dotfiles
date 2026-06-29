#!/bin/zsh

claude() {
    command claude -C "${WORK_ROOT:-$HOME/Workspace}" "$@"
}
