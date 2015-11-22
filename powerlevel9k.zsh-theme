# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# This theme was inspired by agnoster's Theme:
# https://gist.github.com/3712874
################################################################

################################################################
# Please see the README file located in the source repository for full docs.
# There are a lot of easy ways you can customize your prompt segments and
# theming with simple variables defined in your `~/.zshrc`.
################################################################

## Turn on for Debugging
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

# Check if the theme was called as a function.
if [[ $(whence -w prompt_powerlevel9k_setup) =~ "function" ]]; then
  # Script is a function! We assume this to happen only in
  # prezto, as they use the zstyle-builtin to set the theme.
  0="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions/prompt_powerlevel9k_setup"
fi

# Check if filename is a symlink.
if [[ -L $0 ]]; then
  # Script is a symlink
  filename="$(realpath -P $0 2>/dev/null || readlink -f $0 2>/dev/null)"
elif [[ -f $0 ]]; then
  # Script is a file
  filename="$0"
else
  print -P "%F{red}Script location could not be found!%f"
  exit 1
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
  DEFAULT_COLOR_DARK="252"
else
  DEFAULT_COLOR=black
  DEFAULT_COLOR_INVERTED=white
  DEFAULT_COLOR_DARK="236"
fi

set_default POWERLEVEL9K_VCS_FOREGROUND "$DEFAULT_COLOR"
set_default POWERLEVEL9K_VCS_DARK_FOREGROUND "$DEFAULT_COLOR_DARK"

################################################################
# Prompt Segment Constructors
#
# Methodology behind user-defined variables overwriting colors:
#     The first parameter to the segment constructors is the calling function's
#     name.  From this function name, we strip the "prompt_"-prefix and
#     uppercase it.  This is then prefixed with "POWERLEVEL9K_" and suffixed
#     with either "_BACKGROUND" or "_FOREGROUND", thus giving us the variable
#     name. So each new segment is user-overwritable by a variable following
#     this naming convention.
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# Begin a left prompt segment
# Takes four arguments:
#   * $1: Name of the function that was orginally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: Background color
#   * $3: Foreground color
#   * $4: The segment content
# The latter three can be omitted,
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS " "
left_prompt_segment() {
  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 2="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 3="$FG_COLOR_MODIFIER"

  local bg fg
  [[ -n $2 ]] && bg="%K{$2}" || bg="%k"
  [[ -n $3 ]] && fg="%F{$3}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' ]] && ! isSameColor "$2" "$CURRENT_BG"; then
    # Middle segment
    echo -n "%{$bg%F{$CURRENT_BG}%}$(print_icon 'LEFT_SEGMENT_SEPARATOR')%{$fg%}$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
  elif isSameColor "$CURRENT_BG" "$2"; then
    # Middle segment with same color as previous segment
    # We take the current foreground color as color for our
    # subsegment (or the default color). This should have
    # enough contrast.
    local complement
    [[ -n $3 ]] && complement=$3 || complement=$DEFAULT_COLOR
    echo -n "%{$bg%F{$complement}%}$(print_icon 'LEFT_SUBSEGMENT_SEPARATOR')%{$fg%}$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
  else
    # First segment
    echo -n "%{$bg%}%{$fg%}$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
  fi
  CURRENT_BG=$2
  [[ -n $4 ]] && echo -n "$4$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS"
}

# End the left prompt, closes the final segment.
left_prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}$(print_icon 'LEFT_SEGMENT_SEPARATOR')"
  else
    echo -n "%k"
  fi
  echo -n "%{%f%}$(print_icon 'LEFT_SEGMENT_END_SEPARATOR')"
  CURRENT_BG=''
}

CURRENT_RIGHT_BG='NONE'

# Begin a right prompt segment
# Takes four arguments:
#   * $1: Name of the function that was orginally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: Background color
#   * $3: Foreground color
#   * $4: The segment content
# No ending for the right prompt segment is needed (unlike the left prompt, above).
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS " "
right_prompt_segment() {
  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 2="$BG_COLOR_MODIFIER"

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 3="$FG_COLOR_MODIFIER"

  local bg fg
  [[ -n $2 ]] && bg="%K{$2}" || bg="%k"
  [[ -n $3 ]] && fg="%F{$3}" || fg="%f"

  if isSameColor "$CURRENT_RIGHT_BG" "$2"; then
    # Middle segment with same color as previous segment
    # We take the current foreground color as color for our
    # subsegment (or the default color). This should have
    # enough contrast.
    local complement
    [[ -n $3 ]] && complement=$3 || complement=$DEFAULT_COLOR
    echo -n "%F{$complement}$(print_icon 'RIGHT_SUBSEGMENT_SEPARATOR')%f%{$bg%}%{$fg%}$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS"
  else
    echo -n "%F{$2}$(print_icon 'RIGHT_SEGMENT_SEPARATOR')%f%{$bg%}%{$fg%}$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS"
  fi
  [[ -n $4 ]] && echo -n "$4$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS%f"

  CURRENT_RIGHT_BG=$2
}

