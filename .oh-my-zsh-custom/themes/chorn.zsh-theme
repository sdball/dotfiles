#-----------------------------------------------------------------------------
typeset -g -A _prompt
typeset -g -A _prompt_languages
#-----------------------------------------------------------------------------
_prompt_reset() {
  print -n "%f%b%k%u%s"
}
#-----------------------------------------------------------------------------
_prompt_update_git() {
  local _git_command="${1:=git}"

  typeset -A g=(staged 0 conflicts 0 changed 0 untracked 0 ignored 0 no_repository 0 clean 0 deleted 0)

  while read -rA _status ; do
    case "${_status[1]}" in
      fatal*)
        g[no_repository]=1
        ;;
      \#)
        case "${_status[2]}" in
          branch.oid)
            g[oid]="${_status[3]:0:8}"
            ;;
          branch.head)
            g[branch]="${_status[3]}"
            ;;
          branch.upstream)
            g[upstream]="${_status[3]}"
            ;;
          branch.ab)
            g[ahead]=$((${_status[3]}))
            g[behind]=$((${_status[4]}))
            ;;
        esac
        ;;
      \?)
        (( g[untracked]++ ))
        ;;
      \!)
        (( g[ignored]++ ))
        ;;
      1)
        case "${_status[2]}" in
          .M)
            (( g[changed]++ ))
            ;;
          .D)
            (( g[deleted]++ ))
            ;;
          A.|M.)
            (( g[staged]++ ))
            ;;
        esac
        ;;
      2)
        case "${_status[2]}" in
          R.)
            (( g[changed]++ ))
            ;;
        esac
        ;;
    esac
  done < <($_git_command status --porcelain=2 --branch 2>&1)

  if (( g[changed] == 0 && g[conflicts] == 0 && g[staged] == 0 && g[untracked] == 0 && g[deleted] == 0)) ; then
    g[clean]='yes_but_no_value_to_show'
  fi

  typeset -p g
}
#-----------------------------------------------------------------------------
function _prompt_print_git_fragment() {
  local theme="${_prompt_git_theme[$1]}"
  local show="${_prompt_git_theme[show_${1}_count]}"
  local value="${g[$1]}"

  [[ -z "$theme" ]] && return
  [[ "${show:=1}" == "1" ]] || return
  [[ "$value" == "0" ]] && return

  print -n "$theme"
  _prompt_reset

  [[ -z "$value" || "$value" == "yes_but_no_value_to_show" ]] && return
  print -n "$value"
}
#-----------------------------------------------------------------------------
_prompt_git() {
  (( $+commands[git] )) || return
  local _git_command="${1:=git}"

  eval "$(_prompt_update_git "$_git_command")"

  (( g[no_repository] == 1 )) && return

  for element in prefix branch behind ahead separator oid separator staged conflicts changed untracked deleted clean suffix ; do
    _prompt_print_git_fragment "$element"
  done
}
#-----------------------------------------------------------------------------
_language_version() {
  local language="$1"

  case "$language" in
    ruby)
      ruby --version | awk '{print $2}'
      ;;
    node)
      node --version | sed -e 's/^v//'
      ;;
    python)
      python --version |& awk '{print $2}'
      ;;
    python2)
      python2 --version |& awk '{print $2}'
      ;;
    python3)
      python3 --version |& awk '{print $2}'
      ;;
    elixir)
      elixir --version |& grep '^Elixir' | awk '{print $2}'
      ;;
    rust)
      rustc --version |& awk '{print $2}'
      ;;
    go|golang)
      go version |& sed -e 's/^go version go//' -e 's/ .*$//'
      ;;
    *)
      ;;
  esac
}
#-----------------------------------------------------------------------------
_prompt_time() {
  print -n "%F{8}%D{%H:%M:%S}"
}
#-----------------------------------------------------------------------------
__prompt_user() {
  print -n '%F{9}_%n_'
}

