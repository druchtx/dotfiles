# Ensure PATH is set when zshrc loads */path.zsh files.
if [[ -f "$ZSH/system/_path.zsh" ]]; then
  source "$ZSH/system/_path.zsh"
fi
