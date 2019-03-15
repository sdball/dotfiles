#-----------------------------------------------------------------------------
for s in \
    ~/.shell-common \
    ~/.config/zsh/zsh-async/async.zsh
do
  if [[ -f "$s" ]] ; then
    source "$s"
  else
    echo "ERROR: $s is an expected dependency"
  fi
done
#-----------------------------------------------------------------------------
for s in \
    ~/.fzf.zsh \
    ~/.zsh-git \
    ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
    ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f "$s" ]] && source "$s"
done

#-----------------------------------------------------------------------------
typeset -g -a _preferred_languages=(ruby node python)
typeset -g -A _prompt
typeset -g -A _prompt_languages
#-----------------------------------------------------------------------------
fpath=(/usr/local/share/zsh-completions $fpath)
#-----------------------------------------------------------------------------
fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  # fasd --init posix-alias if you want to see the default aliases
  fasd --init zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# rbenv
command -v rbenv >& /dev/null && eval "$(rbenv init -)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# forgit
if ! typset -f forgit::warn >&/dev/null ; then
  local _forgit="$HOME/.config/zsh/forgit/forgit.plugin.zsh"
  [[ -f "$_forgit" ]] || return
  forgit() {
    source "$_forgit"
  }
fi

# # direnv
command -v direnv >& /dev/null && eval "$(direnv hook zsh)"

# bind up and down arrows to search through history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# bind emacs command editing: ^X^E
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

if [ -f ~/.config/exercism/exercism_completion.zsh ]; then
  source ~/.config/exercism/exercism_completion.zsh
fi

# neovim if possible
# NOT YET
# if command -v nvim > /dev/null; then
#   export EDITOR=nvim
#   alias vim=nvim
#   alias vi=nvim
# else
#   export EDITOR=vim
# fi

if (( $+commands[direnv] )) ; then
  eval "$(direnv hook zsh)"
fi

[[ -s $HOME/.local_zshrc ]] && source $HOME/.local_zshrc

# -- terse/verbose prompt things --
alias a=prompt-async
alias t=prompt-terse
alias tt=prompt-tterse
alias v=prompt-verbose
alias vv=prompt-vverbose
prompt-terse() {
  PROMPT="`prompt-tags`$ "
}

prompt-tterse() {
  PROMPT="$ "
}

prompt-verbose() {
  PROMPT="`pwd` `prompt-tags`$ "
}

prompt-vverbose() {
  PROMPT="`pwd` (`current-git-checkout`) `prompt-tags`$ "
}

# -- async prompt things --
prompt-async() {
  PROMPT='$(left_prompt)'
  RPROMPT=''
}
prompt-async # call now to make this the default prompt

#-----------------------------------------------------------------------------
_nonprintable_begin() {
  print -n '\001'
}
#-----------------------------------------------------------------------------
_nonprintable_end() {
  print -n '\002'
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
    *)
      ;;
  esac
}
#-----------------------------------------------------------------------------
_prompt_reset() {
  print -n "%f%b%k%u%s"
}
#-----------------------------------------------------------------------------
_prompt_time() {
  print -n "%F{8}%D{%H:%M:%S}"
}
#-----------------------------------------------------------------------------
_prompt_user() {
  if am_i_someone_else ; then
    print -n "%F{9}_%n_"
  fi
}
#-----------------------------------------------------------------------------
_prompt_host() {
  if [[ -n "$SSH_TTY" ]] ; then
    print -n "%F{15}@%F{14}%m"
  fi
}
#-----------------------------------------------------------------------------
_prompt_path() {
  print -n "%F{7}%~"
}
#-----------------------------------------------------------------------------
_prompt_lastexit() {
  print -n ' %(?.%F{7}.%F{15})%? %(!.#.$)'
}
#-----------------------------------------------------------------------------
_prompt_gitrepo() {
  (( $+commands[git] )) || return
  typeset -f _prompt_update_git >&/dev/null || return

  _prompt_update_git
  local _git_prompt="$(build_git_status)"

  if [[ -n "${_git_prompt}" ]] ; then
    print -n "%f${_git_prompt}"
  fi
}
#-----------------------------------------------------------------------------
_prompt_gitconfigs() {
  [[ "$PWD" == "$HOME" ]] || return
  (( $+commands[git] )) || return
  typeset -f _prompt_update_git >&/dev/null || return

  if typeset -f pubgit >&/dev/null ; then
    _prompt_update_git pubgit .git-pub-dotfiles
    print -n "%F{8}PUB:%f$(build_git_status pubgit)"
  fi

  if typeset -f prvgit >&/dev/null ; then
    _prompt_update_git prvgit .git-prv-dotfiles
    print -n ' '
    print -n "%F{8}PRV:%f$(build_git_status prvgit)"
  fi
}
#-----------------------------------------------------------------------------
left_prompt() {
  local -a _line1=()
  local -a _line2=()

  _prompt[time]="$(_prompt_time)"
  _prompt[user]="$(_prompt_user)"
  _prompt[host]="$(_prompt_host)"
  _prompt[path]="$(_prompt_path)"

  for _language in ${_preferred_languages[@]} ; do
    [[ -n "${_prompt_languages[$_language]}" ]] && _line1+=("${_prompt_languages[$_language]}")
  done

  for piece in gitrepo gitconfigs ; do
    [[ -n "${_prompt[$piece]}" ]] && _line1+=("${_prompt[$piece]}")
  done

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
  _prompt_lastexit
  _prompt_reset
  print -n ' '
}
#-----------------------------------------------------------------------------
_async_prompt_language() {
  cd -q "$1"
  local _language="$2"

  [[ -n "$_language" ]] || return

  echo "_prompt_languages[${_language}]=\"%F{6}${_language}-$(_language_version "$_language")\""
}
#-----------------------------------------------------------------------------
_async_prompt_gitrepo() {
  cd -q "$1"
  echo "_prompt[gitrepo]=\"$(_prompt_gitrepo)\""
}
#-----------------------------------------------------------------------------
_async_prompt_gitconfigs() {
  cd -q "$1"
  echo "_prompt[gitconfigs]=\"$(_prompt_gitconfigs)\""
}

#-----------------------------------------------------------------------------
_async_prompt_callback() {
  [[ -n "$3" ]] && eval "$3" && zle && zle reset-prompt >&/dev/null
}
#-----------------------------------------------------------------------------
prompt_precmd() {
  typeset -f async_job >&/dev/null || return
  async_job 'prompt_worker' _async_prompt_gitrepo "$PWD"
  async_job 'prompt_worker' _async_prompt_gitconfigs "$PWD"
  for _language in ${_preferred_languages[@]} ; do
    async_job 'prompt_worker' _async_prompt_language "$PWD" "$_language"
  done
}
#-----------------------------------------------------------------------------
typeset -f async_init >&/dev/null || return

async_init
async_start_worker 'prompt_worker' -n
async_register_callback 'prompt_worker' _async_prompt_callback
add-zsh-hook precmd prompt_precmd

