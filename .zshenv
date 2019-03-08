# straight from https://github.com/chorn/dotfiles
#-----------------------------------------------------------------------------
typeset -g HISTFILE="$HOME/.zsh_history"
typeset -g SAVEHIST=99999999999
typeset -g WORDCHARS='*?_-.[]~&;!#$%^(){}<>'
skip_global_compinit=1
typeset -g PROMPT="%f%b%k%u%s%n@%m %~ %(!.#.$)%f%b%k%u%s "
#-----------------------------------------------------------------------------
zmodload zsh/compctl \
         zsh/complete \
         zsh/complist \
         zsh/datetime \
         zsh/main \
         zsh/parameter \
         zsh/terminfo \
         zsh/zle \
         zsh/zleparameter \
         zsh/zutil

#-----------------------------------------------------------------------------
setopt \
  always_to_end \
  auto_cd \
  auto_list \
  auto_menu \
  auto_param_slash \
  brace_ccl \
  case_glob \
  cdable_vars \
  check_jobs \
  clobber \
  combining_chars \
  complete_in_word \
  emacs \
  extended_glob \
  hash_list_all \
  interactive_comments \
  list_ambiguous \
  list_packed \
  list_types \
  long_list_jobs \
  multios \
  path_dirs \
  posix_builtins \
  prompt_subst

unsetopt \
  auto_resume \
  beep \
  bg_nice \
  correct \
  correct_all \
  flow_control \
  hup \
  list_beep \
  mail_warning \
  menu_complete \
  notify

# History
setopt \
  append_history \
  bang_hist \
  extended_history \
  hist_allow_clobber \
  hist_fcntl_lock \
  hist_find_no_dups \
  hist_ignore_space \
  hist_no_store \
  hist_reduce_blanks \
  hist_verify \
  inc_append_history

unsetopt \
  hist_ignore_all_dups \
  inc_append_history_time \
  share_history
#-----------------------------------------------------------------------------
# typeset -g _debug_times
# typeset -F SECONDS
#
# function debug_timer() {
#   [[ -z "$_debug_times" ]] && return
#   local _what="$1"
#   local _start="$2"
#   print -f "%d %2.3f %s\n" $$ $(( SECONDS - _start )) "$_what" >> ~/zsh_debug_timer
# }
#-----------------------------------------------------------------------------
for s in ~/.shell-path ~/.shell-env ; do
  [[ -f "$s" ]] && source "$s"
done
#-----------------------------------------------------------------------------
# vim: set syntax=zsh ft=zsh sw=2 ts=2 expandtab:
