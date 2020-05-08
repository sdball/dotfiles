# base16 shell
if [[ -s "$HOME/.config/base16-shell" ]]; then
  BASE16_SHELL=$HOME/.config/base16-shell/
  [[ -n "$PS1" ]] && [[ -s $BASE16_SHELL/profile_helper.sh ]] && eval "$($BASE16_SHELL/profile_helper.sh)"
fi

# Git gpg
export GPG_TTY=$(tty)
