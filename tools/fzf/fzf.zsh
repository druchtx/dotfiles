# Core paths (Homebrew installs fzf + fzf-tab)
export FZF_BASE="$(brew --prefix fzf)"
export FZF_TAB_HOME="$(brew --prefix fzf-tab)/share/fzf-tab"

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
source "$FZF_BASE/shell/key-bindings.zsh"
