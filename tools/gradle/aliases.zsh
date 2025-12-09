#!/bin/zsh

function gradlew() {
  local gradlew_path=$(find . -name 'gradlew' -type f -maxdepth 1)

  if [ ! -f "$gradlew_path" ]; then
    echo "No gradlew found in current directory" >&2
    return 1
  fi
  $gradlew_path "$@"
}


