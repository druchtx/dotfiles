#!/bin/zsh

# Lazy load kubectl completions
_lazy_kubectl_completion() {
  unfunction _lazy_kubectl_completion
  source <(kubectl completion zsh)
  compdef k=kubectl
}

compdef _lazy_kubectl_completion kubectl
compdef _lazy_kubectl_completion k
