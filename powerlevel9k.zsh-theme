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

if test -z "${ZSH_VERSION}"; then
  echo "powerlevel10k: unsupported shell; try zsh instead" >&2
  return 1
  exit 1
fi

if ! autoload -U is-at-least || ! is-at-least 5.1; then
  () {
    >&2 echo -E "You are using ZSH version $ZSH_VERSION. The minimum required version for Powerlevel10k is 5.1."
    >&2 echo -E "Type 'echo \$ZSH_VERSION' to see your current zsh version."
    local def=${SHELL:c:A}
    local cur=${${ZSH_ARGZERO#-}:c:A}
    local cur_v=$($cur -c 'echo -E $ZSH_VERSION' 2>/dev/null)
    if [[ $cur_v == $ZSH_VERSION && $cur != $def ]]; then
      >&2 echo -E "The shell you are currently running is likely $cur."
    fi
    local other=${${:-zsh}:c}
    if [[ -n $other ]] && $other -c 'autoload -U is-at-least && is-at-least 5.1' &>/dev/null; then
      local other_v=$($other -c 'echo -E $ZSH_VERSION' 2>/dev/null)
      if [[ -n $other_v && $other_v != $ZSH_VERSION ]]; then
        >&2 echo -E "You have $other with version $other_v but this is not what you are using."
        if [[ -n $def && $def != ${other:A} ]]; then
          >&2 echo -E "To change your user shell, type the following command:"
          >&2 echo -E ""
          if [[ $(grep -F $other /etc/shells 2>/dev/null) != $other ]]; then
            >&2 echo -E "  echo ${(q-)other} | sudo tee -a /etc/shells"
          fi
          >&2 echo -E "  chsh -s ${(q-)other}"
        fi
      fi
    fi
  }
  return 1
fi

if (( $+_P9K_SOURCED )); then
  prompt_powerlevel9k_setup "$@"
  return
fi

readonly _P9K_SOURCED=1

typeset -g _P9K_INSTALLATION_DIR

# Try to set the installation path
if [[ -n "$POWERLEVEL9K_INSTALLATION_DIR" ]]; then
  _P9K_INSTALLATION_DIR=${POWERLEVEL9K_INSTALLATION_DIR:A}
else
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/powerlevel9k.zsh-theme" ]]; then
      # Antigen uses eval to load things so it can change the plugin (!!)
      # https://github.com/zsh-users/antigen/issues/581
      _P9K_INSTALLATION_DIR=$PWD
    else
      print -P "%F{red}You must set POWERLEVEL9K_INSTALLATION_DIR work from within an (eval).%f"
      return 1
    fi
  else
    # Get the path to file this code is executing in; then
    # get the absolute path and strip the filename.
    # See https://stackoverflow.com/a/28336473/108857
    _P9K_INSTALLATION_DIR=${${(%):-%x}:A:h}
  fi
fi

source "${_P9K_INSTALLATION_DIR}/functions/utilities.zsh"
source "${_P9K_INSTALLATION_DIR}/functions/icons.zsh"
source "${_P9K_INSTALLATION_DIR}/functions/colors.zsh"
source "${_P9K_INSTALLATION_DIR}/functions/vcs.zsh"

typeset -g _P9K_RETVAL
typeset -g _P9K_CACHE_KEY
typeset -ga _P9K_CACHE_VAL
typeset -gA _P9K_CACHE
typeset -ga _P9K_T
typeset -g _P9K_N
typeset -gi _P9K_I
typeset -g _P9K_BG
typeset -g _P9K_F

# Specifies the maximum number of elements in the cache. When the cache grows over this limit,
# it gets cleared. This is meant to avoid memory leaks when a rogue prompt is filling the cache
# with data.
set_default -i POWERLEVEL9K_MAX_CACHE_SIZE 10000

# Note: Several performance-critical functions return results to the caller via global
# variabls rather than stdout. This is faster.

# Caching allows storing array-to-array associations. It should be used like this:
#
#   if ! _p9k_cache_get "$key1" "$key2"; then
#     # Compute val1 and val2 and then store them in the cache.
#     _p9k_cache_set "$val1" "$val2"
#   fi
#   # Here ${_P9K_CACHE_VAL[1]} and ${_P9K_CACHE_VAL[2]} are $val1 and $val2 respectively.
#
# Limitations:
#
#   * Calling _p9k_cache_set without arguments clears the cache entry. Subsequent calls to
#     _p9k_cache_get for the same key will return an error.
#   * There must be no intervening _p9k_cache_get calls between the associated _p9k_cache_get
#     and _p9k_cache_set.
_p9k_cache_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_P9K_CACHE_KEY} => (${(q)@})" >&2
  _P9K_CACHE[$_P9K_CACHE_KEY]="${(pj:\0:)*}"
  _P9K_CACHE_VAL=("$@")
  (( #_P9K_CACHE < POWERLEVEL9K_MAX_CACHE_SIZE )) || typeset -gAH _P9K_CACHE=()
}

_p9k_cache_get() {
  _P9K_CACHE_KEY="${(pj:\0:)*}"
  _P9K_CACHE_VAL=("${(@0)${_P9K_CACHE[$_P9K_CACHE_KEY]}}")
  (( #_P9K_CACHE_VAL ))
}

# Sets _P9K_RETVAL to the icon whose name is supplied via $1.
_p9k_get_icon() {
  local var_name=POWERLEVEL9K_$1
  _P9K_RETVAL=${(g::)${${(P)var_name}-$icons[$1]}}
}

typeset -ga _P9K_LEFT_JOIN=(1)
typeset -ga _P9K_RIGHT_JOIN=(1)

# Resolves a color to its numerical value, or an empty string. Communicates the result back
# by setting _P9K_RETVAL.
_p9k_color() {
  local user_var=POWERLEVEL9K_${(U)${2}#prompt_}_${3}
  local color=${${(P)user_var}:-${1}}
  if [[ $color == <-> ]]; then     # decimal color code: 255
    _P9K_RETVAL=${(l:3::0:)color}
  elif [[ $color == '#'* ]]; then  # hexademical color code: #ffffff
    _P9K_RETVAL=$color
  else                             # named color: red
    # Strip prifixes if there are any.
    _P9K_RETVAL=$__P9K_COLORS[${${${color#bg-}#fg-}#br}]
  fi
}

_p9k_background() {
  [[ -n $1 ]] && _P9K_RETVAL="%K{$1}" || _P9K_RETVAL="%k"
}

_p9k_foreground() {
  [[ -n $1 ]] && _P9K_RETVAL="%F{$1}" || _P9K_RETVAL="%f"
}

_p9k_escape_rcurly() {
  _P9K_RETVAL=${${1//\\/\\\\}//\}/\\\}}
}

# Begin a left prompt segment.
#
#    * $1: Name of the function that was originally invoked.
#          Necessary, to make the dynamic color-overwrite mechanism work.
#    * $2: The array index of the current segment.
#    * $3: Background color.
#    * $4: Foreground color.
#    * $5: An identifying icon (must be a key of the icons array).
#    * $6: 1 to to perform parameter expansion and process substitution.
#    * $7: If not empty but becomes empty after parameter expansion and process substitution,
#          the segment isn't rendered.
#   * $8+: The segment content
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS " "
left_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$5"; then
    _p9k_color $3 $1 BACKGROUND
    local bg_color=$_P9K_RETVAL
    _p9k_background $bg_color
    local bg=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local fg_color=$_P9K_RETVAL
    _p9k_foreground $fg_color
    local fg=$_P9K_RETVAL

    _p9k_get_icon LEFT_SUBSEGMENT_SEPARATOR
    local subsep=$_P9K_RETVAL

    _p9k_escape_rcurly $POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
    local space=$_P9K_RETVAL

    local icon
    local -i has_icon
    if [[ -n $5 ]]; then
      _p9k_get_icon $5
      if [[ -n $_P9K_RETVAL ]]; then
        local glyph=$_P9K_RETVAL
        _p9k_color $fg_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        icon=$_P9K_RETVAL$glyph
        has_icon=1
      fi
    fi

    # Segment separator logic:
    #
    #   if [[ $_P9K_BG == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $bg_color == $_P9K_BG ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$#_P9K_T
    _P9K_T+=$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon                           # 1
    _P9K_T+=$bg$icon                                                                         # 2
    if [[ -z $fg_color ]]; then
      _p9k_foreground $DEFAULT_COLOR
      _P9K_T+=$bg$_P9K_RETVAL$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon      # 3
    else
      _P9K_T+=$bg$fg$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon               # 3
    fi
    _p9k_get_icon LEFT_SEGMENT_SEPARATOR
    _P9K_T+=$bg$_P9K_RETVAL$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon               # 4

    local pre
    pre+="\${_P9K_N::=}\${_P9K_F::=}"
    pre+="\${\${\${\${_P9K_BG:-0}:#NONE}:-\${_P9K_N::=$((t+1))}}+}"                        # 1
    pre+="\${\${_P9K_N:=\${\${\$((_P9K_I>=$_P9K_LEFT_JOIN[$2])):#0}:+$((t+2))}}+}"         # 2
    pre+="\${\${_P9K_N:=\${\${\$((!\${#\${:-0\$_P9K_BG}:#0$bg_color})):#0}:+$((t+3))}}+}"  # 3
    pre+="\${\${_P9K_N:=\${\${_P9K_F::=%F{\$_P9K_BG\}}+$((t+4))}}+}"                       # 4
    pre+="\$_P9K_F\${_P9K_T[\$_P9K_N]}"

    local post="\${_P9K_C}$space\${\${_P9K_I::=$2}+}\${\${_P9K_BG::=$bg_color}+}}"

    _p9k_cache_set $has_icon $fg $pre $post
  fi

  local name=$1
  local -i has_icon=${_P9K_CACHE_VAL[1]}
  local fg=${_P9K_CACHE_VAL[2]}
  local -i expand=$6
  local cond=${7:-1}
  shift 7

  _p9k_escape_rcurly $fg
  local content="${(j::):-$_P9K_RETVAL${^@}}"
  (( expand )) || content="\${(Q)\${:-${(q)content}}}"

  _P9K_PROMPT+="\${\${:-$cond}:+\${\${_P9K_C::=${content}}+}${_P9K_CACHE_VAL[3]}"
  (( has_icon )) && _P9K_PROMPT+="\${\${\${#_P9K_C}:#$(($# * $#fg))}:+ }"
  _P9K_PROMPT+=${_P9K_CACHE_VAL[4]}
}

# The same as left_prompt_segment above but for the right prompt.
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS " "
right_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$5"; then
    _p9k_color $3 $1 BACKGROUND
    local bg_color=$_P9K_RETVAL
    _p9k_background $bg_color
    local bg=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local fg_color=$_P9K_RETVAL
    _p9k_foreground $fg_color
    local fg=$_P9K_RETVAL

    _p9k_get_icon RIGHT_SUBSEGMENT_SEPARATOR
    local subsep=$_P9K_RETVAL

    local icon_fg icon
    local -i has_icon
    if [[ -n $5 ]]; then
      _p9k_get_icon $5
      if [[ -n $_P9K_RETVAL ]]; then
        _p9k_escape_rcurly $_P9K_RETVAL
        icon=$_P9K_RETVAL
        _p9k_color $fg_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        _p9k_escape_rcurly $_P9K_RETVAL
        icon_fg=$_P9K_RETVAL
        has_icon=1
      fi
    fi

    # Segment separator logic is the same as in left_prompt_segment except that here #4 and #1 are
    # identical.

    local t=$#_P9K_T
    _p9k_get_icon RIGHT_SEGMENT_SEPARATOR
    _P9K_T+="%F{$bg_color}$_P9K_RETVAL$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS$fg"  # 1
    _P9K_T+=$bg$fg                                                                            # 2
    if [[ -z $fg_color ]]; then
      _p9k_foreground $DEFAULT_COLOR
      _P9K_T+=$_P9K_RETVAL$subsep$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS$fg        # 3
    else
      _P9K_T+=$fg$subsep$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS                    # 3
    fi

    local pre
    pre+="\${_P9K_N::=}"
    pre+="\${\${\${\${_P9K_BG:-0}:#NONE}:-\${_P9K_N::=$((t+1))}}+}"                        # 1
    pre+="\${\${_P9K_N:=\${\${\$((_P9K_I>=$_P9K_RIGHT_JOIN[$2])):#0}:+$((t+2))}}+}"        # 2
    pre+="\${\${_P9K_N:=\${\${\$((!\${#\${:-0\$_P9K_BG}:#0$bg_color})):#0}:+$((t+3))}}+}"  # 3
    pre+="\${\${_P9K_N:=$((t+1))}+}"                                                       # 4 == 1
    pre+="\${_P9K_T[\$_P9K_N]}\${_P9K_C}$icon_fg"

    _p9k_escape_rcurly $POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS
    local post="$icon$_P9K_RETVAL\${\${_P9K_I::=$2}+}\${\${_P9K_BG::=$bg_color}+}}"

    _p9k_cache_set $has_icon $fg $pre $post
  fi

  local -i has_icon=${_P9K_CACHE_VAL[1]}
  local fg=${_P9K_CACHE_VAL[2]}
  local -i expand=$6
  local cond=${7:-1}
  shift 7

  _p9k_escape_rcurly $fg
  local content="${(j::):-$_P9K_RETVAL${^@}}"
  (( expand )) || content="\${(Q)\${:-${(q)content}}}"

  _P9K_PROMPT+="\${\${:-$cond}:+\${\${_P9K_C::=${content}}+}${_P9K_CACHE_VAL[3]}"
  (( has_icon )) && _P9K_PROMPT+="\${\${\${#_P9K_C}:#$(($# * $#fg))}:+ }"
  _P9K_PROMPT+=${_P9K_CACHE_VAL[4]}
}

################################################################
# Prompt Segment Definitions
################################################################

################################################################
# Anaconda Environment
set_default POWERLEVEL9K_ANACONDA_LEFT_DELIMITER "("
set_default POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER ")"
prompt_anaconda() {
  # Depending on the conda version, either might be set. This
  # variant works even if both are set.
  local path=$CONDA_ENV_PATH$CONDA_PREFIX
  if [[ -n $path ]]; then
    local msg="$POWERLEVEL9K_ANACONDA_LEFT_DELIMITER${${path:t}//\%/%%}$POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER"
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "$msg"
  fi
}

################################################################
# AWS Profile
prompt_aws() {
  local aws_profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [[ -n "$aws_profile" ]]; then
    "$1_prompt_segment" "$0" "$2" red white 'AWS_ICON' 0 '' "${aws_profile//\%/%%}"
  fi
}

################################################################
# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  # TODO(roman): This is clearly broken. Fix it.
  local eb_env=$(grep environment .elasticbeanstalk/config.yml 2> /dev/null | awk '{print $2}')
  if [[ -n "$eb_env" ]]; then
    "$1_prompt_segment" "$0" "$2" black green 'AWS_EB_ICON' 0 '' "${eb_env//\%/%%}"
  fi
}

################################################################
# Segment to indicate background jobs with an icon.
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE true
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS false
prompt_background_jobs() {
  local msg
  if [[ $POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE == true ]]; then
    if [[ $POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS == true ]]; then
      msg='${(%):-%j}'
    else
      msg='${${(%):-%j}:#1}'
    fi
  fi
  $1_prompt_segment $0 $2 "$DEFAULT_COLOR" cyan BACKGROUND_JOBS_ICON 1 '${${(%):-%j}:#0}' "$msg"
}

function _p9k_left_prompt_end_line() {
  _p9k_get_icon LEFT_SEGMENT_SEPARATOR
  _p9k_escape_rcurly $_P9K_RETVAL
  _P9K_PROMPT+="%k"
  _P9K_PROMPT+="\${_P9K_N::=}"
  _P9K_PROMPT+="\${\${\${_P9K_BG:#NONE}:-\${_P9K_N:=1}}+}"
  _P9K_PROMPT+="\${\${_P9K_N:=2}+}"
  _P9K_PROMPT+="\${\${_P9K_T[2]::=%F{\$_P9K_BG\}$_P9K_RETVAL}+}"
  _P9K_PROMPT+="\${_P9K_T[\$_P9K_N]}"
  _P9K_PROMPT+='%f'
}

################################################################
# A newline in your prompt, so you can segments on multiple lines.
set_default POWERLEVEL9K_PROMPT_ON_NEWLINE false
prompt_newline() {
  [[ "$1" == "right" ]] && return
  _p9k_left_prompt_end_line
  _P9K_PROMPT+=$'\n'
  _P9K_PROMPT+='${${_P9K_BG::=NONE}+}'
  if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE == true ]]; then
    _p9k_get_icon MULTILINE_NEWLINE_PROMPT_PREFIX
    _P9K_PROMPT+=$_P9K_RETVAL
  fi
}

################################################################
# Segment that indicates usage level of current partition.
set_default POWERLEVEL9K_DISK_USAGE_ONLY_WARNING false
set_default -i POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL 90
set_default -i POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL 95
prompt_disk_usage() {
  local current_state="unknown"
  typeset -AH hdd_usage_forecolors
  hdd_usage_forecolors=(
    'normal'        'yellow'
    'warning'       "$DEFAULT_COLOR"
    'critical'      'white'
  )
  typeset -AH hdd_usage_backcolors
  hdd_usage_backcolors=(
    'normal'        $DEFAULT_COLOR
    'warning'       'yellow'
    'critical'      'red'
  )

  local disk_usage="${$(\df -P . | sed -n '2p' | awk '{ print $5 }')%%\%}"

  if [ "$disk_usage" -ge "$POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL" ]; then
    current_state='warning'
    if [ "$disk_usage" -ge "$POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL" ]; then
        current_state='critical'
    fi
  else
    if [[ "$POWERLEVEL9K_DISK_USAGE_ONLY_WARNING" == true ]]; then
        current_state=''
        return
    fi
    current_state='normal'
  fi

  local message="${disk_usage}%%"

  # Draw the prompt_segment
  if [[ -n $disk_usage ]]; then
    "$1_prompt_segment" "${0}_${current_state}" "$2" "${hdd_usage_backcolors[$current_state]}" "${hdd_usage_forecolors[$current_state]}" 'DISK_ICON' 0 '' "$message"
  fi
}

################################################################
# Segment that displays the battery status in levels and colors
set_default -i POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10
set_default -i POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD 999
set_default -a POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND
set_default    POWERLEVEL9K_BATTERY_VERBOSE true
typeset     -g POWERLEVEL9K_BATTERY_STAGES

prompt_battery() {
  # The battery can have four different states - default to 'unknown'.
  local current_state='unknown'
  typeset -AH battery_states
  battery_states=(
    'low'           'red'
    'charging'      'yellow'
    'charged'       'green'
    'disconnected'  "$DEFAULT_COLOR_INVERTED"
  )
  local ROOT_PREFIX="${4}"

  if [[ $OS =~ OSX && -f "${ROOT_PREFIX}"/usr/bin/pmset && -x "${ROOT_PREFIX}"/usr/bin/pmset ]]; then
    # obtain battery information from system
    local raw_data="$(${ROOT_PREFIX}/usr/bin/pmset -g batt | awk 'FNR==2{print}')"
    # return if there is no battery on system
    [[ -z $(echo $raw_data | grep "InternalBattery") ]] && return

    # Time remaining on battery operation (charging/discharging)
    local tstring=$(echo $raw_data | awk -F ';' '{print $3}' | awk '{print $1}')
    # If time has not been calculated by system yet
    [[ $tstring =~ '(\(no|not)' ]] && tstring="..."

    # percent of battery charged
    typeset -i 10 bat_percent
    bat_percent=$(echo $raw_data | grep -o '[0-9]*%' | sed 's/%//')

    local remain=""
    # Logic for string output
    case $(echo $raw_data | awk -F ';' '{print $2}' | awk '{$1=$1};1') in
      # for a short time after attaching power, status will be 'AC attached;'
      'charging'|'finishing charge'|'AC attached')
        current_state="charging"
        remain=" ($tstring)"
        ;;
      'discharging')
        [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && current_state="low" || current_state="disconnected"
        remain=" ($tstring)"
        ;;
      *)
        current_state="charged"
        ;;
    esac
  fi

  if [[ "$OS" == 'Linux' ]] || [[ "$OS" == 'Android' ]]; then
    local sysp="${ROOT_PREFIX}/sys/class/power_supply"

    # Reported BAT0 or BAT1 depending on kernel version
    [[ -a $sysp/BAT0 ]] && local bat=$sysp/BAT0
    [[ -a $sysp/BAT1 ]] && local bat=$sysp/BAT1

    # Android-related
    # Tested on: Moto G falcon (CM 13.0)
    [[ -a $sysp/battery ]] && local bat=$sysp/battery

    # Return if no battery found
    [[ -z $bat ]] && return
    local capacity=$(cat $bat/capacity)
    local battery_status=$(cat $bat/status)
    [[ $capacity -gt 100 ]] && local bat_percent=100 || local bat_percent=$capacity
    [[ $battery_status =~ Charging || $battery_status =~ Full ]] && local connected=true
    if [[ -z  $connected ]]; then
      [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && current_state="low" || current_state="disconnected"
    else
      [[ $bat_percent =~ 100 ]] && current_state="charged"
      [[ $bat_percent -lt 100 ]] && current_state="charging"
    fi
    if [[ -f ${ROOT_PREFIX}/usr/bin/acpi ]]; then
      local time_remaining=$(${ROOT_PREFIX}/usr/bin/acpi | awk '{ print $5 }')
      if [[ $time_remaining =~ rate ]]; then
        local tstring="..."
      elif [[ $time_remaining =~ "[[:digit:]]+" ]]; then
        local tstring=${(f)$(date -u -d "$(echo $time_remaining)" +%k:%M 2> /dev/null)}
      fi
    fi
    [[ -n $tstring ]] && local remain=" ($tstring)"
  fi

  local message
  if [[ "$POWERLEVEL9K_BATTERY_VERBOSE" == true ]]; then
    message="$bat_percent%%$remain"
  else
    message="$bat_percent%%"
  fi

  # override default icon if we are using battery stages
  if [[ -n "$POWERLEVEL9K_BATTERY_STAGES" ]]; then
    local segment=$(( 100.0 / (${#POWERLEVEL9K_BATTERY_STAGES} - 1 ) ))
    if [[ $segment > 1 ]]; then
      local offset=$(( ($bat_percent / $segment) + 1 ))
      # check if the stages are in an array or a string
      [[ "${(t)POWERLEVEL9K_BATTERY_STAGES}" =~ "array" ]] && POWERLEVEL9K_BATTERY_ICON="$POWERLEVEL9K_BATTERY_STAGES[$offset]" || POWERLEVEL9K_BATTERY_ICON=${POWERLEVEL9K_BATTERY_STAGES:$offset:1}
    fi
  fi
  # return if POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD is set and the battery percentage is greater or equal
  if (( bat_percent >= POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD )); then
    return
  fi

  # override the default color if we are using a color level array
  if (( #POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND )); then
    local segment=$(( 100.0 / (${#POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND} - 1 ) ))
    local offset=$(( ($bat_percent / $segment) + 1 ))
    "$1_prompt_segment" "$0_${current_state}" "$2" "${POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND[$offset]}" "${battery_states[$current_state]}" "BATTERY_ICON" 0 '' "${message}"
  else
    # Draw the prompt_segment
    "$1_prompt_segment" "$0_${current_state}" "$2" "${DEFAULT_COLOR}" "${battery_states[$current_state]}" "BATTERY_ICON" 0 '' "${message}"
  fi
}

################################################################
# Public IP segment
# Parameters:
#   * $1 Alignment: string - left|right
#   * $2 Index: integer
#   * $3 Joined: bool - If the segment should be joined
#   * $4 Root Prefix: string - Root prefix for testing purposes
set_default -i POWERLEVEL9K_PUBLIC_IP_TIMEOUT 300
set_default -a POWERLEVEL9K_PUBLIC_IP_METHODS dig curl wget
set_default    POWERLEVEL9K_PUBLIC_IP_NONE ""
set_default    POWERLEVEL9K_PUBLIC_IP_FILE "/tmp/p9k_public_ip"
set_default    POWERLEVEL9K_PUBLIC_IP_HOST "http://ident.me"
set_default    POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ""

prompt_public_ip() {
  local ROOT_PREFIX="${4}"

  # Do we need a fresh IP?
  local refresh_ip=false
  if [[ -f $POWERLEVEL9K_PUBLIC_IP_FILE ]]; then
    typeset -i timediff
    # if saved IP is more than
    if [[ "$OS" == "OSX" ]]; then
      timediff=$(($(date +%s) - $(stat -f "%m" $POWERLEVEL9K_PUBLIC_IP_FILE)))
    else
      timediff=$(($(date +%s) - $(date -r $POWERLEVEL9K_PUBLIC_IP_FILE +%s)))
    fi
    (( timediff > POWERLEVEL9K_PUBLIC_IP_TIMEOUT )) && refresh_ip=true
    # If tmp file is empty get a fresh IP
    [[ -z $(cat $POWERLEVEL9K_PUBLIC_IP_FILE) ]] && refresh_ip=true
    [[ -n $POWERLEVEL9K_PUBLIC_IP_NONE ]] && [[ $(cat $POWERLEVEL9K_PUBLIC_IP_FILE) =~ "$POWERLEVEL9K_PUBLIC_IP_NONE" ]] && refresh_ip=true
  else
    touch $POWERLEVEL9K_PUBLIC_IP_FILE && refresh_ip=true
  fi

  # grab a fresh IP if needed
  local fresh_ip
  if [[ $refresh_ip == true && -w $POWERLEVEL9K_PUBLIC_IP_FILE ]]; then
    for method in "${POWERLEVEL9K_PUBLIC_IP_METHODS[@]}"; do
      case $method in
        'dig')
            fresh_ip="$(dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com 2> /dev/null)"
            [[ "$fresh_ip" =~ ^\; ]] && unset fresh_ip
          ;;
        'curl')
            fresh_ip="$(curl --max-time 10 -w '\n' "$POWERLEVEL9K_PUBLIC_IP_HOST" 2> /dev/null)"
          ;;
        'wget')
            fresh_ip="$(wget -T 10 -qO- "$POWERLEVEL9K_PUBLIC_IP_HOST" 2> /dev/null)"
          ;;
      esac
      # If we found a fresh IP, break loop.
      if [[ -n "${fresh_ip}" ]]; then
        break;
      fi
    done

    # write IP to tmp file or clear tmp file if an IP was not retrieved
    # Redirection with `>!`. From the manpage: Same as >, except that the file
    #   is truncated to zero length if it exists, even if CLOBBER is unset.
    # If the file already exists, and a simple `>` redirection and CLOBBER
    # unset, ZSH will produce an error.
    [[ -n "${fresh_ip}" ]] && echo $fresh_ip >! $POWERLEVEL9K_PUBLIC_IP_FILE || echo $POWERLEVEL9K_PUBLIC_IP_NONE >! $POWERLEVEL9K_PUBLIC_IP_FILE
  fi

  # read public IP saved to tmp file
  local public_ip="$(cat $POWERLEVEL9K_PUBLIC_IP_FILE)"

  # Draw the prompt segment
  if [[ -n $public_ip ]]; then
    icon='PUBLIC_IP_ICON'
    # Check VPN is on if VPN interface is set
    if [[ -n $POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]]; then
      local vpnIp="$(p9k::parseIp "${POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE}" "${ROOT_PREFIX}")"
      if [[ -n "$vpnIp" ]]; then
        icon='VPN_ICON'
      fi
    fi
    $1_prompt_segment "$0" "$2" "$DEFAULT_COLOR" "$DEFAULT_COLOR_INVERTED" "$icon" 0 '' "${public_ip}"
  fi
}

################################################################
# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_ALWAYS_SHOW_CONTEXT false
set_default POWERLEVEL9K_ALWAYS_SHOW_USER false
set_default POWERLEVEL9K_CONTEXT_TEMPLATE "%n@%m"
prompt_context() {
  local content
  if [[ $POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == true || -z $DEFAULT_USER || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    content=$POWERLEVEL9K_CONTEXT_TEMPLATE
  else
    local user=$(whoami)
    if [[ $user != $DEFAULT_USER ]]; then
      content="${POWERLEVEL9K_CONTEXT_TEMPLATE}"
    elif [[ $POWERLEVEL9K_ALWAYS_SHOW_USER == true ]]; then
      content="${user//\%/%%}"
    else
      return
    fi
  fi

  local current_state="DEFAULT"
  if [[ "${(%):-%#}" == '#' ]]; then
    current_state="ROOT"
  elif [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    if [[ -n "$SUDO_COMMAND" ]]; then
      current_state="REMOTE_SUDO"
    else
      current_state="REMOTE"
    fi
  elif [[ -n "$SUDO_COMMAND" ]]; then
    current_state="SUDO"
  fi

  "$1_prompt_segment" "${0}_${current_state}" "$2" "$DEFAULT_COLOR" yellow '' 0 '' "${content}"
}

################################################################
# User: user (who am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_USER_TEMPLATE "%n"
prompt_user() {
  local user=$(whoami)
  [[ $POWERLEVEL9K_ALWAYS_SHOW_USER != true && $user == $DEFAULT_USER ]] && return
  if [[ "${(%):-%#}" == '#' ]]; then
    "$1_prompt_segment" "${0}_ROOT" "$2" "${DEFAULT_COLOR}" yellow ROOT_ICON 0 '' "${POWERLEVEL9K_USER_TEMPLATE}"
  elif [[ -n "$SUDO_COMMAND" ]]; then
    "$1_prompt_segment" "${0}_SUDO" "$2" "${DEFAULT_COLOR}" yellow SUDO_ICON 0 '' "${POWERLEVEL9K_USER_TEMPLATE}"
  else
    "$1_prompt_segment" "${0}_DEFAULT" "$2" "${DEFAULT_COLOR}" yellow USER_ICON 0 '' "${user//\%/%%}"
  fi
}

################################################################
# Host: machine (where am I)
set_default POWERLEVEL9K_HOST_TEMPLATE "%m"
prompt_host() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0_REMOTE" "$2" "${DEFAULT_COLOR}" yellow SSH_ICON 0 '' "${POWERLEVEL9K_HOST_TEMPLATE}"
  else
    "$1_prompt_segment" "$0_LOCAL" "$2" "${DEFAULT_COLOR}" yellow HOST_ICON 0 '' "${POWERLEVEL9K_HOST_TEMPLATE}"
  fi
}

################################################################
# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
prompt_custom() {
  local segment_name="${3:u}"
  # Get content of custom segment
  local command="POWERLEVEL9K_CUSTOM_${segment_name}"
  local segment_content="$(eval ${(P)command})"
  # Note: this would be a better implementation. I'm keeping the old one in case anyone
  # relies on its quirks.
  # local segment_content=$("${(@Q)${(z)${(P)command}}}")

  if [[ -n $segment_content ]]; then
    "$1_prompt_segment" "${0}_${3:u}" "$2" $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR "CUSTOM_${segment_name}_ICON" 0 '' "$segment_content"
  fi
}

################################################################
# Display the duration the command needed to run.
typeset -gF _P9K_COMMAND_DURATION
set_default -i POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD 3
set_default -i POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION 2
prompt_command_execution_time() {
  (( _P9K_COMMAND_DURATION < POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD )) && return
  # Print time in human readable format
  # For that use `strftime` and convert
  # the duration (float) to an seconds
  # (integer).
  # See http://unix.stackexchange.com/a/89748
  local humanReadableDuration
  if (( _P9K_COMMAND_DURATION > 3600 )); then
    humanReadableDuration=$(TZ=GMT; strftime '%H:%M:%S' $(( int(rint(_P9K_COMMAND_DURATION)) )))
  elif (( _P9K_COMMAND_DURATION > 60 )); then
    humanReadableDuration=$(TZ=GMT; strftime '%M:%S' $(( int(rint(_P9K_COMMAND_DURATION)) )))
  else
    # If the command executed in seconds, print as float.
    # Convert to float
    if [[ "${POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION}" == "0" ]]; then
      # If user does not want microseconds, then we need to convert
      # the duration to an integer.
      typeset -i humanReadableDuration
    else
      typeset -F ${POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION} humanReadableDuration
    fi
    humanReadableDuration=$_P9K_COMMAND_DURATION
  fi

  "$1_prompt_segment" "$0" "$2" "red" "yellow1" 'EXECUTION_TIME_ICON' 0 '' "${humanReadableDuration}"
}

################################################################
# Determine the unique path - this is needed for the
# truncate_to_unique strategy.
#
function getUniqueFolder() {
  local trunc_path directory test_dir test_dir_length
  local -a matching
  local -a paths
  local cur_path='/'
  paths=(${(s:/:)1})
  for directory in ${paths[@]}; do
    test_dir=''
    for (( i=0; i < ${#directory}; i++ )); do
      test_dir+="${directory:$i:1}"
      matching=("$cur_path"/"$test_dir"*/)
      if [[ ${#matching[@]} -eq 1 ]]; then
        break
      fi
    done
    trunc_path+="$test_dir/"
    cur_path+="$directory/"
  done
  echo "${trunc_path: : -1}"
}

################################################################
# Dir: current working directory
# Parameters:
#   * $1 Alignment: string - left|right
#   * $2 Index: integer
set_default POWERLEVEL9K_DIR_PATH_SEPARATOR "/"
set_default POWERLEVEL9K_HOME_FOLDER_ABBREVIATION "~"
set_default POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD false
set_default POWERLEVEL9K_DIR_PATH_ABSOLUTE false
set_default POWERLEVEL9K_DIR_SHOW_WRITABLE false
set_default POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER false
set_default POWERLEVEL9K_SHORTEN_STRATEGY ""
set_default POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND ""
set_default POWERLEVEL9K_SHORTEN_DELIMITER $'\u2026'
set_default POWERLEVEL9K_SHORTEN_FOLDER_MARKER ".shorten_folder_marker"
set_default -i POWERLEVEL9K_SHORTEN_DIR_LENGTH -1
set_default -a POWERLEVEL9K_DIR_PACKAGE_FILES package.json composer.json
prompt_dir() {
  # using $PWD instead of "$(print -P '%~')" to allow use of POWERLEVEL9K_DIR_PATH_ABSOLUTE
  local current_path=$PWD # WAS: local current_path="$(print -P '%~')"
  [[ "${POWERLEVEL9K_DIR_SHOW_WRITABLE}" == true && ! -w "$PWD" ]]
  local -i writable=$?
  if ! _p9k_cache_get "$0" "$2" "$current_path" "$writable"; then
    # check if the user wants to use absolute paths or "~" paths
    [[ ${(L)POWERLEVEL9K_DIR_PATH_ABSOLUTE} != "true" ]] && current_path=${current_path/#$HOME/"~"}
    # declare all local variables
    local paths directory test_dir test_dir_length trunc_path threshhold
    # if we are not in "~" or "/", split the paths into an array and exclude "~"
    (( ${#current_path} > 1 )) && paths=(${(s:/:)${current_path//"~\/"/}}) || paths=()
    # only run the code if SHORTEN_DIR_LENGTH is set, or we are using the two strategies that don't rely on it.
    if [[ "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" -ge 0 ||
          "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_with_folder_marker" ||
          "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_to_last" ||
          "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_with_package_name" ]]; then
      case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
        truncate_absolute_chars)
          if [ ${#current_path} -gt $(( $POWERLEVEL9K_SHORTEN_DIR_LENGTH + ${#POWERLEVEL9K_SHORTEN_DELIMITER} )) ]; then
            current_path=$POWERLEVEL9K_SHORTEN_DELIMITER${current_path:(-POWERLEVEL9K_SHORTEN_DIR_LENGTH)}
          fi
        ;;
        truncate_middle)
          # truncate characters from the middle of the path
          current_path=$(truncatePath $current_path $POWERLEVEL9K_SHORTEN_DIR_LENGTH $POWERLEVEL9K_SHORTEN_DELIMITER "middle")
        ;;
        truncate_from_right)
          # truncate characters from the right of the path
          current_path=$(truncatePath "$current_path" $POWERLEVEL9K_SHORTEN_DIR_LENGTH $POWERLEVEL9K_SHORTEN_DELIMITER)
        ;;
        truncate_absolute)
          # truncate all characters except the last POWERLEVEL9K_SHORTEN_DIR_LENGTH characters
          if [ ${#current_path} -gt $(( $POWERLEVEL9K_SHORTEN_DIR_LENGTH + ${#POWERLEVEL9K_SHORTEN_DELIMITER} )) ]; then
            current_path=$POWERLEVEL9K_SHORTEN_DELIMITER${current_path:(-POWERLEVEL9K_SHORTEN_DIR_LENGTH)}
          fi
        ;;
        truncate_to_last)
          # truncate all characters before the current directory
          current_path=${current_path##*/}
        ;;
        truncate_to_first_and_last)
          if (( ${#current_path} > 1 )) && (( ${POWERLEVEL9K_SHORTEN_DIR_LENGTH} > 0 )); then
            threshhold=$(( ${POWERLEVEL9K_SHORTEN_DIR_LENGTH} * 2))
            # if we are in "~", add it back into the paths array
            [[ $current_path == '~'* ]] && paths=("~" "${paths[@]}")
            if (( ${#paths} > $threshhold )); then
              local num=$(( ${#paths} - ${POWERLEVEL9K_SHORTEN_DIR_LENGTH} ))
              # repace the middle elements
              for (( i=$POWERLEVEL9K_SHORTEN_DIR_LENGTH; i<$num; i++ )); do
                paths[$i+1]=$POWERLEVEL9K_SHORTEN_DELIMITER
              done
              [[ $current_path != '~'* ]] && current_path="/" || current_path=""
              current_path+="${(j:/:)paths}"
            fi
          fi
        ;;
        truncate_to_unique)
          # for each parent path component find the shortest unique beginning
          # characters sequence. Source: https://stackoverflow.com/a/45336078
          if (( ${#current_path} > 1 )); then # root and home are exceptions and won't have paths
            # cheating here to retain ~ as home folder
            local home_path="$(getUniqueFolder $HOME)"
            trunc_path="$(getUniqueFolder $PWD)"
            [[ $current_path == "~"* ]] && current_path="~${trunc_path//${home_path}/}" || current_path="/${trunc_path}"
          fi
        ;;
        truncate_with_folder_marker)
          if (( ${#paths} > 0 )); then # root and home are exceptions and won't have paths, so skip this
            local last_marked_folder marked_folder

            # Search for the folder marker in the parent directories and
            # buildup a pattern that is removed from the current path
            # later on.
            for marked_folder in $(upsearch $POWERLEVEL9K_SHORTEN_FOLDER_MARKER); do
              if [[ "$marked_folder" == "/" ]]; then
                # If we reached root folder, stop upsearch.
                trunc_path="/"
              elif [[ "$marked_folder" == "$HOME" ]]; then
                # If we reached home folder, stop upsearch.
                trunc_path="~"
              elif [[ "${marked_folder%/*}" == $last_marked_folder ]]; then
                trunc_path="${trunc_path%/}/${marked_folder##*/}"
              else
                trunc_path="${trunc_path%/}/$POWERLEVEL9K_SHORTEN_DELIMITER/${marked_folder##*/}"
              fi
              last_marked_folder=$marked_folder
            done

            # Replace the shortest possible match of the marked folder from
            # the current path.
            current_path=$trunc_path${current_path#${last_marked_folder}*}
          fi
        ;;
        truncate_with_package_name)
          local name repo_path package_path current_dir zero

          # Get the path of the Git repo, which should have the package.json file
          if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]; then
            # Get path from the root of the git repository to the current dir
            local gitPath=$(git rev-parse --show-prefix)
            # Remove trailing slash from git path, so that we can
            # remove that git path from the pwd.
            gitPath=${gitPath%/}
            package_path=${PWD%%$gitPath}
            # Remove trailing slash
            package_path=${package_path%/}
          elif [[ $(git rev-parse --is-inside-git-dir 2> /dev/null) == "true" ]]; then
            package_path=${PWD%%/.git*}
          fi

         [[ ${(L)POWERLEVEL9K_DIR_PATH_ABSOLUTE} != "true" ]] && package_path=${package_path/$HOME/"~"}

          # Replace the shortest possible match of the marked folder from
          # the current path. Remove the amount of characters up to the
          # folder marker from the left. Count only the visible characters
          # in the path (this is done by the "zero" pattern; see
          # http://stackoverflow.com/a/40855342/5586433).
          local zero='%([BSUbfksu]|([FB]|){*})'
          trunc_path=$PWD
          # Then, find the length of the package_path string, and save the
          # subdirectory path as a substring of the current directory's path from 0
          # to the length of the package path's string
          subdirectory_path=$(truncatePath "${trunc_path:${#${(S%%)package_path//$~zero/}}}" $POWERLEVEL9K_SHORTEN_DIR_LENGTH $POWERLEVEL9K_SHORTEN_DELIMITER)
          # Parse the 'name' from the package.json; if there are any problems, just
          # print the file path

          local pkgFile="unknown"
          for file in "${POWERLEVEL9K_DIR_PACKAGE_FILES[@]}"; do
            if [[ -f "${package_path}/${file}" ]]; then
              pkgFile="${package_path}/${file}"
              break;
            fi
          done

          local packageName=$(jq '.name' ${pkgFile} 2> /dev/null \
            || node -e 'console.log(require(process.argv[1]).name);' ${pkgFile} 2>/dev/null \
            || cat "${pkgFile}" 2> /dev/null | grep -m 1 "\"name\"" | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' 2>/dev/null \
            )
          if [[ -n "${packageName}" ]]; then
            # Instead of printing out the full path, print out the name of the package
            # from the package.json and append the current subdirectory
            current_path="`echo $packageName | tr -d '"'`$subdirectory_path"
          fi
        ;;
        *)
          if [[ $current_path != "~" ]]; then
            current_path="%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:$POWERLEVEL9K_SHORTEN_DELIMITER/:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c"
            current_path="${(%)current_path}"
          fi
        ;;
      esac
    fi

    current_path=${current_path//\%/%%}

    local path_opt=$current_path
    local current_state icon
    if (( ! writable )); then
      current_state=NOT_WRITABLE
      icon=LOCK_ICON
    else
      case $PWD in
        /etc*)
          current_state=ETC
          icon=ETC_ICON
          ;;
        ~)
          current_state=HOME
          icon=HOME_ICON
          ;;
        ~/*)
          current_state=HOME_SUBFOLDER
          icon=HOME_SUB_ICON
          ;;
        *)
          current_state=DEFAULT
          icon=FOLDER_ICON
          ;;
      esac
    fi

    # This is not what Powerlevel9k does but I cannot imagine anyone wanting ~/foo to become /foo.
    if [[ $POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == true ]]; then
      if [[ $current_path == /?* ]]; then
        current_path=${current_path[2,-1]}
      elif [[ $current_path == '~'/?* ]]; then
        current_path=${current_path[3,-1]}
      fi
    fi

    if [[ $POWERLEVEL9K_HOME_FOLDER_ABBREVIATION != '~' &&
          $POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER != true &&
          $path_opt == '~'?* ]]; then
      current_path=${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}${current_path[2,-1]}
    fi

    local bld_on bld_off dir_state_foreground dir_state_user_foreground
    # test if user wants the last directory printed in bold
    if [[ $POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD == true ]]; then
      bld_on="%B"
      bld_off="%b"
    else
      bld_on=""
      bld_off=""
    fi
    # determine is the user has set a last directory color
    local dir_state_user_foreground=POWERLEVEL9K_DIR_${current_state}_FOREGROUND
    local dir_state_foreground=${${(P)dir_state_user_foreground}:-$DEFAULT_COLOR}

    local dir_name=${${current_path:h}%/}/
    local base_name=${current_path:t}
    if [[ $dir_name == ./ ]]; then
      dir_name=''
    fi
    # if the user wants the last directory colored...
    if [[ -n ${POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND} ]]; then
      if [[ -z $base_name ]]; then
        current_path="${bld_on}%F{$POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND}${current_path}${bld_off}"
      else
        current_path="${dir_name}${bld_on}%F{$POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND}${base_name}${bld_off}"
      fi
    else # no coloring
      if [[ -z $base_name ]]; then
        current_path="${bld_on}${current_path}${bld_off}"
      else
        current_path="${dir_name}${bld_on}${base_name}${bld_off}"
      fi
    fi
    # check if the user wants the separator colored.
    if [[ -n ${POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND} ]]; then
      local repl="%F{$POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND}/%F{$dir_state_foreground}"
      current_path=${current_path//\//$repl}
    fi
    if [[ "${POWERLEVEL9K_DIR_PATH_SEPARATOR}" != "/" ]]; then
      current_path=${current_path//\//$POWERLEVEL9K_DIR_PATH_SEPARATOR}
    fi

    _p9k_cache_set "$current_state" "$icon" "$current_path"
  fi

  "$1_prompt_segment" "$0_${_P9K_CACHE_VAL[1]}" "$2" blue "$DEFAULT_COLOR" "${_P9K_CACHE_VAL[2]}" 0 "" "${_P9K_CACHE_VAL[3]}"
}

################################################################
# Docker machine
prompt_docker_machine() {
  if [[ -n "$DOCKER_MACHINE_NAME" ]]; then
    "$1_prompt_segment" "$0" "$2" "magenta" "$DEFAULT_COLOR" 'SERVER_ICON' 0 '' "${DOCKER_MACHINE_NAME//\%/%%}"
  fi
}

################################################################
# GO prompt
prompt_go_version() {
  local go_version=$(go version 2>/dev/null | sed -E "s/.*(go[0-9.]*).*/\1/")
  local go_path=$(go env GOPATH 2>/dev/null)
  if [[ -n "$go_version" && "${PWD##$go_path}" != "$PWD" ]]; then
    "$1_prompt_segment" "$0" "$2" "green" "grey93" "GO_ICON" 0 '' "${go_version//\%/%%}"
  fi
}

################################################################
# Command number (in local history)
prompt_history() {
  "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" '' 0 '' '%h'
}

################################################################
# Detection for virtualization (systemd based systems only)
prompt_detect_virt() {
  local virt=$(systemd-detect-virt 2> /dev/null)
  if [[ "$virt" == "none" ]]; then
    if [[ "$(ls -di / | grep -o 2)" != "2" ]]; then
      virt="chroot"
    fi
  fi

  if [[ -n "${virt}" ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" '' 0 '' "${virt//\%/%%}"
  fi
}

################################################################
# Test icons
prompt_icons_test() {
  for key in ${(@k)icons}; do
    # The lower color spectrum in ZSH makes big steps. Choosing
    # the next color has enough contrast to read.
    local random_color=$((RANDOM % 8))
    local next_color=$((random_color+1))
    "$1_prompt_segment" "$0" "$2" "$random_color" "$next_color" "$key" 0 '' "$key"
  done
}

################################################################
# Segment to display the current IP address
set_default POWERLEVEL9K_IP_INTERFACE "^[^ ]+"
prompt_ip() {
  local ROOT_PREFIX="${4}"
  local ip=$(p9k::parseIp "${POWERLEVEL9K_IP_INTERFACE}" "${ROOT_PREFIX}")

  if [[ -n "$ip" ]]; then
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" 'NETWORK_ICON' 0 '' "${ip//\%/%%}"
  fi
}

################################################################
# Segment to display if VPN is active
set_default POWERLEVEL9K_VPN_IP_INTERFACE "tun"
# prompt if vpn active
prompt_vpn_ip() {
  local ROOT_PREFIX="${4}"
  local ip=$(p9k::parseIp "${POWERLEVEL9K_VPN_IP_INTERFACE}" "${ROOT_PREFIX}")

  if [[ -n "${ip}" ]]; then
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" 'VPN_ICON' 0 '' "${ip//\%/%%}"
  fi
}

################################################################
# Segment to display laravel version
prompt_laravel_version() {
  local laravel_version="$(php artisan --version 2> /dev/null)"
  if [[ -n "${laravel_version}" && "${laravel_version}" =~ "Laravel Framework" ]]; then
    # Strip out everything but the version
    laravel_version="${laravel_version//Laravel Framework /}"
    "$1_prompt_segment" "$0" "$2" "maroon" "white" 'LARAVEL_ICON' 0 '' "${laravel_version//\%/%%}"
  fi
}

################################################################
# Segment to display load
set_default -i POWERLEVEL9K_LOAD_WHICH 5
prompt_load() {
  local ROOT_PREFIX="${4}"
  # The load segment can have three different states
  local current_state="unknown"
  local load_select=2
  local load_avg
  local cores

  typeset -AH load_states
  load_states=(
    'critical'      'red'
    'warning'       'yellow'
    'normal'        'green'
  )

  case "$POWERLEVEL9K_LOAD_WHICH" in
    1)
      load_select=1
      ;;
    5)
      load_select=2
      ;;
    15)
      load_select=3
      ;;
  esac

  case "$OS" in
    OSX|BSD)
      load_avg=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | sed -n ${load_select}p)
      if [[ "$OS" == "OSX" ]]; then
        cores=$(sysctl -n hw.logicalcpu)
      else
        cores=$(sysctl -n hw.ncpu)
      fi
      ;;
    *)
      load_avg=$(cut -d" " -f${load_select} ${ROOT_PREFIX}/proc/loadavg)
      cores=$(nproc)
  esac

  # Replace comma
  load_avg=${load_avg//,/.}

  if [[ "$load_avg" -gt $((${cores} * 0.7)) ]]; then
    current_state="critical"
  elif [[ "$load_avg" -gt $((${cores} * 0.5)) ]]; then
    current_state="warning"
  else
    current_state="normal"
  fi

  "$1_prompt_segment" "${0}_${current_state}" "$2" "${load_states[$current_state]}" "$DEFAULT_COLOR" 'LOAD_ICON' 0 '' "$load_avg"
}

################################################################
# Segment to diplay Node version
set_default P9K_NODE_VERSION_PROJECT_ONLY false
prompt_node_version() {
  if [ "$P9K_NODE_VERSION_PROJECT_ONLY" = true ] ; then
    local foundProject=false # Variable to stop searching if a project is found
    local currentDir=$(pwd)  # Variable to iterate through the path ancestry tree

    # Search as long as no project could been found or until the root directory
    # has been reached
    while [ "$foundProject" = false -a ! "$currentDir" = "/" ] ; do

      # Check if directory contains a project description
      if [[ -e "$currentDir/package.json" ]] ; then
        foundProject=true
        break
      fi
      # Go to the parent directory
      currentDir="$(dirname "$currentDir")"
    done
  fi

  # Show version if a project has been found, or set to always show
  if [ "$P9K_NODE_VERSION_PROJECT_ONLY" != true -o "$foundProject" = true ] ; then
    # Get the node version
    local node_version=$(node -v 2>/dev/null)

    # Return if node is not installed
    [[ -z "${node_version}" ]] && return
    "$1_prompt_segment" "$0" "$2" "green" "white" 'NODE_ICON' 0 '' "${${node_version:1}//\%/%%}"
  fi
}

################################################################
# Segment to display Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  local node_version nvm_default
  (( $+functions[nvm_version] )) || return

  node_version=$(nvm_version current)
  [[ -z "${node_version}" || ${node_version} == "none" ]] && return

  nvm_default=$(nvm_version default)
  [[ "$node_version" =~ "$nvm_default" ]] && return

  $1_prompt_segment "$0" "$2" "magenta" "black" 'NODE_ICON' 0 '' "${${node_version:1}//\%/%%}"
}

################################################################
# Segment to display NodeEnv
prompt_nodeenv() {
  if [[ -n "$NODE_VIRTUAL_ENV" ]]; then
    local info="$(node -v)[${NODE_VIRTUAL_ENV:t}]"
    "$1_prompt_segment" "$0" "$2" "black" "green" 'NODE_ICON' 0 '' "${info//\%/%%}"
  fi
}

################################################################
# Segment to print a little OS icon
prompt_os_icon() {
  "$1_prompt_segment" "$0" "$2" "black" "white" '' 0 '' "$OS_ICON"
}

################################################################
# Segment to display PHP version number
prompt_php_version() {
  local php_version
  php_version=$(php -v 2>&1 | grep -oe "^PHP\s*[0-9.]*")

  if [[ -n "$php_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "fuchsia" "grey93" '' 0 '' "${php_version//\%/%%}"
  fi
}

################################################################
# Segment to display free RAM and used Swap
prompt_ram() {
  local ROOT_PREFIX="${4}"
  local base=''
  local ramfree=0
  if [[ "$OS" == "OSX" ]]; then
    # Available = Free + Inactive
    # See https://support.apple.com/en-us/HT201538
    ramfree=$(vm_stat | grep "Pages free" | grep -o -E '[0-9]+')
    ramfree=$((ramfree + $(vm_stat | grep "Pages inactive" | grep -o -E '[0-9]+')))
    # Convert pages into Bytes
    ramfree=$(( ramfree * 4096 ))
  else
    if [[ "$OS" == "BSD" ]]; then
      ramfree=$(grep 'avail memory' ${ROOT_PREFIX}/var/run/dmesg.boot | awk '{print $4}')
    else
      ramfree=$(grep -o -E "MemAvailable:\s+[0-9]+" ${ROOT_PREFIX}/proc/meminfo | grep -o -E "[0-9]+")
      base='K'
    fi
  fi

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" 'RAM_ICON' 0 '' "$(printSizeHumanReadable "$ramfree" $base)"
}

################################################################
# Segment to display rbenv information
# https://github.com/rbenv/rbenv#choosing-the-ruby-version
set_default POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW false
prompt_rbenv() {
  if [[ -n "$RBENV_VERSION" ]]; then
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "$RBENV_VERSION"
  elif [ $commands[rbenv] ]; then
    local rbenv_version_name="$(rbenv version-name)"
    local rbenv_global="$(rbenv global)"
    if [[ "${rbenv_version_name}" != "${rbenv_global}" || "${POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW}" == "true" ]]; then
      "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${rbenv_version_name//\%/%%}"
    fi
  fi
}

################################################################
# Segment to display chruby information
# see https://github.com/postmodern/chruby/issues/245 for chruby_auto issue with ZSH
set_default POWERLEVEL9K_CHRUBY_SHOW_VERSION true
set_default POWERLEVEL9K_CHRUBY_SHOW_ENGINE true
prompt_chruby() {
  # Uses $RUBY_VERSION and $RUBY_ENGINE set by chruby
  local chruby_label=""

  if [[ "$POWERLEVEL9K_CHRUBY_SHOW_ENGINE" == true ]]; then
    chruby_label+="$RUBY_ENGINE "
  fi
  if [[ "$POWERLEVEL9K_CHRUBY_SHOW_VERSION" == true ]]; then
    chruby_label+="$RUBY_VERSION"
  fi

  # Truncate trailing spaces
  chruby_label="${chruby_label%"${chruby_label##*[![:space:]]}"}"

  # Don't show anything if the chruby did not change the default ruby
  if [[ "$RUBY_ENGINE" != "" ]]; then
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${chruby_label//\%/%%}"
  fi
}

################################################################
# Segment to print an icon if user is root.
prompt_root_indicator() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" 'ROOT_ICON' 0 '${${(%):-%#}:#%}' ''
}

# This segment is a demo. It can disappear any time. Use prompt_dir instead.
prompt_simple_dir() {
  if ! _p9k_cache_get "$0" "$1" "$2" ; then
    local p=$_P9K_PROMPT
    local key=$_P9K_CACHE_KEY
    _P9K_PROMPT=''
    $1_prompt_segment $0_HOME $2 blue "$DEFAULT_COLOR" HOME_ICON 0 '${$((!${#${(%):-%~}:#\~})):#0}' "%~"
    $1_prompt_segment $0_HOME_SUBFOLDER $2 blue "$DEFAULT_COLOR" HOME_SUB_ICON 0 '${$((!${#${(%):-%~}:#\~?*})):#0}' "%~"
    $1_prompt_segment $0_ETC $2 blue "$DEFAULT_COLOR" ETC_ICON 0 '${$((!${#${(%):-%~}:#/etc*})):#0}' "%~"
    $1_prompt_segment $0_DEFAULT $2 blue "$DEFAULT_COLOR" FOLDER_ICON 0 '${${${(%):-%~}:#\~*}:#/etc*}' "%~"
    _P9K_CACHE_KEY=$key
    _p9k_cache_set "$_P9K_PROMPT"
    _P9K_PROMPT=$p
  fi
  _P9K_PROMPT+=${_P9K_CACHE_VAL[1]}
}

################################################################
# Segment to display Rust version number
prompt_rust_version() {
  local rust_version
  rust_version=$(command rustc --version 2>/dev/null)
  # Remove "rustc " (including the whitespace) from the beginning
  # of the version string and remove everything after the next
  # whitespace. This way we'll end up with only the version.
  rust_version=${${rust_version/rustc /}%% *}

  if [[ -n "$rust_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "darkorange" "$DEFAULT_COLOR" 'RUST_ICON' 0 '' "${rust_version//\%/%%}"
  fi
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ -d app && -d spec ]]; then
    local code_amount tests_amount
    code_amount=$(ls -1 app/**/*.rb | wc -l)
    tests_amount=$(ls -1 spec/**/*.rb | wc -l)

    build_test_stats "$1" "$0" "$2" "$code_amount" "$tests_amount" "RSpec" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Ruby Version Manager information
prompt_rvm() {
  if [ $commands[rvm-prompt] ]; then
    local version_and_gemset=${$(rvm-prompt v p)/ruby-}

    if [[ -n "$version_and_gemset" ]]; then
      "$1_prompt_segment" "$0" "$2" "240" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${version_and_gemset//\%/%%}"
    fi
  fi
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" 'SSH_ICON' 0 '' ''
  fi
}

################################################################
# Status: When an error occur, return the error code, or a cross icon if option is set
# Display an ok icon when no error occur, or hide the segment if option is set to false
#
set_default POWERLEVEL9K_STATUS_CROSS false
set_default POWERLEVEL9K_STATUS_OK true
set_default POWERLEVEL9K_STATUS_SHOW_PIPESTATUS true
set_default POWERLEVEL9K_STATUS_HIDE_SIGNAME false
# old options, retro compatibility
set_default POWERLEVEL9K_STATUS_VERBOSE true
set_default POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE false

exit_code_or_status() {
  local ec=$1
  if [[ "$POWERLEVEL9K_STATUS_HIDE_SIGNAME" = true ]] || (( ec <= 128 )); then
    _P9K_RETVAL=$ec
  else
    _P9K_RETVAL="SIG${signals[$((sig + 1))]}($((ec - 128)))"
  fi
}

typeset -gi _P9K_EXIT_CODE
typeset -ga _P9K_PIPE_EXIT_CODES

prompt_status() {
  if ! _p9k_cache_get "$0" "$2" "$_P9K_EXIT_CODE" "${(@)_P9K_PIPE_EXIT_CODES}"; then
    local ec_text
    local ec_sum
    local ec

    if [[ $POWERLEVEL9K_STATUS_SHOW_PIPESTATUS == true ]]; then
      if (( $#_P9K_PIPE_EXIT_CODES > 1 )); then
        ec_sum=${_P9K_PIPE_EXIT_CODES[1]}
        exit_code_or_status "${_P9K_PIPE_EXIT_CODES[1]}"

      else
        ec_sum=${_P9K_EXIT_CODE}
        exit_code_or_status "${_P9K_EXIT_CODE}"
      fi
      ec_text=$_P9K_RETVAL
      for ec in "${(@)_P9K_PIPE_EXIT_CODES[2,-1]}"; do
        (( ec_sum += ec ))
        exit_code_or_status "$ec"
        ec_text+="|$_P9K_RETVAL"
      done
    else
      ec_sum=${_P9K_EXIT_CODE}
      # We use _P9K_EXIT_CODE instead of the right-most _P9K_PIPE_EXIT_CODES item because
      # PIPE_FAIL may be set.
      exit_code_or_status "${_P9K_EXIT_CODE}"
      ec_text=$_P9K_RETVAL
    fi

    if (( ec_sum > 0 )); then
      if [[ "$POWERLEVEL9K_STATUS_CROSS" == false && "$POWERLEVEL9K_STATUS_VERBOSE" == true ]]; then
        _P9K_CACHE_VAL=("$0_ERROR" "$2" red yellow1 CARRIAGE_RETURN_ICON 0 '' "$ec_text")
      else
        _P9K_CACHE_VAL=("$0_ERROR" "$2" "$DEFAULT_COLOR" red FAIL_ICON 0 '' '')
      fi
    elif [[ "$POWERLEVEL9K_STATUS_OK" == true ]] && [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true || "$POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE" == true ]]; then
      _P9K_CACHE_VAL=("$0_OK" "$2" "$DEFAULT_COLOR" green OK_ICON 0 '' '')
    else
      return
    fi
    if (( $#_P9K_PIPE_EXIT_CODES < 3 )); then
      _p9k_cache_set "${(@)_P9K_CACHE_VAL}"
    fi
  fi
  "$1_prompt_segment" "${(@)_P9K_CACHE_VAL}"
}

################################################################
# Segment to display Swap information
prompt_swap() {
  local ROOT_PREFIX="${4}"
  local swap_used=0
  local base=''

  if [[ "$OS" == "OSX" ]]; then
    local raw_swap_used
    raw_swap_used=$(sysctl vm.swapusage | grep -o "used\s*=\s*[0-9,.A-Z]*" | grep -o "[0-9,.A-Z]*$")

    typeset -F 2 swap_used
    swap_used=${$(echo $raw_swap_used | grep -o "[0-9,.]*")//,/.}
    # Replace comma
    swap_used=${swap_used//,/.}

    base=$(echo "$raw_swap_used" | grep -o "[A-Z]*$")
  else
    swap_total=$(grep -o -E "SwapTotal:\s+[0-9]+" ${ROOT_PREFIX}/proc/meminfo | grep -o -E "[0-9]+")
    swap_free=$(grep -o -E "SwapFree:\s+[0-9]+" ${ROOT_PREFIX}/proc/meminfo | grep -o -E "[0-9]+")
    swap_used=$(( swap_total - swap_free ))
    base='K'
  fi

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" 'SWAP_ICON' 0 '' "$(printSizeHumanReadable "$swap_used" $base)"
}

################################################################
# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ -d src && -d app && -f app/AppKernel.php ]]; then
    local code_amount tests_amount
    code_amount=$(ls -1 src/**/*.php | grep -vc Tests)
    tests_amount=$(ls -1 src/**/*.php | grep -c Tests)

    build_test_stats "$1" "$0" "$2" "$code_amount" "$tests_amount" "SF2" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Symfony2-Version
prompt_symfony2_version() {
  if [[ -f app/bootstrap.php.cache ]]; then
    local symfony2_version
    symfony2_version=$(grep " VERSION " app/bootstrap.php.cache | sed -e 's/[^.0-9]*//g')
    "$1_prompt_segment" "$0" "$2" "grey35" "$DEFAULT_COLOR" 'SYMFONY_ICON' 0 '' "${symfony2_version//\%/%%}"
  fi
}

################################################################
# Show a ratio of tests vs code
build_test_stats() {
  local code_amount="$4"
  local tests_amount="$5"+0.00001
  local headline="$6"

  # Set float precision to 2 digits:
  local -F 2 ratio=$(( (tests_amount/code_amount) * 100 ))

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
}

################################################################
# System time

# If set to true, `time` prompt will update every second.
set_default POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME false
set_default POWERLEVEL9K_TIME_FORMAT "%D{%H:%M:%S}"
prompt_time() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "TIME_ICON" 0 '' "$POWERLEVEL9K_TIME_FORMAT"
}

################################################################
# System date
set_default POWERLEVEL9K_DATE_FORMAT "%D{%d.%m.%y}"
prompt_date() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "DATE_ICON" 0 '' "$POWERLEVEL9K_DATE_FORMAT"
}

################################################################
# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  if $(hash todo.sh 2>&-); then
    count=$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+) tasks shown" | awk '{ print $4 }')
    if [[ "$count" = <-> ]]; then
      "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" 'TODO_ICON' 0 '' "${count//\%/%%}"
    fi
  fi
}

################################################################
# VCS segment: shows the state of your repository, if you are in a folder under
# version control

# The vcs segment can have 4 different states - defaults to 'clean'.
typeset -gA vcs_states=(
  'clean'         'green'
  'modified'      'yellow'
  'untracked'     'green'
  'loading'       'grey'
)

set_default POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND red
set_default POWERLEVEL9K_SHOW_CHANGESET false
set_default POWERLEVEL9K_VCS_LOADING_TEXT loading
set_default -i POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH 8
set_default -a POWERLEVEL9K_VCS_GIT_HOOKS vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname
set_default -a POWERLEVEL9K_VCS_HG_HOOKS vcs-detect-changes
set_default -a POWERLEVEL9K_VCS_SVN_HOOKS vcs-detect-changes svn-detect-changes

# If it takes longer than this to fetch git repo status, display the prompt with a greyed out
# vcs segment and fix it asynchronously when the results come it.
set_default -F POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS 0.05
set_default -a POWERLEVEL9K_VCS_BACKENDS git

powerlevel9k_vcs_init() {
  if [[ -n "$POWERLEVEL9K_CHANGESET_HASH_LENGTH" ]]; then
    POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH="$POWERLEVEL9K_CHANGESET_HASH_LENGTH"
  fi

  local component state
  for component in REMOTE_URL COMMIT BRANCH TAG REMOTE_BRANCH STAGED UNSTAGED UNTRACKED \
                   OUTGOING_CHANGES INCOMING_CHANGES STASH ACTION; do
    local color=${(P)${:-POWERLEVEL9K_VCS_${component}FORMAT_FOREGROUND}}
    if [[ -n $color ]]; then
      for state in "${(@k)vcs_states}"; do
        local var=POWERLEVEL9K_VCS_${(U)state}_${component}FORMAT_FOREGROUND
        if [[ -z ${(P)var} ]]; then
          typeset -g $var=$color
        fi
      done
    fi
  done

  autoload -Uz vcs_info

  VCS_CHANGESET_PREFIX=''
  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    VCS_CHANGESET_PREFIX="$(print_icon 'VCS_COMMIT_ICON')%0.$POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH""i "
  fi

  zstyle ':vcs_info:*' check-for-changes true

  VCS_DEFAULT_FORMAT="$VCS_CHANGESET_PREFIX%b%c%u%m"
  zstyle ':vcs_info:*' formats "$VCS_DEFAULT_FORMAT"
  zstyle ':vcs_info:*' actionformats "%b %F{${POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}}| %a%f"
  zstyle ':vcs_info:*' stagedstr " $(print_icon 'VCS_STAGED_ICON')"
  zstyle ':vcs_info:*' unstagedstr " $(print_icon 'VCS_UNSTAGED_ICON')"
  zstyle ':vcs_info:git*+set-message:*' hooks $POWERLEVEL9K_VCS_GIT_HOOKS
  zstyle ':vcs_info:hg*+set-message:*' hooks $POWERLEVEL9K_VCS_HG_HOOKS
  zstyle ':vcs_info:svn*+set-message:*' hooks $POWERLEVEL9K_VCS_SVN_HOOKS

  # For Hg, only show the branch name
  zstyle ':vcs_info:hg*:*' branchformat "$(print_icon 'VCS_BRANCH_ICON')%b"
  # The `get-revision` function must be turned on for dirty-check to work for Hg
  zstyle ':vcs_info:hg*:*' get-revision true
  zstyle ':vcs_info:hg*:*' get-bookmarks true
  zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks

  # TODO: fix the %b (branch) format for svn. Using %b breaks color-encoding of the foreground
  # for the rest of the powerline.
  zstyle ':vcs_info:svn*:*' formats "$VCS_CHANGESET_PREFIX%c%u"
  zstyle ':vcs_info:svn*:*' actionformats "$VCS_CHANGESET_PREFIX%c%u %F{${POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}}| %a%f"

  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    zstyle ':vcs_info:*' get-revision true
  fi
}

# git workdir => the last prompt we've shown for it
typeset -gAH _P9K_LAST_GIT_PROMPT

# git workdir => 1 if gitstatus is slow on it, 0 if it's fast.
typeset -gAH _P9K_GIT_SLOW

function _p9k_vcs_style() {
  local color=${(P)${:-POWERLEVEL9K_VCS_${1}_${2}FORMAT_FOREGROUND}}
  if [[ -z $color ]]; then
    _P9K_RETVAL=""
    return
  fi
  if [[ $color == <-> ]]; then
    color=${(l:3::0:)color}
  else
    color=$__P9K_COLORS[${${${color#bg-}#fg-}#br}]
    if [[ -z $color ]]; then
      _P9K_RETVAL=""
      return
    fi
  fi
  _P9K_RETVAL="%F{$color}"
}

function _p9k_vcs_render() {
  if (( $+_P9K_NEXT_VCS_DIR )); then
    local -a msg
    local dir=${${GIT_DIR:a}:-$PWD}
    while true; do
      msg=("${(@0)${_P9K_LAST_GIT_PROMPT[$dir]}}")
      [[ $#msg -gt 1 || -n ${msg[1]} ]] && break
      [[ $dir == / ]] && msg=() && break
      dir=${dir:h}
    done
    if (( $#msg )); then
      $2_prompt_segment $1_LOADING $3 "${vcs_states[loading]}" "$DEFAULT_COLOR" '' 0 '' "${msg[@]}"
    else
      _p9k_get_icon VCS_LOADING_ICON
      if [[ -n $_P9K_RETVAL || -n $POWERLEVEL9K_VCS_LOADING_TEXT ]]; then
        $2_prompt_segment $1_LOADING $3 "${vcs_states[loading]}" "$DEFAULT_COLOR" VCS_LOADING_ICON 0 '' "$POWERLEVEL9K_VCS_LOADING_TEXT"
      fi
    fi
    return 0
  fi

  [[ $VCS_STATUS_RESULT == ok-* ]] || return 1

  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-untracked]} )) || VCS_STATUS_HAS_UNTRACKED=0
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-aheadbehind]} )) || { VCS_STATUS_COMMITS_AHEAD=0 && VCS_STATUS_COMMITS_BEHIND=0 }
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-stash]} )) || VCS_STATUS_STASHES=0
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-remotebranch]} )) || VCS_STATUS_REMOTE_BRANCH=""
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-tagname]} )) || VCS_STATUS_TAG=""

  local -a cache_key=(
    "$VCS_STATUS_LOCAL_BRANCH"
    "$VCS_STATUS_REMOTE_BRANCH"
    "$VCS_STATUS_REMOTE_URL"
    "$VCS_STATUS_ACTION"
    "$VCS_STATUS_HAS_STAGED"
    "$VCS_STATUS_HAS_UNSTAGED"
    "$VCS_STATUS_HAS_UNTRACKED"
    "$VCS_STATUS_COMMITS_AHEAD"
    "$VCS_STATUS_COMMITS_BEHIND"
    "$VCS_STATUS_STASHES"
    "$VCS_STATUS_TAG"
  )
  if [[ $POWERLEVEL9K_SHOW_CHANGESET == true || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    cache_key+=$VCS_STATUS_COMMIT
  fi

  if ! _p9k_cache_get "${(@)cache_key}"; then
    local state=CLEAN
    local -a cur_prompt
    local -a stale_prompt

    function _$0_fmt() {
      _p9k_vcs_style $state $1
      cur_prompt+=$_P9K_RETVAL$2
      _p9k_vcs_style LOADING $1
      stale_prompt+=$_P9K_RETVAL$2
    }

    trap "unfunction _$0_fmt" EXIT

    if (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)vcs-detect-changes]} )); then
      if [[ $VCS_STATUS_HAS_STAGED != 0 || $VCS_STATUS_HAS_UNSTAGED != 0 ]]; then
        state=MODIFIED
      elif [[ $VCS_STATUS_HAS_UNTRACKED != 0 ]]; then
        state=UNTRACKED
      fi

      # It's weird that removing vcs-detect-changes from POWERLEVEL9K_VCS_GIT_HOOKS gets rid
      # of the GIT icon. That's what vcs_info does, so we do the same in the name of compatiblity.
      if [[ "$VCS_STATUS_REMOTE_URL" == *github* ]] then
        _p9k_get_icon VCS_GIT_GITHUB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *bitbucket* ]] then
        _p9k_get_icon VCS_GIT_BITBUCKET_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *stash* ]] then
        _p9k_get_icon VCS_GIT_GITHUB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *gitlab* ]] then
        _p9k_get_icon VCS_GIT_GITLAB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      else
        _p9k_get_icon VCS_GIT_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      fi
    fi

    local ws
    if [[ $POWERLEVEL9K_SHOW_CHANGESET == true || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      _p9k_get_icon VCS_COMMIT_ICON
      _$0_fmt COMMIT "$_P9K_RETVAL${${VCS_STATUS_COMMIT:0:$POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH}:-HEAD}"
      ws=' '
    fi

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      _p9k_get_icon VCS_BRANCH_ICON
      _$0_fmt BRANCH "$ws$_P9K_RETVAL${VCS_STATUS_LOCAL_BRANCH//\%/%%}"
    fi

    if [[ $POWERLEVEL9K_VCS_HIDE_TAGS == false && -n $VCS_STATUS_TAG ]]; then
      _p9k_get_icon VCS_TAG_ICON
      _$0_fmt TAG " $_P9K_RETVAL${VCS_STATUS_TAG//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_ACTION ]]; then
      _$0_fmt ACTION " | ${VCS_STATUS_ACTION//\%/%%}"
    else
      if [[ -n $VCS_STATUS_REMOTE_BRANCH &&
            $VCS_STATUS_LOCAL_BRANCH != $VCS_STATUS_REMOTE_BRANCH ]]; then
        _p9k_get_icon VCS_REMOTE_BRANCH_ICON
        _$0_fmt REMOTE_BRANCH " $_P9K_RETVAL${VCS_STATUS_REMOTE_BRANCH//\%/%%}"
      fi
      if [[ $VCS_STATUS_HAS_STAGED == 1 ]]; then
        _p9k_get_icon VCS_STAGED_ICON
        _$0_fmt STAGED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
        _p9k_get_icon VCS_UNSTAGED_ICON
        _$0_fmt UNSTAGED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
        _p9k_get_icon VCS_UNTRACKED_ICON
        _$0_fmt UNTRACKED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 ]]; then
        _p9k_get_icon VCS_OUTGOING_CHANGES_ICON
        _$0_fmt OUTGOING_CHANGES " $_P9K_RETVAL$VCS_STATUS_COMMITS_AHEAD"
      fi
      if [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
        _p9k_get_icon VCS_INCOMING_CHANGES_ICON
        _$0_fmt INCOMING_CHANGES " $_P9K_RETVAL$VCS_STATUS_COMMITS_BEHIND"
      fi
      if [[ $VCS_STATUS_STASHES -gt 0 ]]; then
        _p9k_get_icon VCS_STASH_ICON
        _$0_fmt STASH " $_P9K_RETVAL$VCS_STATUS_STASHES"
      fi
    fi

    _p9k_cache_set "${1}_$state" "${vcs_states[${(L)state}]}" "${stale_prompt[@]}" "${cur_prompt[@]}"
  fi

  local id=${_P9K_CACHE_VAL[1]}
  local bg=${_P9K_CACHE_VAL[2]}
  shift 2 _P9K_CACHE_VAL
  local -i n=$(($#_P9K_CACHE_VAL / 2))
  _P9K_LAST_GIT_PROMPT[$VCS_STATUS_WORKDIR]="${(pj:\0:)_P9K_CACHE_VAL[1,$n]}"
  shift $n _P9K_CACHE_VAL
  $2_prompt_segment "$id" "$3" "$bg" "$DEFAULT_COLOR" '' 0 '' "${(@)_P9K_CACHE_VAL}"
  return 0
}

function _p9k_vcs_resume() {
  emulate -L zsh

  if [[ $VCS_STATUS_RESULT == ok-async ]]; then
    local latency=$((EPOCHREALTIME - _P9K_GITSTATUS_START_TIME))
    if (( latency > POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS )); then
      _P9K_GIT_SLOW[$VCS_STATUS_WORKDIR]=1
    elif (( latency < 0.8 * POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS )); then  # 0.8 to avoid flip-flopping
      _P9K_GIT_SLOW[$VCS_STATUS_WORKDIR]=0
    fi
  fi

  if [[ -z $_P9K_NEXT_VCS_DIR ]]; then
    unset _P9K_NEXT_VCS_DIR
    _p9k_update_prompt gitstatus
  else
    typeset -gFH _P9K_GITSTATUS_START_TIME=$EPOCHREALTIME
    if ! gitstatus_query -d $_P9K_NEXT_VCS_DIR -t 0 -c _p9k_vcs_resume POWERLEVEL9K; then
      unset _P9K_NEXT_VCS_DIR
      return
    fi
    case $VCS_STATUS_RESULT in
      *-sync)
        unset _P9K_NEXT_VCS_DIR
        _p9k_update_prompt gitstatus
        ;;
      tout)
        typeset -gH _P9K_NEXT_VCS_DIR=""
        ;;
    esac
  fi
}

function _p9k_vcs_gitstatus() {
  [[ $POWERLEVEL9K_DISABLE_GITSTATUS == true ]] && return 1
  if [[ $_P9K_REFRESH_REASON == precmd ]]; then
    if (( $+_P9K_NEXT_VCS_DIR )); then
      typeset -gH _P9K_NEXT_VCS_DIR=${${GIT_DIR:a}:-$PWD}
    else
      local dir=${${GIT_DIR:a}:-$PWD}
      local -F timeout=$POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS
      while true; do
        case "$_P9K_GIT_SLOW[$dir]" in
          "") [[ $dir == / ]] && break; dir=${dir:h};;
          0) break;;
          1) timeout=0; break;;
        esac
      done
      typeset -gFH _P9K_GITSTATUS_START_TIME=$EPOCHREALTIME
      gitstatus_query -d ${${GIT_DIR:a}:-$PWD} -t $timeout -c _p9k_vcs_resume POWERLEVEL9K || return 1
      [[ $VCS_STATUS_RESULT == tout ]] && typeset -gH _P9K_NEXT_VCS_DIR=""
    fi
  fi
  return 0
}

################################################################
# Segment to show VCS information

prompt_vcs() {
  local -a backends=($POWERLEVEL9K_VCS_BACKENDS)
  if (( ${backends[(I)git]} )) && _p9k_vcs_gitstatus; then
    _p9k_vcs_render $0 $1 $2 && return
    backends=(${backends:#git})
  fi
  if (( #backends )); then
    VCS_WORKDIR_DIRTY=false
    VCS_WORKDIR_HALF_DIRTY=false
    local current_state=""
    # Actually invoke vcs_info manually to gather all information.
    zstyle ':vcs_info:*' enable ${backends}
    vcs_info
    local vcs_prompt="${vcs_info_msg_0_}"
    if [[ -n "$vcs_prompt" ]]; then
      if [[ "$VCS_WORKDIR_DIRTY" == true ]]; then
        # $vcs_visual_identifier gets set in +vi-vcs-detect-changes in functions/vcs.zsh,
        # as we have there access to vcs_info internal hooks.
        current_state='modified'
      else
        if [[ "$VCS_WORKDIR_HALF_DIRTY" == true ]]; then
          current_state='untracked'
        else
          current_state='clean'
        fi
      fi
      $1_prompt_segment "${0}_${(U)current_state}" "$2" "${vcs_states[$current_state]}" "$DEFAULT_COLOR" "$vcs_visual_identifier" 0 '' "$vcs_prompt"
    fi
  fi
}

################################################################
# Vi Mode: show editing mode (NORMAL|INSERT|VISUAL)
#
# VISUAL mode is shown as NORMAL unless POWERLEVEL9K_VI_VISUAL_MODE_STRING is explicitly set.
# Your ZSH version must be >= 5.3 if you set this parameter.
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
prompt_vi_mode() {
  $1_prompt_segment $0_NORMAL $2 "$DEFAULT_COLOR" white '' 0 '${$((!${#${:-$KEYMAP$_P9K_REGION_ACTIVE}:#vicmd0})):#0}' "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
  $1_prompt_segment $0_VISUAL $2 "$DEFAULT_COLOR" white '' 0 '${$((!${#${:-$KEYMAP$_P9K_REGION_ACTIVE}:#vicmd1})):#0}' "$POWERLEVEL9K_VI_VISUAL_MODE_STRING"
  if [[ -n $POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
    $1_prompt_segment $0_INSERT $2 "$DEFAULT_COLOR" blue '' 0 '${${KEYMAP:-0}:#vicmd}' "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
  fi
}

################################################################
# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "${${VIRTUAL_ENV:t}//\%/%%}"
  fi
}

################################################################
# Segment to display pyenv information
# https://github.com/pyenv/pyenv#choosing-the-python-version
set_default POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW false
prompt_pyenv() {
  if [[ -n "$PYENV_VERSION" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "${PYENV_VERSION//\%/%%}"
  elif [ $commands[pyenv] ]; then
    local pyenv_version_name="$(pyenv version-name)"
    local pyenv_global="system"
    local pyenv_root="$(pyenv root)"
    if [[ -f "${pyenv_root}/version" ]]; then
      pyenv_global="$(pyenv version-file-read ${pyenv_root}/version)"
    fi
    if [[ "${pyenv_version_name}" != "${pyenv_global}" || "${POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW}" == "true" ]]; then
      "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "${pyenv_version_name//\%/%%}"
    fi
  fi
}

################################################################
# Display openfoam information
prompt_openfoam() {
  local wm_project_version="$WM_PROJECT_VERSION"
  local wm_fork="$WM_FORK"
  if [[ -n "$wm_project_version" && -z "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" '' 0 '' "OF: ${${wm_project_version:t}//\%/%%}"
  elif [[ -n "$wm_project_version" && -n "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" '' 0 '' "F-X: ${${wm_project_version:t}//\%/%%}"
  fi
}

################################################################
# Segment to display Swift version
prompt_swift_version() {
  # Get the first number as this is probably the "main" version number..
  local swift_version=$(swift --version 2>/dev/null | grep -o -E "[0-9.]+" | head -n 1)
  [[ -z "${swift_version}" ]] && return

  "$1_prompt_segment" "$0" "$2" "magenta" "white" 'SWIFT_ICON' 0 '' "${swift_version//\%/%%}"
}

################################################################
# dir_writable: Display information about the user's permission to write in the current directory
prompt_dir_writable() {
  if [[ ! -w "$PWD" ]]; then
    "$1_prompt_segment" "$0_FORBIDDEN" "$2" "red" "yellow1" 'LOCK_ICON' 0 '' ''
  fi
}

################################################################
# Kubernetes Current Context/Namespace
prompt_kubecontext() {
  local kubectl_version="$(kubectl version --client 2>/dev/null)"

  if [[ -n "$kubectl_version" ]]; then
    # Get the current Kuberenetes context
    local cur_ctx=$(kubectl config view -o=jsonpath='{.current-context}')
    cur_namespace="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${cur_ctx}\")].context.namespace}")"
    # If the namespace comes back empty set it default.
    if [[ -z "${cur_namespace}" ]]; then
      cur_namespace="default"
    fi

    local k8s_final_text=""

    if [[ "$cur_ctx" == "$cur_namespace" ]]; then
      # No reason to print out the same identificator twice
      k8s_final_text="$cur_ctx"
    else
      k8s_final_text="$cur_ctx/$cur_namespace"
    fi

    "$1_prompt_segment" "$0" "$2" "magenta" "white" "KUBERNETES_ICON" 0 '' "${k8s_final_text//\%/%%}"
  fi
}

################################################################
# Dropbox status
prompt_dropbox() {
  # The first column is just the directory, so cut it
  local dropbox_status="$(dropbox-cli filestatus . | cut -d\  -f2-)"

  # Only show if the folder is tracked and dropbox is running
  if [[ "$dropbox_status" != 'unwatched' && "$dropbox_status" != "isn't running!" ]]; then
    # If "up to date", only show the icon
    if [[ "$dropbox_status" =~ 'up to date' ]]; then
      dropbox_status=""
    fi

    "$1_prompt_segment" "$0" "$2" "white" "blue" "DROPBOX_ICON" 0 '' "${dropbox_status//\%/%%}"
  fi
}

# print Java version number
prompt_java_version() {
  local java_version
  # Stupid: Java prints its version on STDERR.
  # The first version ouput will print nothing, we just
  # use it to transport whether the command was successful.
  # If yes, we parse the version string (and need to
  # redirect the stderr to stdout to make the pipe work).
  java_version=$(java -version 2>/dev/null && java -fullversion 2>&1 | cut -d '"' -f 2)

  if [[ -n "$java_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "red" "white" "JAVA_ICON" 0 '' "${java_version//\%/%%}"
  fi
}

################################################################
# Prompt processing and drawing
################################################################
# Main prompt
set_default -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS context dir vcs
build_left_prompt() {
  local -i index=1
  local element
  for element in "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]}"; do
    # Remove joined information in direct calls
    element=${element%_joined}

    # Check if it is a custom command, otherwise interpet it as
    # a prompt.
    if [[ $element == custom_* ]]; then
      "prompt_custom" "left" "$index" $element[8,-1]
    else
      (( $+functions[prompt_$element] )) && "prompt_$element" "left" "$index"
    fi

    ((++index))
  done
}

# Right prompt
set_default -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS status root_indicator background_jobs history time
build_right_prompt() {
  local -i index=1
  local element

  for element in "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}"; do
    # Remove joined information in direct calls
    element=${element%_joined}

    # Check if it is a custom command, otherwise interpet it as
    # a prompt.
    if [[ $element == custom_* ]]; then
      "prompt_custom" "right" "$index" $element[8,-1]
    else
      (( $+functions[prompt_$element] )) && "prompt_$element" "right" "$index"
    fi

    ((++index))
  done
}

typeset -gF _P9K_TIMER_START

powerlevel9k_preexec() { _P9K_TIMER_START=$EPOCHREALTIME }

typeset -g _P9K_PROMPT
typeset -g _P9K_LEFT_PREFIX
typeset -g _P9K_LEFT_SUFFIX
typeset -g _P9K_RIGHT_PREFIX
typeset -g _P9K_RIGHT_SUFFIX

set_default POWERLEVEL9K_DISABLE_RPROMPT false
function _p9k_set_prompt() {
  emulate -L zsh

  _P9K_PROMPT=''
  build_left_prompt
  PROMPT=$_P9K_LEFT_PREFIX$_P9K_PROMPT$_P9K_LEFT_SUFFIX

  if [[ $POWERLEVEL9K_DISABLE_RPROMPT == true ]]; then
    RPROMPT=''
  else
    _P9K_PROMPT=''
    build_right_prompt
    RPROMPT=$_P9K_RIGHT_PREFIX$_P9K_PROMPT$_P9K_RIGHT_SUFFIX
  fi
}

typeset -g _P9K_REFRESH_REASON

function _p9k_update_prompt() {
  (( _P9K_ENABLED )) || return
  _P9K_REFRESH_REASON=$1
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
  zle && zle .reset-prompt && zle -R
}

typeset -gi _P9K_REGION_ACTIVE

set_default POWERLEVEL9K_PROMPT_ADD_NEWLINE false
powerlevel9k_prepare_prompts() {
  # Do not move these lines down, otherwise the last command is not what you expected it to be.
  _P9K_EXIT_CODE=$?
  _P9K_PIPE_EXIT_CODES=( "$pipestatus[@]" )
  _P9K_COMMAND_DURATION=$((EPOCHREALTIME - _P9K_TIMER_START))

  unsetopt local_options
  prompt_opts=(cr percent sp subst)
  setopt nopromptbang prompt{cr,percent,sp,subst}

  _p9k_init
  _P9K_TIMER_START=1e10
  _P9K_REGION_ACTIVE=0

  _P9K_REFRESH_REASON=precmd
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
}

function _p9k_zle_keymap_select() {
  zle && zle .reset-prompt && zle -R
}

set_default POWERLEVEL9K_IGNORE_TERM_COLORS false
set_default POWERLEVEL9K_IGNORE_TERM_LANG false
set_default POWERLEVEL9K_DISABLE_GITSTATUS false
set_default -i POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY -1

typeset -g DEFAULT_COLOR
typeset -g DEFAULT_COLOR_INVERTED
typeset -gi _P9K_INITIALIZED=0

typeset -g OS
typeset -g OS_ICON
typeset -g SED_EXTENDED_REGEX_PARAMETER

typeset -g  _P9K_TIMER_FIFO
typeset -gi _P9K_TIMER_FD=0
typeset -gi _P9K_TIMER_PID=0
typeset -gi _P9K_TIMER_SUBSHELL=0

_p9k_init_timer() {
  _p9k_start_timer() {
    emulate -L zsh
    setopt err_return no_bg_nice

    _P9K_TIMER_FIFO=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.timer.pipe.XXXXXXXXXX)
    mkfifo $_P9K_TIMER_FIFO
    sysopen -rw -o cloexec,sync -u _P9K_TIMER_FD $_P9K_TIMER_FIFO
    zsystem flock $_P9K_TIMER_FIFO

    function _p9k_on_timer() {
      emulate -L zsh
      local dummy
      while IFS='' read -t -u $_P9K_TIMER_FD dummy; do true; done
      zle && zle .reset-prompt && zle -R
    }

    zle -F $_P9K_TIMER_FD _p9k_on_timer

    # `kill -WINCH $$` is a workaround for a bug in zsh. After a background job completes, callbacks
    # registered with `zle -F` stop firing until the user presses any key or the process receives a
    # signal (any signal at all).
    zsh -c "
      zmodload zsh/system
      while sleep 1 && ! zsystem flock -t 0 ${(q)_P9K_TIMER_FIFO} && kill -WINCH $$ && echo; do
        true
      done
      command rm -f ${(q)_P9K_TIMER_FIFO}
    " </dev/null >&$_P9K_TIMER_FD 2>/dev/null &!

    _P9K_TIMER_PID=$!
    _P9K_TIMER_SUBSHELL=$ZSH_SUBSHELL

    function _p9k_kill_timer() {
      emulate -L zsh
      if (( ZSH_SUBSHELL == _P9K_TIMER_SUBSHELL )); then
        (( _P9K_TIMER_PID )) && kill -- -$_P9K_TIMER_PID &>/dev/null
        command rm -f $_P9K_TIMER_FIFO
      fi
    }
    add-zsh-hook zshexit _p9k_kill_timer
  }

  if ! _p9k_start_timer ; then
    echo "powerlevel10k: failed to initialize background timer" >&2
    if (( _P9K_TIMER_FD )); then
      zle -F $_P9K_TIMER_FD
      exec {_P9K_TIMER_FD}>&-
      _P9K_TIMER_FD=0
    fi
    if (( _P9K_TIMER_PID )); then
      kill -- -$_P9K_TIMER_PID &>/dev/null
      _P9K_TIMER_PID=0
    fi
    command rm -f $_P9K_TIMER_FIFO
    _P9K_TIMER_FIFO=''
    unset -f _p9k_on_timer
  fi
}

# Some people write POWERLEVEL9K_DIR_PATH_SEPARATOR='\uNNNN' instead of
# POWERLEVEL9K_DIR_PATH_SEPARATOR=$'\uNNNN'. There is no good reason for it and if we were
# starting from scratch we wouldn't perform automatic conversion from the former to the latter.
# But we aren't starting from scratch, so convert we do.
_p9k_init_strings() {
  # To find candidates:
  #
  #   egrep 'set_default [^-]' powerlevel9k.zsh-theme | egrep -v '(true|false)$'
  _p9k_g_expand POWERLEVEL9K_ANACONDA_LEFT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_CONTEXT_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_DATE_FORMAT
  _p9k_g_expand POWERLEVEL9K_DIR_PATH_SEPARATOR
  _p9k_g_expand POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
  _p9k_g_expand POWERLEVEL9K_HOST_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_SHORTEN_DELIMITER
  _p9k_g_expand POWERLEVEL9K_TIME_FORMAT
  _p9k_g_expand POWERLEVEL9K_USER_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_VCS_LOADING_TEXT
  _p9k_g_expand POWERLEVEL9K_VI_COMMAND_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_VI_INSERT_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS
}

_p9k_init() {
  (( _P9K_INITIALIZED )) && return

  _p9k_init_icons
  _p9k_init_strings

  function _$0_set_os() {
    OS=$1
    _p9k_get_icon $2
    OS_ICON=$_P9K_RETVAL
  }

  trap "unfunction _$0_set_os" EXIT

  if [[ $(uname -o 2>/dev/null) == Android ]]; then
    _$0_set_os Android ANDROID_ICON
  else
    case $(uname) in
      SunOS)                     _$0_set_os Solaris SUNOS_ICON;;
      Darwin)                    _$0_set_os OSX     APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   _$0_set_os Windows WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) _$0_set_os BSD     FREEBSD_ICON;;
      Linux)
        OS='Linux'
        local os_release_id
        [[ -f /etc/os-release &&
          "${(f)$((</etc/os-release) 2>/dev/null)}" =~ "ID=([A-Za-z]+)" ]] && os_release_id="${match[1]}"
        case "$os_release_id" in
          *arch*)                  _$0_set_os Linux LINUX_ARCH_ICON;;
          *debian*)                _$0_set_os Linux LINUX_DEBIAN_ICON;;
          *raspbian*)              _$0_set_os Linux LINUX_RASPBIAN_ICON;;
          *ubuntu*)                _$0_set_os Linux LINUX_UBUNTU_ICON;;
          *elementary*)            _$0_set_os Linux LINUX_ELEMENTARY_ICON;;
          *fedora*)                _$0_set_os Linux LINUX_FEDORA_ICON;;
          *coreos*)                _$0_set_os Linux LINUX_COREOS_ICON;;
          *gentoo*)                _$0_set_os Linux LINUX_GENTOO_ICON;;
          *mageia*)                _$0_set_os Linux LINUX_MAGEIA_ICON;;
          *centos*)                _$0_set_os Linux LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) _$0_set_os Linux LINUX_OPENSUSE_ICON;;
          *sabayon*)               _$0_set_os Linux LINUX_SABAYON_ICON;;
          *slackware*)             _$0_set_os Linux LINUX_SLACKWARE_ICON;;
          *linuxmint*)             _$0_set_os Linux LINUX_MINT_ICON;;
          *alpine*)                _$0_set_os Linux LINUX_ALPINE_ICON;;
          *aosc*)                  _$0_set_os Linux LINUX_AOSC_ICON;;
          *nixos*)                 _$0_set_os Linux LINUX_NIXOS_ICON;;
          *devuan*)                _$0_set_os Linux LINUX_DEVUAN_ICON;;
          *manjaro*)               _$0_set_os Linux LINUX_MANJARO_ICON;;
          *)                       _$0_set_os Linux LINUX_ICON;;
        esac
        ;;
    esac
  fi

  if [[ $POWERLEVEL9K_COLOR_SCHEME == light ]]; then
    DEFAULT_COLOR=white
    DEFAULT_COLOR_INVERTED=black
  else
    DEFAULT_COLOR=black
    DEFAULT_COLOR_INVERTED=white
  fi

  local i
  for ((i = 2; i <= $#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS; ++i)); do
    local elem=$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[$i]
    if [[ $elem == *_joined ]]; then
      _P9K_LEFT_JOIN+=$_P9K_LEFT_JOIN[((i-1))]
    else
      _P9K_LEFT_JOIN+=$i
    fi
  done

  for ((i = 2; i <= $#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS; ++i)); do
    local elem=$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[$i]
    if [[ $elem == *_joined ]]; then
      _P9K_RIGHT_JOIN+=$_P9K_RIGHT_JOIN[((i-1))]
    else
      _P9K_RIGHT_JOIN+=$i
    fi
  done

  if [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]]; then
    _p9k_init_timer
  fi

  _P9K_LEFT_PREFIX+='${${_P9K_BG::=NONE}+}${${_P9K_I::=0}+}'
  _P9K_RIGHT_PREFIX+='${${_P9K_BG::=NONE}+}${${_P9K_I::=0}+}'

  _p9k_get_icon LEFT_SEGMENT_SEPARATOR
  _P9K_T=("%f$_P9K_RETVAL" "")
  _P9K_PROMPT=''
  _p9k_left_prompt_end_line
  _P9K_LEFT_SUFFIX=$_P9K_PROMPT
  _P9K_PROMPT=''
  _p9k_get_icon LEFT_SEGMENT_END_SEPARATOR
  _P9K_LEFT_SUFFIX+=$_P9K_RETVAL

  _P9K_RIGHT_SUFFIX+='%f%b%k'
  _P9K_RIGHT_PREFIX+='%f%b%k'

  if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE == true ]]; then
    _p9k_get_icon MULTILINE_FIRST_PROMPT_PREFIX
    _P9K_LEFT_PREFIX+="$_P9K_RETVAL%f%b%k"
    _p9k_get_icon MULTILINE_LAST_PROMPT_PREFIX
    _P9K_LEFT_SUFFIX+=$'\n'$_P9K_RETVAL
    if [[ $POWERLEVEL9K_RPROMPT_ON_NEWLINE != true ]]; then
      # The right prompt should be on the same line as the first line of the left
      # prompt. To do so, there is just a quite ugly workaround: Before zsh draws
      # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
      # advise it to go one line down. See:
      # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
      local LC_ALL="" LC_CTYPE="en_US.UTF-8" # Set the right locale to protect special characters
      _P9K_RIGHT_PREFIX+='%{'$'\e[1A''%}' # one line up
      _P9K_RIGHT_SUFFIX+='%{'$'\e[1B''%}' # one line down
    fi
  else
    _P9K_LEFT_PREFIX+="%f%b%k"
  fi

  if [[ $POWERLEVEL9K_PROMPT_ADD_NEWLINE == true ]]; then
    repeat ${POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT:-1} { _P9K_LEFT_PREFIX=$'\n'$_P9K_LEFT_PREFIX }
  fi

  if [[ $ITERM_SHELL_INTEGRATION_INSTALLED == Yes ]]; then
    _P9K_LEFT_PREFIX="%{$(iterm2_prompt_mark)%}$_P9K_LEFT_PREFIX"
  fi

  # If the terminal `LANG` is set to `C`, this theme will not work at all.
  if [[ $LANG == C && $POWERLEVEL9K_IGNORE_TERM_LANG == false ]]; then
    print -P "\t%F{red}WARNING!%f Your terminal's 'LANG' is set to 'C', which breaks this theme!"
    print -P "\t%F{red}WARNING!%f Please set your 'LANG' to a UTF-8 language, like 'en_US.UTF-8'"
    print -P "\t%F{red}WARNING!%f _before_ loading this theme in your \~\.zshrc. Putting"
    print -P "\t%F{red}WARNING!%f %F{blue}export LANG=\"en_US.UTF-8\"%f at the top of your \~\/.zshrc is sufficient."
    print -P 'Set POWERLEVEL9K_IGNORE_TERM_LANG=true to suppress this warning.'
  fi

  # Display a warning if the terminal does not support 256 colors.
  if [[ $POWERLEVEL9K_IGNORE_TERM_COLORS == false ]]; then
    if zmodload zsh/terminfo 2>/dev/null && (( $+terminfo[colors] && $terminfo[colors] < 256 )); then
      print -P '%F{red}WARNING!%f Your terminal appears to support fewer than 256 colors!'
      print -P 'If your terminal supports 256 colors, please export the appropriate environment variable.'
      print -P 'In most terminal emulators, adding %F{blue}export TERM=xterm-256color%f to your %F{yellow}~/.zshrc%f is sufficient.'
      print -P 'Set %F{blue}POWERLEVEL9K_IGNORE_TERM_COLORS=true%f to suppress this warning.'
    fi
  fi

  if segment_in_use longstatus; then
    print -P '%F{yellow}WARNING!%f The "longstatus" segment is deprecated. Use "%F{blue}status%f" instead.'
    print -P 'For more informations, have a look at https://github.com/bhilburn/powerlevel9k/blob/master/CHANGELOG.md.'
  fi

  if segment_in_use vcs; then
    powerlevel9k_vcs_init
    if [[ $POWERLEVEL9K_DISABLE_GITSTATUS != true ]] && (( ${POWERLEVEL9K_VCS_BACKENDS[(I)git]} )); then
      source ${POWERLEVEL9K_GITSTATUS_DIR:-${_P9K_INSTALLATION_DIR}/gitstatus}/gitstatus.plugin.zsh
      gitstatus_start -m $POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY POWERLEVEL9K
    fi
  fi

  if segment_in_use vi_mode && (( $+POWERLEVEL9K_VI_VISUAL_MODE_STRING )); then
    if is-at-least 5.3; then
      function _p9k_zle_line_pre_redraw() {
        [[ $KEYMAP == vicmd ]] &&
          [[ ${REGION_ACTIVE:-0} != $_P9K_REGION_ACTIVE ]] &&
          _P9K_REGION_ACTIVE=${REGION_ACTIVE:-0} &&
          zle && zle .reset-prompt && zle -R
      }
      autoload -Uz add-zle-hook-widget
      add-zle-hook-widget line-pre-redraw _p9k_zle_line_pre_redraw
      _p9k_g_expand POWERLEVEL9K_VI_VISUAL_MODE_STRING
    else
      >&2 print -P '%F{yellow}WARNING!%f POWERLEVEL9K_VI_VISUAL_MODE_STRING requires ZSH >= 5.3.'
      >&2 print -r "Your zsh version is $ZSH_VERSION. Either upgrade zsh or unset POWERLEVEL9K_VI_VISUAL_MODE_STRING."
    fi
  fi

  zle -N zle-keymap-select _p9k_zle_keymap_select

  _P9K_INITIALIZED=1
}

typeset -gi _P9K_ENABLED=0

prompt_powerlevel9k_setup() {
  prompt_powerlevel9k_teardown

  add-zsh-hook precmd powerlevel9k_prepare_prompts
  add-zsh-hook preexec powerlevel9k_preexec

  _P9K_TIMER_START=1e10
  _P9K_ENABLED=1
}

prompt_powerlevel9k_teardown() {
  add-zsh-hook -D precmd powerlevel9k_\*
  add-zsh-hook -D preexec powerlevel9k_\*
  PROMPT='%m%# '
  RPROMPT=
  _P9K_ENABLED=0
}

autoload -U colors && colors
autoload -Uz add-zsh-hook

zmodload zsh/datetime
zmodload zsh/mathfunc
zmodload zsh/system

prompt_powerlevel9k_setup "$@"
