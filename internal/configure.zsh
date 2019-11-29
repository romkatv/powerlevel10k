typeset -gr __p9k_wizard_columns=55
typeset -gr __p9k_wizard_lines=21
typeset -gr __p9k_zd=${ZDOTDIR:-$HOME}
typeset -gr __p9k_zd_u=${${${(q)__p9k_zd}/#(#b)${(q)HOME}(|\/*)/'~'$match[1]}//\%/%%}
typeset -gr __p9k_cfg_basename=.p10k.zsh
typeset -gr __p9k_cfg_path=$__p9k_zd/$__p9k_cfg_basename
typeset -gr __p9k_cfg_path_u=$__p9k_zd_u/$__p9k_cfg_basename
typeset -gr __p9k_zshrc=$__p9k_zd/.zshrc
typeset -gr __p9k_zshrc_u=$__p9k_zd_u/.zshrc
typeset -gr __p9k_root_dir_u=${${${(q)__p9k_root_dir}/#(#b)${(q)HOME}(|\/*)/'~'$match[1]}//\%/%%}

function _p9k_can_configure() {
  emulate -L zsh
  setopt extended_glob no_prompt_{bang,subst} prompt_percent
  [[ $1 == '-q' ]] && local -i q=1 || local -i q=0
  function $0_error() {
    (( q )) || print -rP "%1F[ERROR]%f %Bp10k configure%b: $1" >&2
  }
  {
    [[ -o multibyte ]]         || { $0_error "multibyte option is not set";      return 1 }
    [[ -e $__p9k_zd ]]         || { $0_error "$__p9k_zd_u does not exist";       return 1 }
    [[ -d $__p9k_zd ]]         || { $0_error "$__p9k_zd_u is not a directory";   return 1 }
    [[ -w $__p9k_zd ]]         || { $0_error "$__p9k_zd_u is not writable";      return 1 }
    [[ ! -d $__p9k_cfg_path ]] || { $0_error "$__p9k_cfg_path_u is a directory"; return 1 }
    [[ ! -d $__p9k_zshrc ]]    || { $0_error "$__p9k_zshrc_u is a directory";    return 1 }

    [[ ! -e $__p9k_cfg_path || -f $__p9k_cfg_path || -h $__p9k_cfg_path ]] || {
      $0_error "$__p9k_cfg_path_u is a special file"
      return 1
    }
    [[ -r $__p9k_root_dir/config/p10k-lean.zsh ]]                          || {
      $0_error "cannot read $__p9k_root_dir_u/config/p10k-lean.zsh"
      return 1
    }
    [[ -r $__p9k_root_dir/config/p10k-classic.zsh ]]                       || {
      $0_error "cannot read $__p9k_root_dir_u/config/p10k-classic.zsh"
      return 1
    }
    [[ ! -e $__p9k_zshrc || -f $__p9k_zshrc || -h $__p9k_zshrc ]]          || {
      $0_error "$__p9k_zshrc_u a special file"
      return 1
    }
    [[ ! -e $__p9k_zshrc || -r $__p9k_zshrc ]]                             || {
      $0_error "$__p9k_zshrc_u is not readable"
      return 1
    }
    [[ ! -e $__p9k_zshrc || -w $__p9k_zshrc ]]                             || {
      $0_error "$__p9k_zshrc_u is not writable"
      return 1
    }
    (( LINES >= __p9k_wizard_lines && COLUMNS >= __p9k_wizard_columns ))   || {
      $0_error "terminal size too small; must be at least $__p9k_wizard_columns x $__p9k_wizard_lines"
      return 1
    }
    [[ -t 0 && -t 1 ]]         || { $0_error "no TTY";                           return 2 }
    return 0
  } always {
    unfunction $0_error
  }
}

function p9k_configure() {
  emulate -L zsh
  setopt no_hist_expand extended_glob
  (
    set -- -f
    source $__p9k_root_dir/internal/wizard.zsh
  )
  local ret=$?
  case $ret in
    0)  source $__p9k_cfg_path; _p9k__force_must_init=1;;
    69) return 0;;
    *)  return $ret;;
  esac
}
