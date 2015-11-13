# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Color functions
# This file holds some color-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

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

