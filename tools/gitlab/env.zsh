#!/bin/zsh

export GITLAB_HOST="gitlab.com"
export GITLAB_REPO_PROTOCOL="ssh"

if [[ -f "$HOME/.netrc" ]]; then
  export GITLAB_TOKEN="$(
    awk -v host="$GITLAB_HOST" '
      {
        for (i = 1; i <= NF; i++) {
          if ($i == "machine" && (i + 1) <= NF) {
            current = $(i + 1)
          }
          if (current == host && $i == "password" && (i + 1) <= NF) {
            print $(i + 1)
            exit
          }
        }
      }
    ' "$HOME/.netrc"
  )"
fi