_prompt_user() {
  if typeset -f am_i_someone_else >&/dev/null ; then
    if am_i_someone_else ; then
      __prompt_user
    fi
  else
    __prompt_user
  fi
}
#-----------------------------------------------------------------------------
_prompt_host() {
  if [[ -n "$SSH_TTY" ]] ; then
    print -n '%F{15}@%F{14}%m'
  fi
}
#-----------------------------------------------------------------------------
_prompt_path() {
  print -n '%F{7}%~'
}
#-----------------------------------------------------------------------------
_prompt_lastexit() {
  print -n ' %(?.%F{7}.%F{15})%? %(!.#.$)'
}
#-----------------------------------------------------------------------------
_prompt_gitconfigs() {
  [[ "$PWD" == "$HOME" ]] || return

  if typeset -f pubgit >&/dev/null ; then
    print -n '%F{8}PUB:%f'
    _prompt_git pubgit
  fi

  if typeset -f prvgit >&/dev/null ; then
    print -n ' '
    print -n '%F{8}PRV:%f'
    _prompt_git prvgit
  fi
}
#-----------------------------------------------------------------------------
_async_prompt_language() {
  cd -q "$1"
  local _language="$2"

  [[ -n "$_language" ]] || return

  echo "_prompt_languages[${_language}]=\"%F{6}${_language}-$(_language_version "$_language")\""
}
#-----------------------------------------------------------------------------
_async_prompt_git() {
  cd -q "$1"
  echo "_prompt[git]=\"$(_prompt_git)\""
}
#-----------------------------------------------------------------------------
_async_prompt_gitconfigs() {
  cd -q "$1"
  echo "_prompt[gitconfigs]=\"$(_prompt_gitconfigs)\""
}
#-----------------------------------------------------------------------------
_async_prompt_callback() {
  [[ -n "$3" ]] \
    && eval "$3" \
    && zle \
    && zle -R  \
    && zle reset-prompt \
    >&/dev/null
}
#-----------------------------------------------------------------------------
_chorn_prompt_precmd() {
  async_job 'prompt_worker' _async_prompt_git "$PWD"
  async_job 'prompt_worker' _async_prompt_gitconfigs "$PWD"

  for _language in ${_preferred_languages[@]} ; do
    async_job 'prompt_worker' _async_prompt_language "$PWD" "$_language"
  done
}
#-----------------------------------------------------------------------------
_chorn_left_prompt() {
  local -a _line1=()
  local -a _line2=()

  _prompt[time]="$(_prompt_time)"
  _prompt[user]="$(_prompt_user)"
  _prompt[host]="$(_prompt_host)"
  _prompt[path]="$(_prompt_path)"

  for _language in ${_preferred_languages[@]} ; do
    [[ -n "${_prompt_languages[$_language]}" ]] && _line1+=("${_prompt_languages[$_language]}")
  done

  for piece in git gitconfigs ; do
    [[ -n "${_prompt[$piece]}" ]] && _line1+=("${_prompt[$piece]}")
  done

  [[ -n "${_prompt[vpn]}" ]] && _line1+=("${_prompt[vpn]}")

  for piece in time user host path ; do
    [[ -n "${_prompt[$piece]}" ]] && _line2+=("${_prompt[$piece]}")
  done

  if (( ${#_line1[@]} > 0 )) ; then
    _prompt_reset
    print "${_line1[@]}"
    _prompt_reset
  fi

  _prompt_reset
  print -n "${_line2[@]}"
  _prompt_lastexit # Like this or $? is wrong
  _prompt_reset
  print -n ' '
}
#-----------------------------------------------------------------------------
prompt_chorn_setup() {
  autoload -Uz async

  if ! typeset -f async >&/dev/null ; then
    echo "ERROR: 'async' must be in your fpath from the 'zsh-async' project: https://github.com/mafredri/zsh-async"
    return
  fi

  if ! typeset -p _preferred_languages >&/dev/null ; then
    typeset -g -a _preferred_languages=(ruby node python)
  fi

  if ! typeset -p _prompt_git_theme >&/dev/null ; then
    typeset -g -A _prompt_git_theme=(
      prefix '('
      suffix ')'
      separator '|'
      branch '%{$fg_bold[magenta]%}'
      clean '%{$fg_bold[green]%}%{✔%G%}'
      changed '%{$fg[blue]%}%{✚%G%}'
      staged '%{$fg[red]%}%{●%G%}'
      conflicts '%{$fg[red]%}%{✖%G%}'
      oid '%{$fg[gray]%}'
      ahead '%{↑%G%}'
      behind '%{↓%G%}'
      untracked '%{…%G%}'
      deleted '%{$fg[red]%}%{ᛞ⃠%G%}'
      show_changed_count 1
      show_staged_count 1
      show_conflict_count 1
      show_ahead_count 1
      show_behind_count 1
      show_untracked_count 0
    )
  fi

  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook

  async
  async_start_worker 'prompt_worker' -n
  async_register_callback 'prompt_worker' _async_prompt_callback
  add-zsh-hook precmd _chorn_prompt_precmd

  prompt_opts=(cr percent sp subst)

  PROMPT='$(_chorn_left_prompt)'
}
#-----------------------------------------------------------------------------
prompt_chorn_setup "$@"
#-----------------------------------------------------------------------------
# vim: set syntax=zsh ft=zsh sw=2 ts=2 expandtab:
