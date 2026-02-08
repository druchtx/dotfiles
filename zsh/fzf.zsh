# Center fzf within the terminal window.
if [[ -n ${FZF_DEFAULT_OPTS:-} ]]; then
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --tmux=center,80%,70% --layout=reverse --border --margin=5%,10% --ansi --preview 'if [[ -f {} ]]; then command sed -n 1,200p {}; elif [[ -d {} ]]; then command ls -la {}; else echo {}; fi' --preview-window=right,60%,border-left,wrap"
else
  export FZF_DEFAULT_OPTS="--tmux=center,80%,70% --layout=reverse --border --margin=5%,10% --ansi --preview 'if [[ -f {} ]]; then command sed -n 1,200p {}; elif [[ -d {} ]]; then command ls -la {}; else echo {}; fi' --preview-window=right,60%,border-left,wrap"
fi

# Use '**' to trigger fzf completion.
export FZF_COMPLETION_TRIGGER='**'

# Homebrew fzf location (Apple Silicon + Intel)
if [[ -d /opt/homebrew/opt/fzf ]]; then
  export FZF_BASE="/opt/homebrew/opt/fzf"
elif [[ -d /usr/local/opt/fzf ]]; then
  export FZF_BASE="/usr/local/opt/fzf"
fi

# Key bindings (Ctrl-T, Ctrl-R, Alt-C, etc.)
if [[ -n ${FZF_BASE:-} && -r "$FZF_BASE/shell/key-bindings.zsh" ]]; then
  source "$FZF_BASE/shell/key-bindings.zsh"
fi
