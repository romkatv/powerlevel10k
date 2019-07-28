typeset -gr __p9k_zd=${ZDOTDIR:-$HOME}
typeset -gr __p9k_zd_u=${__p9k_zd/#(#b)$HOME(|\/*)/'~'$match[1]}
typeset -gr __p9k_cfg_basename=.p10k.zsh
typeset -gr __p9k_cfg_path=$__p9k_zd/$__p9k_cfg_basename
typeset -gr __p9k_cfg_path_u=$__p9k_zd_u/$__p9k_cfg_basename
typeset -gr __p9k_installation_dir_u=${__p9k_installation_dir/#(#b)$HOME(|\/*)/'~'$match[1]}

function _p9k_can_configure() {
  emulate -L zsh
  setopt err_return
  [[ $1 == '-q' ]] && local -i q=1 || local -i q=0
  function $0_error() {
    (( q )) || print -P "%1F[ERROR]%f %Bp9k_configure%b: $1" >&2
    return 1
  }
  {
    [[ -t 0 && -t 1 ]]                                || $0_error "no TTY"
    (( LINES >= 20 && COLUMNS >= 70 ))                || $0_error "terminal size too small"
    [[ -o multibyte ]]                                || $0_error "multibyte option is not set"
    [[ "${#$(print -P '\u276F' 2>/dev/null)}" == 1 ]] || $0_error "shell doesn't support unicode"
    [[ -w $__p9k_zd ]]                                || $0_error "$__p9k_zd_u is not writable"
    [[ ! -d $__p9k_cfg_path ]]                        || $0_error "$__p9k_cfg_path_u is a directory"

    [[ ! -e $__p9k_cfg_path || -f $__p9k_cfg_path || -h $__p9k_cfg_path ]] ||
      $0_error "$__p9k_cfg_path_u is a special file"
    [[ -r $__p9k_installation_dir/config/p10k-lean.zsh ]] ||
      $0_error "cannot read $__p9k_installation_dir_u/config/p10k-lean.zsh"
    [[ -r $__p9k_installation_dir/config/p10k-classic.zsh ]] ||
      $0_error "cannot read $__p9k_installation_dir_u/config/p10k-classic.zsh"
  } always {
    unfunction $0_error
  }
}
