# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# power-functions
# This file holds some utility-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################
################################################################
# Utility functions
################################################################

# Exits with 0 if a variable has been previously defined (even if empty)
# Takes the name of a variable that should be checked.
function defined() {
  local varname="$1"

  typeset -p "$varname" > /dev/null 2>&1
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

# Safety function for printing icons
# Prints the named icon, or if that icon is undefined, the string name.
function print_icon() {
  local icon_name=$1
  local ICON_USER_VARIABLE=POWERLEVEL9K_${icon_name}
  local USER_ICON=${(P)ICON_USER_VARIABLE}
  if defined "$ICON_USER_VARIABLE"; then
    echo -n "$USER_ICON"
  else
    echo -n "${icons[$icon_name]}"
  fi
}

# Get numerical color codes. That way we translate ANSI codes
# into ZSH-Style color codes.
function getColorCode() {
  # Check if given value is already numerical
  if [[ "$1" = <-> ]]; then
    # ANSI color codes distinguish between "foreground"
    # and "background" colors. We don't need to do that,
    # as ZSH uses a 256 color space anyway.
    if [[ "$1" = <8-15> ]]; then
      echo $(($1 - 8))
    else
      echo "$1"
    fi
  else
    typeset -A codes
    codes=(
      'black'   '000'
      'red'     '001'
      'green'   '002'
      'yellow'  '003'
      'blue'    '004'
      'magenta' '005'
      'cyan'    '006'
      'white'   '007'
    )

    # Strip eventual "bg-" prefixes
    1=${1#bg-}
    # Strip eventual "fg-" prefixes
    1=${1#fg-}
    # Strip eventual "br" prefixes ("bright" colors)
    1=${1#br}
    echo $codes[$1]
  fi
}

# Check if two colors are equal, even if one is specified as ANSI code.
function isSameColor() {
  if [[ "$1" == "NONE" || "$2" == "NONE" ]]; then
    return 1
  fi

  local color1=$(getColorCode "$1")
  local color2=$(getColorCode "$2")

  return $(( color1 != color2 ))
}

# Converts large memory values into a human-readable unit (e.g., bytes --> GB)
printSizeHumanReadable() {
  local size=$1
  local extension
  extension=(B K M G T P E Z Y)
  local index=1

  # if the base is not Bytes
  if [[ -n $2 ]]; then
    for idx in "${extension[@]}"; do
      if [[ "$2" == "$idx" ]]; then
        break
      fi
      index=$(( index + 1 ))
    done
  fi

  while (( (size / 1024) > 0 )); do
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
  setopt shwordsplit # We need to split the words in $interfaces

  local list callback
  list=$1
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

get_icon_names() {
  for key in ${(@k)icons}; do
    echo "POWERLEVEL9K_$key: ${icons[$key]}"
  done
}

# OS detection for the `os_icon` segment
case $(uname) in
    Darwin)
      OS='OSX'
      OS_ICON=$(print_icon 'APPLE_ICON')
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
      OS_ICON=$(print_icon 'LINUX_ICON')
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

