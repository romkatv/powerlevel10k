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

################################################################
# For basic documentation, please refer to the README.md in the
# top-level directory.
################################################################

## Turn on for Debugging
#PS4='%s%f%b%k%F{blue}%{λ%}%L %F{240}%N:%i%(?.. %F{red}%?) %1(_.%F{yellow}%-1_ .)%s%f%b%k '
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

() {
  'builtin' 'emulate' '-L' 'zsh'

  'builtin' 'local' "_p9k_aliases=$(
      'builtin' 'alias' '-rL'
      'builtin' 'alias' '-gL'
      'builtin' 'alias' '-sL')"

  'builtin' 'unalias' '-m' '*'

  {
    if (( $+_p9k_sourced )); then
      prompt_powerlevel9k_setup
      return
    fi
    typeset -gr _p9k_sourced=1
    typeset -g _p9k_installation_dir=''

    if [[ -n $POWERLEVEL9K_INSTALLATION_DIR ]]; then
      _p9k_installation_dir=${POWERLEVEL9K_INSTALLATION_DIR:A}
    else
      if [[ ${(%):-%N} == '(eval)' ]]; then
        if [[ $0 == '-antigen-load' && -r powerlevel9k.zsh-theme ]]; then
          # Antigen uses eval to load things so it can change the plugin (!!)
          # https://github.com/zsh-users/antigen/issues/581
          _p9k_installation_dir=$PWD
        else
          >&2 print -P '%F{red}[ERROR]%f Powerlevel10k cannot figure out its installation directory.'
          >&2 print -P 'Please set %F{green}POWERLEVEL9K_INSTALLATION_DIR.%f'
          return 1
        fi
      else
        _p9k_installation_dir=${${(%):-%x}:A:h}
      fi
    fi

    source $_p9k_installation_dir/internal/p10k.zsh
  } always {
    eval "$_p9k_aliases"
  }
}
