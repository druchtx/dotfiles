# Uses git's autocompletion for inner commands.
completion=""
for path in /usr/share/zsh/vendor-completions/_git /usr/share/zsh/site-functions/_git; do
  if [ -f "$path" ]; then
    completion="$path"
    break
  fi
done

if [ -n "$completion" ]; then
  source "$completion"
fi