################################################################
# Prompt Segment Definitions
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# AWS Profile
prompt_aws() {
  local aws_profile="$AWS_DEFAULT_PROFILE"
  if [[ -n "$aws_profile" ]];
  then
    "$1_prompt_segment" "$0" red white "$(print_icon 'AWS_ICON') $aws_profile"
  fi
}

prompt_battery() {
  icons[BATTERY_ICON]=$'\UE894'
  # set default values of not specified in shell
  set_default POWERLEVEL9K_BATTERY_CHARGING       "yellow"
  set_default POWERLEVEL9K_BATTERY_CHARGED        "green"
  set_default POWERLEVEL9K_BATTERY_DISCONNECTED   "$DEFAULT_COLOR_INVERTED"
  set_default POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10
  set_default POWERLEVEL9K_BATTERY_LOW_COLOR      "red"
  [[ -z $POWERLEVEL9K_BATTERY_FOREGROUND ]] && local fg_color="" || local fg_color="%F{$POWERLEVEL9K_BATTERY_FOREGROUND}"
  [[ -z $POWERLEVEL9K_BATTERY_FOREGROUND ]] && local icon_color="$DEFAULT_COLOR_INVERTED" || local icon_color="$POWERLEVEL9K_BATTERY_FOREGROUND"

  if [[ $OS =~ OSX && -f /usr/sbin/ioreg && -x /usr/sbin/ioreg ]]; then
    local raw_data=$(ioreg -n AppleSmartBattery)
    # return if there is no battery on system
    [[ -z $(echo $raw_data | grep MaxCapacity) ]] && return

    # get charge status
    [[ $(echo $raw_data | grep ExternalConnected | awk '{ print $5 }') =~ "Yes" ]] && local connected=true
    [[ $(echo $raw_data | grep IsCharging | awk '{ print $5 }') =~ "Yes" ]] && local charging=true

    # convert time remaining from minutes to hours:minutes date string
    local time_remaining=$(echo $raw_data | grep TimeRemaining | awk '{ print $5 }')
    if [[ ! -z $time_remaining ]]; then
      # this value is set to a very high number when the system is calculating
      [[ $time_remaining -gt 10000 ]] && local tstring="..." || local tstring=${(f)$(date -u -r $(($time_remaining * 60)) +%k:%M)}
    fi

    # get charge values
    local max_capacity=$(echo $raw_data | grep MaxCapacity | awk '{ print $5 }')
    local current_capacity=$(echo $raw_data | grep CurrentCapacity | awk '{ print $5 }')

    if [[ -n "$max_capacity" && -n "$current_capacity" ]]; then
      typeset -F 2 current_capacity
      current_capacity="$current_capacity"+0.00001
      typeset -i 10 bat_percent
      bat_percent=$(( (current_capacity / max_capacity) * 100 ))
    fi

    # logic for string output
    [[ $charging =~ true && $connected =~ true ]] && local icon_color="$POWERLEVEL9K_BATTERY_CHARGING" && local remain=" ($tstring)"
    [[ ! $charging =~ true && $connected =~ true ]] && local icon_color="$POWERLEVEL9K_BATTERY_CHARGED" && local remain=""
    if [[ ! $connected =~ true ]]; then
      [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && local icon_color="$POWERLEVEL9K_BATTERY_LOW_COLOR" || local icon_color="$POWERLEVEL9K_BATTERY_DISCONNECTED"
      local remain=" ($tstring)"
    fi
  fi

  if [[ $OS =~ Linux ]]; then
    local sysp="/sys/class/power_supply"
    # reported BAT0 or BAT1 depending on kernel version
    [[ -a $sysp/BAT0 ]] && local bat=$sysp/BAT0
    [[ -a $sysp/BAT1 ]] && local bat=$sysp/BAT1

    # return if no battery found
    [[ -z $bat ]] && return
    [[ $(cat $bat/capacity) -gt 100 ]] && local bat_percent=100 || local bat_percent=$(cat $bat/capacity)
    [[ $(cat $bat/status) =~ Charging ]] && local connected=true
    [[ $(cat $bat/status) =~ Charging && $bat_percent =~ 100 ]] && local icon_color="$POWERLEVEL9K_BATTERY_CHARGED"
    [[ $(cat $bat/status) =~ Charging && $bat_percent -lt 100 ]] && local icon_color="$POWERLEVEL9K_BATTERY_CHARGING"
    if [[ -z  $connected ]]; then
      [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && local icon_color="$POWERLEVEL9K_BATTERY_LOW_COLOR" || local icon_color="$POWERLEVEL9K_BATTERY_DISCONNECTED"
    fi
    if [[ -f /usr/bin/acpi ]]; then
      local time_remaining=$(acpi | awk '{ print $5 }')
      if [[ $time_remaining =~ rate ]]; then
        local tstring="..."
      elif [[ $time_remaining =~ "[:digit:]+" ]]; then
        local tstring=${(f)$(date -u -d "$(echo $time_remaining)" +%k:%M)}
      fi
    fi
    [[ ! -z $tstring ]] && local remain=" ($tstring)"
  fi

  # display prompt_segment
  [[ ! -z $bat_percent ]] && "$1_prompt_segment" "$0" "$DEFAULT_COLOR" "$DEFAULT_COLOR_INVERTED" "%F{$icon_color}$(print_icon 'BATTERY_ICON')$fg_color $bat_percent%%$remain%f"
}

# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    if [[ $(print -P "%#") == '#' ]]; then
      # Shell runs as root
      "$1_prompt_segment" "$0_ROOT" "$DEFAULT_COLOR" "yellow" "$USER@%m"
    else
      "$1_prompt_segment" "$0_DEFAULT" "$DEFAULT_COLOR" "011" "$USER@%m"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  local current_path='%~'
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" ]]; then

    case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
      truncate_middle)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})\//\1\.\.\2\//g")
      ;;
      truncate_from_right)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+\//\1..\//g")
      ;;
      *)
        current_path="%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:.../:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c"
      ;;
    esac

  fi

  "$1_prompt_segment" "$0" "blue" "$DEFAULT_COLOR" "$(print_icon 'HOME_ICON')$current_path"
}

