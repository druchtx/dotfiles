#!/bin/sh

install_self() {
    # Install mise if not already present
    if ! command -v mise >/dev/null 2>&1; then
       curl https://mise.run | sh
    fi
}

update_self() {
    if command -v mise >/dev/null 2>&1; then
        mise self-update
    fi
}

install_tool() {
    # Install toolchains as defined in mise.toml
    mise trust -y
    mise install -y
}

install_self
update_self
install_tool
