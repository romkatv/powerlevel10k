# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Color functions
# This file holds some color-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

typeset -gAh __P9K_COLORS
# https://jonasjacek.github.io/colors/
# use color names by default to allow dark/light themes to adjust colors based on names
__P9K_COLORS=(
  black 000
  red 001
  green 002
  yellow 003
  blue 004
  magenta 005
  cyan 006
  white 007
  grey 008
  maroon 009
  lime 010
  olive 011
  navy 012
  fuchsia 013
  purple 013
  aqua 014
  teal 014
  silver 015
  grey0 016
  navyblue 017
  darkblue 018
  blue3 019
  blue3 020
  blue1 021
  darkgreen 022
  deepskyblue4 023
  deepskyblue4 024
  deepskyblue4 025
  dodgerblue3 026
  dodgerblue2 027
  green4 028
  springgreen4 029
  turquoise4 030
  deepskyblue3 031
  deepskyblue3 032
  dodgerblue1 033
  green3 034
  springgreen3 035
  darkcyan 036
  lightseagreen 037
  deepskyblue2 038
  deepskyblue1 039
  green3 040
  springgreen3 041
  springgreen2 042
  cyan3 043
  darkturquoise 044
  turquoise2 045
  green1 046
  springgreen2 047
  springgreen1 048
  mediumspringgreen 049
  cyan2 050
  cyan1 051
  darkred 052
  deeppink4 053
  purple4 054
  purple4 055
  purple3 056
  blueviolet 057
  orange4 058
  grey37 059
  mediumpurple4 060
  slateblue3 061
  slateblue3 062
  royalblue1 063
  chartreuse4 064
  darkseagreen4 065
  paleturquoise4 066
  steelblue 067
  steelblue3 068
  cornflowerblue 069
  chartreuse3 070
  darkseagreen4 071
  cadetblue 072
  cadetblue 073
  skyblue3 074
  steelblue1 075
  chartreuse3 076
  palegreen3 077
  seagreen3 078
  aquamarine3 079
  mediumturquoise 080
  steelblue1 081
  chartreuse2 082
  seagreen2 083
  seagreen1 084
  seagreen1 085
  aquamarine1 086
  darkslategray2 087
  darkred 088
  deeppink4 089
  darkmagenta 090
  darkmagenta 091
  darkviolet 092
  purple 093
  orange4 094
  lightpink4 095
  plum4 096
  mediumpurple3 097
  mediumpurple3 098
  slateblue1 099
  yellow4 100
  wheat4 101
  grey53 102
  lightslategrey 103
  mediumpurple 104
  lightslateblue 105
  yellow4 106
  darkolivegreen3 107
  darkseagreen 108
  lightskyblue3 109
  lightskyblue3 110
  skyblue2 111
  chartreuse2 112
  darkolivegreen3 113
  palegreen3 114
  darkseagreen3 115
  darkslategray3 116
  skyblue1 117
  chartreuse1 118
  lightgreen 119
  lightgreen 120
  palegreen1 121
  aquamarine1 122
  darkslategray1 123
  red3 124
  deeppink4 125
  mediumvioletred 126
  magenta3 127
  darkviolet 128
  purple 129
  darkorange3 130
  indianred 131
  hotpink3 132
  mediumorchid3 133
  mediumorchid 134
  mediumpurple2 135
  darkgoldenrod 136
  lightsalmon3 137
  rosybrown 138
  grey63 139
  mediumpurple2 140
  mediumpurple1 141
  gold3 142
  darkkhaki 143
  navajowhite3 144
  grey69 145
  lightsteelblue3 146
  lightsteelblue 147
  yellow3 148
  darkolivegreen3 149
  darkseagreen3 150
  darkseagreen2 151
  lightcyan3 152
  lightskyblue1 153
  greenyellow 154
  darkolivegreen2 155
  palegreen1 156
  darkseagreen2 157
  darkseagreen1 158
  paleturquoise1 159
  red3 160
  deeppink3 161
  deeppink3 162
  magenta3 163
  magenta3 164
  magenta2 165
  darkorange3 166
  indianred 167
  hotpink3 168
  hotpink2 169
  orchid 170
  mediumorchid1 171
  orange3 172
  lightsalmon3 173
  lightpink3 174
  pink3 175
  plum3 176
  violet 177
  gold3 178
  lightgoldenrod3 179
  tan 180
  mistyrose3 181
  thistle3 182
  plum2 183
  yellow3 184
  khaki3 185
  lightgoldenrod2 186
  lightyellow3 187
  grey84 188
  lightsteelblue1 189
  yellow2 190
  darkolivegreen1 191
  darkolivegreen1 192
  darkseagreen1 193
  honeydew2 194
  lightcyan1 195
  red1 196
  deeppink2 197
  deeppink1 198
  deeppink1 199
  magenta2 200
  magenta1 201
  orangered1 202
  indianred1 203
  indianred1 204
  hotpink 205
  hotpink 206
  mediumorchid1 207
  darkorange 208
  salmon1 209
  lightcoral 210
  palevioletred1 211
  orchid2 212
  orchid1 213
  orange1 214
  sandybrown 215
  lightsalmon1 216
  lightpink1 217
  pink1 218
  plum1 219
  gold1 220
  lightgoldenrod2 221
  lightgoldenrod2 222
  navajowhite1 223
  mistyrose1 224
  thistle1 225
  yellow1 226
  lightgoldenrod1 227
  khaki1 228
  wheat1 229
  cornsilk1 230
  grey100 231
  grey3 232
  grey7 233
  grey11 234
  grey15 235
  grey19 236
  grey23 237
  grey27 238
  grey30 239
  grey35 240
  grey39 241
  grey42 242
  grey46 243
  grey50 244
  grey54 245
  grey58 246
  grey62 247
  grey66 248
  grey70 249
  grey74 250
  grey78 251
  grey82 252
  grey85 253
  grey89 254
  grey93 255
)

