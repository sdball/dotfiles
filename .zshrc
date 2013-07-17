[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions
[[ -s $HOME/.zsh/colors.zsh ]] && source $HOME/.zsh/colors.zsh
[[ -s $HOME/.zsh/bindkeys.zsh ]] && source $HOME/.zsh/bindkeys.zsh

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
PATH=$PATH:$HOME/.rvm/bin
