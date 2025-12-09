#!/bin/zsh

function grdl() {
  local gradlew_path=$(find . -name 'gradlew' -type f -maxdepth 1)
  if [ -n "$gradlew_path" ]; then
    $gradlew_path "$@"
  else
    echo "No gradlew found in current directory" >&2
    return 1
  fi
}

