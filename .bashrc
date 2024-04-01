# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

source /Users/sdball/.config/broot/launcher/bash/br
