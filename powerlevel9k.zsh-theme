# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# This theme was inspired by agnoster's Theme:
# https://gist.github.com/3712874
################################################################

################################################################
# For basic documentation, please refer to the README.md in the top-level
# directory. For more detailed documentation, refer to the project wiki, hosted
# on Github: https://github.com/bhilburn/powerlevel9k/wiki
#
# There are a lot of easy ways you can customize your prompt segments and
# theming with simple variables defined in your `~/.zshrc`.
################################################################

## Turn on for Debugging
#PS4='%s%f%b%k%F{blue}%{λ%}%L %F{240}%N:%i%(?.. %F{red}%?) %1(_.%F{yellow}%-1_ .)%s%f%b%k '
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

# Try to set the installation path
if [[ -n "$POWERLEVEL9K_INSTALLATION_DIR" ]]; then
  p9k_directory=${POWERLEVEL9K_INSTALLATION_DIR:A}
else
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/powerlevel9k.zsh-theme" ]]; then
      # Antigen uses eval to load things so it can change the plugin (!!)
      # https://github.com/zsh-users/antigen/issues/581
      p9k_directory=$PWD
    else
      print -P "%F{red}You must set POWERLEVEL9K_INSTALLATION_DIR work from within an (eval).%f"
      return 1
    fi
  else
    # Get the path to file this code is executing in; then
    # get the absolute path and strip the filename.
    # See https://stackoverflow.com/a/28336473/108857
    p9k_directory=${${(%):-%x}:A:h}
  fi
fi

################################################################
# Source icon functions
################################################################

source "${p9k_directory}/functions/icons.zsh"

################################################################
# Source utility functions
################################################################

source "${p9k_directory}/functions/utilities.zsh"

################################################################
# Source color functions
################################################################

source "${p9k_directory}/functions/colors.zsh"

################################################################
# Source VCS_INFO hooks / helper functions
################################################################

source "${p9k_directory}/functions/vcs.zsh"

# cleanup temporary variables.
unset p9k_directory

################################################################
# Color Scheme
################################################################

if [[ "$POWERLEVEL9K_COLOR_SCHEME" == "light" ]]; then
  DEFAULT_COLOR=white
  DEFAULT_COLOR_INVERTED=black
else
  DEFAULT_COLOR=black
  DEFAULT_COLOR_INVERTED=white
fi

################################################################
# Prompt Segment Constructors
#
# Methodology behind user-defined variables overwriting colors:
#     The first parameter to the segment constructors is the calling function's
#     name. From this function name, we strip the "prompt_"-prefix and
#     uppercase it. This is then prefixed with "POWERLEVEL9K_" and suffixed
#     with either "_BACKGROUND" or "_FOREGROUND", thus giving us the variable
#     name. So each new segment is user-overwritten by a variable following
#     this naming convention.
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

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
set_default last_left_element_index 1
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS " "
left_prompt_segment() {
  local segment_name="${1}"
  local current_index=$2
  # Check if the segment should be joined with the previous one
  local joined
  segmentShouldBeJoined $current_index $last_left_element_index "$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS" && joined=true || joined=false

  # Colors
  local backgroundColor="${3}"
  local foregroundColor="${4}"

  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)${segment_name}#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && backgroundColor="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)${segment_name}#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && foregroundColor="$FG_COLOR_MODIFIER"

  # Get color codes here to save some calls later on
  backgroundColor="$(getColorCode ${backgroundColor})"
  foregroundColor="$(getColorCode ${foregroundColor})"

  local background foreground
  [[ -n "${backgroundColor}" ]] && background="$(backgroundColor ${backgroundColor})" || background="%k"
  [[ -n "${foregroundColor}" ]] && foreground="$(foregroundColor ${foregroundColor})" || foreground="%f"

  if [[ $CURRENT_BG != 'NONE' ]] && ! isSameColor "${backgroundColor}" "$CURRENT_BG"; then
    echo -n "${background}%F{$CURRENT_BG}"
    if [[ $joined == false ]]; then
      # Middle segment
      echo -n "$(print_icon 'LEFT_SEGMENT_SEPARATOR')$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
    fi
  elif isSameColor "$CURRENT_BG" "${backgroundColor}"; then
    # Middle segment with same color as previous segment
    # We take the current foreground color as color for our
    # subsegment (or the default color). This should have
    # enough contrast.
    local complement
    [[ -n "${foregroundColor}" ]] && complement="${foreground}" || complement="$(foregroundColor $DEFAULT_COLOR)"
    echo -n "${background}${complement}"
    if [[ $joined == false ]]; then
      echo -n "$(print_icon 'LEFT_SUBSEGMENT_SEPARATOR')$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
    fi
  else
    # First segment
    echo -n "${background}$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
  fi

  local visual_identifier
  if [[ -n $6 ]]; then
    visual_identifier="$(print_icon $6)"
    if [[ -n "$visual_identifier" ]]; then
      # Add an whitespace if we print more than just the visual identifier.
      # To avoid cutting off the visual identifier in some terminal emulators (e.g., Konsole, st),
      # we need to color both the visual identifier and the whitespace.
      [[ -n "$5" ]] && visual_identifier="$visual_identifier "
      # Allow users to overwrite the color for the visual identifier only.
      local visual_identifier_color_variable=POWERLEVEL9K_${(U)${segment_name}#prompt_}_VISUAL_IDENTIFIER_COLOR
      set_default $visual_identifier_color_variable "${foregroundColor}"
      visual_identifier="$(foregroundColor ${(P)visual_identifier_color_variable})${visual_identifier}%f"
    fi
  fi

  # Print the visual identifier
  echo -n "${visual_identifier}"
  # Print the content of the segment, if there is any
  [[ -n "$5" ]] && echo -n "${foreground}${5}"
  echo -n "${POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS}"

  CURRENT_BG="${backgroundColor}"
  last_left_element_index=$current_index
}

