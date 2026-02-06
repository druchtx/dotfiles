_lazy_spanner_completion() {
  unfunction _lazy_spanner_completion
  source <(spanner-cli completion zsh) 
  compdef _spanner spanner-cli
}

compdef _lazy_spanner_completion spanner-cli

# completion for custom function `spanner`
_spanner_completions() {
  # the first argument is the database name
  if (( CURRENT == 2 )); then
    local PROJECT_ID
    PROJECT_ID=$(gcloud config get project 2>/dev/null)
    local INSTANCE_ID
    INSTANCE_ID=$(gcloud config get spanner/instance 2>/dev/null)

    if [ -z "$PROJECT_ID" ] || [ -z "$INSTANCE_ID" ]; then
      return 0
    fi

    local info="[INFO] project=$PROJECT_ID, instance=$INSTANCE_ID"

    local -a DB_NAMES
    _message "$info"
    _message "[INFO] Fetching database list..."
    DB_NAMES=(${(f)"$(gcloud spanner databases list --instance="$INSTANCE_ID" --project="$PROJECT_ID" --format="value(name)" 2>/dev/null)"})
    if (( ${#DB_NAMES[@]} == 0 )); then
      _message "[ERROR] No databases found ! Please create one first."
      return 0
    fi

    compadd -a DB_NAMES
    return 0
    fi

  # The second argument, when starts with '.', assumes it's a SQL file
  # Auto-completes current directory's .sql files
  # If the third argument starts with '--', auto-completes options with explanations
  if (( CURRENT == 3 )); then
    if [[ ${words[3]} == .* ]]; then
      _files -g "*.sql"
      return 0
    elif [[ ${words[3]} == --* ]]; then
      local -a opts
      opts=(
        "--create:create database"
        "--drop:drop database"
      )
      _describe 'option' opts
      return 0
    fi
  fi

  return 0
}

compdef _spanner_completions spn