function git_prompt_info {
  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  local gitst="$(git status 2> /dev/null)"
  local branch="$(git branch 2> /dev/null | grep '*' | sed 's/* //')"
  local statuscolor="green"

  if [[ -f .git/MERGE_HEAD ]]; then
    if [[ ${gitst} =~ "unmerged" ]]; then
      gitstatus=" %{$fg[red]%}unmerged%{$reset_color%}"
    else
      gitstatus=" %{$fg[green]%}merged%{$reset_color%}"
    fi
  elif [[ ${gitst} =~ "Changes" || ${gitst} =~ "Untracked" ]]; then
    statuscolor="yellow"
  elif [[ -n `git checkout HEAD 2> /dev/null | grep ahead` ]]; then
    statuscolor="yellow"
  else
    gitstatus=''
  fi

  if [[ -n $ref ]]; then
    echo "%{$fg[$statuscolor]%}[${ref#refs/heads/}]$gitstatus${reset_color}"
  fi
}

PROMPT='$(PWD) $(git_prompt_info)
> '
