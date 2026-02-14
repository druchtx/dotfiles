# Enable fzf-tab (try common installation paths)
fzf_tab_paths=(
  "$FZF_TAB_HOME/fzf-tab.zsh"                           # Set by fzf.zsh
  "$HOME/.local/share/fzf-tab/fzf-tab.zsh"              # XDG data dir
  "$HOME/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.zsh" # Oh My Zsh
  "/usr/share/fzf-tab/fzf-tab.zsh"                      # System install
)

for fzf_tab_path in "${fzf_tab_paths[@]}"; do
  if [[ -r "$fzf_tab_path" ]]; then
    source "$fzf_tab_path"
    break
  fi
done
unset fzf_tab_path fzf_tab_paths

# Exit if fzf-tab wasn't loaded
[[ -n "$__fzf_tab_loaded" ]] || return 0

# Use dedicated fzf-tab styles to avoid conflicts with global FZF_DEFAULT_OPTS.
zstyle ':fzf-tab:*' use-fzf-default-opts no

autoload -U is-at-least
fzf_tab_version="$(fzf --version | awk '{print $1}')"
fzf_tab_border_opts=()
if is-at-least 0.58.0 "$fzf_tab_version"; then
  fzf_tab_border_opts=(
    --input-border --input-label=' Input '
    --info=inline-right
    --list-border --list-label=' Options '
    --preview-border --preview-label=' Preview '
  )
fi

if [[ -n ${TMUX-} ]]; then
  fzf_tab_flags=(
    --ansi
    --layout=reverse
    --border
    --tmux=center,70%,80%
    --preview-window=right,60%,border-left,wrap
  )
else
  fzf_tab_flags=(
    --ansi
    --layout=reverse
    --border
    --height=80%
    --margin=10%,15%
    --preview-window=right,60%,border-left,wrap
  )
fi
if (( ${#fzf_tab_border_opts[@]} )); then
  fzf_tab_flags+=("${fzf_tab_border_opts[@]}")
fi
zstyle ':fzf-tab:*' fzf-flags "${fzf_tab_flags[@]}"
zstyle ':fzf-tab:*' fzf-preview 'print -r -- ${desc:-$word}'
