#-----------------------------------------------------------------------------
for s in ~/.shell-common \
    ~/.fzf.zsh \
    ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
    ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f "$s" ]] && source "$s"
done
#-----------------------------------------------------------------------------
typeset -g -a _preferred_languages=(ruby elixir)

alias -g M='| $PAGER'
bindkey -e
bindkey -m 2>/dev/null

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit && compinit -C
#-----------------------------------------------------------------------------
autoload -Uz zcalc
__calc() {
  zcalc -e "$*"
}
aliases[=]='noglob __calc'
#-----------------------------------------------------------------------------
fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  # fasd --init posix-alias if you want to see the default aliases
  fasd --init zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache
#-----------------------------------------------------------------------------
alias a=prompt-async
alias t=prompt-terse
alias tt=prompt-tterse
alias v=prompt-verbose
alias vv=prompt-vverbose

prompt-async() {
  prompt chorn
}

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

autoload -U promptinit
promptinit

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# history is important
typeset -g SAVEHIST=99999999
typeset -g HISTSIZE=99999999

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

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# very special zsh magic to allow vim to open a filelist with files that might have spaces
vimmo() {
  vim -O -- "${(f)$($*)}"
}

if command -v rbenv >/dev/null; then
  eval "$(rbenv init -)"
fi

prompt chorn
