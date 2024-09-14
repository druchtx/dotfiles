#!/bin/bash

# Basic install script for Debian packages
# Reads packages from debian/apt-packages.list and installs with apt

install_self() {
    # Assuming apt is installed on Debian systems
    :
}

update_self() {
    sudo apt update
    sudo apt upgrade -y
}

install_tool() {
    if [ -f "debian/apt-packages.list" ]; then
        PACKAGES=$(cat debian/apt-packages.list | tr '\n' ' ')
        if [ -n "$PACKAGES" ]; then
            sudo apt update
            sudo apt install -y $PACKAGES
            sudo apt upgrade -y
        fi
    fi
}

# Always run install_self, update_self, install_tool
install_self
update_self
install_tool