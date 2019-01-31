setopt inc_append_history # save every command before it is executed
setopt share_history # retrieve the history file everytime history is called upon

DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_CUSTOM=$HOME/.omz-custom
[[ -s $HOME/.local_zshrc ]] && source $HOME/.local_zshrc

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  echo "Creating a zgen save"
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-completions src
  zgen save
fi

fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  # fasd --init posix-alias if you want to see the default aliases
  fasd --init zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# rbenv
command -v rbenv >& /dev/null && eval "$(rbenv init -)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

# terse terse prompt by default
tt

export PATH="$HOME/.cargo/bin:$PATH"

if [[ -d $HOME/Library/Python/3.6/bin ]]; then
  export PATH="$HOME/Library/Python/3.6/bin:$PATH"
fi

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

export PATH="/usr/local/sbin:$PATH"

if (( $+commands[direnv] )) ; then
  eval "$(direnv hook zsh)"
fi

