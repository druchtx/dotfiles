#!/bin/zsh

_lazy_spanner_completion() {
  unfunction _lazy_spanner_completion
  source <(spanner-cli completion zsh) # this line will complete  spanner with _spanner
  compdef _spanner spanner-cli
}

compdef _lazy_spanner_completion spanner-cli
compdef _lazy_spanner_completion spanner
