#!/bin/zsh

_lazy_terraform_completion() {
    unfunction _lazy_terraform_completion
    complete -o nospace -C $(which terraform) terraform
    complete -o nospace -C $(which terraform) tf
}

compdef _lazy_terraform_completion terraform
compdef _lazy_terraform_completion tf