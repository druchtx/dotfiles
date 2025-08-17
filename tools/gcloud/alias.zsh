#!/bin/zsh


alias gcal="gcloud auth login --update-adc"

g() {
  gcloud "$@"
}


spanner() {
  spanner-cli "$@"
}