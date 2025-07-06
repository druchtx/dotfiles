#!/bin/zsh

source "$(gcloud info --format='value(installation.sdk_root)')/path.zsh.inc"
source "$(gcloud info --format='value(installation.sdk_root)')/completion.zsh.inc"

compdef g=gcloud
