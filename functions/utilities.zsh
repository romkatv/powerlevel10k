# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Utility functions
# This file holds some utility-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

# Usage: set_default [OPTION]... NAME [VALUE]...
#
# Options are the same as in `typeset`.
function set_default() {
  emulate -L zsh
  local -a flags=(-g)
  while true; do
    case $1 in
      --) shift; break;;
      -*) flags+=$1; shift;;
      *) break;
    esac
  done

  local varname=$1
  shift
  if [[ -n ${(tP)varname} ]]; then
    typeset $flags $varname
  elif [[ "$flags" == *[aA]* ]]; then
    eval "typeset ${(@q)flags} ${(q)varname}=(${(qq)@})"
  else
    typeset $flags $varname="$*"
  fi
}

function _p9k_g_expand() {
  (( $+parameters[$1] )) || return
  local -a ts=("${=$(typeset -p $1)}")
  shift ts
  local x
  for x in "${ts[@]}"; do
    [[ $x == -* ]] || break
    # Don't change readonly variables. Ideally, we shouldn't modify any variables at all,
    # but for now this will do.
    [[ $x == -*r* ]] && return
  done
  typeset -g $1=${(g::)${(P)1}}
}

# If we execute `print -P $1`, how many characters will be printed on the last line?
# Assumes that `%{%}` and `%G` don't lie.
#
#   _p9k_prompt_length '' => 0
#   _p9k_prompt_length 'abc' => 3
#   _p9k_prompt_length $'abc\nxy' => 2
#   _p9k_prompt_length $'\t' => 8
#   _p9k_prompt_length '%F{red}abc' => 3
#   _p9k_prompt_length $'%{a\b%Gb%}' => 1
function _p9k_prompt_length() {
  emulate -L zsh
  local COLUMNS=1024
  local -i x y=$#1 m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done
    local xy
    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done
  fi
  _P9K_RETVAL=$x
}

typeset -g _P9K_BYTE_SUFFIX=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# 42 => 42B
# 1536 => 1.5K
function _p9k_human_readable_bytes() {
  typeset -F 2 n=$1
  local suf
  for suf in $_P9K_BYTE_SUFFIX; do
    (( n < 100 )) && break
    (( n /= 1024 ))
  done
  _P9K_RETVAL=$n$suf
}

# Determine if the passed segment is used in the prompt
#
# Pass the name of the segment to this function to test for its presence in
# either the LEFT or RIGHT prompt arrays.
#    * $1: The segment to be tested.
segment_in_use() {
  local key=$1
  [[ -n "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(r)${key}]}" ||
     -n "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(r)${key}_joined]}" ||
     -n "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(r)${key}]}" ||
     -n "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(r)${key}_joined]}" ]]
}

function _p9k_parse_ip() {
  local desiredInterface=${1:-'^[^ ]+'}

  if [[ $OS == OSX ]]; then
    [[ -x /sbin/ifconfig ]] || return
    local rawInterfaces && rawInterfaces="$(/sbin/ifconfig -l 2>/dev/null)" || return
    local -a interfaces=(${(A)=rawInterfaces})
    local pattern="${desiredInterface}[^ ]?"
    local -a relevantInterfaces
    for rawInterface in $interfaces; do
      [[ "$rawInterface" =~ $pattern ]] && relevantInterfaces+=$MATCH
    done
    local newline=$'\n'
    local interfaceName interface
    for interfaceName in $relevantInterfaces; do
      interface="$(/sbin/ifconfig $interfaceName 2>/dev/null)" || continue
      [[ "${interface}" =~ "lo[0-9]*" ]] && continue
      if [[ "${interface//${newline}/}" =~ "<([^>]*)>(.*)inet[ ]+([^ ]*)" ]]; then
        local ipFound="${match[3]}"
        local -a interfaceStates=(${(s:,:)match[1]})
        if (( ${interfaceStates[(I)UP]} )); then
          _P9K_RETVAL=$ipFound
          return
        fi
      fi
    done
  else
    [[ -x /sbin/ip ]] || return
    local -a interfaces=( "${(f)$(/sbin/ip -brief -4 a show 2>/dev/null)}" )
    local pattern="^${desiredInterface}[[:space:]]+UP[[:space:]]+([^/ ]+)"
    local interface
    for interface in "${(@)interfaces}"; do
      if [[ "$interface" =~ $pattern ]]; then
        _P9K_RETVAL=$match[1]
        return
      fi
    done
  fi

  return 1
}
