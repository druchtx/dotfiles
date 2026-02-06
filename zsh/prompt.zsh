autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo "on %{$fg_bold[green]%}$(git_prompt_info) ✔︎%{$reset_color%}"
    else
      echo "on %{$fg_bold[red]%}$(git_prompt_info) ✘%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

# This assumes that you always have an origin named `origin`, and that you only
# care about one specific origin. If this is not the case, you might want to use
# `$git cherry -v @{upstream}` instead.
need_push () {
  if [ $($git rev-parse --is-inside-work-tree 2>/dev/null) ]
  then
    number=$($git cherry -v origin/$(git symbolic-ref --short HEAD) 2>/dev/null | wc -l | bc)

    if [[ $number == 0 ]]
    then
      echo ""
    else
      echo " with %{$fg_bold[magenta]%}$number unpushed%{$reset_color%}"
    fi
  fi
}

directory_name() {
  if [[ "$HOME" == "$(pwd -P)" ]];then
    echo "%{$fg_bold[cyan]%}~%{$reset_color%}"
  else
    echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"

  fi
}

current_user() {
    echo "%{$fg[magenta]%}%n%{$reset_color%}"  
}

aws_vault_name() {
  [[ -z "$AWS_VAULT" || -z "$AWS_CREDENTIAL_EXPIRATION" ]] && return

  local utc_epoch current_epoch diff_seconds diff_hour
  local date_cmd="date"
  command -v gdate &>/dev/null && date_cmd="gdate"

  if [[ "$date_cmd" == "gdate" ]]; then
    utc_epoch=$(TZ='UTC' gdate -d "$AWS_CREDENTIAL_EXPIRATION" +%s 2>/dev/null)
    current_epoch=$(gdate +%s 2>/dev/null)
  else
    utc_epoch=$(TZ='UTC' date -j -f "%Y-%m-%dT%H:%M:%SZ" "$AWS_CREDENTIAL_EXPIRATION" +%s 2>/dev/null)
    current_epoch=$(date +%s 2>/dev/null)
  fi

  if [[ -n "$utc_epoch" && -n "$current_epoch" ]]; then
    diff_seconds=$((utc_epoch - current_epoch))
    diff_hour=$([[ $diff_seconds -lt 0 ]] && echo "expired" || echo "<$(( (diff_seconds + 3599) / 3600 ))h")
    echo "%{$fg_bold[yellow]%}(AWS: ${AWS_VAULT} ${diff_hour})%{$reset_color%}"
  else
    echo "%{$fg_bold[yellow]%}(AWS: ${AWS_VAULT})%{$reset_color%}"
  fi
}

export PROMPT=$'\$(current_user) in $(directory_name) $(git_dirty)$(need_push) $(aws_vault_name)\n⧉ '
set_prompt () {
  export RPROMPT="%{$fg[cyan]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
