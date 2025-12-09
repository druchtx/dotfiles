#!/bin/zsh

function gradlew() {
  local gradlew_path=$(find . -name 'gradlew' -type f -maxdepth 1)

  if [ ! -x "$gradlew_path" ]; then
    echo "No execute permission for $gradlew_path" >&2
    return 1
  elif [ ! -f "$gradlew_path" ]; then
    echo "No gradlew found in current directory" >&2
    return 1
  else
    $gradlew_path "$@"
  fi
}