# GO-prompt
prompt_go_version() {
  local go_version
  go_version=$(go version 2>&1 | grep -oe "^go[0-9.]*")

  if [[ -n "$go_version" ]]; then
    "$1_prompt_segment" "$0" "green" "255" "$go_version"
  fi
}

# Command number (in local history)
prompt_history() {
  "$1_prompt_segment" "$0" "244" "$DEFAULT_COLOR" '%h'
}

prompt_icons_test() {
  for key in ${(@k)icons}; do
    # The lower color spectrum in ZSH makes big steps. Choosing
    # the next color has enough contrast to read.
    local random_color=$((RANDOM % 8))
    local next_color=$((random_color+1))
    "$1_prompt_segment" "$0" "$random_color" "$next_color" "$key: ${icons[$key]}"
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

  "$1_prompt_segment" "$0" "cyan" "$DEFAULT_COLOR" "$(print_icon 'NETWORK_ICON') $ip"
}

prompt_load() {
  if [[ "$OS" == "OSX" ]]; then
    load_avg_5min=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | head -n 1)
  else
    load_avg_5min=$(grep -o "[0-9.]*" /proc/loadavg | head -n 1)
  fi

  # Replace comma
  load_avg_5min=${load_avg_5min//,/.}

  if [[ "$load_avg_5min" -gt 10 ]]; then
    BACKGROUND_COLOR="red"
    FUNCTION_SUFFIX="_CRITICAL"
  elif [[ "$load_avg_5min" -gt 3 ]]; then
    BACKGROUND_COLOR="yellow"
    FUNCTION_SUFFIX="_WARNING"
  else
    BACKGROUND_COLOR="green"
    FUNCTION_SUFFIX="_NORMAL"
  fi

  "$1_prompt_segment" "$0$FUNCTION_SUFFIX" "$BACKGROUND_COLOR" "$DEFAULT_COLOR" "$(print_icon 'LOAD_ICON') $load_avg_5min"
}

