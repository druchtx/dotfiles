# GRC colorizes nifty unix tools all over the place
if (( $+commands[grc] )); then
  if [[ "$(uname -s)" == "Darwin" ]] && (( $+commands[brew] )); then
    source "$(brew --prefix)/etc/grc.bashrc"
  elif [[ -f /etc/grc.bashrc ]]; then
    source /etc/grc.bashrc
  fi
fi