# End the left prompt, closes the final segment.
left_prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%k$(foregroundColor ${CURRENT_BG})$(print_icon 'LEFT_SEGMENT_SEPARATOR')"
  else
    echo -n "%k"
  fi
  echo -n "%f$(print_icon 'LEFT_SEGMENT_END_SEPARATOR')"
  CURRENT_BG=''
}

CURRENT_RIGHT_BG='NONE'

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
set_default last_right_element_index 1
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS " "
right_prompt_segment() {
  local segment_name="${1}"
  local current_index=$2

  # Check if the segment should be joined with the previous one
  local joined
  segmentShouldBeJoined $current_index $last_right_element_index "$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" && joined=true || joined=false

  # Colors
  local backgroundColor="${3}"
  local foregroundColor="${4}"

  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)${segment_name}#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && backgroundColor="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)${segment_name}#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && foregroundColor="$FG_COLOR_MODIFIER"

  # Get color codes here to save some calls later on
  backgroundColor="$(getColorCode ${backgroundColor})"
  foregroundColor="$(getColorCode ${foregroundColor})"

  local background foreground
  [[ -n "${backgroundColor}" ]] && background="$(backgroundColor ${backgroundColor})" || background="%k"
  [[ -n "${foregroundColor}" ]] && foreground="$(foregroundColor ${foregroundColor})" || foreground="%f"

  # If CURRENT_RIGHT_BG is "NONE", we are the first right segment.

  if [[ "$CURRENT_RIGHT_BG" != "NONE" ]]; then
    # This is the closing whitespace for the previous segment
    echo -n "${POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS}%f"
  fi

  if [[ $joined == false ]] || [[ "$CURRENT_RIGHT_BG" == "NONE" ]]; then
    if isSameColor "$CURRENT_RIGHT_BG" "${backgroundColor}"; then
      # Middle segment with same color as previous segment
      # We take the current foreground color as color for our
      # subsegment (or the default color). This should have
      # enough contrast.
      local complement
      [[ -n "${foregroundColor}" ]] && complement="${foreground}" || complement="$(foregroundColor $DEFAULT_COLOR)"
      echo -n "$complement$(print_icon 'RIGHT_SUBSEGMENT_SEPARATOR')%f"
    else
      # Use the new Background Color as the foreground of the segment separator
      echo -n "$(foregroundColor ${backgroundColor})$(print_icon 'RIGHT_SEGMENT_SEPARATOR')%f"
    fi
  fi

  local visual_identifier
  if [[ -n "$6" ]]; then
    visual_identifier="$(print_icon $6)"
    if [[ -n "$visual_identifier" ]]; then
      # Add an whitespace if we print more than just the visual identifier.
      # To avoid cutting off the visual identifier in some terminal emulators (e.g., Konsole, st),
      # we need to color both the visual identifier and the whitespace.
      [[ -n "$5" ]] && visual_identifier=" $visual_identifier"
      # Allow users to overwrite the color for the visual identifier only.
      local visual_identifier_color_variable=POWERLEVEL9K_${(U)${segment_name}#prompt_}_VISUAL_IDENTIFIER_COLOR
      set_default $visual_identifier_color_variable "${foregroundColor}"
      visual_identifier="$(foregroundColor ${(P)visual_identifier_color_variable})${visual_identifier}%f"
    fi
  fi

  echo -n "${background}${foreground}"

  # Print whitespace only if segment is not joined or first right segment
  [[ $joined == false ]] || [[ "$CURRENT_RIGHT_BG" == "NONE" ]] && echo -n "${POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS}"

  # Print segment content if there is any
  [[ -n "$5" ]] && echo -n "${5}"
  # Print the visual identifier
  echo -n "${visual_identifier}"

  CURRENT_RIGHT_BG="${backgroundColor}"
  last_right_element_index=$current_index
}

