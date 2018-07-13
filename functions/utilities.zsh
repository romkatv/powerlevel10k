# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Utility functions
# This file holds some utility-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

# Exits with 0 if a variable has been previously defined (even if empty)
# Takes the name of a variable that should be checked.
function defined() {
  [[ ! -z "${(tP)1}" ]]
}

# Given the name of a variable and a default value, sets the variable
# value to the default only if it has not been defined.
#
# Typeset cannot set the value for an array, so this will only work
# for scalar values.
function set_default() {
  local varname="$1"
  local default_value="$2"

  defined "$varname" || typeset -g "$varname"="$default_value"
}

# Converts large memory values into a human-readable unit (e.g., bytes --> GB)
# Takes two arguments:
#   * $size - The number which should be prettified
#   * $base - The base of the number (default Bytes)
printSizeHumanReadable() {
  typeset -F 2 size
  size="$1"+0.00001
  local extension
  extension=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')
  local index=1

  # if the base is not Bytes
  if [[ -n $2 ]]; then
    local idx
    for idx in "${extension[@]}"; do
      if [[ "$2" == "$idx" ]]; then
        break
      fi
      index=$(( index + 1 ))
    done
  fi

  while (( (size / 1024) > 0.1 )); do
    size=$(( size / 1024 ))
    index=$(( index + 1 ))
  done

  echo "$size${extension[$index]}"
}

# Gets the first value out of a list of items that is not empty.
# The items are examined by a callback-function.
# Takes two arguments:
#   * $list - A list of items
#   * $callback - A callback function to examine if the item is
#                 worthy. The callback function has access to
#                 the inner variable $item.
function getRelevantItem() {
  local -a list
  local callback
  # Explicitly split the elements by whitespace.
  list=(${=1})
  callback=$2

  for item in $list; do
    # The first non-empty item wins
    try=$(eval "$callback")
    if [[ -n "$try" ]]; then
      echo "$try"
      break;
    fi
  done
}

# OS detection
case $(uname) in
    Darwin)
      OS='OSX'
      OS_ICON=$(print_icon 'APPLE_ICON')
      ;;
    CYGWIN_NT-* | MSYS_NT-*)
      OS='Windows'
      OS_ICON=$(print_icon 'WINDOWS_ICON')
      ;;
    FreeBSD)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    OpenBSD)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    DragonFly)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    Linux)
      OS='Linux'
      os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
      case "$os_release_id" in
        *arch*)
        OS_ICON=$(print_icon 'LINUX_ARCH_ICON')
        ;;
        *debian*)
        OS_ICON=$(print_icon 'LINUX_DEBIAN_ICON')
        ;;
       *ubuntu*)
        OS_ICON=$(print_icon 'LINUX_UBUNTU_ICON')
        ;;
       *elementary*)
        OS_ICON=$(print_icon 'LINUX_ELEMENTARY_ICON')
        ;;
       *fedora*)
        OS_ICON=$(print_icon 'LINUX_FEDORA_ICON')
        ;;
       *coreos*)
        OS_ICON=$(print_icon 'LINUX_COREOS_ICON')
        ;;
       *gentoo*)
        OS_ICON=$(print_icon 'LINUX_GENTOO_ICON')
        ;;
       *mageia*)
        OS_ICON=$(print_icon 'LINUX_MAGEIA_ICON')
        ;;
       *centos*)
        OS_ICON=$(print_icon 'LINUX_CENTOS_ICON')
        ;;
       *opensuse*|*tumbleweed*)
        OS_ICON=$(print_icon 'LINUX_OPENSUSE_ICON')
        ;;
       *sabayon*)
        OS_ICON=$(print_icon 'LINUX_SABAYON_ICON')
        ;;
       *slackware*)
        OS_ICON=$(print_icon 'LINUX_SLACKWARE_ICON')
        ;;
       *linuxmint*)
        OS_ICON=$(print_icon 'LINUX_MINT_ICON')
        ;;
       *alpine*)
        OS_ICON=$(print_icon 'LINUX_ALPINE_ICON')
        ;;
       *aosc*)
        OS_ICON=$(print_icon 'LINUX_AOSC_ICON')
        ;;
       *nixos*)
        OS_ICON=$(print_icon 'LINUX_NIXOS_ICON')
        ;;
       *devuan*)
        OS_ICON=$(print_icon 'LINUX_DEVUAN_ICON')
        ;;
       *manjaro*)
        OS_ICON=$(print_icon 'LINUX_MANJARO_ICON')
        ;;
        *)
        OS='Linux'
        OS_ICON=$(print_icon 'LINUX_ICON')
        ;;
      esac

      # Check if we're running on Android
      case $(uname -o 2>/dev/null) in
        Android)
          OS='Android'
          OS_ICON=$(print_icon 'ANDROID_ICON')
          ;;
      esac
      ;;
    SunOS)
      OS='Solaris'
      OS_ICON=$(print_icon 'SUNOS_ICON')
      ;;
    *)
      OS=''
      OS_ICON=''
      ;;
