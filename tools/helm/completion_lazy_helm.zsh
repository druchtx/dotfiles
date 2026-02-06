#!/bin/zsh

_lazy_helm_completion() {
    unfunction _lazy_helm_completion
    source <(helm completion zsh)
}

compdef _lazy_helm_completion helm