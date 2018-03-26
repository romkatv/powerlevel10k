# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# Color functions
# This file holds some color-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

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
  # no need to check numerical values
  if [[ "$1" = <-> ]]; then
    if [[ "$1" = <8-15> ]]; then
      1=$(($1 - 8))
    fi
  else
    # named color added to parameter expansion print -P to test if the name exists in terminal
    local named="%K{$1}"
    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    local default="$'\033'\[49m"
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    local quoted=$(printf "%q" $(print -P "$named"))
    if [[ $quoted = "$'\033'\[49m" && $1 != "black" ]]; then
        # color not found, so try to get the code
        1=$(getColorCode $1)
    fi
  fi
  echo -n "$1"
}

# empty paramenter resets (stops) background color
function backgroundColor() {
  if [[ -z $1 ]]; then
    echo -n "%k"
  else
    echo -n "%K{$(getColor $1)}"
  fi
}

# empty paramenter resets (stops) foreground color
function foregroundColor() {
  if [[ -z $1 ]]; then
    echo -n "%f"
  else
    echo -n "%F{$(getColor $1)}"
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
      echo -n $(($1 - 8))
    else
      echo -n "$1"
    fi
  else
    typeset -A codes
    # https://jonasjacek.github.io/colors/
    # use color names by default to allow dark/light themes to adjust colors based on names
    codes[black]=000
    codes[maroon]=001
    codes[green]=002
    codes[olive]=003
    codes[navy]=004
    codes[purple]=005
    codes[teal]=006
    codes[silver]=007
    codes[grey]=008
    codes[red]=009
    codes[lime]=010
    codes[yellow]=011
    codes[blue]=012
    codes[fuchsia]=013
    codes[aqua]=014
    codes[white]=015
    codes[grey0]=016
    codes[navyblue]=017
    codes[darkblue]=018
    codes[blue3]=019
    codes[blue3]=020
    codes[blue1]=021
    codes[darkgreen]=022
    codes[deepskyblue4]=023
    codes[deepskyblue4]=024
    codes[deepskyblue4]=025
    codes[dodgerblue3]=026
    codes[dodgerblue2]=027
    codes[green4]=028
    codes[springgreen4]=029
    codes[turquoise4]=030
    codes[deepskyblue3]=031
    codes[deepskyblue3]=032
    codes[dodgerblue1]=033
    codes[green3]=034
    codes[springgreen3]=035
    codes[darkcyan]=036
    codes[lightseagreen]=037
    codes[deepskyblue2]=038
    codes[deepskyblue1]=039
    codes[green3]=040
    codes[springgreen3]=041
    codes[springgreen2]=042
    codes[cyan3]=043
    codes[darkturquoise]=044
    codes[turquoise2]=045
    codes[green1]=046
    codes[springgreen2]=047
    codes[springgreen1]=048
    codes[mediumspringgreen]=049
    codes[cyan2]=050
    codes[cyan1]=051
    codes[darkred]=052
    codes[deeppink4]=053
    codes[purple4]=054
    codes[purple4]=055
    codes[purple3]=056
    codes[blueviolet]=057
    codes[orange4]=058
    codes[grey37]=059
    codes[mediumpurple4]=060
    codes[slateblue3]=061
    codes[slateblue3]=062
    codes[royalblue1]=063
    codes[chartreuse4]=064
    codes[darkseagreen4]=065
    codes[paleturquoise4]=066
    codes[steelblue]=067
    codes[steelblue3]=068
    codes[cornflowerblue]=069
    codes[chartreuse3]=070
    codes[darkseagreen4]=071
    codes[cadetblue]=072
    codes[cadetblue]=073
    codes[skyblue3]=074
    codes[steelblue1]=075
    codes[chartreuse3]=076
    codes[palegreen3]=077
    codes[seagreen3]=078
    codes[aquamarine3]=079
    codes[mediumturquoise]=080
    codes[steelblue1]=081
    codes[chartreuse2]=082
    codes[seagreen2]=083
    codes[seagreen1]=084
    codes[seagreen1]=085
    codes[aquamarine1]=086
    codes[darkslategray2]=087
    codes[darkred]=088
    codes[deeppink4]=089
    codes[darkmagenta]=090
    codes[darkmagenta]=091
    codes[darkviolet]=092
    codes[purple]=093
    codes[orange4]=094
    codes[lightpink4]=095
    codes[plum4]=096
    codes[mediumpurple3]=097
    codes[mediumpurple3]=098
    codes[slateblue1]=099
    codes[yellow4]=100
    codes[wheat4]=101
    codes[grey53]=102
    codes[lightslategrey]=103
    codes[mediumpurple]=104
    codes[lightslateblue]=105
    codes[yellow4]=106
    codes[darkolivegreen3]=107
    codes[darkseagreen]=108
    codes[lightskyblue3]=109
    codes[lightskyblue3]=110
    codes[skyblue2]=111
    codes[chartreuse2]=112
    codes[darkolivegreen3]=113
    codes[palegreen3]=114
    codes[darkseagreen3]=115
    codes[darkslategray3]=116
    codes[skyblue1]=117
    codes[chartreuse1]=118
    codes[lightgreen]=119
    codes[lightgreen]=120
    codes[palegreen1]=121
    codes[aquamarine1]=122
    codes[darkslategray1]=123
    codes[red3]=124
    codes[deeppink4]=125
    codes[mediumvioletred]=126
    codes[magenta3]=127
    codes[darkviolet]=128
    codes[purple]=129
    codes[darkorange3]=130
    codes[indianred]=131
    codes[hotpink3]=132
    codes[mediumorchid3]=133
    codes[mediumorchid]=134
    codes[mediumpurple2]=135
    codes[darkgoldenrod]=136
    codes[lightsalmon3]=137
    codes[rosybrown]=138
    codes[grey63]=139
    codes[mediumpurple2]=140
    codes[mediumpurple1]=141
    codes[gold3]=142
    codes[darkkhaki]=143
    codes[navajowhite3]=144
    codes[grey69]=145
    codes[lightsteelblue3]=146
    codes[lightsteelblue]=147
    codes[yellow3]=148
    codes[darkolivegreen3]=149
    codes[darkseagreen3]=150
    codes[darkseagreen2]=151
    codes[lightcyan3]=152
    codes[lightskyblue1]=153
    codes[greenyellow]=154
    codes[darkolivegreen2]=155
    codes[palegreen1]=156
    codes[darkseagreen2]=157
    codes[darkseagreen1]=158
    codes[paleturquoise1]=159
    codes[red3]=160
    codes[deeppink3]=161
    codes[deeppink3]=162
    codes[magenta3]=163
    codes[magenta3]=164
    codes[magenta2]=165
    codes[darkorange3]=166
    codes[indianred]=167
    codes[hotpink3]=168
    codes[hotpink2]=169
    codes[orchid]=170
    codes[mediumorchid1]=171
    codes[orange3]=172
    codes[lightsalmon3]=173
    codes[lightpink3]=174
    codes[pink3]=175
    codes[plum3]=176
    codes[violet]=177
    codes[gold3]=178
    codes[lightgoldenrod3]=179
    codes[tan]=180
    codes[mistyrose3]=181
    codes[thistle3]=182
    codes[plum2]=183
    codes[yellow3]=184
    codes[khaki3]=185
    codes[lightgoldenrod2]=186
    codes[lightyellow3]=187
    codes[grey84]=188
    codes[lightsteelblue1]=189
    codes[yellow2]=190
    codes[darkolivegreen1]=191
    codes[darkolivegreen1]=192
    codes[darkseagreen1]=193
    codes[honeydew2]=194
    codes[lightcyan1]=195
    codes[red1]=196
    codes[deeppink2]=197
    codes[deeppink1]=198
    codes[deeppink1]=199
    codes[magenta2]=200
    codes[magenta1]=201
    codes[orangered1]=202
    codes[indianred1]=203
    codes[indianred1]=204
    codes[hotpink]=205
    codes[hotpink]=206
    codes[mediumorchid1]=207
    codes[darkorange]=208
    codes[salmon1]=209
    codes[lightcoral]=210
    codes[palevioletred1]=211
    codes[orchid2]=212
    codes[orchid1]=213
    codes[orange1]=214
    codes[sandybrown]=215
    codes[lightsalmon1]=216
    codes[lightpink1]=217
    codes[pink1]=218
    codes[plum1]=219
    codes[gold1]=220
    codes[lightgoldenrod2]=221
    codes[lightgoldenrod2]=222
    codes[navajowhite1]=223
    codes[mistyrose1]=224
    codes[thistle1]=225
    codes[yellow1]=226
    codes[lightgoldenrod1]=227
    codes[khaki1]=228
    codes[wheat1]=229
    codes[cornsilk1]=230
    codes[grey100]=231
    codes[grey3]=232
    codes[grey7]=233
    codes[grey11]=234
    codes[grey15]=235
    codes[grey19]=236
    codes[grey23]=237
    codes[grey27]=238
    codes[grey30]=239
    codes[grey35]=240
    codes[grey39]=241
    codes[grey42]=242
    codes[grey46]=243
    codes[grey50]=244
    codes[grey54]=245
    codes[grey58]=246
    codes[grey62]=247
    codes[grey66]=248
    codes[grey70]=249
    codes[grey74]=250
    codes[grey78]=251
    codes[grey82]=252
    codes[grey85]=253
    codes[grey89]=254
    codes[grey93]=255

    # for testing purposes in terminal
    if [[ "$1" == "foreground"  ]]; then
        # call via `getColorCode foreground`
        for i in "${(k@)codes}"; do
            print -P "$(foregroundColor $i)$(getColor $i) - $i$(foregroundColor)"
        done
    elif [[ "$1" == "background"  ]]; then
        # call via `getColorCode background`
        for i in "${(k@)codes}"; do
            print -P "$(backgroundColor $i)$(getColor $i) - $i$(backgroundColor)"
        done
    else
        #[[ -n "$1" ]] bg="%K{$1}" || bg="%k"
        # Strip eventual "bg-" prefixes
        1=${1#bg-}
        # Strip eventual "fg-" prefixes
        1=${1#fg-}
        # Strip eventual "br" prefixes ("bright" colors)
        1=${1#br}
        echo -n $codes[$1]
    fi
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
