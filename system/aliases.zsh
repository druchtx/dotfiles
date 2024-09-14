# Cross-platform ls aliases
if [[ "$(uname -s)" == "Darwin" ]] && $(gls &>/dev/null); then
  # macOS with coreutils (gls)
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
else
  # Linux or macOS without gls
  alias ls="ls -F --color"
  alias l="ls -lAh --color"
  alias ll="ls -l --color"
  alias la='ls -A --color'
fi