# Node version
prompt_node_version() {
  local nvm_prompt
  nvm_prompt=$(node -v 2>/dev/null)
  [[ -z "${nvm_prompt}" ]] && return

  "$1_prompt_segment" "$0" "green" "white" "${nvm_prompt:1} $(print_icon 'NODE_ICON')"
}

# print a little OS icon
prompt_os_icon() {
  "$1_prompt_segment" "$0" "black" "255" "$OS_ICON"
}

# print PHP version number
prompt_php_version() {
  local php_version
  php_version=$(php -v 2>&1 | grep -oe "^PHP\s*[0-9.]*")

  if [[ -n "$php_version" ]]; then
    "$1_prompt_segment" "$0" "013" "255" "$php_version"
  fi
}

# Show free RAM and used Swap
prompt_ram() {
  defined POWERLEVEL9K_RAM_ELEMENTS || POWERLEVEL9K_RAM_ELEMENTS=(ram_free swap_used)

  local rendition base
  for element in "${POWERLEVEL9K_RAM_ELEMENTS[@]}"; do
    case $element in
      ram_free)
        if [[ "$OS" == "OSX" ]]; then
          ramfree=$(vm_stat | grep "Pages free" | grep -o -E '[0-9]+')
          # Convert pages into Bytes
          ramfree=$(( ramfree * 4096 ))
          base=''
        else
          ramfree=$(grep -o -E "MemFree:\s+[0-9]+" /proc/meminfo | grep -o "[0-9]*")
          base=K
        fi

        rendition+="$(print_icon 'RAM_ICON') $(printSizeHumanReadable "$ramfree" $base) "
      ;;
      swap_used)
        if [[ "$OS" == "OSX" ]]; then
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
          base=K
        fi

        rendition+="$(printSizeHumanReadable "$swap_used" $base) "
      ;;
    esac
  done

  "$1_prompt_segment" "$0" "yellow" "$DEFAULT_COLOR" "${rendition% }"
}

# Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  local node_version=$(nvm current)
  local nvm_default=$(cat $NVM_DIR/alias/default)
  [[ -z "${node_version}" ]] && return
  [[ "$node_version" =~ "$nvm_default" ]] && return
  NODE_ICON=$'\u2B22' # ⬢
  $1_prompt_segment "$0" "green" "011" "${node_version:1} $NODE_ICON"
}

# rbenv information
prompt_rbenv() {
  if [[ -n "$RBENV_VERSION" ]]; then
    "$1_prompt_segment" "$0" "red" "$DEFAULT_COLOR" "$RBENV_VERSION"
  fi
}

# print Rust version number
prompt_rust_version() {
  local rust_version
  rust_version=$(rustc --version 2>&1 | grep -oe "^rustc\s*[^ ]*" | grep -o '[0-9.a-z\\\-]*$')

  if [[ -n "$rust_version" ]]; then
    "$1_prompt_segment" "$0" "208" "$DEFAULT_COLOR" "Rust $rust_version"
  fi
}
# RSpec test ratio
prompt_rspec_stats() {
  if [[ (-d app && -d spec) ]]; then
    local code_amount tests_amount
    code_amount=$(ls -1 app/**/*.rb | wc -l)
    tests_amount=$(ls -1 spec/**/*.rb | wc -l)

    build_test_stats "$1" "$0" "$code_amount" "$tests_amount" "RSpec $(print_icon 'TEST_ICON')"
  fi
}

# Ruby Version Manager information
prompt_rvm() {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"

  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')

  if [[ -n "$version$gemset" ]]; then
    "$1_prompt_segment" "$0" "240" "$DEFAULT_COLOR" "$version$gemset $(print_icon 'RUBY_ICON') "
  fi
}

# Status: (return code, root status, background jobs)
set_default POWERLEVEL9K_STATUS_VERBOSE true
prompt_status() {
  local symbols bg
  symbols=()

  if [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true ]]; then
    if [[ "$RETVAL" -ne 0 ]]; then
      symbols+="%F{226}$RETVAL $(print_icon 'CARRIAGE_RETURN_ICON')%f"
      bg="red"
    else
      symbols+="%F{046}$(print_icon 'OK_ICON')%f"
      bg="black"
    fi
  else
    [[ "$RETVAL" -ne 0 ]] && symbols+="%{%F{red}%}$(print_icon 'FAIL_ICON')%f"
    bg="$DEFAULT_COLOR"
  fi

  [[ "$UID" -eq 0 ]] && symbols+="%{%F{yellow}%} $(print_icon 'ROOT_ICON')%f"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$(print_icon 'BACKGROUND_JOBS_ICON')%f"

  [[ -n "$symbols" ]] && "$1_prompt_segment" "$0" "$bg" "white" "$symbols"
}

# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ (-d src && -d app && -f app/AppKernel.php) ]]; then
    local code_amount tests_amount
    code_amount=$(ls -1 src/**/*.php | grep -vc Tests)
    tests_amount=$(ls -1 src/**/*.php | grep -c Tests)

    build_test_stats "$1" "$0" "$code_amount" "$tests_amount" "SF2 $(print_icon 'TEST_ICON')"
  fi
}

# Symfony2-Version
prompt_symfony2_version() {
  if [[ -f app/bootstrap.php.cache ]]; then
    local symfony2_version
    symfony2_version=$(grep " VERSION " app/bootstrap.php.cache | sed -e 's/[^.0-9]*//g')
    "$1_prompt_segment" "$0" "240" "$DEFAULT_COLOR" "$(print_icon 'SYMFONY_ICON') $symfony2_version"
  fi
}

# Show a ratio of tests vs code
build_test_stats() {
  local code_amount="$3"
  local tests_amount="$4"+0.00001
  local headline="$5"

  # Set float precision to 2 digits:
  typeset -F 2 ratio
  local ratio=$(( (tests_amount/code_amount) * 100 ))

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "cyan" "$DEFAULT_COLOR" "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "yellow" "$DEFAULT_COLOR" "$headline: $ratio%%"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "red" "$DEFAULT_COLOR" "$headline: $ratio%%"
}

# System time
prompt_time() {
  local time_format="%D{%H:%M:%S}"
  if [[ -n "$POWERLEVEL9K_TIME_FORMAT" ]]; then
    time_format="$POWERLEVEL9K_TIME_FORMAT"
  fi

  "$1_prompt_segment" "$0" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$time_format"
}

# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  if $(hash todo.sh 2>&-); then
    count=$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+) tasks shown" | awk '{ print $4 }')
    if [[ "$count" = <-> ]]; then
      "$1_prompt_segment" "$0" "244" "$DEFAULT_COLOR" "$(print_icon 'TODO_ICON') $count"
    fi
  fi
}

# VCS segment: shows the state of your repository, if you are in a folder under version control
prompt_vcs() {
  autoload -Uz vcs_info

  VCS_WORKDIR_DIRTY=false
  VCS_CHANGESET_PREFIX=''
  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    # Default: Just display the first 12 characters of our changeset-ID.
    local VCS_CHANGESET_HASH_LENGTH=12
    if [[ -n "$POWERLEVEL9K_CHANGESET_HASH_LENGTH" ]]; then
      VCS_CHANGESET_HASH_LENGTH="$POWERLEVEL9K_CHANGESET_HASH_LENGTH"
    fi

    VCS_CHANGESET_PREFIX="%F{$POWERLEVEL9K_VCS_DARK_FOREGROUND}$(print_icon 'VCS_COMMIT_ICON')%0.$VCS_CHANGESET_HASH_LENGTH""i%f "
  fi

  zstyle ':vcs_info:*' enable git hg
  zstyle ':vcs_info:*' check-for-changes true

  VCS_DEFAULT_FORMAT="$VCS_CHANGESET_PREFIX%F{$POWERLEVEL9K_VCS_FOREGROUND}%b%c%u%m%f"
  zstyle ':vcs_info:git*:*' formats "%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_GIT_ICON')%f$VCS_DEFAULT_FORMAT"
  zstyle ':vcs_info:hg*:*' formats "%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_HG_ICON')%f$VCS_DEFAULT_FORMAT"

  zstyle ':vcs_info:*' actionformats "%b %F{red}| %a%f"

  zstyle ':vcs_info:*' stagedstr " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_STAGED_ICON')%f"
  zstyle ':vcs_info:*' unstagedstr " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_UNSTAGED_ICON')%f"

  zstyle ':vcs_info:git*+set-message:*' hooks vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname
  zstyle ':vcs_info:hg*+set-message:*' hooks vcs-detect-changes

  # For Hg, only show the branch name
  zstyle ':vcs_info:hg*:*' branchformat "$(print_icon 'VCS_BRANCH_ICON')%b"
  # The `get-revision` function must be turned on for dirty-check to work for Hg
  zstyle ':vcs_info:hg*:*' get-revision true
  zstyle ':vcs_info:hg*:*' get-bookmarks true
  zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks

  if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
    zstyle ':vcs_info:*' get-revision true
  fi

  # Actually invoke vcs_info manually to gather all information.
  vcs_info
  local vcs_prompt="${vcs_info_msg_0_}"

  if [[ -n "$vcs_prompt" ]]; then
    if [[ "$VCS_WORKDIR_DIRTY" == true ]]; then
      "$1_prompt_segment" "$0_MODIFIED" "yellow" "$DEFAULT_COLOR"
    else
      "$1_prompt_segment" "$0" "green" "$DEFAULT_COLOR"
    fi

    echo -n "$vcs_prompt "
  fi
}

