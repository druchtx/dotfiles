# Uses git's autocompletion for inner commands. Checks for brew command;
# if available, uses Homebrew's location, otherwise uses standard Linux location.
if command -v brew >/dev/null 2>&1; then
  completion='$(brew --prefix)/share/zsh/site-functions/_git'
else
  completion='/usr/share/zsh/functions/Unix/_git'
fi

if test -f $completion
then
  source $completion
fi
