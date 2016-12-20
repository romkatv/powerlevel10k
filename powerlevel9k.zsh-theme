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
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

# Try to set the installation path
if [[ -n "$POWERLEVEL9K_INSTALLATION_PATH" ]]; then
  # If an installation path was set manually,
  # it should trump any other location found.
  # Do nothing. This is all right, as we use the
  # POWERLEVEL9K_INSTALLATION_PATH for further processing.
elif [[ $(whence -w prompt_powerlevel9k_setup) =~ "function" ]]; then
  # Check if the theme was called as a function (e.g., from prezto)
  autoload -U is-at-least
  if is-at-least 5.0.8; then
    # Try to find the correct path of the script.
    POWERLEVEL9K_INSTALLATION_PATH=$(whence -v $0 | sed "s/$0 is a shell function from //")
  elif [[ -f "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/init.zsh" ]]; then
    # If there is an prezto installation, we assume that powerlevel9k is linked there.
    POWERLEVEL9K_INSTALLATION_PATH="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup"
  fi
else
  # Last resort: Set installation path is script path
  POWERLEVEL9K_INSTALLATION_PATH="$0"
fi

# Resolve the installation path
if [[ -L "$POWERLEVEL9K_INSTALLATION_PATH" ]]; then
  # If this theme is sourced as a symlink, we need to locate the real URL
  filename="$(realpath -P $POWERLEVEL9K_INSTALLATION_PATH 2>/dev/null || readlink -f $POWERLEVEL9K_INSTALLATION_PATH 2>/dev/null || perl -MCwd=abs_path -le 'print abs_path readlink(shift);' $POWERLEVEL9K_INSTALLATION_PATH 2>/dev/null)"
elif [[ -d "$POWERLEVEL9K_INSTALLATION_PATH" ]]; then
  # Directory
  filename="${POWERLEVEL9K_INSTALLATION_PATH}/powerlevel9k.zsh-theme"
elif [[ -f "$POWERLEVEL9K_INSTALLATION_PATH" ]]; then
  # Script is a file
  filename="$POWERLEVEL9K_INSTALLATION_PATH"
elif [[ -z "$POWERLEVEL9K_INSTALLATION_PATH" ]]; then
  # Fallback: specify an installation path!
  print -P "%F{red}We could not locate the installation path of powerlevel9k.%f"
  print -P "Please specify by setting %F{blue}POWERLEVEL9K_INSTALLATION_PATH%f (full path incl. file name) at the very beginning of your ~/.zshrc"
  return 1
else
  print -P "%F{red}Script location could not be found! Maybe your %F{blue}POWERLEVEL9K_INSTALLATION_PATH%F{red} is not correct?%f"
  return 1
fi
script_location="$(dirname $filename)"

################################################################
# Source icon functions
################################################################

source $script_location/functions/icons.zsh

################################################################
# Source utility functions
################################################################

source $script_location/functions/utilities.zsh

################################################################
# Source color functions
################################################################

source $script_location/functions/colors.zsh

################################################################
# Source VCS_INFO hooks / helper functions
################################################################

source $script_location/functions/vcs.zsh

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
  local current_index=$2
  # Check if the segment should be joined with the previous one
  local joined
  segmentShouldBeJoined $current_index $last_left_element_index "$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS" && joined=true || joined=false

  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 3="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 4="$FG_COLOR_MODIFIER"

  local bg fg
  [[ -n "$3" ]] && bg="%K{$3}" || bg="%k"
  [[ -n "$4" ]] && fg="%F{$4}" || fg="%f"

  if [[ $CURRENT_BG != 'NONE' ]] && ! isSameColor "$3" "$CURRENT_BG"; then
    echo -n "$bg%F{$CURRENT_BG}"
    if [[ $joined == false ]]; then
      # Middle segment
      echo -n "$(print_icon 'LEFT_SEGMENT_SEPARATOR')$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
    fi
  elif isSameColor "$CURRENT_BG" "$3"; then
    # Middle segment with same color as previous segment
    # We take the current foreground color as color for our
    # subsegment (or the default color). This should have
    # enough contrast.
    local complement
    [[ -n "$4" ]] && complement="$4" || complement=$DEFAULT_COLOR
    echo -n "$bg%F{$complement}"
    if [[ $joined == false ]]; then
      echo -n "$(print_icon 'LEFT_SUBSEGMENT_SEPARATOR')$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
    fi
  else
    # First segment
    echo -n "${bg}$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
  fi

  local visual_identifier
  if [[ -n $6 ]]; then
    visual_identifier="$(print_icon $6)"
    if [[ -n "$visual_identifier" ]]; then
      # Allow users to overwrite the color for the visual identifier only.
      local visual_identifier_color_variable=POWERLEVEL9K_${(U)1#prompt_}_VISUAL_IDENTIFIER_COLOR
      set_default $visual_identifier_color_variable $4
      visual_identifier="%F{${(P)visual_identifier_color_variable}%}$visual_identifier%f"
      # Add an whitespace if we print more than just the visual identifier
      [[ -n "$5" ]] && visual_identifier="$visual_identifier "
    fi
  fi

  # Print the visual identifier
  echo -n "${visual_identifier}"
  # Print the content of the segment, if there is any
  [[ -n "$5" ]] && echo -n "${fg}${5}"
  echo -n "${POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS}"

  CURRENT_BG=$3
  last_left_element_index=$current_index
}

