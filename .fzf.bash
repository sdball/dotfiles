# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/sdball/.fzf/bin* ]]; then
  export PATH="$PATH:/Users/sdball/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/sdball/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/Users/sdball/.fzf/shell/key-bindings.bash"

