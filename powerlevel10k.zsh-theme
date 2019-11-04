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

# Temporarily change options.
'builtin' 'local' '-a' '__p9k_src_opts'
[[ ! -o 'aliases'         ]] || __p9k_src_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || __p9k_src_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || __p9k_src_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

(( $+__p9k_root_dir )) || typeset -gr __p9k_root_dir=${POWERLEVEL9K_INSTALLATION_DIR:-${${(%):-%x}:A:h}}

() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang no_prompt_subst prompt_percent no_aliases
  if (( $+__p9k_sourced )); then
    prompt_powerlevel9k_setup
    return 0
  fi
  typeset -gr __p9k_dump_file=${XDG_CACHE_HOME:-~/.cache}/p10k-dump-${(%):-%n}.zsh
  if [[ $__p9k_dump_file != $__p9k_instant_prompt_dump_file ]] && (( ! $+functions[_p9k_preinit] )) && source $__p9k_dump_file 2>/dev/null && (( $+functions[_p9k_preinit] )); then
    _p9k_preinit
  fi
  typeset -gr __p9k_sourced=1
  if [[ -w $__p9k_root_dir && -w $__p9k_root_dir/internal && -w $__p9k_root_dir/gitstatus && ${(%):-%#} == % ]]; then
    local f
    for f in $__p9k_root_dir/{powerlevel9k.zsh-theme,powerlevel10k.zsh-theme,internal/p10k.zsh,internal/icons.zsh,internal/configure.zsh,gitstatus/gitstatus.plugin.zsh}; do
      [[ $f.zwc -nt $f ]] || zcompile $f
    done
  fi
  source $__p9k_root_dir/internal/p10k.zsh || true
}

(( ! $+__p9k_instant_prompt_active )) || unsetopt local_options prompt_cr prompt_sp

(( ${#__p9k_src_opts} )) && setopt ${__p9k_src_opts[@]}
'builtin' 'unset' '__p9k_src_opts'
