export PATH="/usr/local/bin:$PATH"
local _start=`gdate +%s%3N`
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
ZSH_CUSTOM=$HOME/.omz-custom
source $HOME/.local_zshrc

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  echo "Creating a zgen save"

  zgen oh-my-zsh

  # plugins
  zgen oh-my-zsh plugins/bundler
  zgen oh-my-zsh plugins/cargo
  zgen oh-my-zsh plugins/common-aliases
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/encode64
  zgen oh-my-zsh plugins/gem
  zgen oh-my-zsh plugins/git-extras
  zgen oh-my-zsh plugins/gitfast
  zgen oh-my-zsh plugins/mix
  zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/sudo
  zgen load zsh-users/zsh-syntax-highlighting

  # completions
  zgen load zsh-users/zsh-completions src

  # theme
  zgen load $HOME/.omz-custom/themes/custom_crunch

  # save all to init script
  zgen save
fi

fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# BASE16_SHELL=$HOME/.config/base16-shell/
# [ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"

# generic shell stuff
[[ -s $HOME/.aliases ]] && source $HOME/.aliases
[[ -s $HOME/.env ]] && source $HOME/.env
[[ -s $HOME/.functions ]] && source $HOME/.functions

# tmuxinator: I'll be back
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

# thefuck
command -v thefuck >&/dev/null && eval $(thefuck --alias oops)

# NVM
# [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_BIN=/Users/stephen.ball/.nvm/versions/node/v6.11.1/bin
  export NVM_CD_FLAGS=-q
  export NVM_DIR=$HOME/.nvm
  export PATH="$HOME/.nvm/versions/node/v6.11.1/bin:$PATH"
fi

# RVM
[[ -s $HOME/.rvm ]] && PATH=$HOME/.rvm/bin:$PATH # Add RVM to PATH for scripting
[[ -s $HOME/.rvm ]] && source $HOME/.rvm/scripts/rvm

# rbenv
command -v rbenv >& /dev/null && eval "$(rbenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --glob "!_build/*" --glob "!deps/*" --glob "!.DS_Store" --glob "!public/*" --glob "!log/*" --glob "!tmp/*" --glob "!vendor/*" --glob "!.git-crypt/*" --glob "!.vagrant/*"'
# '

# direnv
command -v direnv >& /dev/null && eval "$(direnv hook zsh)"

local _end=`gdate +%s%3N`
ruby -e "puts ($_end.to_i - $_start.to_i).to_s + 'ms to prompt'"

