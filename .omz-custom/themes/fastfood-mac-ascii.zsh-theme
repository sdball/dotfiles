#!/bin/bash
# fastfood - hacked from CRUNCH

function time_since() {
    now=`date +%s`
    compared_time=$1
    seconds_since=$((now-$compared_time))
    minutes=$((seconds_since/60))
    hours=$((seconds_since/3600))
    days=$((seconds_since/86400))
    sub_hours=$((hours%24))
    sub_minutes=$((minutes%60))
}

FASTFOOD_BACKUP_DRIVE_VOLUME="Backup"
FASTFOOD_BRACKET_COLOR="%{$fg[white]%}"
FASTFOOD_TIME_COLOR="%{$fg[yellow]%}"
FASTFOOD_RUBY_COLOR="%{$fg[magenta]%}"
FASTFOOD_DIR_COLOR="%{$fg[cyan]%}"
FASTFOOD_GIT_BRANCH_COLOR="%{$fg[green]%}"
FASTFOOD_GIT_CLEAN_COLOR="%{$fg[green]%}"
FASTFOOD_GIT_DIRTY_COLOR="%{$fg[red]%}"
FASTFOOD_TIME_SINCE_LONG="%{$fg[red]%}"
FASTFOOD_TIME_SINCE_MEDIUM="%{$fg[yellow]%}"
FASTFOOD_TIME_SINCE_SHORT="%{$fg[green]%}"
FASTFOOD_EMOJI="$"
FASTFOOD_BACKUP_DRIVE_MOUNTED="[M]"
FASTFOOD_BACKUP_DRIVE_UNMOUNTED="[_]"

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX="$FASTFOOD_BRACKET_COLOR:$FASTFOOD_GIT_BRANCH_COLOR"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN="${FASTFOOD_GIT_CLEAN_COLOR}*"
ZSH_THEME_GIT_PROMPT_DIRTY="${FASTFOOD_GIT_DIRTY_COLOR}X"

# Our elements:
DALLAS_CURRENT_MACH_="%{$fg[green]%}%m%{$fg[white]%}:%{$reset_color%}"
FASTFOOD_TIME_="$FASTFOOD_BRACKET_COLOR{$FASTFOOD_TIME_COLOR%T$FASTFOOD_BRACKET_COLOR}%{$reset_color%}"
if [ -e ~/.rvm/bin/rvm-prompt ]; then
  FASTFOOD_RUBY_="$FASTFOOD_BRACKET_COLOR"["$FASTFOOD_RUBY_COLOR\${\$(~/.rvm/bin/rvm-prompt i v g)#ruby-}$FASTFOOD_BRACKET_COLOR"]"%{$reset_color%}"
fi

if which rbenv &> /dev/null; then
  FASTFOOD_RUBY_="$FASTFOOD_BRACKET_COLOR"["$FASTFOOD_RUBY_COLOR\${\$(rbenv version | sed -e 's/ (set.*$//' -e 's/^ruby-//')}$FASTFOOD_BRACKET_COLOR"]"%{$reset_color%}"
fi

if which current_ruby &> /dev/null; then
  FASTFOOD_RUBY_="$FASTFOOD_BRACKET_COLOR"["$FASTFOOD_RUBY_COLOR\${\$(current_ruby)}$FASTFOOD_BRACKET_COLOR"]"%{$reset_color%}"
fi

FASTFOOD_DIR_="$FASTFOOD_DIR_COLOR%~\$(git_prompt_info) "

FASTFOOD_PROMPT="$FASTFOOD_BRACKET_COLOR$FASTFOOD_EMOJI "

# Wrap up the left prompt
PROMPT="$DALLAS_CURRENT_MACH_$FASTFOOD_BACKUP_$FASTFOOD_RUBY_$FASTFOOD_DIR_$FASTFOOD_PROMPT%{$reset_color%}"
RPROMPT='$(backup_status)'
