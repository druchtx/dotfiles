#!/bin/zsh

# gcloud
alias gcal="gcloud auth login --update-adc"
alias gccl="gcloud config list"
g() {
  gcloud "$@"
}


# spanner
spanner() {
  spanner-cli "$@"
}

spanner-tables(){
    if [[ "$1" =~ "-h" ]] ; then
      echo "Usage: $0 [database_name]"
      echo "Options: -h ,--help"
    return 1
  fi
  gcloud spanner databases list --format=json --filter="name~${1:-''}" | jq -r .
}


spanner-instances(){
    if [[ "$1" =~ "-h" ]] ; then
      echo "Usage: $0 [instance_name]"
      echo "Options: -h ,--help"
    return 1
  fi
    gcloud spanner instances list --format=json --filter="name~${1:-''}" | jq -r .
}

spanner-file(){
  if [[ "$1" =~ "-h" ]] || [ "$#" -lt 2 ] || [[ ! "$2" =~ ".sql" ]] || [[ ! -f "$2" ]]; then
    echo "Usage: spanner-file <database_name> <file_path>"
    echo "Options: -h ,--help"
    return 1
  fi
  local project_name instance_name file_path database_name
  project_name=$(gcloud config get core/project 2>/dev/null)
  instance_name=$(gcloud config get spanner/instance 2>/dev/null)
  file_path="$2"
  database_name="$1"

  if [ -z "$instance_name" ] || [ -z "$project_name" ] || [ -z "$file_path" ] || [ -z "$database_name" ] || [ ! -f "$file_path" ]; then
    echo "Please set the project name and spanner instance name"
    return 1
  fi

  spanner-cli sql --project "$project_name" --instance "$instance_name" --database "$database_name" --file "$file_path"
}

spanner-exec(){

  if [[ "$1" =~ "-h" ]] || [ "$#" -lt 2 ]; then
    echo "Usage: spanner-exec database_name> <query>"
    echo "Options: -h ,--help"
    return 1
  fi
  local project_name instance_name file_path database_name
  project_name=$(gcloud config get core/project 2>/dev/null)
  instance_name=$(gcloud config get spanner/instance 2>/dev/null)
  sql="$2"
  database_name="$1"

  if [ -z "$instance_name" ] || [ -z "$project_name" ] || [ -z "$sql" ] || [ -z "$database_name" ]; then
    echo "Please set the project name and spanner instance name"
    return 1
  fi

  spanner-cli sql --project "$project_name" --instance "$instance_name" --database "$database_name" --execute $sql 

}