function termColors() {
  if [[ $POWERLEVEL9K_IGNORE_TERM_COLORS == true ]]; then
    return
  fi

  local term_colors

  if which tput &>/dev/null; then
	term_colors=$(tput colors)
  else
	term_colors=$(echotc Co)
  fi
  if (( ! $? && ${term_colors:-0} < 256 )); then
    print -P "%F{red}WARNING!%f Your terminal appears to support fewer than 256 colors!"
    print -P "If your terminal supports 256 colors, please export the appropriate environment variable"
    print -P "_before_ loading this theme in your \~\/.zshrc. In most terminal emulators, putting"
    print -P "%F{blue}export TERM=\"xterm-256color\"%f at the top of your \~\/.zshrc is sufficient."
  fi
}

# get the proper color code if it does not exist as a name.
function getColor() {
  # If Color is not numerical, try to get the color code.
  if [[ "$1" != <-> ]]; then
    1=$(getColorCode $1)
  fi
  echo -n "$1"
}

# empty paramenter resets (stops) background color
function backgroundColor() {
  echo -n "%K{$(getColor $1)}"
}

# empty paramenter resets (stops) foreground color
function foregroundColor() {
  echo -n "%F{$(getColor $1)}"
}

# Get numerical color codes. That way we translate ANSI codes
# into ZSH-Style color codes.
function getColorCode() {
  # Early exit: Check if given value is already numerical
  if [[ "$1" == <-> ]]; then
    # Pad color with zeroes
    echo -n "${(l:3::0:)1}"
    return
  fi

  local colorName="${1}"
  # Check if value is none with any case.
  if [[ "${(L)colorName}" == "none" ]]; then
      echo -n 'none'
  elif [[ "${colorName}" == "foreground"  ]]; then
      # for testing purposes in terminal
      # call via `getColorCode foreground`
      for i in "${(k@)__P9K_COLORS}"; do
          print -P "$(foregroundColor $i)$(getColor $i) - $i%f"
      done
  elif [[ "${colorName}" == "background"  ]]; then
      # call via `getColorCode background`
      for i in "${(k@)__P9K_COLORS}"; do
          print -P "$(backgroundColor $i)$(getColor $i) - $i%k"
      done
  else
      # Strip eventual "bg-" prefixes
      colorName=${colorName#bg-}
      # Strip eventual "fg-" prefixes
      colorName=${colorName#fg-}
      # Strip eventual "br" prefixes ("bright" colors)
      colorName=${colorName#br}
      echo -n $__P9K_COLORS[$colorName]
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
