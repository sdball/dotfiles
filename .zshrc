_start=$(ruby --disable-gems -e "puts Float(Time.now) * 1000")
#-----------------------------------------------------------------------------
for s in ~/.shell-path \
    ~/.shell-common \
    ~/.fzf.zsh \
    ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
    ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -f "$s" ]] && source "$s"
done
#-----------------------------------------------------------------------------
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit && compinit -C
#-----------------------------------------------------------------------------
fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  # fasd --init posix-alias if you want to see the default aliases
  fasd --init zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache
#-----------------------------------------------------------------------------

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

if (( $+commands[direnv] )) ; then
  eval "$(direnv hook zsh)"
fi

[[ -s $HOME/.local_zshrc ]] && source $HOME/.local_zshrc

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if command -v rbenv >/dev/null; then
  eval "$(rbenv init -)"
fi

_end=$(ruby --disable-gems -e "puts Float(Time.now) * 1000")
echo "Time to prompt: " $((_end - _start)) " ms"
