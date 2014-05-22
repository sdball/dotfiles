# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots while waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=/home/deploy/.omz-custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# plugins=(git)

# ----> setup plugins in .local_zshrc <----
source $HOME/.local_zshrc

source $ZSH/oh-my-zsh.sh

# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

setopt braceccl
unsetopt correct_all # don't try to correct arguments (it's usually wrong)
setopt correct # but try to correct commands (it's usually right)
setopt autocd # type the name of a subdirectory will cd into that subdirectory

lebowski || echo "Not ready reading drive A"; echo "Abort, Retry, Fail?"

# RVM
[[ -s $HOME/.rvm ]] && PATH=$HOME/.rvm/bin:$PATH # Add RVM to PATH for scripting
[[ -s $HOME/.rvm ]] && source $HOME/.rvm/scripts/rvm