# End the left prompt, closes the final segment.
left_prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%k%F{$CURRENT_BG}$(print_icon 'LEFT_SEGMENT_SEPARATOR')"
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
  local current_index=$2

  # Check if the segment should be joined with the previous one
  local joined
  segmentShouldBeJoined $current_index $last_right_element_index "$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" && joined=true || joined=false

  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 3="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 4="$FG_COLOR_MODIFIER"

  local bg fg
  [[ -n "$3" ]] && bg="%K{$3}" || bg="%k"
  [[ -n "$4" ]] && fg="%F{$4}" || fg="%f"

  # If CURRENT_RIGHT_BG is "NONE", we are the first right segment.
  if [[ $joined == false ]] || [[ "$CURRENT_RIGHT_BG" == "NONE" ]]; then
    if isSameColor "$CURRENT_RIGHT_BG" "$3"; then
      # Middle segment with same color as previous segment
      # We take the current foreground color as color for our
      # subsegment (or the default color). This should have
      # enough contrast.
      local complement
      [[ -n "$4" ]] && complement="$4" || complement=$DEFAULT_COLOR
      echo -n "%F{$complement}$(print_icon 'RIGHT_SUBSEGMENT_SEPARATOR')%f"
    else
      echo -n "%F{$3}$(print_icon 'RIGHT_SEGMENT_SEPARATOR')%f"
    fi
  fi

  local visual_identifier
  if [[ -n "$6" ]]; then
    visual_identifier="$(print_icon $6)"
    if [[ -n "$visual_identifier" ]]; then
      # Allow users to overwrite the color for the visual identifier only.
      local visual_identifier_color_variable=POWERLEVEL9K_${(U)1#prompt_}_VISUAL_IDENTIFIER_COLOR
      set_default $visual_identifier_color_variable $4
      visual_identifier="%F{${(P)visual_identifier_color_variable}%}$visual_identifier%f"
      # Add an whitespace if we print more than just the visual identifier
      [[ -n "$5" ]] && visual_identifier=" $visual_identifier"
    fi
  fi

  echo -n "${bg}${fg}"

  # Print whitespace only if segment is not joined or first right segment
  [[ $joined == false ]] || [[ "$CURRENT_RIGHT_BG" == "NONE" ]] && echo -n "${POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS}"

  # Print segment content if there is any
  [[ -n "$5" ]] && echo -n "${5}"
  # Print the visual identifier
  echo -n "${visual_identifier}${POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS}%f"

  CURRENT_RIGHT_BG=$3
  last_right_element_index=$current_index
}

################################################################
# Prompt Segment Definitions
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# Anaconda Environment
prompt_anaconda() {
  # Depending on the conda version, either might be set. This
  # variant works even if both are set.
  _path=$CONDA_ENV_PATH$CONDA_PREFIX
  if ! [ -z "$_path" ]; then
    # config - can be overwritten in users' zshrc file.
    set_default POWERLEVEL9K_ANACONDA_LEFT_DELIMITER "("
    set_default POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER ")"
    "$1_prompt_segment" "$0" "$2" "$3" "$4" "$POWERLEVEL9K_ANACONDA_LEFT_DELIMITER$(basename $_path)$POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER" 'PYTHON_ICON'
  fi
}

# AWS Profile
prompt_aws() {
  local aws_profile="$AWS_DEFAULT_PROFILE"

  if [[ -n "$aws_profile" ]]; then
    "$1_prompt_segment" "$0" "$2" red white "$aws_profile" 'AWS_ICON'
  fi
}

# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  local eb_env=$(grep environment .elasticbeanstalk/config.yml 2> /dev/null | awk '{print $2}')

  if [[ -n "$eb_env" ]]; then
    "$1_prompt_segment" "$0" "$2" black green "$eb_env" 'AWS_EB_ICON'
  fi
}

# Segment to indicate background jobs with an icon.
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE true
prompt_background_jobs() {
  local background_jobs_number=${$(jobs -l | wc -l)// /}
  local wrong_lines=`jobs -l | awk '/pwd now/{ count++ } END {print count}'`
  if [[ wrong_lines -gt 0 ]]; then
     background_jobs_number=$(( $background_jobs_number - $wrong_lines ))
  fi
  if [[ background_jobs_number -gt 0 ]]; then
    local background_jobs_number_print=""
    if [[ "$POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE" == "true" ]] && [[ "$background_jobs_number" -gt 1 ]]; then
      background_jobs_number_print="$background_jobs_number"
    fi
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "cyan" "$background_jobs_number_print" 'BACKGROUND_JOBS_ICON'
  fi
}

prompt_battery() {
  # The battery can have four different states - default to 'unknown'.
  local current_state="unknown"
  typeset -AH battery_states
  battery_states=(
    'low'           'red'
    'charging'      'yellow'
    'charged'       'green'
    'disconnected'  "$DEFAULT_COLOR_INVERTED"
  )
  # Set default values if the user did not configure them
  set_default POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10

  if [[ $OS =~ OSX && -f /usr/sbin/ioreg && -x /usr/sbin/ioreg ]]; then
    # Pre-Grep as much information as possible to save some memory and
    # avoid pollution of the xtrace output.
    local raw_data="$(ioreg -n AppleSmartBattery | grep -E "MaxCapacity|TimeRemaining|CurrentCapacity|ExternalConnected|IsCharging")"
    # return if there is no battery on system
    [[ -z $(echo $raw_data | grep MaxCapacity) ]] && return

    # Convert time remaining from minutes to hours:minutes date string
    local time_remaining=$(echo $raw_data | grep TimeRemaining | awk '{ print $5 }')
    if [[ -n $time_remaining ]]; then
      # this value is set to a very high number when the system is calculating
      [[ $time_remaining -gt 10000 ]] && local tstring="..." || local tstring=${(f)$(/bin/date -u -r $(($time_remaining * 60)) +%k:%M)}
    fi

    # Get charge values
    local max_capacity=$(echo $raw_data | grep MaxCapacity | awk '{ print $5 }')
    local current_capacity=$(echo $raw_data | grep CurrentCapacity | awk '{ print $5 }')

    if [[ -n "$max_capacity" && -n "$current_capacity" ]]; then
      typeset -i 10 bat_percent
      bat_percent=$(( (current_capacity * 100) / max_capacity ))
    fi

    local remain=""
    # Logic for string output
    if [[ $(echo $raw_data | grep ExternalConnected | awk '{ print $5 }') =~ "Yes" ]]; then
      # Battery is charging
      if [[ $(echo $raw_data | grep IsCharging | awk '{ print $5 }') =~ "Yes" ]]; then
        current_state="charging"
        remain=" ($tstring)"
      else
        current_state="charged"
      fi
    else
      [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && current_state="low" || current_state="disconnected"
      remain=" ($tstring)"
    fi
  fi

  if [[ $OS =~ Linux ]]; then
    local sysp="/sys/class/power_supply"
    # Reported BAT0 or BAT1 depending on kernel version
    [[ -a $sysp/BAT0 ]] && local bat=$sysp/BAT0
    [[ -a $sysp/BAT1 ]] && local bat=$sysp/BAT1

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
    if [[ -f /usr/bin/acpi ]]; then
      local time_remaining=$(acpi | awk '{ print $5 }')
      if [[ $time_remaining =~ rate ]]; then
        local tstring="..."
      elif [[ $time_remaining =~ "[:digit:]+" ]]; then
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

  # Draw the prompt_segment
  if [[ -n $bat_percent ]]; then
    "$1_prompt_segment" "${0}_${current_state}" "$2" "$DEFAULT_COLOR" "${battery_states[$current_state]}" "$message" 'BATTERY_ICON'
  fi
}

# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    if [[ $(print -P "%#") == '#' ]]; then
      # Shell runs as root
      "$1_prompt_segment" "$0_ROOT" "$2" "$DEFAULT_COLOR" "yellow" "$USER@%m"
    else
      "$1_prompt_segment" "$0_DEFAULT" "$2" "$DEFAULT_COLOR" "011" "$USER@%m"
    fi
  fi
}

# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
prompt_custom() {
  local command=POWERLEVEL9K_CUSTOM_$3:u
  local segment_content="$(eval ${(P)command})"

  if [[ -n $segment_content ]]; then
    "$1_prompt_segment" "${0}_${3:u}" "$2" $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR "$segment_content"
  fi
}

# Dir: current working directory
prompt_dir() {
  local current_path='%~'
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" ]]; then

    set_default POWERLEVEL9K_SHORTEN_DELIMITER $'\U2026'

    case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
      truncate_middle)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})\//\1$POWERLEVEL9K_SHORTEN_DELIMITER\2\//g")
      ;;
      truncate_from_right)
        current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
      ;;
      truncate_with_package_name)
        local name repo_path package_path current_dir zero

        # Get the path of the Git repo, which should have the package.json file
        if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]; then
          package_path=$(git rev-parse --show-toplevel)
        elif [[ $(git rev-parse --is-inside-git-dir 2> /dev/null) == "true" ]]; then
          package_path=${$(pwd)%%/.git*}
        fi

        zero='%([BSUbfksu]|([FB]|){*})'
        current_dir=$(pwd)
        # Then, find the length of the package_path string, and save the
        # subdirectory path as a substring of the current directory's path from 0
        # to the length of the package path's string
        subdirectory_path=$(truncatePathFromRight "${current_dir:${#${(S%%)package_path//$~zero/}}}")
        # Parse the 'name' from the package.json; if there are any problems, just
        # print the file path
        if name=$( cat "$package_path/package.json" 2> /dev/null | grep -m 1 "\"name\""); then
          name=$(echo $name | awk -F ':' '{print $2}' | awk -F '"' '{print $2}')

          # Instead of printing out the full path, print out the name of the package
          # from the package.json and append the current subdirectory
          current_path="`echo $name | tr -d '"'`$subdirectory_path"
        else
          current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
        fi
      ;;
      *)
        current_path="%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:$POWERLEVEL9K_SHORTEN_DELIMITER/:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c"
      ;;
    esac

  fi

  local current_icon=''
  if [[ $(print -P "%~") == '~' ]]; then
    "$1_prompt_segment" "$0_HOME" "$2" "blue" "$DEFAULT_COLOR" "$current_path" 'HOME_ICON'
  elif [[ $(print -P "%~") == '~'* ]]; then
    "$1_prompt_segment" "$0_HOME_SUBFOLDER" "$2" "blue" "$DEFAULT_COLOR" "$current_path" 'HOME_SUB_ICON'
  else
    "$1_prompt_segment" "$0_DEFAULT" "$2" "blue" "$DEFAULT_COLOR" "$current_path" 'FOLDER_ICON'
  fi
}

# Docker machine
prompt_docker_machine() {
  local docker_machine="$DOCKER_MACHINE_NAME"

  if [[ -n "$docker_machine" ]]; then
    "$1_prompt_segment" "$0" "$2" "magenta" "$DEFAULT_COLOR" "$docker_machine" 'SERVER_ICON'
  fi
}

# GO prompt
prompt_go_version() {
  local go_version
  go_version=$(go version 2>/dev/null | sed -E "s/.*(go[0-9.]*).*/\1/")

  if [[ -n "$go_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "green" "255" "$go_version"
  fi
}

# Command number (in local history)
prompt_history() {
  "$1_prompt_segment" "$0" "$2" "244" "$DEFAULT_COLOR" '%h'
}

prompt_icons_test() {
  for key in ${(@k)icons}; do
    # The lower color spectrum in ZSH makes big steps. Choosing
    # the next color has enough contrast to read.
    local random_color=$((RANDOM % 8))
    local next_color=$((random_color+1))
    "$1_prompt_segment" "$0" "$2" "$random_color" "$next_color" "$key" "$key"
  done
}

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
      ip=$(ip -4 a show "$POWERLEVEL9K_IP_INTERFACE" | grep -o "inet\s*[0-9.]*" | grep -o "[0-9.]*")
    else
      local interfaces callback
      # Get all network interface names that are up
      interfaces=$(ip link ls up | grep -o -E ":\s+[a-z0-9]+:" | grep -v "lo" | grep -o "[a-z0-9]*")
      callback='ip -4 a show $item | grep -o "inet\s*[0-9.]*" | grep -o "[0-9.]*"'

      ip=$(getRelevantItem "$interfaces" "$callback")
    fi
  fi

  "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" "$ip" 'NETWORK_ICON'
}

prompt_load() {
  # The load segment can have three different states
  local current_state="unknown"
  local cores

  typeset -AH load_states
  load_states=(
    'critical'      'red'
    'warning'       'yellow'
    'normal'        'green'
  )

  if [[ "$OS" == "OSX" ]] || [[ "$OS" == "BSD" ]]; then
    load_avg_1min=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | head -n 1)
    if [[ "$OS" == "OSX" ]]; then
      cores=$(sysctl -n hw.logicalcpu)
    else
      cores=$(sysctl -n hw.ncpu)
    fi
  else
    load_avg_1min=$(grep -o "[0-9.]*" /proc/loadavg | head -n 1)
    cores=$(nproc)
  fi

  # Replace comma
  load_avg_1min=${load_avg_1min//,/.}

  if [[ "$load_avg_1min" -gt $(bc -l <<< "${cores} * 0.7") ]]; then
    current_state="critical"
  elif [[ "$load_avg_1min" -gt $(bc -l <<< "${cores} * 0.5") ]]; then
    current_state="warning"
  else
    current_state="normal"
  fi

  "$1_prompt_segment" "${0}_${current_state}" "$2" "${load_states[$current_state]}" "$DEFAULT_COLOR" "$load_avg_1min" 'LOAD_ICON'
}

# Node version
prompt_node_version() {
  local node_version=$(node -v 2>/dev/null)
  [[ -z "${node_version}" ]] && return

  "$1_prompt_segment" "$0" "$2" "green" "white" "${node_version:1}" 'NODE_ICON'
}

# Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  [[ ! $(type nvm) =~ 'nvm is a shell function'* ]] && return
  local node_version=$(nvm current)
  [[ -z "${node_version}" ]] || [[ ${node_version} = "none" ]] && return
  local nvm_default=$(cat $NVM_DIR/alias/default)
  [[ "$node_version" =~ "$nvm_default" ]] && return

  $1_prompt_segment "$0" "$2" "green" "011" "${node_version:1}" 'NODE_ICON'
}

# NodeEnv Prompt
prompt_nodeenv() {
  local nodeenv_path="$NODE_VIRTUAL_ENV"
  if [[ -n "$nodeenv_path" && "$NODE_VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
    local info="$(node -v)[$(basename "$nodeenv_path")]"
    "$1_prompt_segment" "$0" "$2" "black" "green" "$info" 'NODE_ICON'
  fi
}

# print a little OS icon
prompt_os_icon() {
  "$1_prompt_segment" "$0" "$2" "black" "255" "$OS_ICON"
}

# print PHP version number
prompt_php_version() {
  local php_version
  php_version=$(php -v 2>&1 | grep -oe "^PHP\s*[0-9.]*")

  if [[ -n "$php_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "013" "255" "$php_version"
  fi
}

# Show free RAM and used Swap
prompt_ram() {
  local base=''
  local ramfree=0
  if [[ "$OS" == "OSX" ]]; then
    ramfree=$(vm_stat | grep "Pages free" | grep -o -E '[0-9]+')
    # Convert pages into Bytes
    ramfree=$(( ramfree * 4096 ))
  else
    if [[ "$OS" == "BSD" ]]; then
      ramfree=$(vmstat | grep -E '([0-9]+\w+)+' | awk '{print $5}')
      base='M'
    else
      ramfree=$(grep -o -E "MemFree:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
      base='K'
    fi
  fi

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "$(printSizeHumanReadable "$ramfree" $base)" 'RAM_ICON'
}

# rbenv information
prompt_rbenv() {
  if which rbenv 2>/dev/null >&2; then
    local rbenv_version_name="$(rbenv version-name)"
    local rbenv_global="$(rbenv global)"

    # Don't show anything if the current Ruby is the same as the global Ruby.
    if [[ $rbenv_version_name == $rbenv_global ]]; then
      return
    fi

    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" "$rbenv_version_name" 'RUBY_ICON'
  fi
}

# chruby information
# see https://github.com/postmodern/chruby/issues/245 for chruby_auto issue with ZSH
prompt_chruby() {
  local chruby_env
  chrb_env="$(chruby 2> /dev/null | grep \* | tr -d '* ')"
  # Don't show anything if the chruby did not change the default ruby
  if [[ "${chrb_env:-system}" != "system" ]]; then
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" "${chrb_env}" 'RUBY_ICON'
  fi
}

# Print an icon if user is root.
prompt_root_indicator() {
  if [[ "$UID" -eq 0 ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" "" 'ROOT_ICON'
  fi
}

# Print Rust version number
prompt_rust_version() {
  local rust_version
  rust_version=$(rustc --version 2>&1 | grep -oe "^rustc\s*[^ ]*" | grep -o '[0-9.a-z\\\-]*$')

  if [[ -n "$rust_version" ]]; then
    "$1_prompt_segment" "$0" "$2" "208" "$DEFAULT_COLOR" "Rust $rust_version" 'RUST_ICON'
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

# Ruby Version Manager information
prompt_rvm() {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"

  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')

  if [[ -n "$version$gemset" ]]; then
    "$1_prompt_segment" "$0" "$2" "240" "$DEFAULT_COLOR" "$version$gemset" 'RUBY_ICON'
  fi
}

# Status: return code if verbose, otherwise just an icon if an error occurred
set_default POWERLEVEL9K_STATUS_VERBOSE true
prompt_status() {
  if [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true ]]; then
    if [[ "$RETVAL" -ne 0 ]]; then
      "$1_prompt_segment" "$0_ERROR" "$2" "red" "226" "$RETVAL" 'CARRIAGE_RETURN_ICON'
    else
      "$1_prompt_segment" "$0_OK" "$2" "$DEFAULT_COLOR" "046" "" 'OK_ICON'
    fi
  else
    if [[ "$RETVAL" -ne 0 ]]; then
      "$1_prompt_segment" "$0_ERROR" "$2" "$DEFAULT_COLOR" "red" "" 'FAIL_ICON'
    fi
  fi
}

prompt_swap() {
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
    swap_total=$(grep -o -E "SwapTotal:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
    swap_free=$(grep -o -E "SwapFree:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
    swap_used=$(( swap_total - swap_free ))
    base='K'
  fi

  "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" "$(printSizeHumanReadable "$swap_used" $base)" 'SWAP_ICON'
}

# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ (-d src && -d app && -f app/AppKernel.php) ]]; then
    local code_amount tests_amount
    code_amount=$(ls -1 src/**/*.php | grep -vc Tests)
    tests_amount=$(ls -1 src/**/*.php | grep -c Tests)

    build_test_stats "$1" "$0" "$2" "$code_amount" "$tests_amount" "SF2" 'TEST_ICON'
  fi
}

# Symfony2-Version
prompt_symfony2_version() {
  if [[ -f app/bootstrap.php.cache ]]; then
    local symfony2_version
    symfony2_version=$(grep " VERSION " app/bootstrap.php.cache | sed -e 's/[^.0-9]*//g')
    "$1_prompt_segment" "$0" "$2" "240" "$DEFAULT_COLOR" "$symfony2_version" 'SYMFONY_ICON'
  fi
}

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

# System time
prompt_time() {
  local time_format="%D{%H:%M:%S}"
  if [[ -n "$POWERLEVEL9K_TIME_FORMAT" ]]; then
    time_format="$POWERLEVEL9K_TIME_FORMAT"
  fi

  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$time_format"
}

# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  if $(hash todo.sh 2>&-); then
    count=$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+) tasks shown" | awk '{ print $4 }')
    if [[ "$count" = <-> ]]; then
      "$1_prompt_segment" "$0" "$2" "244" "$DEFAULT_COLOR" "$count" 'TODO_ICON'
    fi
  fi
}

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

  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    zstyle ':vcs_info:*' get-revision true
  fi
}

prompt_vcs() {
  VCS_WORKDIR_DIRTY=false
  VCS_WORKDIR_HALF_DIRTY=false
  current_state=""

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

# Vi Mode: show editing mode (NORMAL|INSERT)
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
prompt_vi_mode() {
  case ${KEYMAP} in
    main|viins)
      "$1_prompt_segment" "$0_INSERT" "$2" "$DEFAULT_COLOR" "blue" "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
    ;;
    vicmd)
      "$1_prompt_segment" "$0_NORMAL" "$2" "$DEFAULT_COLOR" "default" "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
    ;;
  esac
}

# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n "$virtualenv_path" && "$VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$(basename "$virtualenv_path")" 'PYTHON_ICON'
  fi
}

# pyenv: current active python version (with restrictions)
# More information on pyenv (Python version manager like rbenv and rvm):
# https://github.com/yyuu/pyenv
# the prompt parses output of pyenv version and only displays the first word
prompt_pyenv() {
  local pyenv_version="$(pyenv version 2>/dev/null)"
  pyenv_version="${pyenv_version%% *}"
  # XXX: The following should return the same as above.
  # This reads better for devs familiar with sed/awk/grep/cut utilities
  # Using shell expansion/substitution may hamper future maintainability
  #local pyenv_version="$(pyenv version 2>/dev/null | head -n1 | cut -d' ' -f1)"
  if [[ -n "$pyenv_version" && "$pyenv_version" != "system" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" "$pyenv_version" 'PYTHON_ICON'
  fi
}

################################################################
# Prompt processing and drawing
################################################################
# Main prompt
build_left_prompt() {
  local index=1
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
}

powerlevel9k_prepare_prompts() {
  RETVAL=$?

  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    PROMPT="$(print_icon 'MULTILINE_FIRST_PROMPT_PREFIX')%f%b%k$(build_left_prompt)
$(print_icon 'MULTILINE_SECOND_PROMPT_PREFIX')"
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
    PROMPT="%f%b%k$(build_left_prompt)"
    RPROMPT_PREFIX=''
    RPROMPT_SUFFIX=''
  fi

  if [[ "$POWERLEVEL9K_DISABLE_RPROMPT" != true ]]; then
    RPROMPT="$RPROMPT_PREFIX%f%b%k$(build_right_prompt)%{$reset_color%}$RPROMPT_SUFFIX"
  fi
}

powerlevel9k_init() {
  # Display a warning if the terminal does not support 256 colors
  local term_colors
  term_colors=$(echotc Co)
  if (( $term_colors < 256 )); then
    print -P "%F{red}WARNING!%f Your terminal appears to support less than 256 colors!"
    print -P "If your terminal supports 256 colors, please export the appropriate environment variable"
    print -P "_before_ loading this theme in your \~\/.zshrc. In most terminal emulators, putting"
    print -P "%F{blue}export TERM=\"xterm-256color\"%f at the top of your \~\/.zshrc is sufficient."
  fi

  # If the terminal `LANG` is set to `C`, this theme will not work at all.
  local term_lang
  term_lang=$(echo $LANG)
  if [[ $term_lang == 'C' ]]; then
      print -P "\t%F{red}WARNING!%f Your terminal's 'LANG' is set to 'C', which breaks this theme!"
      print -P "\t%F{red}WARNING!%f Please set your 'LANG' to a UTF-8 language, like 'en_US.UTF-8'"
      print -P "\t%F{red}WARNING!%f _before_ loading this theme in your \~\.zshrc. Putting"
      print -P "\t%F{red}WARNING!%f %F{blue}export LANG=\"en_US.UTF-8\"%f at the top of your \~\/.zshrc is sufficient."
  fi

  defined POWERLEVEL9K_LEFT_PROMPT_ELEMENTS || POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
  defined POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)

  # Display a warning if deprecated segments are in use.
  typeset -AH deprecated_segments
  # old => new
  deprecated_segments=(
    'longstatus'      'status'
  )
  print_deprecation_warning deprecated_segments

  setopt prompt_subst

  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  setopt PROMPT_CR PROMPT_PERCENT PROMPT_SUBST MULTIBYTE

  # initialize colors
  autoload -U colors && colors

  if segment_in_use "vcs"; then
    powerlevel9k_vcs_init
  fi

  # initialize hooks
  autoload -Uz add-zsh-hook

  # prepare prompts
  add-zsh-hook precmd powerlevel9k_prepare_prompts
}

powerlevel9k_init "$@"

