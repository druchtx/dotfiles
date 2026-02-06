# Skip if fzf is not installed
command -v fzf &>/dev/null || return 0

# Detect fzf shell integration path
if command -v brew &>/dev/null; then
  export FZF_BASE="$(brew --prefix fzf 2>/dev/null)"
  export FZF_TAB_HOME="$(brew --prefix fzf-tab 2>/dev/null)/share/fzf-tab"
elif [[ -d "$HOME/.fzf" ]]; then
  export FZF_BASE="$HOME/.fzf"
elif [[ -d /usr/share/fzf ]]; then
  export FZF_BASE="/usr/share/fzf"
elif [[ -d /usr/share/doc/fzf/examples ]]; then
  # Debian/Ubuntu apt install
  export FZF_BASE="/usr/share/doc/fzf/examples"
fi
: ${FZF_TAB_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/fzf-tab}
export FZF_TAB_HOME

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
elif [[ -f "$FZF_BASE/key-bindings.zsh" ]]; then
  # FZF_BASE points directly at examples dir (Debian/Ubuntu)
  source "$FZF_BASE/key-bindings.zsh"
fi