esac

# Determine the correct sed parameter.
#
# `sed` is unfortunately not consistent across OSes when it comes to flags.
SED_EXTENDED_REGEX_PARAMETER="-r"
if [[ "$OS" == 'OSX' ]]; then
  local IS_BSD_SED="$(sed --version &>> /dev/null || echo "BSD sed")"
  if [[ -n "$IS_BSD_SED" ]]; then
    SED_EXTENDED_REGEX_PARAMETER="-E"
  fi
fi

# Determine if the passed segment is used in the prompt
#
# Pass the name of the segment to this function to test for its presence in
# either the LEFT or RIGHT prompt arrays.
#    * $1: The segment to be tested.
segment_in_use() {
    local key=$1
    if [[ -n "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(r)$key]}" ]] || [[ -n "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(r)$key]}" ]]; then
        return 0
    else
        return 1
    fi
}

# Print a deprecation warning if an old segment is in use.
# Takes the name of an associative array that contains the
# deprecated segments as keys, the values contain the new
# segment names.
print_deprecation_warning() {
  typeset -AH raw_deprecated_segments
  raw_deprecated_segments=(${(kvP@)1})

  for key in ${(@k)raw_deprecated_segments}; do
    if segment_in_use $key; then
      # segment is deprecated
      print -P "%F{yellow}Warning!%f The '$key' segment is deprecated. Use '%F{blue}${raw_deprecated_segments[$key]}%f' instead. For more informations, have a look at the CHANGELOG.md."
    fi
  done
}

