# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Powerlevel10k Theme
# https://github.com/romkatv/powerlevel10k
#
# Forked from Powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# Which in turn was forked from Agnoster Theme
# https://github.com/robbyrussell/oh-my-zsh/blob/74177c5320b2a1b2f8c4c695c05984b57fd7c6ea/themes/agnoster.zsh-theme
################################################################

if [[ -o 'aliases' ]]; then
  'builtin' 'unsetopt' 'aliases'
  local __p9k_restore_aliases=1
else
  local __p9k_restore_aliases=0
fi

typeset -g __p9k_root_dir="${POWERLEVEL9K_INSTALLATION_DIR:-${${(%):-%x}:A:h}}"

() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang no_prompt_subst prompt_percent
  if (( $+__p9k_sourced )); then
    prompt_powerlevel9k_setup
    return
  fi
  typeset -gr __p9k_sourced=1
  source $__p9k_root_dir/internal/p10k.zsh || true
}

(( ! __p9k_restore_aliases )) || setopt aliases
'builtin' 'unset' '__p9k_restore_aliases'