# Vi Mode: show editing mode (NORMAL|INSERT)
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
prompt_vi_mode() {
  case ${KEYMAP} in
    main|viins)
      "$1_prompt_segment" "$0_INSERT" "$DEFAULT_COLOR" "blue" "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
    ;;
    vicmd)
      "$1_prompt_segment" "$0_NORMAL" "$DEFAULT_COLOR" "default" "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
    ;;
  esac
}

# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n "$virtualenv_path" && "$VIRTUAL_ENV_DISABLE_PROMPT" != true ]]; then
    "$1_prompt_segment" "$0" "blue" "$DEFAULT_COLOR" "($(basename "$virtualenv_path"))"
  fi
}

################################################################
# Prompt processing and drawing
################################################################

# Main prompt
build_left_prompt() {
  defined POWERLEVEL9K_LEFT_PROMPT_ELEMENTS || POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)

  for element in "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[@]}"; do
    "prompt_$element" "left"
  done

  left_prompt_end
}

# Right prompt
build_right_prompt() {
  defined POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)

  for element in "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}"; do
    "prompt_$element" "right"
  done
}

powerlevel9k_prepare_prompts() {
  RETVAL=$?

  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    PROMPT="$(print_icon 'MULTILINE_FIRST_PROMPT_PREFIX')%{%f%b%k%}$(build_left_prompt)
$(print_icon 'MULTILINE_SECOND_PROMPT_PREFIX')"
    if [[ "$POWERLEVEL9K_RPROMPT_ON_NEWLINE" != true ]]; then
      # The right prompt should be on the same line as the first line of the left
      # prompt.  To do so, there is just a quite ugly workaround: Before zsh draws
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
    PROMPT="%{%f%b%k%}$(build_left_prompt)"
    RPROMPT_PREFIX=''
    RPROMPT_SUFFIX=''
  fi

  if [[ "$POWERLEVEL9K_DISABLE_RPROMPT" != true ]]; then
    RPROMPT="$RPROMPT_PREFIX%{%f%b%k%}$(build_right_prompt)%{$reset_color%}$RPROMPT_SUFFIX"
  fi
}

function zle-line-init {
  powerlevel9k_prepare_prompts
  if (( ${+terminfo[smkx]} )); then
    printf '%s' ${terminfo[smkx]}
  fi
  zle reset-prompt
  zle -R
}

function zle-line-finish {
  powerlevel9k_prepare_prompts
  if (( ${+terminfo[rmkx]} )); then
    printf '%s' ${terminfo[rmkx]}
  fi
  zle reset-prompt
  zle -R
}

function zle-keymap-select {
  powerlevel9k_prepare_prompts
  zle reset-prompt
  zle -R
}

powerlevel9k_init() {
  # Display a warning if the terminal does not support 256 colors
  local term_colors
  term_colors=$(echotc Co)
  if (( term_colors < 256 )); then
    print -P "%F{red}WARNING!%f Your terminal supports less than 256 colors!"
    print -P "You should put: %F{blue}export TERM=\"xterm-256color\"%f in your \~\/.zshrc"
  fi

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

  # initialize hooks
  autoload -Uz add-zsh-hook

  # prepare prompts
  add-zsh-hook precmd powerlevel9k_prepare_prompts

  zle -N zle-line-init
  zle -N zle-line-finish
  zle -N zle-keymap-select
}

powerlevel9k_init "$@"
