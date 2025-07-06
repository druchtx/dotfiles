#!/bin/zsh

NODE_GLOBALS=$HOME/.node-globals
if [ ! -d "$NODE_GLOBALS" ]; then
  mkdir -p "$NODE_GLOBALS"
  npm config set prefix "$NODE_GLOBALS"
fi

export PATH=$NODE_GLOBALS/bin:$PATH
