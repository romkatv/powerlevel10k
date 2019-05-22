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

# Parse IP address from ifconfig on OSX and from IP on Linux
# Parameters:
#  $1 - string The desired Interface
#  $2 - string A root prefix for testing purposes
function p9k::parseIp() {
  local desiredInterface="${1}"

  if [[ -z "${desiredInterface}" ]]; then
    desiredInterface="^[^ ]+"
  fi

  local ROOT_PREFIX="${2}"
  if [[ "$OS" == "OSX" ]]; then
    # Get a plain list of all interfaces
    local rawInterfaces="$(${ROOT_PREFIX}/sbin/ifconfig -l 2>/dev/null)"
    # Parse into array (split by whitespace)
    local -a interfaces
    interfaces=(${=rawInterfaces})
    # Parse only relevant interface names
    local pattern="${desiredInterface}[^ ]?"
    local -a relevantInterfaces
    for rawInterface in $interfaces; do
      [[ "$rawInterface" =~ $pattern ]] && relevantInterfaces+=( $MATCH )
    done
    local newline=$'\n'
    for interfaceName in $relevantInterfaces; do
      local interface="$(${ROOT_PREFIX}/sbin/ifconfig $interfaceName 2>/dev/null)"
      if [[ "${interface}" =~ "lo[0-9]*" ]]; then
        continue
      fi
      # Check if interface is UP.
      if [[ "${interface//${newline}/}" =~ "<([^>]*)>(.*)inet[ ]+([^ ]*)" ]]; then
        local ipFound="${match[3]}"
        local -a interfaceStates=(${(s:,:)match[1]})
        if [[ "${interfaceStates[(r)UP]}" == "UP" ]]; then
          echo "${ipFound}"
          return 0
        fi
      fi
    done
  else
    local -a interfaces
    interfaces=( "${(f)$(${ROOT_PREFIX}/sbin/ip -brief -4 a show 2>/dev/null)}" )
    local pattern="^${desiredInterface}[ ]+UP[ ]+([^/ ]+)"
    for interface in "${(@)interfaces}"; do
      if [[ "$interface" =~ $pattern ]]; then
        echo "${match[1]}"
        return 0
      fi
    done
  fi

  return 1
}
