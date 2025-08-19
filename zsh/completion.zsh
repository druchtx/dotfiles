# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

zstyle ':completion:*:*:*:*:*' menu select

# Added for message and description display
zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:descriptions' format '%d'
# zstyle ':completion:*:warnings' format '--- no matches ---'
