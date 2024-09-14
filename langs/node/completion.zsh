#!/bin/zsh

if command -v npm &> /dev/null; then
  eval "$(npm completion --shell zsh)"
fi