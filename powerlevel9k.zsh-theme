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

() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_{bang,subst} prompt_{cr,percent,sp}

  if (( $+__p9k_sourced )); then
    prompt_powerlevel9k_setup
    return
  fi
  typeset -gr __p9k_sourced=1
  typeset -g __p9k_root_dir=''

  if [[ -n $POWERLEVEL9K_INSTALLATION_DIR ]]; then
    __p9k_root_dir=${POWERLEVEL9K_INSTALLATION_DIR:A}
  else
    if [[ ${(%):-%N} == '(eval)' ]]; then
      if [[ $0 == '-antigen-load' && -r powerlevel9k.zsh-theme ]]; then
        # Antigen uses eval to load things so it can change the plugin (!!)
        # https://github.com/zsh-users/antigen/issues/581
        __p9k_root_dir=$PWD
      else
        >&2 print -P '%F{red}[ERROR]%f Powerlevel10k cannot figure out its installation directory.'
        >&2 print -P 'Please set %F{green}POWERLEVEL9K_INSTALLATION_DIR.%f'
        return
      fi
    else
      __p9k_root_dir=${${(%):-%x}:A:h}
    fi
  fi

  typeset -gr __p9k_root_dir
  source $__p9k_root_dir/internal/p10k.zsh || true
}

(( ! __p9k_restore_aliases )) || setopt aliases
'builtin' 'unset' '__p9k_restore_aliases'
