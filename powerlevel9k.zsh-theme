# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# powerlevel10k Theme
# https://github.com/romkatv/powerlevel10k
#
# Forked from powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# Which was inspired by agnoster's Theme:
# https://gist.github.com/3712874
################################################################

################################################################
# For basic documentation, please refer to the README.md in the
# top-level directory.
################################################################

## Turn on for Debugging
#PS4='%s%f%b%k%F{blue}%{λ%}%L %F{240}%N:%i%(?.. %F{red}%?) %1(_.%F{yellow}%-1_ .)%s%f%b%k '
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

# Bail out if it's not the first time the file is being sourced.
# Second sourcing will cause mayhem.
[[ -n "${_P9K_SOURCED}" ]] && return
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

typeset -g _P9K_CURRENT_BG
typeset -gi _P9K_LAST_SEGMENT_INDEX

_p9k_should_join_left() [[ $_P9K_LAST_SEGMENT_INDEX -ge ${_P9K_LEFT_JOIN[$1]:-$1} ]]
_p9k_should_join_right() [[ $_P9K_LAST_SEGMENT_INDEX -ge ${_P9K_RIGHT_JOIN[$1]:-$1} ]]

# Resolves a color to its numerical value, or an empty string. Communicates the result back
# by setting _P9K_RETVAL.
_p9k_color() {
  local user_var=POWERLEVEL9K_${(U)${2}#prompt_}_${3}
  local color=${${(P)user_var}:-${1}}
  # Check if given value is already numerical.
  if [[ $color == <-> ]]; then
    _P9K_RETVAL=${(l:3::0:)color}
  else
    # Strip prifices if there are any.
    _P9K_RETVAL=$__P9K_COLORS[${${${color#bg-}#fg-}#br}]
  fi
}

_p9k_background() {
  [[ -n $1 ]] && _P9K_RETVAL="%K{$1}" || _P9K_RETVAL="%k"
}

_p9k_foreground() {
  [[ -n $1 ]] && _P9K_RETVAL="%F{$1}" || _P9K_RETVAL="%f"
}

# Begin a left prompt segment
# Takes four arguments:
#   * $1: Name of the function that was originally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: The array index of the current segment
#   * $3: Background color
#   * $4: Foreground color
#   * $5: The segment content
#   * $6: An identifying icon (must be a key of the icons array)
# The latter three can be omitted,
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS " "
left_prompt_segment() {
  _p9k_should_join_left $2
  local -i separate=$?
  if ! _p9k_cache_get "$0" "$1" "$3" "$4" "${5:+1}" "$6" "$_P9K_CURRENT_BG" "$separate"; then
    _p9k_color $3 $1 BACKGROUND
    local background_color=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local foreground_color=$_P9K_RETVAL
    _p9k_foreground $foreground_color
    local foreground=$_P9K_RETVAL

    _p9k_background $background_color
    local output=$_P9K_RETVAL

    if [[ $_P9K_CURRENT_BG == NONE ]]; then
      # The first segment on the line.
      output+=$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
    elif (( separate )); then
      if [[ $background_color == $_P9K_CURRENT_BG ]]; then
        # Middle segment with same color as previous segment
        # We take the current foreground color as color for our
        # subsegment (or the default color). This should have
        # enough contrast.
        if [[ $foreground == "%f" ]]; then
          _p9k_foreground $DEFAULT_COLOR
          output+=$_P9K_RETVAL
        else
          output+=$foreground
        fi
        _p9k_get_icon LEFT_SUBSEGMENT_SEPARATOR
        output+="${_P9K_RETVAL}${POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS}"
      else
        output+="%F{$_P9K_CURRENT_BG}"
        _p9k_get_icon LEFT_SEGMENT_SEPARATOR
        output+="${_P9K_RETVAL}${POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS}"
      fi
    fi
    if [[ -n $6 ]]; then
      _p9k_get_icon $6
      if [[ -n $_P9K_RETVAL ]]; then
        local icon=$_P9K_RETVAL
        _p9k_color $foreground_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        
        # Add an whitespace if we print more than just the visual identifier.
        # To avoid cutting off the visual identifier in some terminal emulators (e.g., Konsole, st),
        # we need to color both the visual identifier and the whitespace.
        output+="${_P9K_RETVAL}${icon}${5:+ }"
      fi
    fi
    output+=$foreground
    _p9k_cache_set "$output" "$background_color"
  fi

  _P9K_PROMPT+="${_P9K_CACHE_VAL[1]}${5}${POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS}"
  _P9K_LAST_SEGMENT_INDEX=$2
  _P9K_CURRENT_BG=$_P9K_CACHE_VAL[2]
}

# Begin a right prompt segment
# Takes four arguments:
#   * $1: Name of the function that was originally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: The array index of the current segment
#   * $3: Background color
#   * $4: Foreground color
#   * $5: The segment content
#   * $6: An identifying icon (must be a key of the icons array)
# No ending for the right prompt segment is needed (unlike the left prompt, above).
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS " "
right_prompt_segment() {
  _p9k_should_join_right $2
  local -i separate=$?
  if ! _p9k_cache_get "$0" "$1" "$3" "$4" "$6" "$_P9K_CURRENT_BG" "$separate"; then
    _p9k_color $3 $1 BACKGROUND
    local background_color=$_P9K_RETVAL
    _p9k_background $background_color
    local background=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local foreground_color=$_P9K_RETVAL
    _p9k_foreground $foreground_color
    local foreground=$_P9K_RETVAL

    local output=''

    if [[ $_P9K_CURRENT_BG == NONE || $separate != 0 ]]; then
      if [[ $background_color == $_P9K_CURRENT_BG ]]; then
        # Middle segment with same color as previous segment
        # We take the current foreground color as color for our
        # subsegment (or the default color). This should have
        # enough contrast.
        if [[ $foreground == "%f" ]]; then
          _p9k_foreground $DEFAULT_COLOR
          output+=$_P9K_RETVAL
        else
          output+=$foreground
        fi
        _p9k_get_icon RIGHT_SUBSEGMENT_SEPARATOR
        output+=$_P9K_RETVAL
      else
        output+="%F{$background_color}"
        _p9k_get_icon RIGHT_SEGMENT_SEPARATOR
        output+=$_P9K_RETVAL
      fi
      output+="${background}${POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS}"
    else
      output+=$background
    fi

    output+=$foreground

    local icon=''
    if [[ -n $6 ]]; then
      _p9k_get_icon $6
      if [[ -n $_P9K_RETVAL ]]; then
        local icon=$_P9K_RETVAL
        _p9k_color $foreground_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        # Add an whitespace if we print more than just the visual identifier.
        # To avoid cutting off the visual identifier in some terminal emulators (e.g., Konsole, st),
        # we need to color both the visual identifier and the whitespace.
        icon="${_P9K_RETVAL}${icon} "
      fi
    fi

    _p9k_cache_set "$output" "$background_color" "$icon"
  fi

  _P9K_PROMPT+="${_P9K_CACHE_VAL[1]}${5}${5:+ }${_P9K_CACHE_VAL[3]}"
  _P9K_CURRENT_BG=$_P9K_CACHE_VAL[2]
  _P9K_LAST_SEGMENT_INDEX=$2
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
  local _path=$CONDA_ENV_PATH$CONDA_PREFIX
  if ! [ -z "$_path" ]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$POWERLEVEL9K_ANACONDA_LEFT_DELIMITER$(basename $_path)$POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER" 'PYTHON_ICON'
  fi
}

################################################################
# AWS Profile
prompt_aws() {
  local aws_profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [[ -n "$aws_profile" ]]; then
    "$1_prompt_segment" "$0" "$2" red white "$aws_profile" 'AWS_ICON'
  fi
}

################################################################
# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  # TODO(roman): This is clearly broken. Fix it.
  local eb_env=$(grep environment .elasticbeanstalk/config.yml 2> /dev/null | awk '{print $2}')
  if [[ -n "$eb_env" ]]; then
    "$1_prompt_segment" "$0" "$2" black green "$eb_env" 'AWS_EB_ICON'
  fi
}

################################################################
# Segment to indicate background jobs with an icon.
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE true
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS false
prompt_background_jobs() {
  local n && n="${(fw)#$(jobs -d)}" && ((n > 1)) || return
  (( n /= 2 ))

  local prompt=''
  if [[ "$POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE" == "true" &&
        ("$n" -gt 1 || "$POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS" == "true") ]]; then
    prompt=$n
  fi
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "cyan" "$prompt" 'BACKGROUND_JOBS_ICON'
}

################################################################
# A newline in your prompt, so you can segments on multiple lines.
set_default POWERLEVEL9K_PROMPT_ON_NEWLINE false
prompt_newline() {
  [[ "$1" == "right" ]] && return
  local newline=$'\n'
  local lws=$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    _p9k_get_icon MULTILINE_NEWLINE_PROMPT_PREFIX
    newline="${newline}${_P9K_RETVAL}"
  fi
  POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=
  "$1_prompt_segment" "$0" "$2" "" "" "${newline}"
  _P9K_CURRENT_BG=NONE
  POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=$lws
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
    "$1_prompt_segment" "${0}_${current_state}" "$2" "${hdd_usage_backcolors[$current_state]}" "${hdd_usage_forecolors[$current_state]}" "$message" 'DISK_ICON'
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
    "$1_prompt_segment" "$0_${current_state}" "$2" "${POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND[$offset]}" "${battery_states[$current_state]}" "${message}" "BATTERY_ICON"
  else
    # Draw the prompt_segment
    "$1_prompt_segment" "$0_${current_state}" "$2" "${DEFAULT_COLOR}" "${battery_states[$current_state]}" "${message}" "BATTERY_ICON"
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
    $1_prompt_segment "$0" "$2" "$DEFAULT_COLOR" "$DEFAULT_COLOR_INVERTED" "${public_ip}" "$icon"
  fi
}

################################################################
# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_ALWAYS_SHOW_CONTEXT false
set_default POWERLEVEL9K_ALWAYS_SHOW_USER false
set_default POWERLEVEL9K_CONTEXT_TEMPLATE "%n@%m"
prompt_context() {
  local current_state="DEFAULT"
  local content=""

  if [[ "$POWERLEVEL9K_ALWAYS_SHOW_CONTEXT" == true || "$(whoami)" != "$DEFAULT_USER" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
      content="${POWERLEVEL9K_CONTEXT_TEMPLATE}"
  elif [[ "$POWERLEVEL9K_ALWAYS_SHOW_USER" == true ]]; then
      content="$(whoami)"
  else
      return
  fi

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

  "$1_prompt_segment" "${0}_${current_state}" "$2" "$DEFAULT_COLOR" yellow "${content}"
}

################################################################
# User: user (who am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_USER_TEMPLATE "%n"
prompt_user() {
  [[ "$POWERLEVEL9K_ALWAYS_SHOW_USER" != true && "$(whoami)" == "$DEFAULT_USER" ]] && return
  if [[ "${(%):-%#}" == '#' ]]; then
    "$1_prompt_segment" "${0}_ROOT" "$2" "${DEFAULT_COLOR}" yellow "${POWERLEVEL9K_USER_TEMPLATE}" ROOT_ICON
  elif [[ -n "$SUDO_COMMAND" ]]; then
    "$1_prompt_segment" "${0}_SUDO" "$2" "${DEFAULT_COLOR}" yellow "${POWERLEVEL9K_USER_TEMPLATE}" SUDO_ICON
  else
    "$1_prompt_segment" "${0}_DEFAULT" "$2" "${DEFAULT_COLOR}" yellow "$(whoami)" USER_ICON
  fi
}

################################################################
# Host: machine (where am I)
set_default POWERLEVEL9K_HOST_TEMPLATE "%m"
prompt_host() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0_REMOTE" "$2" "${DEFAULT_COLOR}" yellow "${POWERLEVEL9K_HOST_TEMPLATE}" SSH_ICON
  else
    "$1_prompt_segment" "$0_LOCAL" "$2" "${DEFAULT_COLOR}" yellow "${POWERLEVEL9K_HOST_TEMPLATE}" HOST_ICON
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
    "$1_prompt_segment" "${0}_${3:u}" "$2" $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR "$segment_content" "CUSTOM_${segment_name}_ICON"
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

  "$1_prompt_segment" "$0" "$2" "red" "yellow1" "${humanReadableDuration}" 'EXECUTION_TIME_ICON'
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
set_default POWERLEVEL9K_DIR_SHOW_WRITABLE false
set_default POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER false
set_default POWERLEVEL9K_SHORTEN_STRATEGY ""
set_default POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND ""
set_default POWERLEVEL9K_SHORTEN_DELIMITER $'\u2026'
set_default POWERLEVEL9K_SHORTEN_FOLDER_MARKER ".shorten_folder_marker"
set_default POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD ""
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
      # convert delimiter from unicode to literal character, so that we can get the correct length later
      local delim=$(echo -n $POWERLEVEL9K_SHORTEN_DELIMITER)

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
            package_path=${$(pwd)%%$gitPath}
            # Remove trailing slash
            package_path=${package_path%/}
          elif [[ $(git rev-parse --is-inside-git-dir 2> /dev/null) == "true" ]]; then
            package_path=${$(pwd)%%/.git*}
          fi

         [[ ${(L)POWERLEVEL9K_DIR_PATH_ABSOLUTE} != "true" ]] && package_path=${package_path/$HOME/"~"}

          # Replace the shortest possible match of the marked folder from
          # the current path. Remove the amount of characters up to the
          # folder marker from the left. Count only the visible characters
          # in the path (this is done by the "zero" pattern; see
          # http://stackoverflow.com/a/40855342/5586433).
          local zero='%([BSUbfksu]|([FB]|){*})'
          trunc_path=$(pwd)
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

    # save state of path for highlighting and bold options
    local path_opt=$current_path
    local state_path="${(%):-%~}"
    local current_state="DEFAULT"
    local icon="FOLDER_ICON"
    if [[ $state_path == '/etc'* ]]; then
      current_state='ETC'
      icon='ETC_ICON'
    elif (( ! writable )); then
      current_state="NOT_WRITABLE"
      icon='LOCK_ICON'
    elif [[ $state_path == '~' ]]; then
      current_state="HOME"
      icon='HOME_ICON'
    elif [[ $state_path == '~'* ]]; then
      current_state="HOME_SUBFOLDER"
      icon='HOME_SUB_ICON'
    fi

    # declare variables used for bold and state colors
    local bld_on bld_off dir_state_foreground dir_state_user_foreground
    # test if user wants the last directory printed in bold
    if [[ "${(L)POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD}" == "true" ]]; then
      bld_on="%B"
      bld_off="%b"
    else
      bld_on=""
      bld_off=""
    fi
    # determine is the user has set a last directory color
    local dir_state_user_foreground=POWERLEVEL9K_DIR_${current_state}_FOREGROUND
    local dir_state_foreground=${(P)dir_state_user_foreground}
    [[ -z ${dir_state_foreground} ]] && dir_state_foreground="${DEFAULT_COLOR}"

    local dir_name base_name
    # use ZSH substitution to get the dirname and basename instead of calling external functions
    dir_name=${path_opt%/*}
    base_name=${path_opt##*/}

    # if the user wants the last directory colored...
    if [[ -n ${POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND} ]]; then
      # it the path is "/" or "~"
      if [[ $path_opt == "/" || $path_opt == "~" ]]; then
        current_path="${bld_on}%F{$POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND}${current_path}${bld_off}"
      else # has a subfolder
        # test if dirname != basename - they are equal if we use truncate_to_last or truncate_absolute
        if [[ $dir_name != $base_name ]]; then
          current_path="${dir_name}/${bld_on}%F{$POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND}${base_name}${bld_off}"
        else
          current_path="${bld_on}%F{$POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND}${base_name}${bld_off}"
        fi
      fi
    else # no coloring
      # it the path is "/" or "~"
      if [[ $path_opt == "/" || $path_opt == "~" ]]; then
        current_path="${bld_on}${current_path}${bld_off}"
      else # has a subfolder
        # test if dirname != basename - they are equal if we use truncate_to_last or truncate_absolute
        if [[ $dir_name != $base_name ]]; then
          current_path="${dir_name}/${bld_on}${base_name}${bld_off}"
        else
          current_path="${bld_on}${base_name}${bld_off}"
        fi
      fi
    fi

    # check if we need to omit the first character and only do it if we are not in "~" or "/"
    if [[ "${POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER}" == "true" && $path_opt != "/" && $path_opt != "~" ]]; then
      current_path="${current_path[2,-1]}"
    fi

    # check if the user wants the separator colored.
    if [[ -n ${POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND} && $path_opt != "/" ]]; then
      # because this contains color changing codes, it is easier to set a variable for what should be replaced
      local repl="%F{$POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND}/%F{$dir_state_foreground}"
      # escape the / with a \
      current_path=${current_path//\//$repl}
    fi

    if [[ "${POWERLEVEL9K_DIR_PATH_SEPARATOR}" != "/" && $path_opt != "/" ]]; then
      current_path=${current_path//\//$POWERLEVEL9K_DIR_PATH_SEPARATOR}
    fi

    if [[ "${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}" != "~" && ! "${(L)POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER}" == "true" ]]; then
      # use :s to only replace the first occurance
      current_path=${current_path:s/~/$POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}
    fi

    _p9k_cache_set "$current_state" "$current_path" "$icon"
  fi

  "$1_prompt_segment" "$0_${_P9K_CACHE_VAL[1]}" "$2" blue "$DEFAULT_COLOR" "${_P9K_CACHE_VAL[2]}" "${_P9K_CACHE_VAL[3]}"
}

################################################################
# Docker machine
prompt_docker_machine() {
  if [[ -n "$DOCKER_MACHINE_NAME" ]]; then
    "$1_prompt_segment" "$0" "$2" "magenta" "$DEFAULT_COLOR" "$DOCKER_MACHINE_NAME" 'SERVER_ICON'
  fi
}

################################################################
# GO prompt
prompt_go_version() {
  local go_version=$(go version 2>/dev/null | sed -E "s/.*(go[0-9.]*).*/\1/")
  local go_path=$(go env GOPATH 2>/dev/null)
  if [[ -n "$go_version" && "${PWD##$go_path}" != "$PWD" ]]; then
    "$1_prompt_segment" "$0" "$2" "green" "grey93" "$go_version" "GO_ICON"
  fi
}

################################################################
# Command number (in local history)
prompt_history() {
  "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" '%h'
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
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" "$virt"
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
    "$1_prompt_segment" "$0" "$2" "$random_color" "$next_color" "$key" "$key"
  done
}

################################################################
# Segment to display the current IP address
set_default POWERLEVEL9K_IP_INTERFACE "^[^ ]+"
prompt_ip() {
  local ROOT_PREFIX="${4}"
  local ip=$(p9k::parseIp "${POWERLEVEL9K_IP_INTERFACE}" "${ROOT_PREFIX}")

  if [[ -n "$ip" ]]; then
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" "$ip" 'NETWORK_ICON'
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
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" "$ip" 'VPN_ICON'
  fi
}

################################################################
# Segment to display laravel version
prompt_laravel_version() {
  local laravel_version="$(php artisan --version 2> /dev/null)"
  if [[ -n "${laravel_version}" && "${laravel_version}" =~ "Laravel Framework" ]]; then
    # Strip out everything but the version
    laravel_version="${laravel_version//Laravel Framework /}"
    "$1_prompt_segment" "$0" "$2" "maroon" "white" "${laravel_version}" 'LARAVEL_ICON'
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

  "$1_prompt_segment" "${0}_${current_state}" "$2" "${load_states[$current_state]}" "$DEFAULT_COLOR" "$load_avg" 'LOAD_ICON'
}

################################################################
# Segment to diplay Node version
prompt_node_version() {
  local node_version=$(node -v 2>/dev/null)
  [[ -z "${node_version}" ]] && return

  "$1_prompt_segment" "$0" "$2" "green" "white" "${node_version:1}" 'NODE_ICON'
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

  $1_prompt_segment "$0" "$2" "magenta" "black" "${node_version:1}" 'NODE_ICON'
}

################################################################
# Segment to display NodeEnv
prompt_nodeenv() {
  if [[ -n "$NODE_VIRTUAL_ENV" ]]; then
    local info="$(node -v)[${NODE_VIRTUAL_ENV:t}]"
    "$1_prompt_segment" "$0" "$2" "black" "green" "$info" 'NODE_ICON'
  fi
}

################################################################
# Segment to print a little OS icon
prompt_os_icon() {
  "$1_prompt_segment" "$0" "$2" "black" "white" "$OS_ICON"
}

################################################################
# Segment to display PHP version number
prompt_php_version() {
  local php_version
  php_version=$(php -v 2>&1 | grep -oe "^PHP\s*[0-9.]*")

  if [[ -n "$php_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "fuchsia" "grey93" "$php_version"
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

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "$(printSizeHumanReadable "$ramfree" $base)" 'RAM_ICON'
}

################################################################
# Segment to display rbenv information
# https://github.com/rbenv/rbenv#choosing-the-ruby-version
set_default POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW false
prompt_rbenv() {
  if [[ -n "$RBENV_VERSION" ]]; then
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" "$RBENV_VERSION" 'RUBY_ICON'
  elif [ $commands[rbenv] ]; then
    local rbenv_version_name="$(rbenv version-name)"
    local rbenv_global="$(rbenv global)"
    if [[ "${rbenv_version_name}" != "${rbenv_global}" || "${POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW}" == "true" ]]; then
      "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" "$rbenv_version_name" 'RUBY_ICON'
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
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" "${chruby_label}" 'RUBY_ICON'
  fi
}

################################################################
# Segment to print an icon if user is root.
prompt_root_indicator() {
  if [[ "$UID" -eq 0 ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" "" 'ROOT_ICON'
  fi
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
    "$1_prompt_segment" "$0" "$2" "darkorange" "$DEFAULT_COLOR" "$rust_version" 'RUST_ICON'
  fi
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ (-d app && -d spec) ]]; then
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
      "$1_prompt_segment" "$0" "$2" "240" "$DEFAULT_COLOR" "$version_and_gemset" 'RUBY_ICON'
    fi
  fi
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" "" 'SSH_ICON'
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
        _P9K_CACHE_VAL=("$0_ERROR" "$2" red yellow1 "$ec_text" CARRIAGE_RETURN_ICON)
      else
        _P9K_CACHE_VAL=("$0_ERROR" "$2" "$DEFAULT_COLOR" red "" FAIL_ICON)
      fi
    elif [[ "$POWERLEVEL9K_STATUS_OK" == true ]] && [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true || "$POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE" == true ]]; then
      _P9K_CACHE_VAL=("$0_OK" "$2" "$DEFAULT_COLOR" green "" OK_ICON)
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

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "$(printSizeHumanReadable "$swap_used" $base)" 'SWAP_ICON'
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
    "$1_prompt_segment" "$0" "$2" "grey35" "$DEFAULT_COLOR" "$symfony2_version" 'SYMFONY_ICON'
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

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
}

################################################################
# System time

# If set to true, `time` prompt will update every second.
set_default POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME false
set_default POWERLEVEL9K_TIME_FORMAT "%D{%H:%M:%S}"
prompt_time() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$POWERLEVEL9K_TIME_FORMAT" "TIME_ICON"
  # For the reference, here's how the code should ideally look like. However, it's 2ms slower
  # for a tiny gain in usability. The difference is that the current code will cause time
  # to update when vcs segment goes from grey to green/yellow, but the commented-out code
  # won't (unless POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME is true).
  #if [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]]; then
  #  local _P9K_TIME=$POWERLEVEL9K_TIME_FORMAT
  #else
  #  [[ -v _P9K_REFRESH_PROMPT ]] || typeset -gH _P9K_TIME=$(print -P $POWERLEVEL9K_TIME_FORMAT)
  #  typeset -gH _P9K_TIME=$POWERLEVEL9K_TIME_FORMAT
  #fi
  #"$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$_P9K_TIME" "TIME_ICON"
}

################################################################
# System date
set_default POWERLEVEL9K_DATE_FORMAT "%D{%d.%m.%y}"
prompt_date() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$POWERLEVEL9K_DATE_FORMAT" "DATE_ICON"
  # See comments in prompt_time.
  # [[ -v _P9K_REFRESH_PROMPT ]] || typeset -gH _P9K_DATE=$(print -P $POWERLEVEL9K_DATE_FORMAT)
  # "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$_P9K_DATE" "DATE_ICON"
}

################################################################
# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  if $(hash todo.sh 2>&-); then
    count=$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+) tasks shown" | awk '{ print $4 }')
    if [[ "$count" = <-> ]]; then
      "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" "$count" 'TODO_ICON'
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

typeset -fH _p9k_vcs_render() {
  if [[ -v _P9K_NEXT_VCS_DIR ]]; then
    local prompt
    local dir=$PWD
    while true; do
      prompt=${_P9K_LAST_GIT_PROMPT[$dir]}
      [[ -n $prompt || $dir == / ]] && break
      dir=${dir:h}
    done
    _p9k_vcs_do_render $2 $1_LOADING $3 "${vcs_states[loading]}" "$DEFAULT_COLOR" ${prompt:-loading}
    return 0
  fi

  [[ $VCS_STATUS_RESULT == ok-* ]] || return 1
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
  )
  if ! _p9k_cache_get "${(@)cache_key}"; then
    local state
    if [[ $VCS_STATUS_HAS_STAGED != 0 || $VCS_STATUS_HAS_UNSTAGED != 0 ]]; then
      state='modified'
    elif [[ $VCS_STATUS_HAS_UNTRACKED != 0 ]]; then
      state='untracked'
    else
      state='clean'
    fi

    local vcs_prompt
    if [[ "$VCS_STATUS_REMOTE_URL" == *github* ]] then
      _p9k_get_icon VCS_GIT_GITHUB_ICON
      vcs_prompt+=$_P9K_RETVAL
    elif [[ "$VCS_STATUS_REMOTE_URL" == *bitbucket* ]] then
      _p9k_get_icon VCS_GIT_BITBUCKET_ICON
      vcs_prompt+=$_P9K_RETVAL
    elif [[ "$VCS_STATUS_REMOTE_URL" == *stash* ]] then
      _p9k_get_icon VCS_GIT_GITHUB_ICON
      vcs_prompt+=$_P9K_RETVAL
    elif [[ "$VCS_STATUS_REMOTE_URL" == *gitlab* ]] then
      _p9k_get_icon VCS_GIT_GITLAB_ICON
      vcs_prompt+=$_P9K_RETVAL
    else
      _p9k_get_icon VCS_GIT_ICON
      vcs_prompt+=$_P9K_RETVAL
    fi

    _p9k_get_icon VCS_BRANCH_ICON
    vcs_prompt+="$_P9K_RETVAL$VCS_STATUS_LOCAL_BRANCH"
    if [[ -n $VCS_STATUS_ACTION ]]; then
      vcs_prompt+=" %F{${POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}}| $VCS_STATUS_ACTION%f"
    else
      if [[ -n $VCS_STATUS_REMOTE_BRANCH &&
            $VCS_STATUS_LOCAL_BRANCH != $VCS_STATUS_REMOTE_BRANCH ]]; then
        _p9k_get_icon VCS_REMOTE_BRANCH_ICON
        vcs_prompt+=" $_P9K_RETVAL$VCS_STATUS_REMOTE_BRANCH"
      fi
      if [[ $VCS_STATUS_HAS_STAGED == 1 ]]; then
        _p9k_get_icon VCS_STAGED_ICON
        vcs_prompt+=" $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
        _p9k_get_icon VCS_UNSTAGED_ICON
        vcs_prompt+=" $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
        _p9k_get_icon VCS_UNTRACKED_ICON
        vcs_prompt+=" $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 ]]; then
        _p9k_get_icon VCS_OUTGOING_CHANGES_ICON
        vcs_prompt+=" $_P9K_RETVAL$VCS_STATUS_COMMITS_AHEAD"
      fi
      if [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
        _p9k_get_icon VCS_INCOMING_CHANGES_ICON
        vcs_prompt+=" $_P9K_RETVAL$VCS_STATUS_COMMITS_BEHIND"
      fi
      if [[ $VCS_STATUS_STASHES -gt 0 ]]; then
        _p9k_get_icon VCS_STASH_ICON
        vcs_prompt+=" $_P9K_RETVAL$VCS_STATUS_STASHES"
      fi
    fi

    _p9k_cache_set "${1}_${(U)state}" "${vcs_states[$state]}" "$vcs_prompt"
  fi

  _P9K_LAST_GIT_PROMPT[$VCS_STATUS_WORKDIR]="${_P9K_CACHE_VAL[3]}"
  _p9k_vcs_do_render $2 "${_P9K_CACHE_VAL[1]}" $3 "${_P9K_CACHE_VAL[2]}" "$DEFAULT_COLOR" "${_P9K_CACHE_VAL[3]}"
  return 0
}

typeset -fH _p9k_vcs_resume() {
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

typeset -fH _p9k_vcs_gitstatus() {
  [[ $POWERLEVEL9K_DISABLE_GITSTATUS == true ]] && return 1
  if [[ $_P9K_REFRESH_REASON == precmd ]]; then
    if [[ -v _P9K_NEXT_VCS_DIR ]]; then
      typeset -gH _P9K_NEXT_VCS_DIR=$PWD
    else
      local dir=$PWD
      local -F timeout=$POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS
      while true; do
        case "$_P9K_GIT_SLOW[$dir]" in
          "") [[ $dir == / ]] && break; dir=${dir:h};;
          0) break;;
          1) timeout=0; break;;
        esac
      done
      typeset -gFH _P9K_GITSTATUS_START_TIME=$EPOCHREALTIME
      gitstatus_query -t $timeout -c _p9k_vcs_resume POWERLEVEL9K || return 1
      [[ $VCS_STATUS_RESULT == tout ]] && typeset -gH _P9K_NEXT_VCS_DIR=""
    fi
  fi
  return 0
}

function _p9k_vcs_do_render() {
  local side=$1
  shift
  _P9K_LAST_VCS_SEGMENT=("$@")
  "${side}_prompt_segment" "$@"
}

################################################################
# Segment to show VCS information

typeset -ga _P9K_LAST_VCS_SEGMENT

prompt_vcs() {
  if [[ $_P9K_REFRESH_REASON != precmd && $_P9K_REFRESH_REASON != gitstatus ]]; then
    if (( #_P9K_LAST_VCS_SEGMENT )); then
      "$1_prompt_segment" "${(@)_P9K_LAST_VCS_SEGMENT}"
    fi
    return
  fi
  _P9K_LAST_VCS_SEGMENT=()
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
      _p9k_vcs_do_render $1 "${0}_${(U)current_state}" "$2" "${vcs_states[$current_state]}" "$DEFAULT_COLOR" "$vcs_prompt" "$vcs_visual_identifier"
    fi
  fi
}

################################################################
# Vi Mode: show editing mode (NORMAL|INSERT)
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"

typeset -gi _P9K_KEYMAP_VIMCMD

prompt_vi_mode() {
  if (( _P9K_KEYMAP_VIMCMD )); then
    "$1_prompt_segment" "$0_NORMAL" "$2" "$DEFAULT_COLOR" "white" "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
  elif [[ -n $POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
    "$1_prompt_segment" "$0_INSERT" "$2" "$DEFAULT_COLOR" "blue" "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
  fi
}

################################################################
# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "${virtualenv_path:t}" 'PYTHON_ICON'
  fi
}

################################################################
# Segment to display pyenv information
# https://github.com/pyenv/pyenv#choosing-the-python-version
set_default POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW false
prompt_pyenv() {
  if [[ -n "$PYENV_VERSION" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$PYENV_VERSION" 'PYTHON_ICON'
  elif [ $commands[pyenv] ]; then
    local pyenv_version_name="$(pyenv version-name)"
    local pyenv_global="system"
    local pyenv_root="$(pyenv root)"
    if [[ -f "${pyenv_root}/version" ]]; then
      pyenv_global="$(pyenv version-file-read ${pyenv_root}/version)"
    fi
    if [[ "${pyenv_version_name}" != "${pyenv_global}" || "${POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW}" == "true" ]]; then
      "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$pyenv_version_name" 'PYTHON_ICON'
    fi
  fi
}

################################################################
# Display openfoam information
prompt_openfoam() {
  local wm_project_version="$WM_PROJECT_VERSION"
  local wm_fork="$WM_FORK"
  if [[ -n "$wm_project_version" ]] &&  [[ -z "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "OF: $(basename "$wm_project_version")"
  elif [[ -n "$wm_project_version" ]] && [[ -n "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "F-X: $(basename "$wm_project_version")"
  fi
}

################################################################
# Segment to display Swift version
prompt_swift_version() {
  # Get the first number as this is probably the "main" version number..
  local swift_version=$(swift --version 2>/dev/null | grep -o -E "[0-9.]+" | head -n 1)
  [[ -z "${swift_version}" ]] && return

  "$1_prompt_segment" "$0" "$2" "magenta" "white" "${swift_version}" 'SWIFT_ICON'
}

################################################################
# dir_writable: Display information about the user's permission to write in the current directory
prompt_dir_writable() {
  if [[ ! -w "$PWD" ]]; then
    "$1_prompt_segment" "$0_FORBIDDEN" "$2" "red" "yellow1" "" 'LOCK_ICON'
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

    "$1_prompt_segment" "$0" "$2" "magenta" "white" "$k8s_final_text" "KUBERNETES_ICON"
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

    "$1_prompt_segment" "$0" "$2" "white" "blue" "$dropbox_status" "DROPBOX_ICON"
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
    "$1_prompt_segment" "$0" "$2" "red" "white" "$java_version" "JAVA_ICON"
  fi
}

################################################################
# Prompt processing and drawing
################################################################
# Main prompt
set_default -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS context dir vcs
build_left_prompt() {
  _P9K_CURRENT_BG=NONE
  _P9K_LAST_SEGMENT_INDEX=0

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
      "prompt_$element" "left" "$index"
    fi

    ((++index))
  done

  if ! _p9k_cache_get "$0" "$_P9K_CURRENT_BG"; then
    local output="%k"
    if [[ $_P9K_CURRENT_BG != NONE ]]; then
      _p9k_foreground $_P9K_CURRENT_BG
      output+=$_P9K_RETVAL
      _p9k_get_icon LEFT_SEGMENT_SEPARATOR
      output+="${_P9K_RETVAL}"
    fi
    _p9k_get_icon LEFT_SEGMENT_END_SEPARATOR
    output+="%f${_P9K_RETVAL}"
    _p9k_cache_set "$output"
  fi
  _P9K_PROMPT+="${_P9K_CACHE_VAL[1]}"
}

# Right prompt
set_default -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS status root_indicator background_jobs history time
build_right_prompt() {
  _P9K_CURRENT_BG=NONE
  _P9K_LAST_SEGMENT_INDEX=0

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
      "prompt_$element" "right" "$index"
    fi

    ((++index))
  done

  # Clear to the end of the line
  _P9K_PROMPT+="%E"
}

typeset -gF _P9K_TIMER_START

powerlevel9k_preexec() { _P9K_TIMER_START=$EPOCHREALTIME }

typeset -g _P9K_PROMPT
typeset -g _P9K_LEFT_PREFIX
typeset -g _P9K_LEFT_SUFFIX
typeset -g _P9K_RIGHT_PREFIX
typeset -g _P9K_RIGHT_SUFFIX

set_default POWERLEVEL9K_DISABLE_RPROMPT false
typeset -fH _p9k_set_prompt() {
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

  unset _P9K_HOOK1
  unset _P9K_HOOK2
}

typeset -g _P9K_REFRESH_REASON

function _p9k_update_prompt() {
  (( _P9K_ENABLED )) || return
  _P9K_REFRESH_REASON=$1
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
  zle .reset-prompt
}

set_default POWERLEVEL9K_PROMPT_ADD_NEWLINE false
powerlevel9k_prepare_prompts() {
  # Do not move these lines down, otherwise the last command is not what you expected it to be.
  _P9K_EXIT_CODE=$?
  _P9K_PIPE_EXIT_CODES=( "$pipestatus[@]" )
  _P9K_COMMAND_DURATION=$((EPOCHREALTIME - _P9K_TIMER_START))

  emulate -L zsh

  _p9k_init
  _P9K_TIMER_START=1e10
  _P9K_KEYMAP_VIMCMD=0

  _P9K_REFRESH_REASON=precmd
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
}

function _p9k_zle_keymap_select() {
  [[ $KEYMAP == vicmd ]] && _P9K_KEYMAP_VIMCMD=1 || _P9K_KEYMAP_VIMCMD=0
  _p9k_update_prompt keymap-select
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

typeset -gi _P9K_TIMER_FD1=0
typeset -gi _P9K_TIMER_FD2=0

_p9k_init_timer() {
  local fifo1 fifo2

  _p9k_start_timer() {
    emulate -L zsh
    setopt err_return no_bg_nice

    fifo1=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.pipe1.timer.XXXXXXXXXX)
    fifo2=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.pipe2.timer.XXXXXXXXXX)
    mkfifo $fifo1
    mkfifo $fifo2
    exec {_P9K_TIMER_FD1}<>$fifo1
    exec {_P9K_TIMER_FD2}<>$fifo2

    function _p9k_on_timer() {
      emulate -L zsh
      local reason
      IFS='' read -u $_P9K_TIMER_FD1 reason || return
      unset _P9K_HOOK1
      unset _P9K_HOOK2
      [[ -n $reason ]] && _p9k_update_prompt $reason || zle .reset-prompt
    }

    zle -F $_P9K_TIMER_FD1 _p9k_on_timer

    # This `sleep 1 && kill -WINCH $$` is a workaround for what seems like a bug in zsh.
    zsh -c "
      while kill -0 $$; do
        if IFS='' read -u $_P9K_TIMER_FD2 -t 1; then
          sleep 1
          kill -WINCH $$
          echo job-complete
        elif [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]]; then
          echo
        fi
      done
    " <&$_P9K_TIMER_FD2 >&$_P9K_TIMER_FD1 2>/dev/null &!
  }

  if ! _p9k_start_timer ; then
    echo "powerlevel10k: failed to initialize background timer" >&2
    if (( _P9K_TIMER_FD1 )); then
      zle -F $_P9K_TIMER_FD1
      exec {_P9K_TIMER_FD1}>&-
    fi
    if (( _P9K_TIMER_FD2 )); then
      exec {_P9K_TIMER_FD2}>&-
    fi
    _P9K_TIMER_FD1=0
    _P9K_TIMER_FD2=0
    unset -f _p9k_on_timer
  fi
  rm -f "$fifo1" "$fifo2"
}

_p9k_init() {
  (( _P9K_INITIALIZED )) && return

  _p9k_init_icons

  local function set_os() {
    OS=$1
    _p9k_get_icon $2
    OS_ICON=$_P9K_RETVAL
  }

  if [[ $(uname -o 2>/dev/null) == Android ]]; then
    set_os Android ANDROID_ICON
  else
    case $(uname) in
      SunOS)                     set_os Solaris SUNOS_ICON;;
      Darwin)                    set_os OSX     APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   set_os Windows WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) set_os BSD     FREEBSD_ICON;;
      Linux)
        OS='Linux'
        local os_release_id
        [[ -f /etc/os-release &&
          "${(f)$((</etc/os-release) 2>/dev/null)}" =~ "ID=([A-Za-z]+)" &&
          os_release_id="${match[1]}" ]]
        case "$os_release_id" in
          *arch*)                  set_os Linux LINUX_ARCH_ICON;;
          *debian*)                set_os Linux LINUX_DEBIAN_ICON;;
          *ubuntu*)                set_os Linux LINUX_UBUNTU_ICON;;
          *elementary*)            set_os Linux LINUX_ELEMENTARY_ICON;;
          *fedora*)                set_os Linux LINUX_FEDORA_ICON;;
          *coreos*)                set_os Linux LINUX_COREOS_ICON;;
          *gentoo*)                set_os Linux LINUX_GENTOO_ICON;;
          *mageia*)                set_os Linux LINUX_MAGEIA_ICON;;
          *centos*)                set_os Linux LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) set_os Linux LINUX_OPENSUSE_ICON;;
          *sabayon*)               set_os Linux LINUX_SABAYON_ICON;;
          *slackware*)             set_os Linux LINUX_SLACKWARE_ICON;;
          *linuxmint*)             set_os Linux LINUX_MINT_ICON;;
          *alpine*)                set_os Linux LINUX_ALPINE_ICON;;
          *aosc*)                  set_os Linux LINUX_AOSC_ICON;;
          *nixos*)                 set_os Linux LINUX_NIXOS_ICON;;
          *devuan*)                set_os Linux LINUX_DEVUAN_ICON;;
          *manjaro*)               set_os Linux LINUX_MANJARO_ICON;;
          *)                       set_os Linux LINUX_ICON;;
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

  if [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]] || segment_in_use background_jobs; then
    _p9k_init_timer
  fi

  local RPROMPT_SUFFIX RPROMPT_PREFIX
  if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE == true ]]; then
    _p9k_get_icon MULTILINE_FIRST_PROMPT_PREFIX
    _P9K_LEFT_PREFIX="$_P9K_RETVAL%f%b%k"
    #PROMPT="$_P9K_RETVAL%f%b%k$left$NEWLINE"
    _p9k_get_icon MULTILINE_LAST_PROMPT_PREFIX
    _P9K_LEFT_SUFFIX=$'\n'$_P9K_RETVAL
    if [[ $POWERLEVEL9K_RPROMPT_ON_NEWLINE != true ]]; then
      # The right prompt should be on the same line as the first line of the left
      # prompt. To do so, there is just a quite ugly workaround: Before zsh draws
      # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
      # advise it to go one line down. See:
      # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
      local LC_ALL="" LC_CTYPE="en_US.UTF-8" # Set the right locale to protect special characters
      _P9K_RIGHT_PREFIX='%{'$'\e[1A''%}' # one line up
      _P9K_RIGHT_SUFFIX='%{'$'\e[1B''%}' # one line down
    fi
  else
    _P9K_LEFT_PREFIX="%f%b%k"
  fi

  if [[ $ITERM_SHELL_INTEGRATION_INSTALLED == Yes ]]; then
    _P9K_LEFT_PREFIX="%{$(iterm2_prompt_mark)%}$_P9K_LEFT_PREFIX"
  fi

  _P9K_RIGHT_PREFIX+="%f%b%k"
  _P9K_RIGHT_SUFFIX="%{$reset_color%}$_P9K_RIGHT_SUFFIX"

  if [[ $POWERLEVEL9K_PROMPT_ADD_NEWLINE == true ]]; then
    repeat ${POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT:-1} { _P9K_LEFT_PREFIX=$'\n'$_P9K_LEFT_PREFIX }
  fi

  if segment_in_use background_jobs && (( _P9K_TIMER_FD2 )); then
    _P9K_LEFT_SUFFIX+="\${_P9K_HOOK1+\${_P9K_HOOK2-\${_P9K_HOOK2=}\$(echo >&$_P9K_TIMER_FD2)}}\${_P9K_HOOK1=}"
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
    local n
    if { hash tput && n=$(tput colors) || hash echotc && n=$(echotc Co) } 2>/dev/null && (( n < 256 )); then
      if [[ -n $n && $n -lt 256 ]]; then
        print -P '%F{red}WARNING!%f Your terminal appears to support fewer than 256 colors!'
        print -P 'If your terminal supports 256 colors, please export the appropriate environment variable.'
        print -P 'In most terminal emulators, putting %F{blue}export TERM=xterm-256color%f at the top of your ~/.zshrc is sufficient.'
        print -P 'Set POWERLEVEL9K_IGNORE_TERM_COLORS=true to suppress this warning.'
      fi
    fi
  fi

  if segment_in_use longstatus; then
    print -P '%F{yellow}Warning!%f The "longstatus" segment is deprecated. Use "%F{blue}status%f" instead.'
    print -P 'For more informations, have a look at https://github.com/bhilburn/powerlevel9k/blob/master/CHANGELOG.md.'
  fi

  if segment_in_use vcs; then
    powerlevel9k_vcs_init
    if [[ $POWERLEVEL9K_DISABLE_GITSTATUS != true ]] && (( ${POWERLEVEL9K_VCS_BACKENDS[(I)git]} )); then
      source ${POWERLEVEL9K_GITSTATUS_DIR:-${_P9K_INSTALLATION_DIR}/gitstatus}/gitstatus.plugin.zsh
      gitstatus_start -m $POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY POWERLEVEL9K
    fi
  fi

  zle -N zle-keymap-select _p9k_zle_keymap_select

  _P9K_INITIALIZED=1
}

typeset -gi _P9K_ENABLED=0

prompt_powerlevel9k_setup() {
  setopt nopromptbang prompt{cr,percent,sp,subst}

  prompt_powerlevel9k_teardown

  add-zsh-hook precmd powerlevel9k_prepare_prompts
  add-zsh-hook preexec powerlevel9k_preexec

  _P9K_TIMER_START=1e10
  _P9K_ENABLED=1
}

prompt_powerlevel9k_teardown() {
  emulate -L zsh
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

prompt_powerlevel9k_setup "$@"
