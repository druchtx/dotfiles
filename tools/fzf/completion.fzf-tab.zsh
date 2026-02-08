# Enable fzf-tab (Homebrew install)
if [[ -r "$FZF_TAB_HOME/fzf-tab.zsh" ]]; then
  source "$FZF_TAB_HOME/fzf-tab.zsh"
else
  return
fi

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
