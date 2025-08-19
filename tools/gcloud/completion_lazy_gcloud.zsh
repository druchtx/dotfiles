#!/bin/zsh

_lazy_gcloud_completion() {
    unfunction _lazy_gcloud_completion
    source "$(gcloud info --format='value(installation.sdk_root)')/path.zsh.inc"
    source "$(gcloud info --format='value(installation.sdk_root)')/completion.zsh.inc"

    compdef g=gcloud
}

compdef _lazy_gcloud_completion gcloud
compdef _lazy_gcloud_completion g