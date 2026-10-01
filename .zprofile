# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/sdball/.docker/bin"
# End of Docker Desktop section.

if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

if command -v brew > /dev/null; then
  eval $(brew shellenv)
fi