# A helper function to determine if a segment should be
# joined or promoted to a full one.
# Takes three arguments:
#   * $1: The array index of the current segment
#   * $2: The array index of the last printed segment
#   * $3: The array of segments of the left or right prompt
function segmentShouldBeJoined() {
  local current_index=$1
  local last_segment_index=$2
  # Explicitly split the elements by whitespace.
  local -a elements
  elements=(${=3})

  local current_segment=${elements[$current_index]}
  local joined=false
  if [[ ${current_segment[-7,-1]} == '_joined' ]]; then
    joined=true
    # promote segment to a full one, if the predecessing full segment
    # was conditional. So this can only be the case for segments that
    # are not our direct predecessor.
    if (( $(($current_index - $last_segment_index)) > 1)); then
      # Now we have to examine every previous segment, until we reach
      # the last printed one (found by its index). This is relevant if
      # all previous segments are joined. Then we want to join our
      # segment as well.
      local examined_index=$((current_index - 1))
      while (( $examined_index > $last_segment_index )); do
        local previous_segment=${elements[$examined_index]}
        # If one of the examined segments is not joined, then we know
        # that the current segment should not be joined, as the target
        # segment is the wrong one.
        if [[ ${previous_segment[-7,-1]} != '_joined' ]]; then
          joined=false
          break
        fi
        examined_index=$((examined_index - 1))
      done
    fi
  fi

  # Return 1 means error; return 0 means no error. So we have
  # to invert $joined
  if [[ "$joined" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

################################################################
# Given a directory path, truncate it according to the settings.
# Parameters:
#   * $1 Path: string - the directory path to be truncated
#   * $2 Length: integer - length to truncate to
#   * $3 Delimiter: string - the delimiter to use
#   * $4 From: string - "right" | "middle". If omited, assumes right.
function truncatePath() {
  # if the current path is not 1 character long (e.g. "/" or "~")
  if (( ${#1} > 1 )); then
    # convert $2 from string to integer
    2=$(( $2 ))
    # set $3 to "" if not defined
    [[ -z $3 ]] && 3="" || 3=$(echo -n $3)
    # set $4 to "right" if not defined
    [[ -z $4 ]] && 4="right"
    # create a variable for the truncated path.
    local trunc_path
    # if the path is in the home folder, add "~/" to the start otherwise "/"
    [[ $1 == "~"* ]] && trunc_path='~/' || trunc_path='/'
    # split the path into an array using "/" as the delimiter
    local paths=$1
    paths=(${(s:/:)${paths//"~\/"/}})
    # declare locals for the directory being tested and its length
    local test_dir test_dir_length
    # do the needed truncation
    case $4 in
      right)
        # include the delimiter length in the threshhold
        local threshhold=$(( $2 + ${#3} ))
        # loop through the paths
        for (( i=1; i<${#paths}; i++ )); do
          # get the current directory value
          test_dir=$paths[$i]
          test_dir_length=${#test_dir}
          # only truncate if the resulting truncation will be shorter than
          # the truncation + delimiter length and at least 3 characters
          if (( $test_dir_length > $threshhold )) && (( $test_dir_length > 3 )); then
            # use the first $2 characters and the delimiter
            trunc_path+="${test_dir:0:$2}$3/"
          else
            # use the full path
            trunc_path+="${test_dir}/"
          fi
        done
      ;;
      middle)
        # we need double the length for start and end truncation + delimiter length
        local threshhold=$(( $2 * 2 ))
        # create a variable for the start of the end truncation
        local last_pos
        # loop through the paths
        for (( i=1; i<${#paths}; i++ )); do
          # get the current directory value
          test_dir=$paths[$i]
          test_dir_length=${#test_dir}
          # only truncate if the resulting truncation will be shorter than
          # the truncation + delimiter length
          if (( $test_dir_length > $threshhold )); then
            # use the first $2 characters, the delimiter and the last $2 characters
            last_pos=$(( $test_dir_length - $2 ))
            trunc_path+="${test_dir:0:$2}$3${test_dir:$last_pos:$test_dir_length}/"
          else
            # use the full path
            trunc_path+="${test_dir}/"
          fi
        done
      ;;
    esac
    # return the truncated path + the current directory
    echo $trunc_path${1:t}
  else # current path is 1 character long (e.g. "/" or "~")
    echo $1
  fi
}

# Given a directory path, truncate it according to the settings for
# `truncate_from_right`
function truncatePathFromRight() {
  local delim_len=${#POWERLEVEL9K_SHORTEN_DELIMITER:-1}
  echo $1 | sed $SED_EXTENDED_REGEX_PARAMETER \
 "s@(([^/]{$((POWERLEVEL9K_SHORTEN_DIR_LENGTH))})([^/]{$delim_len}))[^/]+/@\2$POWERLEVEL9K_SHORTEN_DELIMITER/@g"
}

# Search recursively in parent folders for given file.
function upsearch () {
  if [[ "$PWD" == "$HOME" || "$PWD" == "/" ]]; then
    echo "$PWD"
  elif test -e "$1"; then
    pushd .. > /dev/null
    upsearch "$1"
    popd > /dev/null
    echo "$PWD"
  else
    pushd .. > /dev/null
    upsearch "$1"
    popd > /dev/null
  fi
}
