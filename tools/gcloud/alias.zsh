#!/bin/zsh

# gcloud
alias gcal="gcloud auth login --update-adc"
alias gccl="gcloud config list"
g() {
  gcloud "$@"
}


# spanner
spn(){
  usage() {
  echo ""
  echo "spanner - Run queries or SQL files against a Google Spanner database."
  echo ""
  echo "Usage:"
  echo "  spanner <database_name> [*.sql | query | blank | --create | --drop]"
  echo "Arguments:"
  echo "  <database_name>   Name of the Spanner database to connect to."
  echo "  *.sql             Path to a SQL file; executes the SQL statements in the file."
  echo "  query             A SQL query string; executes the query directly."
  echo "  blank             If no additional argument is provided, enters the spanner-cli REPL for interactive queries."
  echo "  --create          Creates the database if it doesn't exist."
  echo "  --drop            Drops the database if it exists."
  echo ""
  echo "Hint: This function uses your gcloud configuration for project and instance."
  echo "      Ensure both 'gcloud' and 'spanner-cli' are installed and configured." 
  }

  # Display help if no arguments or help flag is present
  if [ "$#" -eq 0 ] || [[ "$1" =~ "^-(h|(-help))$|^help$" ]]; then
      usage
      return 1
  fi

  # Process the first argument - the database name
  local DATABASE_NAME=$1
  # shift # Consume the database name argument

  # Fetch project and instance from gcloud config
  local PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
  local INSTANCE_ID=$(gcloud config get-value spanner/instance 2>/dev/null)
  if [ -z "$PROJECT_ID" ] || [ -z "$INSTANCE_ID" ]; then 
      usage
      return 1 
  fi

  local info="[project=$PROJECT_ID, instance=$INSTANCE_ID, database=$DATABASE_NAME]\n"

  # Process the second argument - the SQL file or query
  local SECOND_AEG=$2
  # if it's a file
  if [[ "$SECOND_AEG" == *.sql ]]; then
      echo "${info}Executing SQL file... " >&2
      spanner-cli sql --project "$PROJECT_ID" --instance "$INSTANCE_ID" --database "$DATABASE_NAME" --source "$SECOND_AEG"
      return 
  fi

  if [[ "$SECOND_AEG" == "--create" ]]; then
      if gcloud spanner databases list --instance "$INSTANCE_ID" --project "$PROJECT_ID" 2>/dev/null | grep -q "$DATABASE_NAME"; then
        echo "Database $DATABASE_NAME already exists."
      return 
      fi  

      gcloud spanner databases create "$DATABASE_NAME" --instance "$INSTANCE_ID" --project "$PROJECT_ID"
      return 
  fi

  if [[ "$SECOND_AEG" == "--drop" ]] || [[ "$SECOND_AEG" == "--delete" ]]; then
      if ! gcloud spanner databases list --instance "$INSTANCE_ID" --project "$PROJECT_ID" 2>/dev/null | grep -q "$DATABASE_NAME"; then
        echo "Database $DATABASE_NAME does not exists."
      return 
      fi  
      
      gcloud spanner databases delete "$DATABASE_NAME" --instance "$INSTANCE_ID" --project "$PROJECT_ID"
      return 
  fi

  # not file or options, assume it's a query
  if [ -n "$SECOND_AEG" ]; then
      echo "${info}Executing query... " >&2
      spanner-cli sql --project "$PROJECT_ID" --instance "$INSTANCE_ID" --database "$DATABASE_NAME" --execute "$SECOND_AEG"
      return 
  fi
    
  # Execute the final command, passing any remaining arguments
  echo "${info}Connecting to Google Cloud Spanner REPL..." >&2
  spanner-cli sql --project "$PROJECT_ID" --instance "$INSTANCE_ID" --database "$DATABASE_NAME"
}

gcenv(){
  usage(){
    echo ""
    echo "gcenv - Easily switch between Google Cloud projects."
    echo ""
  }

  if [[ -z "$1" ]]; then
    cat "$HOME/.config/gcloud/active_config" && echo 
    return 0
  fi


}