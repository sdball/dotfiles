if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if command -v brew > /dev/null; then
  eval $(brew shellenv)
fi
