# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="blinks"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# plugins=(git bundler brew gem sdball rvm)
# setup plugins in .local_zshrc

# needs to come before oh-my-zsh.sh since it includes plugins
[[ -s $HOME/.local_zshrc ]] && source $HOME/.local_zshrc

# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# rubies!
[[ -s /usr/local/share/chruby/chruby.sh ]] && source /usr/local/share/chruby/chruby.sh
[[ -s /usr/local/share/chruby/auto.sh ]] && source /usr/local/share/chruby/auto.sh
[[ -s ~/.ruby-version ]] && chruby `cat ~/.ruby-version`

source $ZSH/oh-my-zsh.sh

setopt braceccl
unsetopt correct_all # don't try to correct arguments (it's usually wrong)
setopt correct # but try to correct commands (it's usually right)
setopt autocd # type the name of a subdirectory will cd into that subdirectory

which fortune 1> /dev/null
if [[ $? == 0 ]]; then
    echo
    fortune
else
    echo
    echo "Not ready reading drive A"
    echo "Abort, Retry, Fail?"
fi
