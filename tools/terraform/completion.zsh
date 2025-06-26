#!/bin/zsh

complete -o nospace -C $(which terraform) terraform
complete -o nospace -C $(which terraform) tf
