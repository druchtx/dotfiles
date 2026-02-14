# Detect fzf installation path (cross-platform)
if command -v brew &>/dev/null; then
  # macOS with Homebrew
  export FZF_BASE="$(brew --prefix fzf)"
  export FZF_TAB_HOME="$(brew --prefix fzf-tab)/share/fzf-tab"
elif [[ -f ~/.fzf.zsh ]]; then
  # Manual install to home directory
  export FZF_BASE="$HOME/.fzf"
  export FZF_TAB_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-tab"
elif [[ -d /usr/share/fzf ]]; then
  # Linux package manager install
  export FZF_BASE="/usr/share/fzf"
  export FZF_TAB_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-tab"
else
  # fzf not found, skip setup
  return 0
fi

# Center fzf within the terminal window.
if [[ -n ${TMUX-} ]]; then
  FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--tmux=center,70%,80% --layout=reverse --border --margin=1%,1% --ansi --preview 'if [[ -f {} ]]; then command sed -n 1,200p {}; elif [[ -d {} ]]; then command ls -la {}; else echo {}; fi' --preview-window=right,60%,border-left,wrap"
else
  FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--height=80% --margin=10%,15% --layout=reverse --border --ansi --preview 'if [[ -f {} ]]; then command sed -n 1,200p {}; elif [[ -d {} ]]; then command ls -la {}; else echo {}; fi' --preview-window=right,60%,border-left,wrap"
fi
export FZF_DEFAULT_OPTS

# Use '**' to trigger fzf completion.
export FZF_COMPLETION_TRIGGER='**'

# Key bindings (Ctrl-T, Ctrl-R, Alt-C, etc.)
if [[ -f "$FZF_BASE/shell/key-bindings.zsh" ]]; then
  source "$FZF_BASE/shell/key-bindings.zsh"
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  # Debian/Ubuntu package path
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
