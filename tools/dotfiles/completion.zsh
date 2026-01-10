#!/bin/zsh  

_dot_completion() {
    local -a commands
    commands=(
      'up:Update dotfiles (git pull + bootstrap)'
      'update:Update dotfiles (git pull + bootstrap)'
      'e:Edit a file in dotfiles (fzf)'
      'edit:Edit a file in dotfiles (fzf)'
      'c:Go to dotfiles directory'
      'cd:Go to dotfiles directory'
      'o:Open dotfiles directory in editor'
      'open:Open dotfiles directory in editor'
      'h:Show help'
      'help:Show help'
    )
    _describe -t commands 'dot command' commands
}

compdef _dot_completion dot