################################################################
# Prompt Segment Definitions
################################################################

################################################################
# Anaconda Environment
prompt_anaconda() {
  # Depending on the conda version, either might be set. This
  # variant works even if both are set.
  local _path=$CONDA_ENV_PATH$CONDA_PREFIX
  if ! [ -z "$_path" ]; then
    # config - can be overwritten in users' zshrc file.
    set_default POWERLEVEL9K_ANACONDA_LEFT_DELIMITER "("
    set_default POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER ")"
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
  local background_jobs_number=${$(jobs -l | wc -l)// /}
  local wrong_lines=`jobs -l | awk '/pwd now/{ count++ } END {print count}'`
  if [[ wrong_lines -gt 0 ]]; then
     background_jobs_number=$(( $background_jobs_number - $wrong_lines ))
  fi
  if [[ background_jobs_number -gt 0 ]]; then
    local background_jobs_number_print=""
    if [[ "$POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE" == "true" ]] && ([[ "$background_jobs_number" -gt 1 ]] || [[ "$POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS" == "true" ]]); then
      background_jobs_number_print="$background_jobs_number"
    fi
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "cyan" "$background_jobs_number_print" 'BACKGROUND_JOBS_ICON'
  fi
}

################################################################
# A newline in your prompt, so you can segments on multiple lines.
prompt_newline() {
  local lws newline
  [[ "$1" == "right" ]] && return
  newline=$'\n'
  lws=$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    newline="${newline}$(print_icon 'MULTILINE_NEWLINE_PROMPT_PREFIX')"
  fi
  POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=
  "$1_prompt_segment" \
    "$0" \
    "$2" \
    "NONE" "NONE" "${newline}"
  POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=$lws
}

################################################################
# Segment that indicates usage level of current partition.
set_default POWERLEVEL9K_DISK_USAGE_ONLY_WARNING false
set_default POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL 90
set_default POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL 95
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
  # Set default values if the user did not configure them
  set_default POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10

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
  # Default behavior: Be verbose!
  set_default POWERLEVEL9K_BATTERY_VERBOSE true
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
  if defined POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD && [[ "${bat_percent}" -ge $POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD ]]; then
    return
  fi

    # override the default color if we are using a color level array
    if [[ -n "$POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND" ]] && [[ "${(t)POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND}" =~ "array" ]]; then
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
prompt_public_ip() {
  # set default values for segment
  set_default POWERLEVEL9K_PUBLIC_IP_TIMEOUT "300"
  set_default POWERLEVEL9K_PUBLIC_IP_NONE ""
  set_default POWERLEVEL9K_PUBLIC_IP_FILE "/tmp/p9k_public_ip"
  set_default POWERLEVEL9K_PUBLIC_IP_HOST "http://ident.me"
  defined POWERLEVEL9K_PUBLIC_IP_METHODS || POWERLEVEL9K_PUBLIC_IP_METHODS=(dig curl wget)

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
    [[ $timediff -gt $POWERLEVEL9K_PUBLIC_IP_TIMEOUT ]] && refresh_ip=true
    # If tmp file is empty get a fresh IP
    [[ -z $(cat $POWERLEVEL9K_PUBLIC_IP_FILE) ]] && refresh_ip=true
    [[ -n $POWERLEVEL9K_PUBLIC_IP_NONE ]] && [[ $(cat $POWERLEVEL9K_PUBLIC_IP_FILE) =~ "$POWERLEVEL9K_PUBLIC_IP_NONE" ]] && refresh_ip=true
  else
    touch $POWERLEVEL9K_PUBLIC_IP_FILE && refresh_ip=true
  fi

  # grab a fresh IP if needed
  local fresh_ip
  if [[ $refresh_ip =~ true && -w $POWERLEVEL9K_PUBLIC_IP_FILE ]]; then
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
      for vpn_iface in $(/sbin/ifconfig | grep -e ^"$POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE" | cut -d":" -f1)
      do
        icon='VPN_ICON'
        break
      done
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
  typeset -AH context_states
  context_states=(
    "ROOT"        "yellow"
    "SUDO"        "yellow"
    "DEFAULT"     "yellow"
    "REMOTE"      "yellow"
    "REMOTE_SUDO" "yellow"
  )

  local content=""

  if [[ "$POWERLEVEL9K_ALWAYS_SHOW_CONTEXT" == true ]] || [[ "$(whoami)" != "$DEFAULT_USER" ]] || [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
      content="${POWERLEVEL9K_CONTEXT_TEMPLATE}"
  elif [[ "$POWERLEVEL9K_ALWAYS_SHOW_USER" == true ]]; then
      content="$(whoami)"
  else
      return
  fi

  if [[ $(print -P "%#") == '#' ]]; then
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

  "$1_prompt_segment" "${0}_${current_state}" "$2" "$DEFAULT_COLOR" "${context_states[$current_state]}" "${content}"
}

################################################################
# User: user (who am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_USER_TEMPLATE "%n"
prompt_user() {
  local current_state="DEFAULT"
  typeset -AH user_state
  if [[ "$POWERLEVEL9K_ALWAYS_SHOW_USER" == true ]] || [[ "$(whoami)" != "$DEFAULT_USER" ]]; then
    if [[ $(print -P "%#") == '#' ]]; then
      user_state=(
        "STATE"               "ROOT"
        "CONTENT"             "${POWERLEVEL9K_USER_TEMPLATE}"
        "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
        "FOREGROUND_COLOR"    "yellow"
        "VISUAL_IDENTIFIER"   "ROOT_ICON"
      )
    elif [[ -n "$SUDO_COMMAND" ]]; then
      user_state=(
        "STATE"               "SUDO"
        "CONTENT"             "${POWERLEVEL9K_USER_TEMPLATE}"
        "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
        "FOREGROUND_COLOR"    "yellow"
        "VISUAL_IDENTIFIER"   "SUDO_ICON"
      )
    else
      user_state=(
        "STATE"               "DEFAULT"
        "CONTENT"             "$(whoami)"
        "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
        "FOREGROUND_COLOR"    "yellow"
        "VISUAL_IDENTIFIER"   "USER_ICON"
      )
    fi
    "$1_prompt_segment" "${0}_${user_state[STATE]}" "$2" "${user_state[BACKGROUND_COLOR]}" "${user_state[FOREGROUND_COLOR]}" "${user_state[CONTENT]}" "${user_state[VISUAL_IDENTIFIER]}"
  fi
}

################################################################
# Host: machine (where am I)
set_default POWERLEVEL9K_HOST_TEMPLATE "%m"
prompt_host() {
  local current_state="LOCAL"
  typeset -AH host_state
  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    host_state=(
      "STATE"               "REMOTE"
      "CONTENT"             "${POWERLEVEL9K_HOST_TEMPLATE}"
      "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
      "FOREGROUND_COLOR"    "yellow"
      "VISUAL_IDENTIFIER"   "SSH_ICON"
    )
  else
    host_state=(
      "STATE"               "LOCAL"
      "CONTENT"             "${POWERLEVEL9K_HOST_TEMPLATE}"
      "BACKGROUND_COLOR"    "${DEFAULT_COLOR}"
      "FOREGROUND_COLOR"    "yellow"
      "VISUAL_IDENTIFIER"   "HOST_ICON"
    )
  fi
  "$1_prompt_segment" "$0_${host_state[STATE]}" "$2" "${host_state[BACKGROUND_COLOR]}" "${host_state[FOREGROUND_COLOR]}" "${host_state[CONTENT]}" "${host_state[VISUAL_IDENTIFIER]}"
}

################################################################
# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
prompt_custom() {
  local segment_name="${3:u}"
  # Get content of custom segment
  local command="POWERLEVEL9K_CUSTOM_${segment_name}"
  local segment_content="$(eval ${(P)command})"

  if [[ -n $segment_content ]]; then
    "$1_prompt_segment" "${0}_${3:u}" "$2" $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR "$segment_content" "CUSTOM_${segment_name}_ICON"
  fi
}

################################################################
# Display the duration the command needed to run.
prompt_command_execution_time() {
  set_default POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD 3
  set_default POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION 2

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

  if (( _P9K_COMMAND_DURATION >= POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD )); then
    "$1_prompt_segment" "$0" "$2" "red" "yellow1" "${humanReadableDuration}" 'EXECUTION_TIME_ICON'
  fi
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
prompt_dir() {
  # using $PWD instead of "$(print -P '%~')" to allow use of POWERLEVEL9K_DIR_PATH_ABSOLUTE
  local current_path=$PWD # WAS: local current_path="$(print -P '%~')"
  # check if the user wants to use absolute paths or "~" paths
  [[ ${(L)POWERLEVEL9K_DIR_PATH_ABSOLUTE} != "true" ]] && current_path=${current_path//$HOME/"~"}
  # declare all local variables
  local paths directory test_dir test_dir_length trunc_path threshhold
  # if we are not in "~" or "/", split the paths into an array and exclude "~"
  (( ${#current_path} > 1 )) && paths=(${(s:/:)${current_path//"~\/"/}}) || paths=()
  # only run the code if SHORTEN_DIR_LENGTH is set, or we are using the two strategies that don't rely on it.
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" || "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_with_folder_marker" || "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_to_last" ]]; then
    set_default POWERLEVEL9K_SHORTEN_DELIMITER "\u2026"
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
          set_default POWERLEVEL9K_SHORTEN_FOLDER_MARKER ".shorten_folder_marker"

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
        defined POWERLEVEL9K_DIR_PACKAGE_FILES || POWERLEVEL9K_DIR_PACKAGE_FILES=(package.json composer.json)

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
          current_path="$(print -P "%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:$POWERLEVEL9K_SHORTEN_DELIMITER/:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c")"
        fi
      ;;
    esac
  fi

  # save state of path for highlighting and bold options
  local path_opt=$current_path

  typeset -AH dir_states
  dir_states=(
    "DEFAULT"         "FOLDER_ICON"
    "HOME"            "HOME_ICON"
    "HOME_SUBFOLDER"  "HOME_SUB_ICON"
    "NOT_WRITABLE"    "LOCK_ICON"
    "ETC"             "ETC_ICON"
  )
  local state_path="$(print -P '%~')"
  local current_state="DEFAULT"
  if [[ $state_path == '/etc'* ]]; then
    current_state='ETC'
  elif [[ "${POWERLEVEL9K_DIR_SHOW_WRITABLE}" == true && ! -w "$PWD" ]]; then
    current_state="NOT_WRITABLE"
  elif [[ $state_path == '~' ]]; then
    current_state="HOME"
  elif [[ $state_path == '~'* ]]; then
    current_state="HOME_SUBFOLDER"
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

  "$1_prompt_segment" "$0_${current_state}" "$2" "blue" "$DEFAULT_COLOR" "${current_path}" "${dir_states[$current_state]}"
}

################################################################
# Docker machine
prompt_docker_machine() {
  local docker_machine="$DOCKER_MACHINE_NAME"

  if [[ -n "$docker_machine" ]]; then
    "$1_prompt_segment" "$0" "$2" "magenta" "$DEFAULT_COLOR" "$docker_machine" 'SERVER_ICON'
  fi
}

################################################################
# GO prompt
prompt_go_version() {
  local go_version
  local go_path
  go_version=$(go version 2>/dev/null | sed -E "s/.*(go[0-9.]*).*/\1/")
  go_path=$(go env GOPATH 2>/dev/null)

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
prompt_ip() {
  if [[ "$OS" == "OSX" ]]; then
    if defined POWERLEVEL9K_IP_INTERFACE; then
      # Get the IP address of the specified interface.
      ip=$(ipconfig getifaddr "$POWERLEVEL9K_IP_INTERFACE")
    else
      local interfaces callback
      # Get network interface names ordered by service precedence.
      interfaces=$(networksetup -listnetworkserviceorder | grep -o "Device:\s*[a-z0-9]*" | grep -o -E '[a-z0-9]*$')
      callback='ipconfig getifaddr $item'

      ip=$(getRelevantItem "$interfaces" "$callback")
    fi
  else
    if defined POWERLEVEL9K_IP_INTERFACE; then
      # Get the IP address of the specified interface.
      ip=$(ip -4 a show "$POWERLEVEL9K_IP_INTERFACE" | grep -o "inet\s*[0-9.]*" | grep -o -E "[0-9.]+")
    else
      local interfaces callback
      # Get all network interface names that are up
      interfaces=$(ip link ls up | grep -o -E ":\s+[a-z0-9]+:" | grep -v "lo" | grep -o -E "[a-z0-9]+")
      callback='ip -4 a show $item | grep -o "inet\s*[0-9.]*" | grep -o -E "[0-9.]+"'

      ip=$(getRelevantItem "$interfaces" "$callback")
    fi
  fi

  if [[ -n "$ip" ]]; then
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" "$ip" 'NETWORK_ICON'
  fi
}

################################################################
# Segment to display if VPN is active
set_default POWERLEVEL9K_VPN_IP_INTERFACE "tun"
# prompt if vpn active
prompt_vpn_ip() {
  for vpn_iface in $(/sbin/ifconfig | grep -e ^"$POWERLEVEL9K_VPN_IP_INTERFACE" | cut -d":" -f1)
  do
    ip=$(/sbin/ifconfig "$vpn_iface" | grep -o "inet\s.*" | cut -d' ' -f2)
    "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" "$ip" 'VPN_ICON'
  done
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
set_default POWERLEVEL9K_LOAD_WHICH 5
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
  local nodeenv_path="$NODE_VIRTUAL_ENV"
  if [[ -n "$nodeenv_path" && "$NODE_VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
    local info="$(node -v)[$(basename "$nodeenv_path")]"
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
prompt_chruby() {
  # Uses $RUBY_VERSION and $RUBY_ENGINE set by chruby
  set_default POWERLEVEL9K_CHRUBY_SHOW_VERSION true
  set_default POWERLEVEL9K_CHRUBY_SHOW_ENGINE true
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
  local version_and_gemset=${rvm_env_string/ruby-}

  if [[ -n "$version_and_gemset" ]]; then
    "$1_prompt_segment" "$0" "$2" "grey35" "$DEFAULT_COLOR" "$version_and_gemset" 'RUBY_ICON'
  fi
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
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
  if [[ "$POWERLEVEL9K_STATUS_HIDE_SIGNAME" = true ]]; then
    echo "$ec"
  elif (( ec <= 128 )); then
    echo "$ec"
  else
    local sig=$(( ec - 128 ))
    local idx=$(( sig + 1 ))
    echo "SIG${signals[$idx]}(${sig})"
  fi
}

prompt_status() {
  local ec_text
  local ec_sum
  local ec

  if [[ $POWERLEVEL9K_STATUS_SHOW_PIPESTATUS == true ]]; then
    if (( $#RETVALS > 1 )); then
      ec_text=$(exit_code_or_status "${RETVALS[1]}")
      ec_sum=${RETVALS[1]}
    else
      ec_text=$(exit_code_or_status "${RETVAL}")
      ec_sum=${RETVAL}
    fi

    for ec in "${(@)RETVALS[2,-1]}"; do
      ec_text="${ec_text}|$(exit_code_or_status "$ec")"
      ec_sum=$(( $ec_sum + $ec ))
    done
  else
    # We use RETVAL instead of the right-most RETVALS item because
    # PIPE_FAIL may be set.
    ec_text=$(exit_code_or_status "${RETVAL}")
    ec_sum=${RETVAL}
  fi

  if (( ec_sum > 0 )); then
    if [[ "$POWERLEVEL9K_STATUS_CROSS" == false && "$POWERLEVEL9K_STATUS_VERBOSE" == true ]]; then
      "$1_prompt_segment" "$0_ERROR" "$2" "red" "yellow1" "$ec_text" 'CARRIAGE_RETURN_ICON'
    else
      "$1_prompt_segment" "$0_ERROR" "$2" "$DEFAULT_COLOR" "red" "" 'FAIL_ICON'
    fi
  elif [[ "$POWERLEVEL9K_STATUS_OK" == true ]] && [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true || "$POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE" == true ]]; then
    "$1_prompt_segment" "$0_OK" "$2" "$DEFAULT_COLOR" "green" "" 'OK_ICON'
  fi
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
  if [[ (-d src && -d app && -f app/AppKernel.php) ]]; then
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
  typeset -F 2 ratio
  local ratio=$(( (tests_amount/code_amount) * 100 ))

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$headline: $ratio%%" "$6"
}

################################################################
# System time
prompt_time() {
  set_default POWERLEVEL9K_TIME_FORMAT "%D{%H:%M:%S}"

  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$POWERLEVEL9K_TIME_FORMAT" "TIME_ICON"
}

################################################################
# System date
prompt_date() {
  set_default POWERLEVEL9K_DATE_FORMAT "%D{%d.%m.%y}"

  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$POWERLEVEL9K_DATE_FORMAT" "DATE_ICON"
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
set_default POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND "red"
# Default: Just display the first 8 characters of our changeset-ID.
set_default POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH "8"
powerlevel9k_vcs_init() {
  if [[ -n "$POWERLEVEL9K_CHANGESET_HASH_LENGTH" ]]; then
    POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH="$POWERLEVEL9K_CHANGESET_HASH_LENGTH"
  fi

  # Load VCS_INFO
  autoload -Uz vcs_info

  VCS_WORKDIR_DIRTY=false
  VCS_WORKDIR_HALF_DIRTY=false

  # The vcs segment can have three different states - defaults to 'clean'.
  typeset -gAH vcs_states
  vcs_states=(
    'clean'         'green'
    'modified'      'yellow'
    'untracked'     'green'
  )

  VCS_CHANGESET_PREFIX=''
  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    VCS_CHANGESET_PREFIX="$(print_icon 'VCS_COMMIT_ICON')%0.$POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH""i "
  fi

  zstyle ':vcs_info:*' enable git hg svn
  zstyle ':vcs_info:*' check-for-changes true

  VCS_DEFAULT_FORMAT="$VCS_CHANGESET_PREFIX%b%c%u%m"
  zstyle ':vcs_info:*' formats "$VCS_DEFAULT_FORMAT"

  zstyle ':vcs_info:*' actionformats "%b %F{${POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}}| %a%f"

  zstyle ':vcs_info:*' stagedstr " $(print_icon 'VCS_STAGED_ICON')"
  zstyle ':vcs_info:*' unstagedstr " $(print_icon 'VCS_UNSTAGED_ICON')"

  defined POWERLEVEL9K_VCS_GIT_HOOKS || POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname)
  zstyle ':vcs_info:git*+set-message:*' hooks $POWERLEVEL9K_VCS_GIT_HOOKS
  defined POWERLEVEL9K_VCS_HG_HOOKS || POWERLEVEL9K_VCS_HG_HOOKS=(vcs-detect-changes)
  zstyle ':vcs_info:hg*+set-message:*' hooks $POWERLEVEL9K_VCS_HG_HOOKS
  defined POWERLEVEL9K_VCS_SVN_HOOKS || POWERLEVEL9K_VCS_SVN_HOOKS=(vcs-detect-changes svn-detect-changes)
  zstyle ':vcs_info:svn*+set-message:*' hooks $POWERLEVEL9K_VCS_SVN_HOOKS

  # For Hg, only show the branch name
  zstyle ':vcs_info:hg*:*' branchformat "$(print_icon 'VCS_BRANCH_ICON')%b"
  # The `get-revision` function must be turned on for dirty-check to work for Hg
  zstyle ':vcs_info:hg*:*' get-revision true
  zstyle ':vcs_info:hg*:*' get-bookmarks true
  zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks

  # For svn, only
  # TODO fix the %b (branch) format for svn. Using %b breaks
  # color-encoding of the foreground for the rest of the powerline.
  zstyle ':vcs_info:svn*:*' formats "$VCS_CHANGESET_PREFIX%c%u"
  zstyle ':vcs_info:svn*:*' actionformats "$VCS_CHANGESET_PREFIX%c%u %F{${POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}}| %a%f"

  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    zstyle ':vcs_info:*' get-revision true
  fi
}

################################################################
# Segment to show VCS information
prompt_vcs() {
  VCS_WORKDIR_DIRTY=false
  VCS_WORKDIR_HALF_DIRTY=false
  local current_state=""

  # Actually invoke vcs_info manually to gather all information.
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
    "$1_prompt_segment" "${0}_${(U)current_state}" "$2" "${vcs_states[$current_state]}" "$DEFAULT_COLOR" "$vcs_prompt" "$vcs_visual_identifier"
  fi
}

################################################################
# Vi Mode: show editing mode (NORMAL|INSERT)
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
prompt_vi_mode() {
  case ${KEYMAP} in
    vicmd)
      "$1_prompt_segment" "$0_NORMAL" "$2" "$DEFAULT_COLOR" "white" "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
    ;;
    main|viins|*)
      if [[ -z $POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then return; fi
      "$1_prompt_segment" "$0_INSERT" "$2" "$DEFAULT_COLOR" "blue" "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
    ;;
  esac
}

################################################################
# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n "$virtualenv_path" && "$VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$(basename "$virtualenv_path")" 'PYTHON_ICON'
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
build_left_prompt() {
  local index=1
  local element
  for element in "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]}"; do
    # Remove joined information in direct calls
    element=${element%_joined}

    # Check if it is a custom command, otherwise interpet it as
    # a prompt.
    if [[ $element[0,7] =~ "custom_" ]]; then
      "prompt_custom" "left" "$index" $element[8,-1]
    else
      "prompt_$element" "left" "$index"
    fi

    index=$((index + 1))
  done

  left_prompt_end
}

# Right prompt
build_right_prompt() {
  local index=1
  local element
  for element in "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}"; do
    # Remove joined information in direct calls
    element=${element%_joined}

    # Check if it is a custom command, otherwise interpet it as
    # a prompt.
    if [[ $element[0,7] =~ "custom_" ]]; then
      "prompt_custom" "right" "$index" $element[8,-1]
    else
      "prompt_$element" "right" "$index"
    fi

    index=$((index + 1))
  done

  # Clear to the end of the line
  echo -n "%E"
}

powerlevel9k_preexec() {
  _P9K_TIMER_START=$EPOCHREALTIME
}

set_default POWERLEVEL9K_PROMPT_ADD_NEWLINE false
powerlevel9k_prepare_prompts() {
  # Return values. These need to be global, because
  # they are used in prompt_status. Also, we need
  # to get the return value of the last command at
  # very first in this function. Do not move the
  # lines down, otherwise the last command is not
  # what you expected it to be.
  RETVAL=$?
  RETVALS=( "$pipestatus[@]" )

  local RPROMPT_SUFFIX RPROMPT_PREFIX
  _P9K_COMMAND_DURATION=$((EPOCHREALTIME - _P9K_TIMER_START))

  # Reset start time
  _P9K_TIMER_START=0x7FFFFFFF

  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    PROMPT='$(print_icon 'MULTILINE_FIRST_PROMPT_PREFIX')%f%b%k$(build_left_prompt)
$(print_icon 'MULTILINE_LAST_PROMPT_PREFIX')'
    if [[ "$POWERLEVEL9K_RPROMPT_ON_NEWLINE" != true ]]; then
      # The right prompt should be on the same line as the first line of the left
      # prompt. To do so, there is just a quite ugly workaround: Before zsh draws
      # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
      # advise it to go one line down. See:
      # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
      local LC_ALL="" LC_CTYPE="en_US.UTF-8" # Set the right locale to protect special characters
      RPROMPT_PREFIX='%{'$'\e[1A''%}' # one line up
      RPROMPT_SUFFIX='%{'$'\e[1B''%}' # one line down
    else
      RPROMPT_PREFIX=''
      RPROMPT_SUFFIX=''
    fi
  else
    PROMPT='%f%b%k$(build_left_prompt)'
    RPROMPT_PREFIX=''
    RPROMPT_SUFFIX=''
  fi

  if [[ "$POWERLEVEL9K_DISABLE_RPROMPT" != true ]]; then
    RPROMPT="${RPROMPT_PREFIX}"'%f%b%k$(build_right_prompt)%{$reset_color%}'"${RPROMPT_SUFFIX}"
  fi

local NEWLINE='
'

  if [[ $POWERLEVEL9K_PROMPT_ADD_NEWLINE == true ]]; then
    NEWLINES=""
    repeat ${POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT:-1} { NEWLINES+=$NEWLINE }
    PROMPT="$NEWLINES$PROMPT"
  fi

  # Allow iTerm integration to work
  [[ $ITERM_SHELL_INTEGRATION_INSTALLED == "Yes" ]] && PROMPT="%{$(iterm2_prompt_mark)%}$PROMPT"
}

zle-keymap-select () {
	zle reset-prompt
	zle -R
}

set_default POWERLEVEL9K_IGNORE_TERM_COLORS false
set_default POWERLEVEL9K_IGNORE_TERM_LANG false

prompt_powerlevel9k_setup() {
  # The value below was set to better support 32-bit CPUs.
  # It's the maximum _signed_ integer value on 32-bit CPUs.
  # Please don't change it until 19 January of 2038. ;)

  # Disable false display of command execution time
  _P9K_TIMER_START=0x7FFFFFFF

  # The prompt function will set these prompt_* options after the setup function
  # returns. We need prompt_subst so we can safely run commands in the prompt
  # without them being double expanded and we need prompt_percent to expand the
  # common percent escape sequences.
  prompt_opts=(cr percent sp subst)

  # Borrowed from promptinit, sets the prompt options in case the theme was
  # not initialized via promptinit.
  setopt noprompt{bang,cr,percent,sp,subst} "prompt${^prompt_opts[@]}"

  # Display a warning if the terminal does not support 256 colors
  termColors

  # If the terminal `LANG` is set to `C`, this theme will not work at all.
  if [[ $POWERLEVEL9K_IGNORE_TERM_LANG == false ]]; then
      local term_lang
      term_lang=$(echo $LANG)
      if [[ $term_lang == 'C' ]]; then
          print -P "\t%F{red}WARNING!%f Your terminal's 'LANG' is set to 'C', which breaks this theme!"
          print -P "\t%F{red}WARNING!%f Please set your 'LANG' to a UTF-8 language, like 'en_US.UTF-8'"
          print -P "\t%F{red}WARNING!%f _before_ loading this theme in your \~\.zshrc. Putting"
          print -P "\t%F{red}WARNING!%f %F{blue}export LANG=\"en_US.UTF-8\"%f at the top of your \~\/.zshrc is sufficient."
      fi
  fi

  defined POWERLEVEL9K_LEFT_PROMPT_ELEMENTS || POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
  defined POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)

  # Display a warning if deprecated segments are in use.
  typeset -AH deprecated_segments
  # old => new
  deprecated_segments=(
    'longstatus'      'status'
  )
  print_deprecation_warning deprecated_segments

  # initialize colors
  autoload -U colors && colors

  if segment_in_use "vcs"; then
    powerlevel9k_vcs_init
  fi

  # initialize timing functions
  zmodload zsh/datetime

  # Initialize math functions
  zmodload zsh/mathfunc

  # initialize hooks
  autoload -Uz add-zsh-hook

  # prepare prompts
  add-zsh-hook precmd powerlevel9k_prepare_prompts
  add-zsh-hook preexec powerlevel9k_preexec

  zle -N zle-keymap-select
}

prompt_powerlevel9k_teardown() {
  add-zsh-hook -D precmd powerlevel9k_\*
  add-zsh-hook -D preexec powerlevel9k_\*
  PROMPT='%m%# '
  RPROMPT=
}

prompt_powerlevel9k_setup "$@"
