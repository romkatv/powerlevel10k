#!/usr/bin/zsh

emulate -L zsh
setopt err_exit no_unset pipe_fail extended_glob xtrace

: ${GITSTATUS_DIR:=${${(%):-%x}:A:h}}
: ${GITSTATUS_URL:=https://github.com/romkatv/gitstatus.git}

readonly GITSTATUS_DIR GITSTATUS_URL
readonly -a IGNORE=(pull-upstream.zsh README.md)

() {
  local repo && repo="$(mktemp -d ${TMPDIR:-/tmp}/gitstatus-pull-upstream.XXXXXXXXXX)"
  trap "rm -rf ${(q)repo}" EXIT
  git clone --depth 1 $GITSTATUS_URL $repo

  local dst
  for dst in $GITSTATUS_DIR/**/*(.,@); do
    local f=${dst#$GITSTATUS_DIR/}
    (( ! ${IGNORE[(I)$f]} )) || continue
    local src=$repo/$f
    [[ -f $src ]] && {
      mkdir -p ${dst:h} && cp -f $src $dst || return
    } || {
      rm -f $dst
    }
  done
}
