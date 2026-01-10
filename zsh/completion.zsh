# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# use arrow keys to navigate the list instead of just tab cycling
zstyle ':completion:*:*:*:*:*' menu select

# Added for message and description display
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'