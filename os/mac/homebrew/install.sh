#!/bin/sh
#
# Homebrew
#

install_self() {
    # install homebrew if not already installed
    if test ! $(which brew)
    then
      echo "  Installing Homebrew..."
      if test "$(uname)" = "Darwin"
      then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    fi
}

update_self() {
    brew update
    brew upgrade
}

install_tool() {
    # install packages
    echo "› brew bundle"
    brew bundle --file "${ZSH}/os/mac/Brewfile"
    echo "› brew upgrade"
    brew upgrade
}

# Always run install_self, update_self, install_tool
install_self
update_self
install_tool

exit 0
