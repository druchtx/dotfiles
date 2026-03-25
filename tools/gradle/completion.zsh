#!/bin/zsh

zmodload zsh/stat 2>/dev/null

typeset -gr _GRADLE_COMPLETION_CACHE_DIR="${TMPDIR:-/tmp}/gradle-cache"
typeset -gr _GRADLE_COMPLETION_REFRESH_SECONDS=60

_gradle_completion_wrapper_path() {
  emulate -L zsh

  if [[ -x ./gradlew ]]; then
    print -r -- "./gradlew"
    return 0
  fi

  local gradlew_path
  gradlew_path=$(find . -maxdepth 1 -name gradlew -type f 2>/dev/null | head -n 1)

  [[ -n "$gradlew_path" ]] || return 1
  print -r -- "$gradlew_path"
}

_gradle_completion_cache_key() {
  emulate -L zsh

  if command -v shasum >/dev/null 2>&1; then
    print -rn -- "$PWD" | shasum -a 256 | awk '{print $1}'
  elif command -v md5sum >/dev/null 2>&1; then
    print -rn -- "$PWD" | md5sum | awk '{print $1}'
  elif command -v md5 >/dev/null 2>&1; then
    md5 -qs "$PWD"
  else
    print -r -- "${PWD//\//_}"
  fi
}

_gradle_completion_cache_file() {
  emulate -L zsh
  print -r -- "$_GRADLE_COMPLETION_CACHE_DIR/$(_gradle_completion_cache_key).tasks"
}

_gradle_completion_lock_dir() {
  emulate -L zsh
  print -r -- "$_GRADLE_COMPLETION_CACHE_DIR/$(_gradle_completion_cache_key).lock"
}

_gradle_completion_needs_refresh() {
  emulate -L zsh

  local cache_file=$1

  [[ -s "$cache_file" ]] || return 0

  local -a stat_result
  zstat -A stat_result +mtime -- "$cache_file" 2>/dev/null || return 0

  (( EPOCHSECONDS - stat_result[1] >= _GRADLE_COMPLETION_REFRESH_SECONDS ))
}

_gradle_completion_write_cache() {
  emulate -L zsh

  local gradlew_path=$1
  local cache_file=$2
  local tmp_file="${cache_file}.$$"

  mkdir -p -- "$_GRADLE_COMPLETION_CACHE_DIR" || return 1

  local task_output
  task_output=$("$gradlew_path" tasks --all --console=plain 2>/dev/null) || return 1

  local parsed
  parsed=$(print -r -- "$task_output" | awk '
    / - / {
      match($0, / - /)
      task = substr($0, 1, RSTART - 1)
      desc = substr($0, RSTART + 3)
      gsub(/:/, "\\\\:", task)
      printf "%s:%s\n", task, desc
      found = 1
    }
    END {
      if (!found) {
        exit 1
      }
    }
  ')

  if [[ -z "$parsed" ]]; then
    parsed=$(print -r -- "$task_output" | awk '
      /^[[:alpha:]][^[:space:]]*/ {
        task = $1
        gsub(/:/, "\\\\:", task)
        printf "%s:\n", task
        found = 1
      }
      END {
        if (!found) {
          exit 1
        }
      }
    ') || return 1
  fi

  print -r -- "$parsed" >| "$tmp_file" || return 1
  mv -f -- "$tmp_file" "$cache_file"
}

_gradle_completion_refresh_cache_async() {
  emulate -L zsh

  local gradlew_path=$1
  local cache_file=$2
  local lock_dir
  lock_dir=$(_gradle_completion_lock_dir)

  mkdir -p -- "$_GRADLE_COMPLETION_CACHE_DIR" || return 0

  if ! mkdir "$lock_dir" 2>/dev/null; then
    return 0
  fi

  (
    _gradle_completion_write_cache "$gradlew_path" "$cache_file"
    rmdir "$lock_dir" 2>/dev/null
  ) >/dev/null 2>&1 &!
}

_gradle_completion_from_cache() {
  emulate -L zsh

  local cache_file=$1
  [[ -s "$cache_file" ]] || return 1

  local -a completions
  local IFS=$'\n'
  completions=($(<"$cache_file"))

  [[ ${#completions[@]} -gt 0 ]] || return 1

  _describe 'gradle task' completions
}

_gradlew_completion() {
  emulate -L zsh

  local gradlew_path
  gradlew_path=$(_gradle_completion_wrapper_path)

  if [[ -z "$gradlew_path" || ! -f "$gradlew_path" ]]; then
    _message "No gradlew found in current directory"
    return 1
  fi

  local cache_file
  cache_file=$(_gradle_completion_cache_file)

  if _gradle_completion_from_cache "$cache_file"; then
    if _gradle_completion_needs_refresh "$cache_file"; then
      _gradle_completion_refresh_cache_async "$gradlew_path" "$cache_file"
    fi
    return 0
  fi

  _gradle_completion_refresh_cache_async "$gradlew_path" "$cache_file"
  _message "Gradle task cache warming; press Tab again"
  return 1
}

compdef _gradlew_completion gradlew
compdef _gradlew_completion gradle
