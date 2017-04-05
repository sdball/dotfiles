# CRUNCH - created from Steve Eley's cat waxing.
# Initially hacked from the Dallas theme. Thanks, Dallas Reedy.
#
# This theme assumes you do most of your oh-my-zsh'ed "colorful" work at a single machine, 
# and eschews the standard space-consuming user and hostname info.  Instead, only the 
# things that vary in my own workflow are shown:
#
# * The time (not the date)
# * The RVM version and gemset (omitting the 'ruby' name if it's MRI)
# * The current directory
# * The Git branch and its 'dirty' state
#
# Colors are at the top so you can mess with those separately if you like.
# For the most part I stuck with Dallas's.

CRUNCH_BRACKET_COLOR="%{$fg[white]%}"
CRUNCH_TIME_COLOR="%{$fg[yellow]%}"
CRUNCH_RB_COLOR="%{$fg[red]%}"
CRUNCH_EX_COLOR="%{$fg[magenta]%}"
CRUNCH_DIR_COLOR="%{$fg[cyan]%}"
CRUNCH_GIT_BRANCH_COLOR="%{$fg[green]%}"
CRUNCH_GIT_CLEAN_COLOR="%{$fg[green]%}"
CRUNCH_GIT_DIRTY_COLOR="%{$fg[red]%}"

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX="$CRUNCH_BRACKET_COLOR:$CRUNCH_GIT_BRANCH_COLOR"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=" $CRUNCH_GIT_CLEAN_COLOR✓"
ZSH_THEME_GIT_PROMPT_DIRTY=" $CRUNCH_GIT_DIRTY_COLOR✗"

# Our elements:
CRUNCH_TIME_="$CRUNCH_BRACKET_COLOR{$CRUNCH_TIME_COLOR%T$CRUNCH_BRACKET_COLOR}%{$reset_color%}"

# Ruby version
if command -v rbenv &> /dev/null; then
    CRUNCH_RB_="$CRUNCH_BRACKET_COLOR"["${CRUNCH_RB_COLOR}ruby \${\$(rbenv version | sed -e 's/ (set.*$//' -e 's/^ruby-//')}$CRUNCH_BRACKET_COLOR"]"%{$reset_color%}"
else
    if command -v asdf &> /dev/null && asdf current ruby &> /dev/null; then
        CRUNCH_RB_="$CRUNCH_BRACKET_COLOR"["${CRUNCH_RB_COLOR}ruby \${\$(asdf current ruby | cut -d ' ' -f 1)}$CRUNCH_BRACKET_COLOR"]"%{$reset_color%}"
    fi
fi

# Elixir version
if command -v asdf &> /dev/null && asdf current elixir &> /dev/null; then
    CRUNCH_EX_="$CRUNCH_BRACKET_COLOR"["${CRUNCH_EX_COLOR}elixir \${\$(asdf current elixir | cut -d ' ' -f 1)}$CRUNCH_BRACKET_COLOR"]"%{$reset_color%}"
fi

# state
CRUNCH_STATE_="$CRUNCH_BRACKET_COLOR"["${CRUNCH_STATE_COLOR}\${\$(prompt_state)}$CRUNCH_BRACKET_COLOR"]"%{$reset_color%}"

CRUNCH_DIR_="$CRUNCH_DIR_COLOR%~\$(git_prompt_info) "
CRUNCH_PROMPT="$CRUNCH_BRACKET_COLOR
$ "

# Put it all together!
PROMPT="$CRUNCH_EX_$CRUNCH_RB_$CRUNCH_STATE_$CRUNCH_DIR_$CRUNCH_PROMPT%{$reset_color%}"
