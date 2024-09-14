#!/bin/zsh

command -v npm >/dev/null 2>&1 || return
NODE_GLOBALS=$HOME/.node-globals
if [ ! -d "$NODE_GLOBALS" ]; then
  mkdir -p "$NODE_GLOBALS"
  npm config set prefix "$NODE_GLOBALS"
fi

export PATH=$NODE_GLOBALS/bin:$PATH
