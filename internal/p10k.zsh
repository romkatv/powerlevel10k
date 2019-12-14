if ! autoload -Uz is-at-least || ! is-at-least 5.1; then
  () {
    >&2 echo -E "You are using ZSH version $ZSH_VERSION. The minimum required version for Powerlevel10k is 5.1."
    >&2 echo -E "Type 'echo \$ZSH_VERSION' to see your current zsh version."
    local def=${SHELL:c:A}
    local cur=${${ZSH_ARGZERO#-}:c:A}
    local cur_v="$($cur -c 'echo -E $ZSH_VERSION' 2>/dev/null)"
    if [[ $cur_v == $ZSH_VERSION && $cur != $def ]]; then
      >&2 echo -E "The shell you are currently running is likely $cur."
    fi
    local other=${${:-zsh}:c}
    if [[ -n $other ]] && $other -c 'autoload -Uz is-at-least && is-at-least 5.1' &>/dev/null; then
      local other_v="$($other -c 'echo -E $ZSH_VERSION' 2>/dev/null)"
      if [[ -n $other_v && $other_v != $ZSH_VERSION ]]; then
        >&2 echo -E "You have $other with version $other_v but this is not what you are using."
        if [[ -n $def && $def != ${other:A} ]]; then
          >&2 echo -E "To change your user shell, type the following command:"
          >&2 echo -E ""
          if [[ "$(grep -F $other /etc/shells 2>/dev/null)" != $other ]]; then
            >&2 echo -E "  echo ${(q-)other} | sudo tee -a /etc/shells"
          fi
          >&2 echo -E "  chsh -s ${(q-)other}"
        fi
      fi
    fi
  }
  return 1
fi

source "${__p9k_root_dir}/internal/configure.zsh"

# For compatibility with Powerlevel9k. It's not recommended to use mnemonic color
# names in the configuration except for colors 0-7 as these are standard.
typeset -grA __p9k_colors=(
            black 000               red 001             green 002            yellow 003
             blue 004           magenta 005              cyan 006             white 007
             grey 008            maroon 009              lime 010             olive 011
             navy 012           fuchsia 013              aqua 014              teal 014
           silver 015             grey0 016          navyblue 017          darkblue 018
            blue3 020             blue1 021         darkgreen 022      deepskyblue4 025
      dodgerblue3 026       dodgerblue2 027            green4 028      springgreen4 029
       turquoise4 030      deepskyblue3 032       dodgerblue1 033          darkcyan 036
    lightseagreen 037      deepskyblue2 038      deepskyblue1 039            green3 040
     springgreen3 041             cyan3 043     darkturquoise 044        turquoise2 045
           green1 046      springgreen2 047      springgreen1 048 mediumspringgreen 049
            cyan2 050             cyan1 051           purple4 055           purple3 056
       blueviolet 057            grey37 059     mediumpurple4 060        slateblue3 062
       royalblue1 063       chartreuse4 064    paleturquoise4 066         steelblue 067
       steelblue3 068    cornflowerblue 069     darkseagreen4 071         cadetblue 073
         skyblue3 074       chartreuse3 076         seagreen3 078       aquamarine3 079
  mediumturquoise 080        steelblue1 081         seagreen2 083         seagreen1 085
   darkslategray2 087           darkred 088       darkmagenta 091           orange4 094
       lightpink4 095             plum4 096     mediumpurple3 098        slateblue1 099
           wheat4 101            grey53 102    lightslategrey 103      mediumpurple 104
   lightslateblue 105           yellow4 106      darkseagreen 108     lightskyblue3 110
         skyblue2 111       chartreuse2 112        palegreen3 114    darkslategray3 116
         skyblue1 117       chartreuse1 118        lightgreen 120       aquamarine1 122
   darkslategray1 123         deeppink4 125   mediumvioletred 126        darkviolet 128
           purple 129     mediumorchid3 133      mediumorchid 134     darkgoldenrod 136
        rosybrown 138            grey63 139     mediumpurple2 140     mediumpurple1 141
        darkkhaki 143      navajowhite3 144            grey69 145   lightsteelblue3 146
   lightsteelblue 147   darkolivegreen3 149     darkseagreen3 150        lightcyan3 152
    lightskyblue1 153       greenyellow 154   darkolivegreen2 155        palegreen1 156
    darkseagreen2 157    paleturquoise1 159              red3 160         deeppink3 162
         magenta3 164       darkorange3 166         indianred 167          hotpink3 168
         hotpink2 169            orchid 170           orange3 172      lightsalmon3 173
       lightpink3 174             pink3 175             plum3 176            violet 177
            gold3 178   lightgoldenrod3 179               tan 180        mistyrose3 181
         thistle3 182             plum2 183           yellow3 184            khaki3 185
     lightyellow3 187            grey84 188   lightsteelblue1 189           yellow2 190
  darkolivegreen1 192     darkseagreen1 193         honeydew2 194        lightcyan1 195
             red1 196         deeppink2 197         deeppink1 199          magenta2 200
         magenta1 201        orangered1 202        indianred1 204           hotpink 206
    mediumorchid1 207        darkorange 208           salmon1 209        lightcoral 210
   palevioletred1 211           orchid2 212           orchid1 213           orange1 214
       sandybrown 215      lightsalmon1 216        lightpink1 217             pink1 218
            plum1 219             gold1 220   lightgoldenrod2 222      navajowhite1 223
       mistyrose1 224          thistle1 225           yellow1 226   lightgoldenrod1 227
           khaki1 228            wheat1 229         cornsilk1 230           grey100 231
            grey3 232             grey7 233            grey11 234            grey15 235
           grey19 236            grey23 237            grey27 238            grey30 239
           grey35 240            grey39 241            grey42 242            grey46 243
           grey50 244            grey54 245            grey58 246            grey62 247
           grey66 248            grey70 249            grey74 250            grey78 251
           grey82 252            grey85 253            grey89 254            grey93 255)

# For compatibility with Powerlevel9k.
#
# Type `getColorCode background` or `getColorCode foreground` to see the list of predefined colors.
function getColorCode() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  if (( ARGC == 1 )); then
    case $1 in
      foreground)
        local k
        for k in "${(k@)__p9k_colors}"; do
          local v=${__p9k_colors[$k]}
          print -rP -- "%F{$v}$v - $k%f"
        done
        return 0
        ;;
      background)
        local k
        for k in "${(k@)__p9k_colors}"; do
          local v=${__p9k_colors[$k]}
          print -rP -- "%K{$v}$v - $k%k"
        done
        return 0
        ;;
    esac
  fi
  echo "Usage: getColorCode background|foreground" >&2
  return 1
}

# Sadly, this is a part of public API. Its use is emphatically discouraged.
function print_icon() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  (( $+functions[_p9k_print_icon] )) || source "${__p9k_root_dir}/internal/icons.zsh"
  _p9k_print_icon "$@"
}

# Prints a list of configured icons.
#
#   * $1 string - If "original", then the original icons are printed,
#                 otherwise "print_icon" is used, which takes the users
#                 overrides into account.
function get_icon_names() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  (( $+functions[_p9k_get_icon_names] )) || source "${__p9k_root_dir}/internal/icons.zsh"
  _p9k_get_icon_names "$@"
}

# _p9k_declare <type> <uppercase-name> [default]...
function _p9k_declare() {
  local -i set=$+parameters[$2]
  (( ARGC > 2 || set )) || return 0
  case $1 in
    -b)
      if (( set )); then
        [[ ${(P)2} == true ]] && typeset -gi _$2=1 || typeset -gi _$2=0
      else
        typeset -gi _$2=$3
      fi
      ;;
    -a)
      local -a v=(${(P)2})
      if (( set )); then
        eval "typeset -ga _${(q)2}=(${(@qq)v})";
      else
        if [[ $3 != '--' ]]; then
          echo "internal error in _p9k_declare " "${(qqq)@}" >&2
        fi
        eval "typeset -ga _${(q)2}=(${(@qq)*[4,-1]})"
      fi
      ;;
    -i)
      (( set )) && typeset -gi _$2=$2 || typeset -gi _$2=$3
      ;;
    -F)
      (( set )) && typeset -gF _$2=$2 || typeset -gF _$2=$3
      ;;
    -s)
      (( set )) && typeset -g _$2=${(P)2} || typeset -g _$2=$3
      ;;
    -e)
      [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
      if (( set )); then
        local v=${(P)2}
        typeset -g _$2=${(g::)v}
      else
        typeset -g _$2=${(g::)3}
      fi
      ;;
    *)
      echo "internal error in _p9k_declare " "${(qqq)@}" >&2
  esac
}

# If we execute `print -P $1`, how many characters will be printed on the last line?
# Assumes that `%{%}` and `%G` don't lie.
#
#   _p9k_prompt_length '' => 0
#   _p9k_prompt_length 'abc' => 3
#   _p9k_prompt_length $'abc\nxy' => 2
#   _p9k_prompt_length $'\t' => 8
#   _p9k_prompt_length '%F{red}abc' => 3
#   _p9k_prompt_length $'%{a\b%Gb%}' => 1
function _p9k_prompt_length() {
  local COLUMNS=1024
  local -i x y=$#1 m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done
    local xy
    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done
  fi
  _p9k_ret=$x
}

typeset -gr __p9k_byte_suffix=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# 42 => 42B
# 1536 => 1.5K
function _p9k_human_readable_bytes() {
  typeset -F 2 n=$1
  local suf
  for suf in $__p9k_byte_suffix; do
    (( n < 100 )) && break
    (( n /= 1024 ))
  done
  _p9k_ret=$n$suf
}

# Determine if the passed segment is used in the prompt
#
# Pass the name of the segment to this function to test for its presence in
# either the LEFT or RIGHT prompt arrays.
#    * $1: The segment to be tested.
_p9k_segment_in_use() {
  (( $_POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(I)$1(|_joined)] ||
     $_POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(I)$1(|_joined)] ))
}

function _p9k_parse_ip() {
  local iface_regex="^(${1:-.*})\$" iface ip
  for iface ip in "${(@kv)_p9k_iface}"; do
    if [[ $iface =~ $iface_regex ]]; then
      _p9k_ret=$ip
      return 0
    fi
  done
  return 1
}

# Caching allows storing array-to-array associations. It should be used like this:
#
#   if ! _p9k_cache_get "$key1" "$key2"; then
#     # Compute val1 and val2 and then store them in the cache.
#     _p9k_cache_set "$val1" "$val2"
#   fi
#   # Here ${_p9k_cache_val[1]} and ${_p9k_cache_val[2]} are $val1 and $val2 respectively.
#
# Limitations:
#
#   * Calling _p9k_cache_set without arguments clears the cache entry. Subsequent calls to
#     _p9k_cache_get for the same key will return an error.
#   * There must be no intervening _p9k_cache_get calls between the associated _p9k_cache_get
#     and _p9k_cache_set.
_p9k_cache_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_p9k_cache_key} => (${(q)@})" >&2
  _p9k_cache[$_p9k_cache_key]="${(pj:\0:)*}0"
  _p9k_cache_val=("$@")
  _p9k__state_dump_scheduled=1
}

_p9k_cache_get() {
  _p9k_cache_key="${(pj:\0:)*}"
  local v=$_p9k_cache[$_p9k_cache_key]
  [[ -n $v ]] && _p9k_cache_val=("${(@0)${v[1,-2]}}")
}

_p9k_cache_ephemeral_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_p9k_cache_key} => (${(q)@})" >&2
  _p9k__cache_ephemeral[$_p9k_cache_key]="${(pj:\0:)*}0"
  _p9k_cache_val=("$@")
}

_p9k_cache_ephemeral_get() {
  _p9k_cache_key="${(pj:\0:)*}"
  local v=$_p9k__cache_ephemeral[$_p9k_cache_key]
  [[ -n $v ]] && _p9k_cache_val=("${(@0)${v[1,-2]}}")
}

_p9k_cache_stat_get() {
  local -H stat
  local label=$1 f
  shift

  _p9k__cache_stat_meta=
  _p9k__cache_stat_fprint=

  for f; do
    if zstat -H stat -- $f 2>/dev/null; then
      _p9k__cache_stat_meta+="${(q)f} $stat[inode] $stat[mtime] $stat[size] $stat[mode]; "
    fi
  done

  if _p9k_cache_get $0 $label meta "$@" && [[ $_p9k_cache_val[1] == $_p9k__cache_stat_meta ]]; then
    _p9k__cache_stat_fprint=$_p9k_cache_val[2]
    local -a key=($0 $label fprint "$@" "$_p9k__cache_stat_fprint")
    _p9k__cache_fprint_key="${(pj:\0:)key}"
    shift 2 _p9k_cache_val
    return 0
  fi

  if (( $+commands[md5] )); then
    local -a md5=(md5)
  elif (( $+commands[md5sum] )); then
    local -a md5=(md5sum -b)
  else
    return 1
  fi

  local fprint
  for f; do
    if fprint="$($md5 $f 2>/dev/null)"; then
      _p9k__cache_stat_fprint+="${(q)fprint} "
    fi
  done

  local meta_key=$_p9k_cache_key
  if _p9k_cache_get $0 $label fprint "$@" "$_p9k__cache_stat_fprint"; then
    _p9k__cache_fprint_key=$_p9k_cache_key
    _p9k_cache_key=$meta_key
    _p9k_cache_set "$_p9k__cache_stat_meta" "$_p9k__cache_stat_fprint" "$_p9k_cache_val[@]"
    shift 2 _p9k_cache_val
    return 0
  fi

  _p9k__cache_fprint_key=$_p9k_cache_key
  _p9k_cache_key=$meta_key
  return 1
}

_p9k_cache_stat_set() {
  _p9k_cache_set "$_p9k__cache_stat_meta" "$_p9k__cache_stat_fprint" "$@"
  _p9k_cache_key=$_p9k__cache_fprint_key
  _p9k_cache_set "$@"
}

# _p9k_param prompt_foo_BAR BACKGROUND red
_p9k_param() {
  local key="_p9k_param ${(pj:\0:)*}"
  _p9k_ret=$_p9k_cache[$key]
  if [[ -n $_p9k_ret ]]; then
    _p9k_ret[-1,-1]=''
  else
    if [[ $1 == (#b)prompt_([a-z0-9_]#)(*) ]]; then
      local var=_POWERLEVEL9K_${(U)match[1]}$match[2]_$2
      if (( $+parameters[$var] )); then
        _p9k_ret=${(P)var}
      else
        var=_POWERLEVEL9K_${(U)match[1]%_}_$2
        if (( $+parameters[$var] )); then
          _p9k_ret=${(P)var}
        else
          var=_POWERLEVEL9K_$2
          if (( $+parameters[$var] )); then
            _p9k_ret=${(P)var}
          else
            _p9k_ret=$3
          fi
        fi
      fi
    else
      local var=_POWERLEVEL9K_$2
      if (( $+parameters[$var] )); then
        _p9k_ret=${(P)var}
      else
        _p9k_ret=$3
      fi
    fi
    _p9k_cache[$key]=${_p9k_ret}.
  fi
}

# _p9k_get_icon prompt_foo_BAR BAZ_ICON quix
_p9k_get_icon() {
  local key="_p9k_param ${(pj:\0:)*}"
  _p9k_ret=$_p9k_cache[$key]
  if [[ -n $_p9k_ret ]]; then
    _p9k_ret[-1,-1]=''
  else
    if [[ $2 == $'\1'* ]]; then
      _p9k_ret=${2[2,-1]}
    else
      _p9k_param "$@" ${icons[$2]-$'\1'$3}
      if [[ $_p9k_ret == $'\1'* ]]; then
        _p9k_ret=${_p9k_ret[2,-1]}
      else
        [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
        _p9k_ret=${(g::)_p9k_ret}
        [[ $_p9k_ret != $'\b'? ]] || _p9k_ret="%{$_p9k_ret%}"  # penance for past sins
      fi
    fi
    _p9k_cache[$key]=${_p9k_ret}.
  fi
}

_p9k_translate_color() {
  if [[ $1 == <-> ]]; then                  # decimal color code: 255
    _p9k_ret=${(l.3..0.)1}
  elif [[ $1 == '#'[[:xdigit:]]## ]]; then  # hexademical color code: #ffffff
    _p9k_ret=${(L)1}
  else                                      # named color: red
    # Strip prifixes if there are any.
    _p9k_ret=$__p9k_colors[${${${1#bg-}#fg-}#br}]
  fi
}

# _p9k_color prompt_foo_BAR BACKGROUND red
_p9k_color() {
  local key="_p9k_color ${(pj:\0:)*}"
  _p9k_ret=$_p9k_cache[$key]
  if [[ -n $_p9k_ret ]]; then
    _p9k_ret[-1,-1]=''
  else
    _p9k_param "$@"
    _p9k_translate_color $_p9k_ret
    _p9k_cache[$key]=${_p9k_ret}.
  fi
}

# _p9k_vcs_color CLEAN REMOTE_BRANCH
_p9k_vcs_style() {
  local key="_p9k_vcs_color ${(pj:\0:)*}"
  _p9k_ret=$_p9k_cache[$key]
  if [[ -n $_p9k_ret ]]; then
    _p9k_ret[-1,-1]=''
  else
    local style=%b  # TODO: support bold
    _p9k_color prompt_vcs_$1 BACKGROUND "${__p9k_vcs_states[$1]}"
    _p9k_background $_p9k_ret
    style+=$_p9k_ret

    local var=_POWERLEVEL9K_VCS_${1}_${2}FORMAT_FOREGROUND
    if (( $+parameters[$var] )); then
      _p9k_translate_color "${(P)var}"
    else
      var=_POWERLEVEL9K_VCS_${2}FORMAT_FOREGROUND
      if (( $+parameters[$var] )); then
        _p9k_translate_color "${(P)var}"
      else
        _p9k_color prompt_vcs_$1 FOREGROUND "$_p9k_color1"
      fi
    fi

    _p9k_foreground $_p9k_ret
    _p9k_ret=$style$_p9k_ret
    _p9k_cache[$key]=${_p9k_ret}.
  fi
}

_p9k_background() {
  [[ -n $1 ]] && _p9k_ret="%K{$1}" || _p9k_ret="%k"
}

_p9k_foreground() {
  # Note: This code used to produce `%1F` instead of `%F{1}` because it's more efficient.
  # Unfortunately, this triggers a bug in zsh. Namely, `%1F{2}` gets percent-expanded as if
  # it was `%F{2}`.
  [[ -n $1 ]] && _p9k_ret="%F{$1}" || _p9k_ret="%f"
}

_p9k_escape_style() {
  [[ $1 == *'}'* ]] && _p9k_ret='${:-"'$1'"}' || _p9k_ret=$1
}

_p9k_escape() {
  [[ $1 == *["~!#\$^&*()\\\"'<>?{}[]"]* ]] && _p9k_ret="\${(Q)\${:-${(qqq)${(q)1}}}}" || _p9k_ret=$1
}

# * $1: Name of the function that was originally invoked.
#       Necessary, to make the dynamic color-overwrite mechanism work.
# * $2: Background color.
# * $3: Foreground color.
# * $4: An identifying icon.
# * $5: 1 to to perform parameter expansion and process substitution.
# * $6: If not empty but becomes empty after parameter expansion and process substitution,
#       the segment isn't rendered.
# * $7: Content.
_p9k_left_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$_p9k_segment_index"; then
    _p9k_color $1 BACKGROUND $2
    local bg_color=$_p9k_ret
    _p9k_background $bg_color
    local bg=$_p9k_ret

    _p9k_color $1 FOREGROUND $3
    local fg_color=$_p9k_ret
    _p9k_foreground $fg_color
    local fg=$_p9k_ret

    _p9k_get_icon $1 LEFT_SEGMENT_SEPARATOR
    local sep=$_p9k_ret
    _p9k_escape $_p9k_ret
    local sep_=$_p9k_ret

    _p9k_get_icon $1 LEFT_SUBSEGMENT_SEPARATOR
    _p9k_escape $_p9k_ret
    local subsep_=$_p9k_ret

    local icon_
    if [[ -n $4 ]]; then
      _p9k_get_icon $1 $4
      _p9k_escape $_p9k_ret
      icon_=$_p9k_ret
    fi

    _p9k_get_icon $1 LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL
    local start_sep=$_p9k_ret
    [[ -n $start_sep ]] && start_sep="%b%k%F{$bg_color}$start_sep"

    _p9k_get_icon $1 LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL $sep
    _p9k_escape $_p9k_ret
    local end_sep_=$_p9k_ret

    local style=%b$bg$fg
    local style_=${style//\}/\\\}}

    _p9k_get_icon $1 WHITESPACE_BETWEEN_LEFT_SEGMENTS ' '
    local space=$_p9k_ret

    _p9k_get_icon $1 LEFT_LEFT_WHITESPACE $space
    local left_space=$_p9k_ret
    [[ $left_space == *%* ]] && left_space+=$style

    _p9k_get_icon $1 LEFT_RIGHT_WHITESPACE $space
    _p9k_escape $_p9k_ret
    local right_space_=$_p9k_ret
    [[ $right_space_ == *%* ]] && right_space_+=$style_

    local s='<_p9k_s>' ss='<_p9k_ss>'

    local -i non_hermetic=0

    # Segment separator logic:
    #
    #   if [[ $_p9k_bg == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $bg_color == (${_p9k_bg}|${_p9k_bg:-0}) ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$(($#_p9k_t - __p9k_ksh_arrays))
    _p9k_t+=$start_sep$style$left_space              # 1
    _p9k_t+=$style                                   # 2
    if [[ -n $fg_color && $fg_color == $bg_color ]]; then
      if [[ $fg_color == $_p9k_color1 ]]; then
        _p9k_foreground $_p9k_color2
      else
        _p9k_foreground $_p9k_color1
      fi
      _p9k_t+=%b$bg$_p9k_ret$ss$style$left_space  # 3
    else
      _p9k_t+=%b$bg$fg$ss$style$left_space           # 3
    fi
    _p9k_t+=%b$bg$s$style$left_space                 # 4

    local join="_p9k_i>=$_p9k_left_join[$_p9k_segment_index]"
    _p9k_param $1 SELF_JOINED false
    if [[ $_p9k_ret == false ]]; then
      if (( _p9k_segment_index > $_p9k_left_join[$_p9k_segment_index] )); then
        join+="&&_p9k_i<$_p9k_segment_index"
      else
        join=
      fi
    fi

    local p=
    p+="\${_p9k_n::=}"
    p+="\${\${\${_p9k_bg:-0}:#NONE}:-\${_p9k_n::=$((t+1))}}"                               # 1
    if [[ -n $join ]]; then
      p+="\${_p9k_n:=\${\${\$(($join)):#0}:+$((t+2))}}"                                    # 2
    fi
    if (( __p9k_sh_glob )); then
      p+="\${_p9k_n:=\${\${(M)\${:-x$bg_color}:#x\$_p9k_bg}:+$((t+3))}}"                   # 3
      p+="\${_p9k_n:=\${\${(M)\${:-x$bg_color}:#x\$${_p9k_bg:-0}}:+$((t+3))}}"             # 3
    else
      p+="\${_p9k_n:=\${\${(M)\${:-x$bg_color}:#x(\$_p9k_bg|\${_p9k_bg:-0})}:+$((t+3))}}"  # 3
    fi
    p+="\${_p9k_n:=$((t+4))}"                                                              # 4

    _p9k_param $1 VISUAL_IDENTIFIER_EXPANSION '${P9K_VISUAL_IDENTIFIER}'
    [[ $_p9k_ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local icon_exp_=${_p9k_ret:+\"$_p9k_ret\"}

    _p9k_param $1 CONTENT_EXPANSION '${P9K_CONTENT}'
    [[ $_p9k_ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local content_exp_=${_p9k_ret:+\"$_p9k_ret\"}

    if [[ ( $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ) ||
          ( $content_exp_ != '"${P9K_CONTENT}"' && $content_exp_ == *'$'* ) ]]; then
      p+="\${P9K_VISUAL_IDENTIFIER::=$icon_}"
    fi

    local -i has_icon=-1  # maybe

    if [[ $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ]]; then
      p+='${_p9k_v::='$icon_exp_$style_'}'
    else
      [[ $icon_exp_ == '"${P9K_VISUAL_IDENTIFIER}"' ]] && _p9k_ret=$icon_ || _p9k_ret=$icon_exp_
      if [[ -n $_p9k_ret ]]; then
        p+="\${_p9k_v::=$_p9k_ret"
        [[ $_p9k_ret == *%* ]] && p+=$style_
        p+="}"
        has_icon=1  # definitely yes
      else
        has_icon=0  # definitely no
      fi
    fi

    p+="\${_p9k_c::=$content_exp_}"
    p+='${_p9k_e::=${${_p9k__'${_p9k_line_index}l${${1#prompt_}%%[A-Z_]#}'+00}:-'
    if (( has_icon == -1 )); then
      p+='${${(%):-$_p9k_c%1(l.1.0)}[-1]}${${(%):-$_p9k_v%1(l.1.0)}[-1]}}'
    else
      p+='${${(%):-$_p9k_c%1(l.1.0)}[-1]}'$has_icon'}'
    fi

    p+='}}+}'

    p+='${${_p9k_e:#00}:+${${_p9k_t[$_p9k_n]/'$ss'/$_p9k_ss}/'$s'/$_p9k_s}'

    [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
    _p9k_param $1 ICON_BEFORE_CONTENT ''
    if [[ $_p9k_ret != false ]]; then
      _p9k_param $1 PREFIX ''
      _p9k_ret=${(g::)_p9k_ret}
      _p9k_escape $_p9k_ret
      p+=$_p9k_ret
      [[ $_p9k_ret == *%* ]] && local -i need_style=1 || local -i need_style=0

      if (( has_icon != 0 )); then
        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k_ret
        _p9k_ret=%b$bg$_p9k_ret
        _p9k_ret=${_p9k_ret//\}/\\\}}
        [[ $_p9k_ret != $style_ || $need_style == 1 ]] && p+=$_p9k_ret
        p+='${_p9k_v}'

        _p9k_get_icon $1 LEFT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k_ret ]]; then
          _p9k_escape $_p9k_ret
          [[ _p9k_ret == *%* ]] && _p9k_ret+=$style_
          p+='${${(M)_p9k_e:#11}:+'$_p9k_ret'}'
        fi
      elif (( need_style )); then
        p+=$style_
      fi

      p+='${_p9k_c}'$style_
    else
      _p9k_param $1 PREFIX ''
      _p9k_ret=${(g::)_p9k_ret}
      _p9k_escape $_p9k_ret
      p+=$_p9k_ret
      [[ $_p9k_ret == *%* ]] && p+=$style_

      p+='${_p9k_c}'$style_

      if (( has_icon != 0 )); then
        local -i need_style=0
        _p9k_get_icon $1 LEFT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k_ret ]]; then
          _p9k_escape $_p9k_ret
          [[ $_p9k_ret == *%* ]] && need_style=1
          p+='${${(M)_p9k_e:#11}:+'$_p9k_ret'}'
        fi

        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k_ret
        _p9k_ret=%b$bg$_p9k_ret
        _p9k_ret=${_p9k_ret//\}/\\\}}
        [[ $_p9k_ret != $style_ || $need_style == 1 ]] && p+=$_p9k_ret
        p+='$_p9k_v'
      fi
    fi

    _p9k_param $1 SUFFIX ''
    _p9k_ret=${(g::)_p9k_ret}
    _p9k_escape $_p9k_ret
    p+=$_p9k_ret
    [[ $_p9k_ret == *%* && -n $right_space_ ]] && p+=$style_
    p+=$right_space_

    p+='${${:-'
    p+="\${_p9k_s::=%F{$bg_color\}$sep_}\${_p9k_ss::=$subsep_}\${_p9k_sss::=%F{$bg_color\}$end_sep_}"
    p+="\${_p9k_i::=$_p9k_segment_index}\${_p9k_bg::=$bg_color}"
    p+='}+}'

    p+='}'

    _p9k_cache_set "$p" $non_hermetic
  fi

  _p9k_non_hermetic_expansion=$_p9k_cache_val[2]

  (( $5 )) && _p9k_ret=\"$7\" || _p9k_escape $7
  if [[ -z $6 ]]; then
    _p9k__prompt+="\${\${:-\${P9K_CONTENT::=$_p9k_ret}$_p9k_cache_val[1]"
  else
    _p9k__prompt+="\${\${:-\"$6\"}:+\${\${:-\${P9K_CONTENT::=$_p9k_ret}$_p9k_cache_val[1]}"
  fi
}

# The same as _p9k_left_prompt_segment above but for the right prompt.
_p9k_right_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$_p9k_segment_index"; then
    _p9k_color $1 BACKGROUND $2
    local bg_color=$_p9k_ret
    _p9k_background $bg_color
    local bg=$_p9k_ret
    local bg_=${_p9k_ret//\}/\\\}}

    _p9k_color $1 FOREGROUND $3
    local fg_color=$_p9k_ret
    _p9k_foreground $fg_color
    local fg=$_p9k_ret

    _p9k_get_icon $1 RIGHT_SEGMENT_SEPARATOR
    local sep=$_p9k_ret
    _p9k_escape $_p9k_ret
    local sep_=$_p9k_ret

    _p9k_get_icon $1 RIGHT_SUBSEGMENT_SEPARATOR
    local subsep=$_p9k_ret

    local icon_
    if [[ -n $4 ]]; then
      _p9k_get_icon $1 $4
      _p9k_escape $_p9k_ret
      icon_=$_p9k_ret
    fi

    _p9k_get_icon $1 RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL $sep
    local start_sep=$_p9k_ret
    [[ -n $start_sep ]] && start_sep="%b%k%F{$bg_color}$start_sep"

    _p9k_get_icon $1 RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL
    _p9k_escape $_p9k_ret
    local end_sep_=$_p9k_ret

    local style=%b$bg$fg
    local style_=${style//\}/\\\}}

    _p9k_get_icon $1 WHITESPACE_BETWEEN_RIGHT_SEGMENTS ' '
    local space=$_p9k_ret

    _p9k_get_icon $1 RIGHT_LEFT_WHITESPACE $space
    local left_space=$_p9k_ret
    [[ $left_space == *%* ]] && left_space+=$style

    _p9k_get_icon $1 RIGHT_RIGHT_WHITESPACE $space
    _p9k_escape $_p9k_ret
    local right_space_=$_p9k_ret
    [[ $right_space_ == *%* ]] && right_space_+=$style_

    local w='<_p9k_w>' s='<_p9k_s>'

    local -i non_hermetic=0

    # Segment separator logic:
    #
    #   if [[ $_p9k_bg == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $_p9k_bg == (${bg_color}|${bg_color:-0}) ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$(($#_p9k_t - __p9k_ksh_arrays))
    _p9k_t+=$start_sep$style$left_space           # 1
    _p9k_t+=$w$style                              # 2
    _p9k_t+=$w$subsep$style$left_space            # 3
    _p9k_t+=$w%F{$bg_color}$sep$style$left_space  # 4

    local join="_p9k_i>=$_p9k_right_join[$_p9k_segment_index]"
    _p9k_param $1 SELF_JOINED false
    if [[ $_p9k_ret == false ]]; then
      if (( _p9k_segment_index > $_p9k_right_join[$_p9k_segment_index] )); then
        join+="&&_p9k_i<$_p9k_segment_index"
      else
        join=
      fi
    fi

    local p=
    p+="\${_p9k_n::=}"
    p+="\${\${\${_p9k_bg:-0}:#NONE}:-\${_p9k_n::=$((t+1))}}"                                      # 1
    if [[ -n $join ]]; then
      p+="\${_p9k_n:=\${\${\$(($join)):#0}:+$((t+2))}}"                                           # 2
    fi
    if (( __p9k_sh_glob )); then
      p+="\${_p9k_n:=\${\${(M)\${:-x\$_p9k_bg}:#x${(b)bg_color}}:+$((t+3))}}"                     # 3
      p+="\${_p9k_n:=\${\${(M)\${:-x\$_p9k_bg}:#x${(b)bg_color:-0}}:+$((t+3))}}"                  # 3
    else
      p+="\${_p9k_n:=\${\${(M)\${:-x\$_p9k_bg}:#x(${(b)bg_color}|${(b)bg_color:-0})}:+$((t+3))}}" # 3
    fi
    p+="\${_p9k_n:=$((t+4))}"                                                                     # 4

    _p9k_param $1 VISUAL_IDENTIFIER_EXPANSION '${P9K_VISUAL_IDENTIFIER}'
    [[ $_p9k_ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local icon_exp_=${_p9k_ret:+\"$_p9k_ret\"}

    _p9k_param $1 CONTENT_EXPANSION '${P9K_CONTENT}'
    [[ $_p9k_ret == (|*[^\\])'$('* ]] && non_hermetic=1
    local content_exp_=${_p9k_ret:+\"$_p9k_ret\"}

    if [[ ( $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ) ||
          ( $content_exp_ != '"${P9K_CONTENT}"' && $content_exp_ == *'$'* ) ]]; then
      p+="\${P9K_VISUAL_IDENTIFIER::=$icon_}"
    fi

    local -i has_icon=-1  # maybe

    if [[ $icon_exp_ != '"${P9K_VISUAL_IDENTIFIER}"' && $icon_exp_ == *'$'* ]]; then
      p+="\${_p9k_v::=$icon_exp_$style_}"
    else
      [[ $icon_exp_ == '"${P9K_VISUAL_IDENTIFIER}"' ]] && _p9k_ret=$icon_ || _p9k_ret=$icon_exp_
      if [[ -n $_p9k_ret ]]; then
        p+="\${_p9k_v::=$_p9k_ret"
        [[ $_p9k_ret == *%* ]] && p+=$style_
        p+="}"
        has_icon=1  # definitely yes
      else
        has_icon=0  # definitely no
      fi
    fi

    p+="\${_p9k_c::=$content_exp_}"
    p+='${_p9k_e::=${${_p9k__'${_p9k_line_index}r${${1#prompt_}%%[A-Z_]#}'+00}:-'
    if (( has_icon == -1 )); then
      p+='${${(%):-$_p9k_c%1(l.1.0)}[-1]}${${(%):-$_p9k_v%1(l.1.0)}[-1]}}'
    else
      p+='${${(%):-$_p9k_c%1(l.1.0)}[-1]}'$has_icon'}'
    fi

    p+='}}+}'

    p+='${${_p9k_e:#00}:+${_p9k_t[$_p9k_n]/'$w'/$_p9k_w}'

    [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
    _p9k_param $1 ICON_BEFORE_CONTENT ''
    if [[ $_p9k_ret != true ]]; then
      _p9k_param $1 PREFIX ''
      _p9k_ret=${(g::)_p9k_ret}
      _p9k_escape $_p9k_ret
      p+=$_p9k_ret
      [[ $_p9k_ret == *%* ]] && p+=$style_

      p+='${_p9k_c}'$style_

      if (( has_icon != 0 )); then
        local -i need_style=0
        _p9k_get_icon $1 RIGHT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k_ret ]]; then
          _p9k_escape $_p9k_ret
          [[ $_p9k_ret == *%* ]] && need_style=1
          p+='${${(M)_p9k_e:#11}:+'$_p9k_ret'}'
        fi

        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k_ret
        _p9k_ret=%b$bg$_p9k_ret
        _p9k_ret=${_p9k_ret//\}/\\\}}
        [[ $_p9k_ret != $style_ || $need_style == 1 ]] && p+=$_p9k_ret
        p+='$_p9k_v'
      fi
    else
      _p9k_param $1 PREFIX ''
      _p9k_ret=${(g::)_p9k_ret}
      _p9k_escape $_p9k_ret
      p+=$_p9k_ret
      [[ $_p9k_ret == *%* ]] && local -i need_style=1 || local -i need_style=0

      if (( has_icon != 0 )); then
        _p9k_color $1 VISUAL_IDENTIFIER_COLOR $fg_color
        _p9k_foreground $_p9k_ret
        _p9k_ret=%b$bg$_p9k_ret
        _p9k_ret=${_p9k_ret//\}/\\\}}
        [[ $_p9k_ret != $style_ || $need_style == 1 ]] && p+=$_p9k_ret
        p+='${_p9k_v}'

        _p9k_get_icon $1 RIGHT_MIDDLE_WHITESPACE ' '
        if [[ -n $_p9k_ret ]]; then
          _p9k_escape $_p9k_ret
          [[ _p9k_ret == *%* ]] && _p9k_ret+=$style_
          p+='${${(M)_p9k_e:#11}:+'$_p9k_ret'}'
        fi
      elif (( need_style )); then
        p+=$style_
      fi

      p+='${_p9k_c}'$style_
    fi

    _p9k_param $1 SUFFIX ''
    _p9k_ret=${(g::)_p9k_ret}
    _p9k_escape $_p9k_ret
    p+=$_p9k_ret

    p+='${${:-'

    if [[ -n $fg_color && $fg_color == $bg_color ]]; then
      if [[ $fg_color == $_p9k_color1 ]]; then
        _p9k_foreground $_p9k_color2
      else
        _p9k_foreground $_p9k_color1
      fi
    else
      _p9k_ret=$fg
    fi
    _p9k_ret=${_p9k_ret//\}/\\\}}
    p+="\${_p9k_w::=${right_space_:+$style_}$right_space_%b$bg_$_p9k_ret}"

    p+='${_p9k_sss::='
    p+=$style_$right_space_
    [[ $right_space_ == *%* ]] && p+=$style_
    if [[ -n $end_sep_ ]]; then
      p+="%k%F{$bg_color\}$end_sep_$style_"
    fi
    p+='}'

    p+="\${_p9k_i::=$_p9k_segment_index}\${_p9k_bg::=$bg_color}"

    p+='}+}'
    p+='}'

    _p9k_cache_set "$p" $non_hermetic
  fi

  _p9k_non_hermetic_expansion=$_p9k_cache_val[2]

  (( $5 )) && _p9k_ret=\"$7\" || _p9k_escape $7
  if [[ -z $6 ]]; then
    _p9k__prompt+="\${\${:-\${P9K_CONTENT::=$_p9k_ret}$_p9k_cache_val[1]"
  else
    _p9k__prompt+="\${\${:-\"$6\"}:+\${\${:-\${P9K_CONTENT::=$_p9k_ret}$_p9k_cache_val[1]}"
  fi
}

function _p9k_prompt_segment() { "_p9k_${_p9k_prompt_side}_prompt_segment" "$@" }
function p9k_prompt_segment() { p10k segment "$@" }

function _p9k_python_version() {
  _p9k_cached_cmd_stdout_stderr python --version || return
  [[ $_p9k_ret == (#b)Python\ ([[:digit:].]##)* ]] && _p9k_ret=$match[1]
}

################################################################
# Prompt Segment Definitions
################################################################

################################################################
# Anaconda Environment
prompt_anaconda() {
  local p=${CONDA_PREFIX:-$CONDA_ENV_PATH}
  [[ -n $p ]] || return
  local msg=''
  if (( _POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION )) && _p9k_python_version; then
    msg="${_p9k_ret//\%//%%} "
  fi
  msg+="$_POWERLEVEL9K_ANACONDA_LEFT_DELIMITER${${p:t}//\%/%%}$_POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER"
  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "$msg"
}

################################################################
# AWS Profile
prompt_aws() {
  local aws_profile="${AWS_VAULT:-${AWSUME_PROFILE:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}}"
  if [[ -n "$aws_profile" ]]; then
    local pat class
    for pat class in "${_POWERLEVEL9K_AWS_CLASSES[@]}"; do
      if [[ $aws_profile == ${~pat} ]]; then
        [[ -n $class ]] && state=_${(U)class}
        break
      fi
    done

    _p9k_prompt_segment "$0$state" red white 'AWS_ICON' 0 '' "${aws_profile//\%/%%}"
  fi
}

################################################################
# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  (( $+commands[eb] )) || return

  local dir=$_p9k_pwd
  while true; do
    [[ $dir == / ]] && return
    [[ -d $dir/.elasticbeanstalk ]] && break
    dir=${dir:h}
  done

  if ! _p9k_cache_stat_get $0 $dir/.elasticbeanstalk/config.yml; then
    local env
    env="$(command eb list 2>/dev/null)" || env=
    env="${${(@M)${(@f)env}:#\* *}#\* }"
    _p9k_cache_stat_set "$env"
  fi
  [[ -n $_p9k_cache_val[1] ]] || return
  _p9k_prompt_segment "$0" black green 'AWS_EB_ICON' 0 '' "${_p9k_cache_val[1]//\%/%%}"
}

################################################################
# Segment to indicate background jobs with an icon.
prompt_background_jobs() {
  local msg
  if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE )); then
    if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS )); then
      msg='${(%):-%j}'
    else
      msg='${${(%):-%j}:#1}'
    fi
  fi
  _p9k_prompt_segment $0 "$_p9k_color1" cyan BACKGROUND_JOBS_ICON 1 '${${(%):-%j}:#0}' "$msg"
}

################################################################
# Segment that indicates usage level of current partition.
prompt_disk_usage() {
  (( $+commands[df] )) || return
  local disk_usage=${${=${(f)"$(df -P . 2>/dev/null)"}[2]}[5]%%%}
  local state bg fg
  if (( disk_usage >= _POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL )); then
    state=critical
    bg=red
    fg=white
  elif (( disk_usage >= _POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL )); then
    state=warning
    bg=yellow
    fg=$_p9k_color1
  else
    (( _POWERLEVEL9K_DISK_USAGE_ONLY_WARNING )) && return
    state=normal
    bg=$_p9k_color1
    fg=yellow
  fi
  _p9k_prompt_segment $0_$state $bg $fg DISK_ICON 0 '' "$disk_usage%%"
}

function _p9k_read_file() {
  _p9k_ret=''
  [[ -n $1 ]] && IFS='' read -r _p9k_ret <$1
  [[ -n $_p9k_ret ]]
}

prompt_fvm() {
  (( $+commands[fvm] )) || return
  local dir=$_p9k_pwd_a
  while [[ $dir != / ]]; do
    local link=$dir/fvm
    if [[ -L $link ]]; then
      if [[ ${link:A} == (#b)*/versions/([^/]##)/bin/flutter ]]; then
        _p9k_prompt_segment $0 blue $_p9k_color1 FLUTTER_ICON 0 '' ${match[1]//\%/%%}
      fi
      return
    fi
    dir=${dir:h}
  done
}

################################################################
# Segment that displays the battery status in levels and colors
prompt_battery() {
  local state remain
  local -i bat_percent

  case $_p9k_os in
    OSX)
      (( $+commands[pmset] )) || return
      local raw_data=${${(f)"$(pmset -g batt 2>/dev/null)"}[2]}
      [[ $raw_data == *InternalBattery* ]] || return
      remain=${${(s: :)${${(s:; :)raw_data}[3]}}[1]}
      [[ $remain == *no* ]] && remain="..."
      [[ $raw_data =~ '([0-9]+)%' ]] && bat_percent=$match[1]

      case "${${(s:; :)raw_data}[2]}" in
        'charging'|'finishing charge'|'AC attached')
          if (( bat_percent == 100 )); then
            state=CHARGED
            remain=''
          else
            state=CHARGING
          fi
        ;;
        'discharging')
          (( bat_percent < _POWERLEVEL9K_BATTERY_LOW_THRESHOLD )) && state=LOW || state=DISCONNECTED
        ;;
        *)
          state=CHARGED
          remain=''
        ;;
      esac
    ;;

    Linux|Android)
      local -a bats=( /sys/class/power_supply/(BAT*|battery)/(FN) )
      (( $#bats )) || return

      local -i energy_now energy_full power_now
      local -i is_full=1 is_calculating is_charching
      local dir
      for dir in $bats; do
        local -i pow=0 full=0
        if _p9k_read_file $dir/(energy_full|charge_full|charge_counter)(N); then
          (( energy_full += ${full::=_p9k_ret} ))
        fi
        if _p9k_read_file $dir/(power|current)_now(N) && (( $#_p9k_ret < 9 )); then
          (( power_now += ${pow::=$_p9k_ret} ))
        fi
        if _p9k_read_file $dir/(energy|charge)_now(N); then
          (( energy_now += _p9k_ret ))
        elif _p9k_read_file $dir/capacity(N); then
          (( energy_now += _p9k_ret * full / 100. + 0.5 ))
        fi
        _p9k_read_file $dir/status(N) && local bat_status=$_p9k_ret || continue
        [[ $bat_status != Full                                ]] && is_full=0
        [[ $bat_status == Charging                            ]] && is_charching=1
        [[ $bat_status == (Charging|Discharging) && $pow == 0 ]] && is_calculating=1
      done

      (( energy_full )) || return

      bat_percent=$(( 100. * energy_now / energy_full + 0.5 ))
      (( bat_percent > 100 )) && bat_percent=100

      if (( is_full || (bat_percent == 100 && is_charching) )); then
        state=CHARGED
      else
        if (( is_charching )); then
          state=CHARGING
        elif (( bat_percent < _POWERLEVEL9K_BATTERY_LOW_THRESHOLD )); then
          state=LOW
        else
          state=DISCONNECTED
        fi

        if (( power_now > 0 )); then
          (( is_charching )) && local -i e=$((energy_full - energy_now)) || local -i e=energy_now
          local -i minutes=$(( 60 * e / power_now ))
          (( minutes > 0 )) && remain=$((minutes/60)):${(l#2##0#)$((minutes%60))}
        elif (( is_calculating )); then
          remain="..."
        fi
      fi
    ;;

    *)
      return 0
    ;;
  esac

  (( bat_percent >= _POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD )) && return

  local msg="$bat_percent%%"
  [[ $_POWERLEVEL9K_BATTERY_VERBOSE == 1 && -n $remain ]] && msg+=" ($remain)"

  local icon=BATTERY_ICON
  if (( $#_POWERLEVEL9K_BATTERY_STAGES )); then
    local -i idx=$#_POWERLEVEL9K_BATTERY_STAGES
    (( bat_percent < 100 )) && idx=$((bat_percent * $#_POWERLEVEL9K_BATTERY_STAGES / 100 + 1))
    icon=$'\1'$_POWERLEVEL9K_BATTERY_STAGES[idx]
  fi

  local bg=$_p9k_color1
  if (( $#_POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND )); then
    local -i idx=$#_POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND
    (( bat_percent < 100 )) && idx=$((bat_percent * $#_POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND / 100 + 1))
    bg=$_POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND[idx]
  fi

  local fg=$_p9k_battery_states[$state]
  if (( $#_POWERLEVEL9K_BATTERY_LEVEL_FOREGROUND )); then
    local -i idx=$#_POWERLEVEL9K_BATTERY_LEVEL_FOREGROUND
    (( bat_percent < 100 )) && idx=$((bat_percent * $#_POWERLEVEL9K_BATTERY_LEVEL_FOREGROUND / 100 + 1))
    fg=$_POWERLEVEL9K_BATTERY_LEVEL_FOREGROUND[idx]
  fi

  _p9k_prompt_segment $0_$state "$bg" "$fg" $icon 0 '' $msg
}

################################################################
# Public IP segment
prompt_public_ip() {
  local icon='PUBLIC_IP_ICON'
  if [[ -n $_POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]]; then
    _p9k_parse_ip $_POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE && icon='VPN_ICON'
  fi

  local ip='${_p9k__public_ip:-$_POWERLEVEL9K_PUBLIC_IP_NONE}'
  _p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" "$icon" 1  $ip $ip
}

################################################################
# Context: user@hostname (who am I and where am I)
prompt_context() {
  if ! _p9k_cache_get $0 "${(%):-%#}"; then
    local -i enabled=1
    local content
    if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]; then
      local user="${(%):-%n}"
      if [[ $user == $DEFAULT_USER ]]; then
        if (( _POWERLEVEL9K_ALWAYS_SHOW_USER )); then
          content="${user//\%/%%}"
        else
          enabled=0
        fi
      fi
    fi

    local state
    if (( enabled )); then
      state="DEFAULT"
      if [[ "${(%):-%#}" == '#' ]]; then
        state="ROOT"
      elif (( P9K_SSH )); then
        if [[ -n "$SUDO_COMMAND" ]]; then
          state="REMOTE_SUDO"
        else
          state="REMOTE"
        fi
      elif [[ -n "$SUDO_COMMAND" ]]; then
        state="SUDO"
      fi

      if [[ -z $content ]]; then
        local var=_POWERLEVEL9K_CONTEXT_${state}_TEMPLATE
        if (( $+parameters[$var] )); then
          [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
          content=${(P)var}
          content=${(g::)content}
        else
          content=$_POWERLEVEL9K_CONTEXT_TEMPLATE
        fi
      fi
    fi

    _p9k_cache_set "$enabled" "$state" "$content"
  fi

  (( _p9k_cache_val[1] )) || return
  _p9k_prompt_segment "$0_$_p9k_cache_val[2]" "$_p9k_color1" yellow '' 0 '' "$_p9k_cache_val[3]"
}

instant_prompt_context() { prompt_context; }

################################################################
# User: user (who am I)
prompt_user() {
  if ! _p9k_cache_get $0 "${(%):-%#}"; then
    local user="${(%):-%n}"
    if [[ $_POWERLEVEL9K_ALWAYS_SHOW_USER == 0 && $user == $DEFAULT_USER ]]; then
      _p9k_cache_set true
    elif [[ "${(%):-%#}" == '#' ]]; then
      _p9k_cache_set _p9k_prompt_segment "${0}_ROOT" "${_p9k_color1}" yellow ROOT_ICON 0 '' "$_POWERLEVEL9K_USER_TEMPLATE"
    elif [[ -n "$SUDO_COMMAND" ]]; then
      _p9k_cache_set _p9k_prompt_segment "${0}_SUDO" "${_p9k_color1}" yellow SUDO_ICON 0 '' "$_POWERLEVEL9K_USER_TEMPLATE"
    else
      _p9k_cache_set _p9k_prompt_segment "${0}_DEFAULT" "${_p9k_color1}" yellow USER_ICON 0 '' "${user//\%/%%}"
    fi
  fi
  "$_p9k_cache_val[@]"
}

instant_prompt_user() { prompt_user; }

################################################################
# Host: machine (where am I)
prompt_host() {
  if (( P9K_SSH )); then
    _p9k_prompt_segment "$0_REMOTE" "${_p9k_color1}" yellow SSH_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
  else
    _p9k_prompt_segment "$0_LOCAL" "${_p9k_color1}" yellow HOST_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
  fi
}

instant_prompt_host() { prompt_host; }

################################################################
# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
_p9k_custom_prompt() {
  local segment_name=${1:u}
  local command=_POWERLEVEL9K_CUSTOM_${segment_name}
  command=${(P)command}
  local cmd="${(Q)${(Az)command}[1]}"
  (( $+functions[$cmd] || $+commands[$cmd] )) || return
  local content="$(eval $command)"
  [[ -n $content ]] || return
  _p9k_prompt_segment "prompt_custom_$segment_name" $_p9k_color2 $_p9k_color1 "CUSTOM_${segment_name}_ICON" 0 '' "$content"
}

################################################################
# Display the duration the command needed to run.
prompt_command_execution_time() {
  (( $+P9K_COMMAND_DURATION_SECONDS )) || return
  (( P9K_COMMAND_DURATION_SECONDS >= _POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD )) || return

  if (( P9K_COMMAND_DURATION_SECONDS < 60 )); then
    if (( !_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION )); then
      local -i sec=$((P9K_COMMAND_DURATION_SECONDS + 0.5))
    else
      local -F $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION sec=P9K_COMMAND_DURATION_SECONDS
    fi
    local text=${sec}s
  else
    local -i d=$((P9K_COMMAND_DURATION_SECONDS + 0.5))
    if [[ $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT == "H:M:S" ]]; then
      local text=${(l.2..0.)$((d % 60))}
      if (( d >= 60 )); then
        text=${(l.2..0.)$((d / 60 % 60))}:$text
        if (( d >= 36000 )); then
          text=$((d / 3600)):$text
        elif (( d >= 3600 )); then
          text=0$((d / 3600)):$text
        fi
      fi
    else
      local text="$((d % 60))s"
      if (( d >= 60 )); then
        text="$((d / 60 % 60))m $text"
        if (( d >= 3600 )); then
          text="$((d / 3600 % 24))h $text"
          if (( d >= 86400 )); then
            text="$((d / 86400))d $text"
          fi
        fi
      fi
    fi
  fi

  _p9k_prompt_segment "$0" "red" "yellow1" 'EXECUTION_TIME_ICON' 0 '' $text
}

function _p9k_shorten_delim_len() {
  local def=$1
  _p9k_ret=${_POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
  (( _p9k_ret >= 0 )) || _p9k_prompt_length $1
}

################################################################
# Dir: current working directory
prompt_dir() {
  if (( _POWERLEVEL9K_DIR_PATH_ABSOLUTE )); then
    local p=$_p9k_pwd
    local -a parts=("${(s:/:)p}")
  elif [[ -o auto_name_dirs ]]; then
    local p=${_p9k_pwd/#(#b)$HOME(|\/*)/'~'$match[1]}
    local -a parts=("${(s:/:)p}")
  else
    local p=${(%):-%~}
    if [[ $p == '~['* ]]; then
      # If "${(%):-%~}" expands to "~[a]/]/b", is the first component "~[a]" or "~[a]/]"?
      # One would expect "${(%):-%-1~}" to give the right answer but alas it always simply
      # gives the segment before the first slash, which would be "~[a]" in this case. Worse,
      # for "~[a/b]" it'll give the nonsensical "~[a". To solve this problem we have to
      # repeat what "${(%):-%~}" does and hope that it produces the same result.
      local func=''
      local -a parts=()
      for func in zsh_directory_name $zsh_directory_name_functions; do
        if (( $+functions[$func] )) && $func d $_p9k_pwd && [[ $p == '~['$reply[1]']'* ]]; then
          parts+='~['$reply[1]']'
          break
        fi
      done
      if (( $#parts )); then
        parts+=(${(s:/:)${p#$parts[1]}})
      else
        p=$_p9k_pwd
        parts=("${(s:/:)p}")
      fi
    else
      local -a parts=("${(s:/:)p}")
    fi
  fi

  local -i fake_first=0 expand=0
  [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
  local delim=${_POWERLEVEL9K_SHORTEN_DELIMITER-$'\u2026'}
  local -i shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:--1}

  case $_POWERLEVEL9K_SHORTEN_STRATEGY in
    truncate_absolute|truncate_absolute_chars)
      if (( shortenlen > 0 && $#p > shortenlen )); then
        _p9k_shorten_delim_len $delim
        if (( $#p > shortenlen + $_p9k_ret )); then
          local -i n=shortenlen
          local -i i=$#parts
          while true; do
            local dir=$parts[i]
            local -i len=$(( $#dir + (i > 1) ))
            if (( len <= n )); then
              (( n -= len ))
              (( --i ))
            else
              parts[i]=$'\1'$dir[-n,-1]
              parts[1,i-1]=()
              break
            fi
          done
        fi
      fi
    ;;
    truncate_with_package_name|truncate_middle|truncate_from_right)
      () {
        [[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name &&
           $+commands[jq] == 1 && $#_POWERLEVEL9K_DIR_PACKAGE_FILES > 0 ]] || return
        local pats="(${(j:|:)_POWERLEVEL9K_DIR_PACKAGE_FILES})"
        local -i i=$#parts
        local dir=$_p9k_pwd
        for (( ; i > 0; --i )); do
          local markers=($dir/${~pats}(N))
          if (( $#markers )); then
            local pat= pkg_file=
            for pat in $_POWERLEVEL9K_DIR_PACKAGE_FILES; do
              for pkg_file in $markers; do
                [[ $pkg_file == $dir/${~pat} ]] || continue
                if ! _p9k_cache_stat_get $0_pkg $pkg_file; then
                  local pkg_name=''
                  pkg_name="$(jq -j '.name | select(. != null)' <$pkg_file 2>/dev/null)" || pkg_name=''
                  _p9k_cache_stat_set "$pkg_name"
                fi
                [[ -n $_p9k_cache_val[1] ]] || continue
                parts[1,i]=($_p9k_cache_val[1])
                fake_first=1
                return 0
              done
            done
          fi
          dir=${dir:h}
        done
      }
      if (( shortenlen > 0 )); then
        _p9k_shorten_delim_len $delim
        local -i d=_p9k_ret pref=shortenlen suf=0 i=2
        [[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_middle ]] && suf=pref
        for (( ; i < $#parts; ++i )); do
          local dir=$parts[i]
          if (( $#dir > pref + suf + d )); then
            dir[pref+1,-suf-1]=$'\1'
            parts[i]=$dir
          fi
        done
      fi
    ;;
    truncate_to_last)
      fake_first=$(($#parts > 1))
      parts[1,-2]=()
    ;;
    truncate_to_first_and_last)
      if (( shortenlen > 0 )); then
        local -i i=$(( shortenlen + 1 ))
        [[ $p == /* ]] && (( ++i ))
        for (( ; i <= $#parts - shortenlen; ++i )); do
          parts[i]=$'\1'
        done
      fi
    ;;
    truncate_to_unique)
      expand=1
      delim=${_POWERLEVEL9K_SHORTEN_DELIMITER-'*'}
      shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1}
      (( shortenlen >= 0 )) || shortenlen=1
      local -i i=2 e=$(($#parts - shortenlen))
      [[ $p[1] == / ]] && (( ++i ))
      local parent="${_p9k_pwd%/${(pj./.)parts[i,-1]}}"
      if (( i <= e )); then
        local MATCH= mtimes=()
        zstat -A mtimes +mtime -- ${(@)${:-{$i..$e}}/(#m)*/$parent/${(pj./.)parts[i,$MATCH]}} 2>/dev/null || mtimes=()
        local key="${(pj.:.)mtimes}"
      else
        local key='good'
      fi
      if ! _p9k_cache_ephemeral_get $0 $e $i $_p9k_pwd || [[ $key != $_p9k_cache_val[1] ]] ; then
        _p9k_prompt_length $delim
        local -i real_delim_len=_p9k_ret
        [[ -n $parts[i-1] ]] && parts[i-1]="\${(Q)\${:-${(qqq)${(q)parts[i-1]}}}}"$'\2'
        local -i d=${_POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
        (( d >= 0 )) || d=real_delim_len
        local -i m=1
        for (( ; i <= e; ++i, ++m )); do
          local sub=$parts[i]
          local dir=$parent/$sub mtime=$mtimes[m]
          local pair=$_p9k__dir_stat_cache[$dir]
          if [[ $pair == ${mtime:-x}:* ]]; then
            parts[i]=${pair#*:}
          else
            [[ $sub != *["~!#\$^&*()\\\"'<>?{}[]"]* ]]
            local -i q=$?
            if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER &&
                  -n $parent/$sub/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]]; then
              (( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}"
              parts[i]+=$'\2'
            else
              local -i j=1
              for (( ; j + d < $#sub; ++j )); do
                local -a matching=($parent/$sub[1,j]*/(N))
                (( $#matching == 1 )) && break
              done
              local -i saved=$(($#sub - j - d))
              if (( saved > 0 )); then
                if (( q )); then
                  parts[i]='${${${_p9k_d:#-*}:+${(Q)${:-'${(qqq)${(q)sub}}'}}}:-${(Q)${:-'
                  parts[i]+=$'\3'${(qqq)${(q)sub[1,j]}}$'}}\1\3''${$((_p9k_d+='$saved'))+}}'
                else
                  parts[i]='${${${_p9k_d:#-*}:+'$sub$'}:-\3'$sub[1,j]$'\1\3''${$((_p9k_d+='$saved'))+}}'
                fi
              else
                (( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}"
              fi
            fi
            [[ -n $mtime ]] && _p9k__dir_stat_cache[$dir]="$mtime:$parts[i]"
          fi
          parent+=/$sub
        done
        for ((; i <= $#parts; ++i)); do
          [[ $parts[i] == *["~!#\$^&*()\\\"'<>?{}[]"]* ]] && parts[i]='${(Q)${:-'${(qqq)${(q)parts[i]}}'}}'
          parts[i]+=$'\2'
        done
        [[ -n $key ]] && _p9k_cache_ephemeral_set "$key" "${parts[@]}"
      fi
      parts=("${(@)_p9k_cache_val[2,-1]}")
    ;;
    truncate_with_folder_marker)
      if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER ]]; then
        local dir=$_p9k_pwd
        local -a m=()
        local -i i=$(($#parts - 1))
        for (( ; i > 1; --i )); do
          dir=${dir:h}
          [[ -n $dir/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]] && m+=$i
        done
        m+=1
        for (( i=1; i < $#m; ++i )); do
          (( m[i] - m[i+1] > 2 )) && parts[m[i+1]+1,m[i]-1]=($'\1')
        done
      fi
    ;;
    *)
      if (( shortenlen > 0 )); then
        local -i len=$#parts
        [[ -z $parts[1] ]] && (( --len ))
        if (( len > shortenlen )); then
          parts[1,-shortenlen-1]=($'\1')
        fi
      fi
    ;;
  esac

  [[ $_POWERLEVEL9K_DIR_SHOW_WRITABLE == 1 && ! -w $_p9k_pwd ]]
  local w=$?
  if ! _p9k_cache_ephemeral_get $0 $_p9k_pwd $p $w $fake_first "${parts[@]}"; then
    local state=$0
    local icon=''
    if (( ! w )); then
      state+=_NOT_WRITABLE
      icon=LOCK_ICON
    else
      local a='' b='' c=''
      for a b c in "${_POWERLEVEL9K_DIR_CLASSES[@]}"; do
        if [[ $_p9k_pwd == ${~a} ]]; then
          [[ -n $b ]] && state+=_${(U)b}
          icon=$'\1'$c
          break
        fi
      done
    fi

    local style=%b
    _p9k_color $state BACKGROUND blue
    _p9k_background $_p9k_ret
    style+=$_p9k_ret
    _p9k_color $state FOREGROUND "$_p9k_color1"
    _p9k_foreground $_p9k_ret
    style+=$_p9k_ret
    if (( expand )); then
      _p9k_escape_style $style
      style=$_p9k_ret
    fi

    parts=("${(@)parts//\%/%%}")
    if [[ $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION != '~' && $fake_first == 0 && $p == ('~'|'~/'*) ]]; then
      (( expand )) && _p9k_escape $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION || _p9k_ret=$_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
      parts[1]=$_p9k_ret
      [[ $_p9k_ret == *%* ]] && parts[1]+=$style
    fi
    [[ $_POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == 1 && $#parts > 1 && -n $parts[2] ]] && parts[1]=()

    local last_style=
    (( _POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD )) && last_style+=%B
    if (( $+_POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND )); then
      _p9k_translate_color $_POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
      _p9k_foreground $_p9k_ret
      last_style+=$_p9k_ret
    fi
    if [[ -n $last_style ]]; then
      (( expand )) && _p9k_escape_style $last_style || _p9k_ret=$last_style
      parts[-1]=$_p9k_ret${parts[-1]//$'\1'/$'\1'$_p9k_ret}$style
    fi

    local anchor_style=
    (( _POWERLEVEL9K_DIR_ANCHOR_BOLD )) && anchor_style+=%B
    if (( $+_POWERLEVEL9K_DIR_ANCHOR_FOREGROUND )); then
      _p9k_translate_color $_POWERLEVEL9K_DIR_ANCHOR_FOREGROUND
      _p9k_foreground $_p9k_ret
      anchor_style+=$_p9k_ret
    fi
    if [[ -n $anchor_style ]]; then
      (( expand )) && _p9k_escape_style $anchor_style || _p9k_ret=$anchor_style
      if [[ -z $last_style ]]; then
        parts=("${(@)parts/%(#b)(*)$'\2'/$_p9k_ret$match[1]$style}")
      else
        (( $#parts > 1 )) && parts[1,-2]=("${(@)parts[1,-2]/%(#b)(*)$'\2'/$_p9k_ret$match[1]$style}")
        parts[-1]=${parts[-1]/$'\2'}
      fi
    else
      parts=("${(@)parts/$'\2'}")
    fi

    if (( $+_POWERLEVEL9K_DIR_SHORTENED_FOREGROUND )); then
      _p9k_translate_color $_POWERLEVEL9K_DIR_SHORTENED_FOREGROUND
      _p9k_foreground $_p9k_ret
      (( expand )) && _p9k_escape_style $_p9k_ret
      local shortened_fg=$_p9k_ret
      (( expand )) && _p9k_escape $delim || _p9k_ret=$delim
      [[ $_p9k_ret == *%* ]] && _p9k_ret+=$style$shortened_fg
      parts=("${(@)parts/(#b)$'\3'(*)$'\1'(*)$'\3'/$shortened_fg$match[1]$_p9k_ret$match[2]$style}")
      parts=("${(@)parts/(#b)(*)$'\1'(*)/$shortened_fg$match[1]$_p9k_ret$match[2]$style}")
    else
      (( expand )) && _p9k_escape $delim || _p9k_ret=$delim
      [[ $_p9k_ret == *%* ]] && _p9k_ret+=$style
      parts=("${(@)parts/$'\1'/$_p9k_ret}")
      parts=("${(@)parts//$'\3'}")
    fi

    local sep=''
    if (( $+_POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND )); then
      _p9k_translate_color $_POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND
      _p9k_foreground $_p9k_ret
      (( expand )) && _p9k_escape_style $_p9k_ret
      sep=$_p9k_ret
    fi
    (( expand )) && _p9k_escape $_POWERLEVEL9K_DIR_PATH_SEPARATOR || _p9k_ret=$_POWERLEVEL9K_DIR_PATH_SEPARATOR
    sep+=$_p9k_ret
    [[ $sep == *%* ]] && sep+=$style

    local content="${(pj.$sep.)parts}"
    if (( _POWERLEVEL9K_DIR_HYPERLINK )); then
      local pref=$'%{\e]8;;file://'${${_p9k_pwd//\%/%%25}//'#'/%%23}$'\a%}'
      local suf=$'%{\e]8;;\a%}'
      if (( expand )); then
        _p9k_escape $pref
        pref=$_p9k_ret
        _p9k_escape $suf
        suf=$_p9k_ret
      fi
      content=$pref$content$suf
    fi

    (( expand )) && _p9k_prompt_length "${(e):-"\${\${_p9k_d::=0}+}$content"}" || _p9k_ret=
    _p9k_cache_ephemeral_set "$state" "$icon" "$expand" "$content" $_p9k_ret
  fi

  if (( _p9k_cache_val[3] )); then
    if (( $+_p9k_dir )); then
      _p9k_cache_val[4]='${${_p9k_d::=-1024}+}'$_p9k_cache_val[4]
    else
      _p9k_dir=$_p9k_cache_val[4]
      _p9k_dir_len=$_p9k_cache_val[5]
      _p9k_cache_val[4]='%{d%}'$_p9k_cache_val[4]'%{d%}'
    fi
  fi
  _p9k_prompt_segment "$_p9k_cache_val[1]" "blue" "$_p9k_color1" "$_p9k_cache_val[2]" "$_p9k_cache_val[3]" "" "$_p9k_cache_val[4]"
}

instant_prompt_dir() { prompt_dir; }

################################################################
# Docker machine
prompt_docker_machine() {
  if [[ -n "$DOCKER_MACHINE_NAME" ]]; then
    _p9k_prompt_segment "$0" "magenta" "$_p9k_color1" 'SERVER_ICON' 0 '' "${DOCKER_MACHINE_NAME//\%/%%}"
  fi
}

################################################################
# GO prompt
prompt_go_version() {
  _p9k_cached_cmd_stdout go version || return
  local -a match
  [[ $_p9k_ret == (#b)*go([[:digit:].]##)* ]] || return
  local v=$match[1]
  if (( _POWERLEVEL9K_GO_VERSION_PROJECT_ONLY )); then
    local p=$GOPATH
    if [[ -z $p ]]; then
      if [[ -d $HOME/go ]]; then
        p=$HOME/go
      else
        p="$(go env GOPATH 2>/dev/null)" && [[ -n $p ]] || return
      fi
    fi
    if [[ $_p9k_pwd/ != $p/* && $_p9k_pwd_a/ != $p/* ]]; then
      local dir=$_p9k_pwd_a
      while true; do
        [[ $dir == / ]] && return
        [[ -e $dir/go.mod ]] && break
        dir=${dir:h}
      done
    fi
  fi
  _p9k_prompt_segment "$0" "green" "grey93" "GO_ICON" 0 '' "${v//\%/%%}"
}

################################################################
# Command number (in local history)
prompt_history() {
  _p9k_prompt_segment "$0" "grey50" "$_p9k_color1" '' 0 '' '%h'
}

################################################################
# Detection for virtualization (systemd based systems only)
prompt_detect_virt() {
  (( $+commands[systemd-detect-virt] )) || return
  local virt="$(systemd-detect-virt 2>/dev/null)"
  if [[ "$virt" == "none" ]]; then
    [[ "$(ls -di /)" != "2 /" ]] && virt="chroot"
  fi
  if [[ -n "${virt}" ]]; then
    _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" '' 0 '' "${virt//\%/%%}"
  fi
}

################################################################
# Segment to display the current IP address
prompt_ip() {
  _p9k_parse_ip $_POWERLEVEL9K_IP_INTERFACE || return
  _p9k_prompt_segment "$0" "cyan" "$_p9k_color1" 'NETWORK_ICON' 0 '' "${_p9k_ret//\%/%%}"
}

################################################################
# Segment to display if VPN is active
prompt_vpn_ip() {
  _p9k_parse_ip $_POWERLEVEL9K_VPN_IP_INTERFACE || return
  _p9k_prompt_segment "$0" "cyan" "$_p9k_color1" 'VPN_ICON' 0 '' "${_p9k_ret//\%/%%}"
}

################################################################
# Segment to display laravel version
prompt_laravel_version() {
  local laravel_version="$(php artisan --version 2> /dev/null)"
  if [[ -n "${laravel_version}" && "${laravel_version}" =~ "Laravel Framework" ]]; then
    # Strip out everything but the version
    laravel_version="${laravel_version//Laravel Framework /}"
    _p9k_prompt_segment "$0" "maroon" "white" 'LARAVEL_ICON' 0 '' "${laravel_version//\%/%%}"
  fi
}

################################################################
# Segment to display load
prompt_load() {
  local bucket=2
  case $_POWERLEVEL9K_LOAD_WHICH in
    1) bucket=1;;
    5) bucket=2;;
    15) bucket=3;;
  esac

  local load
  case $_p9k_os in
    OSX|BSD)
      (( $+commands[sysctl] )) || return
      load="$(sysctl -n vm.loadavg 2>/dev/null)" || return
      load=${${(A)=load}[bucket+1]//,/.}
    ;;
    *)
      [[ -r /proc/loadavg ]] || return
      _p9k_read_file /proc/loadavg || return
      load=${${(A)=_p9k_ret}[bucket]//,/.}
    ;;
  esac

  (( _p9k_num_cpus )) || return

  if (( load > 0.7 * _p9k_num_cpus )); then
    local state=CRITICAL bg=red
  elif (( load > 0.5 * _p9k_num_cpus )); then
    local state=WARNING bg=yellow
  else
    local state=NORMAL bg=green
  fi

  _p9k_prompt_segment $0_$state $bg "$_p9k_color1" LOAD_ICON 0 '' $load
}

function _p9k_cached_cmd_stdout() {
  local cmd=${commands[$1]:A}
  [[ -n $cmd ]] || return
  shift
  if ! _p9k_cache_stat_get $0" ${(q)*}" $cmd; then
    local out
    out="$($cmd "$@" 2>/dev/null)"
    _p9k_cache_stat_set $(( ! $? )) "$out"
  fi
  (( $_p9k_cache_val[1] )) || return
  _p9k_ret=$_p9k_cache_val[2]
}

function _p9k_cached_cmd_stdout_stderr() {
  local cmd=${commands[$1]:A}
  [[ -n $cmd ]] || return
  shift
  if ! _p9k_cache_stat_get $0" ${(q)*}" $cmd; then
    local out
    out="$($cmd "$@" 2>&1)"  # this line is the only diff with _p9k_cached_cmd_stdout
    _p9k_cache_stat_set $(( ! $? )) "$out"
  fi
  (( $_p9k_cache_val[1] )) || return
  _p9k_ret=$_p9k_cache_val[2]
}

################################################################
# Segment to diplay Node version
prompt_node_version() {
  (( $+commands[node] )) || return

  if (( _POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY )); then
    local dir=$_p9k_pwd
    while true; do
      [[ $dir == / ]] && return
      [[ -e $dir/package.json ]] && break
      dir=${dir:h}
    done
  fi

  _p9k_cached_cmd_stdout node --version && [[ $_p9k_ret == v?* ]] || return
  _p9k_prompt_segment "$0" "green" "white" 'NODE_ICON' 0 '' "${_p9k_ret#v}"
}

# Almost the same as `nvm_version default` but faster. The differences shouldn't affect
# the observable behavior of Powerlevel10k.
function _p9k_nvm_ls_default() {
  local v=default
  local -a seen=($v)
  while [[ -r $NVM_DIR/alias/$v ]]; do
    local target=
    IFS='' read -r target <$NVM_DIR/alias/$v
    [[ -z $target ]] && break
    (( $seen[(I)$target] )) && return
    seen+=$target
    v=$target
  done

  case $v in
    default|N/A)
      return 1
    ;;
    system|v)
      _p9k_ret=system
      return 0
    ;;
    iojs-[0-9]*)
      v=iojs-v${v#iojs-}
    ;;
    [0-9]*)
      v=v$v
    ;;
  esac

  if [[ $v == v*.*.* ]]; then
    if [[ -x $NVM_DIR/versions/node/$v/bin/node || -x $NVM_DIR/$v/bin/node ]]; then
      _p9k_ret=$v
      return 0
    elif [[ -x $NVM_DIR/versions/io.js/$v/bin/node ]]; then
      _p9k_ret=iojs-$v
      return 0
    else
      return 1
    fi
  fi

  local -a dirs=()
  case $v in
    node|node-|stable)
      dirs=($NVM_DIR/versions/node $NVM_DIR)
      v='(v[1-9]*|v0.*[02468].*)'
    ;;
    unstable)
      dirs=($NVM_DIR/versions/node $NVM_DIR)
      v='v0.*[13579].*'
    ;;
    iojs*)
      dirs=($NVM_DIR/versions/io.js)
      v=v${${${v#iojs}#-}#v}'*'
    ;;
    *)
      dirs=($NVM_DIR/versions/node $NVM_DIR $NVM_DIR/versions/io.js)
      v=v${v#v}'*'
    ;;
  esac

  local -a matches=(${^dirs}/${~v}(/N))
  (( $#matches )) || return

  local max path
  local -a match
  for path in ${(Oa)matches}; do
    [[ ${path:t} == (#b)v(*).(*).(*) ]] || continue
    v=${(j::)${(@l:6::0:)match}}
    [[ $v > $max ]] || continue
    max=$v
    _p9k_ret=${path:t}
    [[ ${path:h:t} != io.js ]] || _p9k_ret=iojs-$_p9k_ret
  done

  [[ -n $max ]]
}

# The same as `nvm_version current` but faster.
_p9k_nvm_ls_current() {
  local node_path=${commands[node]:A}
  [[ -n $node_path ]] || return

  local nvm_dir=${NVM_DIR:A}
  if [[ -n $nvm_dir && $node_path == $nvm_dir/versions/io.js/* ]]; then
    _p9k_cached_cmd_stdout iojs --version || return
    _p9k_ret=iojs-v${_p9k_ret#v}
  elif [[ -n $nvm_dir && $node_path == $nvm_dir/* ]]; then
    _p9k_cached_cmd_stdout node --version || return
    _p9k_ret=v${_p9k_ret#v}
  else
    _p9k_ret=system
  fi
}

################################################################
# Segment to display Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  (( $+commands[nvm] || $+functions[nvm] )) || return
  [[ -n $NVM_DIR ]] && _p9k_nvm_ls_current || return
  local current=$_p9k_ret
  ! _p9k_nvm_ls_default || [[ $_p9k_ret != $current ]] || return
  _p9k_prompt_segment "$0" "magenta" "black" 'NODE_ICON' 0 '' "${${current#v}//\%/%%}"
}

################################################################
# Segment to display NodeEnv
prompt_nodeenv() {
  [[ -n "$NODE_VIRTUAL_ENV" ]] || return
  local msg
  if (( _POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION )) && _p9k_cached_cmd_stdout node --version; then
    msg="${_p9k_ret//\%/%%} "
  fi
  msg+="$_POWERLEVEL9K_NODEENV_LEFT_DELIMITER${${NODE_VIRTUAL_ENV:t}//\%/%%}$_POWERLEVEL9K_NODEENV_RIGHT_DELIMITER"
  _p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "$msg"
}

function _p9k_read_nodenv_version_file() {
  [[ -r $1 ]] || return
  local rest
  read _p9k_ret rest <$1 2>/dev/null
  [[ -n $_p9k_ret ]]
}

function _p9k_nodeenv_version_transform() {
  local dir=${NODENV_ROOT:-$HOME/.nodenv}/versions
  [[ -z $1 || $1 == system ]] && _p9k_ret=$1          && return
  [[ -d $dir/$1 ]]            && _p9k_ret=$1          && return
  [[ -d $dir/${1/v} ]]        && _p9k_ret=${1/v}      && return
  [[ -d $dir/${1#node-} ]]    && _p9k_ret=${1#node-}  && return
  [[ -d $dir/${1#node-v} ]]   && _p9k_ret=${1#node-v} && return
  return 1
}

function _p9k_nodenv_global_version() {
  _p9k_read_nodenv_version_file ${NODENV_ROOT:-$HOME/.nodenv}/version || _p9k_ret=system
}

################################################################
# Segment to display nodenv information
# https://github.com/nodenv/nodenv
prompt_nodenv() {
  (( $+commands[nodenv] || $+functions[nodenv] )) || return
  _p9k_ret=$NODENV_VERSION
  if [[ -z $_p9k_ret ]]; then
    [[ $NODENV_DIR == /* ]] && local dir=$NODENV_DIR || local dir="$_p9k_pwd_a/$NODENV_DIR"
    while [[ $dir != //[^/]# ]]; do
      _p9k_read_nodenv_version_file $dir/.node-version && break
      [[ $dir == / ]] && break
      dir=${dir:h}
    done
    if [[ -z $_p9k_ret ]]; then
      (( _POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW )) || return
      _p9k_nodenv_global_version
    fi
  fi

  _p9k_nodeenv_version_transform $_p9k_ret || return
  local v=$_p9k_ret

  if (( !_POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_nodenv_global_version
    _p9k_nodeenv_version_transform $_p9k_ret && [[ $v == $_p9k_ret ]] && return
  fi

  _p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "${v//\%/%%}"
}

prompt_dotnet_version() {
  (( $+commands[dotnet] )) || return

  if (( _POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY )); then
    case $_p9k_pwd in
      ~|/) return 0;;
      ~/*)
        local parent=~/
        local parts=(${(s./.)_p9k_pwd#$parent})
      ;;
      *)
        local parent=/
        local parts=(${(s./.)_p9k_pwd})
      ;;
    esac
    local MATCH
    local dirs=(${(@)${:-{1..$#parts}}/(#m)*/$parent${(pj./.)parts[i,$MATCH]}})
    local mtimes=()
    zstat -A mtimes +mtime -- $dirs 2>/dev/null || mtimes=()
    local key="${(pj.:.)mtimes}"
    if ! _p9k_cache_ephemeral_get $0 $_p9k_pwd || [[ $key != $_p9k_cache_val[1] ]] ; then
      local -i i found
      for i in {1..$#dirs}; do
        local dir=$dirs[i] mtime=$mtimes[i]
        local pair=$_p9k__dotnet_stat_cache[$dir]
        if [[ $pair == ${mtime:-x}:* ]]; then
          (( $pair[-1] )) && found=1
        else
          [[ -z $dir/(project.json|global.json|packet.dependencies|*.csproj|*.fsproj|*.xproj|*.sln)(#qN^/) ]]
          local -i has=$?
          (( has )) && found=1
          [[ -n $mtime ]] && _p9k__dotnet_stat_cache[$dir]="$mtime:$has"
        fi
      done
      [[ -n $key ]] && _p9k_cache_ephemeral_set "$key" $found
    fi
    (( _p9k_cache_val[2] )) || return
  fi

  _p9k_cached_cmd_stdout dotnet --version || return
  _p9k_prompt_segment "$0" "magenta" "white" 'DOTNET_ICON' 0 '' "$_p9k_ret"
}


################################################################
# Segment to print a little OS icon
prompt_os_icon() {
  _p9k_prompt_segment "$0" "black" "white" '' 0 '' "$_p9k_os_icon"
}

instant_prompt_os_icon() { prompt_os_icon; }

################################################################
# Segment to display PHP version number
prompt_php_version() {
  _p9k_cached_cmd_stdout php --version || return
  local -a match
  [[ $_p9k_ret == (#b)(*$'\n')#(PHP [[:digit:].]##)* ]] || return
  local v=$match[2]
  _p9k_prompt_segment "$0" "fuchsia" "grey93" '' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to display free RAM and used Swap
prompt_ram() {
  local -F free_bytes

  case $_p9k_os in
    OSX)
      (( $+commands[vm_stat] )) || return
      local stat && stat="$(vm_stat 2>/dev/null)" || return
      [[ $stat =~ 'Pages free:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes+=match[1] ))
      [[ $stat =~ 'Pages inactive:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes+=match[1] ))
      (( free_bytes *= 4096 ))
    ;;
    BSD)
      local stat && stat="$(grep -F 'avail memory' /var/run/dmesg.boot 2>/dev/null)" || return
      free_bytes=${${(A)=stat}[4]}
    ;;
    *)
      [[ -r /proc/meminfo ]] || return
      local stat && stat="$(</proc/meminfo)" || return
      [[ $stat == (#b)*'MemAvailable:'[[:space:]]#(<->)* ]] || return
      free_bytes=$(( $match[1] * 1024 ))
    ;;
  esac

  _p9k_human_readable_bytes $free_bytes
  _p9k_prompt_segment $0 yellow "$_p9k_color1" RAM_ICON 0 '' $_p9k_ret
}

function _p9k_read_rbenv_version_file() {
  [[ -r $1 ]] || return
  local rest
  read _p9k_ret rest <$1 2>/dev/null
  [[ -n $_p9k_ret ]]
}

function _p9k_rbenv_global_version() {
  _p9k_read_rbenv_version_file ${RBENV_ROOT:-$HOME/.rbenv}/version || _p9k_ret=system
}

################################################################
# Segment to display rbenv information
# https://github.com/rbenv/rbenv#choosing-the-ruby-version
prompt_rbenv() {
  (( $+commands[rbenv] || $+functions[rbenv] )) || return
  if [[ -n $RBENV_VERSION ]]; then
    (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)shell]} )) || return
    local v=$RBENV_VERSION
  else
    (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local|global]} )) || return
    [[ $RBENV_DIR == /* ]] && local dir=$RBENV_DIR || local dir="$_p9k_pwd_a/$RBENV_DIR"
    while true; do
      if _p9k_read_rbenv_version_file $dir/.ruby-version; then
        (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local]} )) || return
        local v=$_p9k_ret
        break
      fi
      if [[ $dir == / ]]; then
        (( _POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW )) || return
        (( ${_POWERLEVEL9K_RBENV_SOURCES[(I)global]} )) || return
        _p9k_rbenv_global_version
        local v=$_p9k_ret
        break
      fi
      dir=${dir:h}
    done
  fi

  if (( !_POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_rbenv_global_version
    [[ $v == $_p9k_ret ]] && return
  fi

  _p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to display chruby information
# see https://github.com/postmodern/chruby/issues/245 for chruby_auto issue with ZSH
prompt_chruby() {
  [[ -n $RUBY_ENGINE ]] || return
  local v=''
  (( _POWERLEVEL9K_CHRUBY_SHOW_ENGINE )) && v=$RUBY_ENGINE
  if [[ $_POWERLEVEL9K_CHRUBY_SHOW_VERSION == 1 && -n $RUBY_VERSION ]] && v+=${v:+ }$RUBY_VERSION
  _p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to print an icon if user is root.
prompt_root_indicator() {
  _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'ROOT_ICON' 0 '${${(%):-%#}:#%}' ''
}

instant_prompt_root_indicator() { prompt_root_indicator; }

################################################################
# Segment to display Rust version number
prompt_rust_version() {
  (( $+commands[rustc] )) || return
  if (( _POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY )); then
    local dir=$_p9k_pwd_a
    while true; do
      [[ $dir == / ]] && return
      [[ -e $dir/Cargo.toml ]] && break
      dir=${dir:h}
    done
  fi
  local rustc=$commands[rustc] so
  if (( $+commands[ldd] )); then
    if _p9k_cache_stat_get $0_so $rustc; then
      so=$_p9k_cache_val[1]
    else
      local line match
      for line in "${(@f)$(ldd $rustc 2>/dev/null)}"; do
        [[ $line == (#b)[[:space:]]#librustc_driver[^[:space:]]#.so' => '(*)' (0x'[[:xdigit:]]#')' ]] || continue
        so=$match[1]
        break
      done
      _p9k_cache_stat_set "$so"
    fi
  fi
  if ! _p9k_cache_stat_get $0_v $rustc $so; then
    _p9k_cache_stat_set "$($rustc --version 2>/dev/null)"
  fi
  local v=${${_p9k_cache_val[1]#rustc }%% *}
  [[ -n $v ]] || return
  _p9k_prompt_segment "$0" "darkorange" "$_p9k_color1" 'RUST_ICON' 0 '' "${v//\%/%%}"
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ -d app && -d spec ]]; then
    local -a code=(app/**/*.rb(N))
    (( $#code )) || return
    local tests=(spec/**/*.rb(N))
    _p9k_build_test_stats "$0" "$#code" "$#tests" "RSpec" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Ruby Version Manager information
prompt_rvm() {
  (( $+commands[rvm-prompt] || $+functions[rvm-prompt] )) || return
  [[ $GEM_HOME == *rvm* && $ruby_string != $rvm_path/bin/ruby ]] || return
  local v=${GEM_HOME:t}
  (( _POWERLEVEL9K_RVM_SHOW_GEMSET )) || v=${v%%${rvm_gemset_separator:-@}*}
  (( _POWERLEVEL9K_RVM_SHOW_PREFIX )) || v=${v#*-}
  [[ -n $v ]] || return
  _p9k_prompt_segment "$0" "240" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  if (( P9K_SSH )); then
    _p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'SSH_ICON' 0 '' ''
  fi
}

instant_prompt_ssh() { prompt_ssh; }

################################################################
# Status: When an error occur, return the error code, or a cross icon if option is set
# Display an ok icon when no error occur, or hide the segment if option is set to false
prompt_status() {
  if ! _p9k_cache_get $0 $_p9k__status $_p9k__pipestatus; then
    (( _p9k__status )) && local state=ERROR || local state=OK
    if (( _POWERLEVEL9K_STATUS_EXTENDED_STATES )); then
      if (( _p9k__status )); then
        if (( $#_p9k__pipestatus > 1 )); then
          state+=_PIPE
        elif (( _p9k__status > 128 )); then
          state+=_SIGNAL
        fi
      elif [[ "$_p9k__pipestatus" == *[1-9]* ]]; then
        state+=_PIPE
      fi
    fi
    _p9k_cache_val=(:)
    if (( _POWERLEVEL9K_STATUS_$state )); then
      if (( _POWERLEVEL9K_STATUS_SHOW_PIPESTATUS )); then
        local text=${(j:|:)${(@)_p9k__pipestatus:/(#b)(*)/$_p9k_exitcode2str[$match[1]+1]}}
      else
        local text=$_p9k_exitcode2str[_p9k__status+1]
      fi
      if (( _p9k__status )); then
        if (( !_POWERLEVEL9K_STATUS_CROSS && _POWERLEVEL9K_STATUS_VERBOSE )); then
          _p9k_cache_val=($0_$state red yellow1 CARRIAGE_RETURN_ICON 0 '' "$text")
        else
          _p9k_cache_val=($0_$state $_p9k_color1 red FAIL_ICON 0 '' '')
        fi
      elif (( _POWERLEVEL9K_STATUS_VERBOSE || _POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE )); then
        [[ $state == OK ]] && text=''
        _p9k_cache_val=($0_$state "$_p9k_color1" green OK_ICON 0 '' "$text")
      fi
    fi
    if (( $#_p9k__pipestatus < 3 )); then
      _p9k_cache_set "${(@)_p9k_cache_val}"
    fi
  fi
  _p9k_prompt_segment "${(@)_p9k_cache_val}"
}

instant_prompt_status() {
  if (( _POWERLEVEL9K_STATUS_OK )); then
    _p9k_prompt_segment prompt_status_OK "$_p9k_color1" green OK_ICON 0 '' ''
  fi
}

prompt_prompt_char() {
  if (( __p9k_sh_glob )); then
    if (( _p9k__status )); then
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' '❯'
        _p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '▶'
      else
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' '❯'
      fi
      _p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
      _p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'Ⅴ'
    else
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' '❯'
        _p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '▶'
      else
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' '❯'
      fi
      _p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
      _p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'Ⅴ'
    fi
  else
    if (( _p9k__status )); then
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' '❯'
        _p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '▶'
      else
        _p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' '❯'
      fi
      _p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
      _p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'Ⅴ'
    else
      if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )); then
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' '❯'
        _p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '▶'
      else
        _p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' '❯'
      fi
      _p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
      _p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'Ⅴ'
    fi
  fi
}

instant_prompt_prompt_char() {
  _p9k_prompt_segment prompt_prompt_char_OK_VIINS "$_p9k_color1" 76 '' 0 '' '❯'
}

################################################################
# Segment to display Swap information
prompt_swap() {
  local -F used_bytes

  if [[ "$_p9k_os" == "OSX" ]]; then
    (( $+commands[sysctl] )) || return
    [[ "$(sysctl vm.swapusage 2>/dev/null)" =~ "used = ([0-9,.]+)([A-Z]+)" ]] || return
    used_bytes=${match[1]//,/.}
    case ${match[2]} in
      'K') (( used_bytes *= 1024 ));;
      'M') (( used_bytes *= 1048576 ));;
      'G') (( used_bytes *= 1073741824 ));;
      'T') (( used_bytes *= 1099511627776 ));;
      *) return 0;;
    esac
  else
    local meminfo && meminfo="$(grep -F 'Swap' /proc/meminfo 2>/dev/null)" || return
    [[ $meminfo =~ 'SwapTotal:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes+=match[1] ))
    [[ $meminfo =~ 'SwapFree:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes-=match[1] ))
    (( used_bytes *= 1024 ))
  fi

  _p9k_human_readable_bytes $used_bytes
  _p9k_prompt_segment $0 yellow "$_p9k_color1" SWAP_ICON 0 '' $_p9k_ret
}

################################################################
# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ -d src && -d app && -f app/AppKernel.php ]]; then
    local -a all=(src/**/*.php(N))
    local -a code=(${(@)all##*Tests*})
    (( $#code )) || return
    _p9k_build_test_stats "$0" "$#code" "$(($#all - $#code))" "SF2" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Symfony2-Version
prompt_symfony2_version() {
  if [[ -r app/bootstrap.php.cache ]]; then
    local v="${$(grep -F " VERSION " app/bootstrap.php.cache 2>/dev/null)//[![:digit:].]}"
    _p9k_prompt_segment "$0" "grey35" "$_p9k_color1" 'SYMFONY_ICON' 0 '' "${v//\%/%%}"
  fi
}

################################################################
# Show a ratio of tests vs code
_p9k_build_test_stats() {
  local code_amount="$2"
  local tests_amount="$3"
  local headline="$4"

  (( code_amount > 0 )) || return
  local -F 2 ratio=$(( 100. * tests_amount / code_amount ))

  (( ratio >= 75 )) && _p9k_prompt_segment "${1}_GOOD" "cyan" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && _p9k_prompt_segment "$1_AVG" "yellow" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
  (( ratio < 50 )) && _p9k_prompt_segment "$1_BAD" "red" "$_p9k_color1" "$5" 0 '' "$headline: $ratio%%"
}

################################################################
# System time
prompt_time() {
  if (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )); then
    _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' "$_POWERLEVEL9K_TIME_FORMAT"
  else
    if [[ $_p9k_refresh_reason == precmd ]]; then
      if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_time_format == $_POWERLEVEL9K_TIME_FORMAT ]]; then
        _p9k_time=${__p9k_instant_prompt_time//\%/%%}
      else
        _p9k_time=${${(%)_POWERLEVEL9K_TIME_FORMAT}//\%/%%}
      fi
    fi
    if (( _POWERLEVEL9K_TIME_UPDATE_ON_COMMAND )); then
      _p9k_escape $_p9k_time
      local t=$_p9k_ret
      _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
      _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' \
          "\${_p9k__line_finished-$t}\${_p9k__line_finished+$_p9k_ret}"
    else
      _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' $_p9k_time
    fi
  fi
}

instant_prompt_time() {
  _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
  local stash='${${__p9k_instant_prompt_time::=${(%)${__p9k_instant_prompt_time_format::='$_p9k_ret'}}}+}'
  _p9k_escape $_POWERLEVEL9K_TIME_FORMAT
  _p9k_prompt_segment prompt_time "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' $stash$_p9k_ret
}

################################################################
# System date
prompt_date() {
  if [[ $_p9k_refresh_reason == precmd ]]; then
    if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_date_format == $_POWERLEVEL9K_DATE_FORMAT ]]; then
      _p9k_date=${__p9k_instant_prompt_date//\%/%%}
    else
      _p9k_date=${${(%)_POWERLEVEL9K_DATE_FORMAT}//\%/%%}
    fi
  fi
  _p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 0 '' "$_p9k_date"
}

instant_prompt_date() {
  _p9k_escape $_POWERLEVEL9K_DATE_FORMAT
  local stash='${${__p9k_instant_prompt_date::=${(%)${__p9k_instant_prompt_date_format::='$_p9k_ret'}}}+}'
  _p9k_escape $_POWERLEVEL9K_DATE_FORMAT
  _p9k_prompt_segment prompt_date "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 1 '' $stash$_p9k_ret
}

################################################################
# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  unset P9K_TODO_TOTAL_TASK_COUNT P9K_TODO_FILTERED_TASK_COUNT
  local todo=$commands[todo.sh]
  [[ -n $todo && -r $_p9k_todo_file ]] || return
  if ! _p9k_cache_stat_get $0 $_p9k_todo_file; then
    local count="$($todo -p ls | tail -1)"
    if [[ $count == (#b)'TODO: '([[:digit:]]##)' of '([[:digit:]]##)' '* ]]; then
      _p9k_cache_stat_set 1 $match[1] $match[2]
    else
      _p9k_cache_stat_set 0
    fi
  fi
  (( $_p9k_cache_val[1] )) || return
  typeset -gi P9K_TODO_FILTERED_TASK_COUNT=$_p9k_cache_val[2]
  typeset -gi P9K_TODO_TOTAL_TASK_COUNT=$_p9k_cache_val[3]
  _p9k_prompt_segment "$0" "grey50" "$_p9k_color1" 'TODO_ICON' 0 '' "$P9K_TODO_TOTAL_TASK_COUNT"
}

################################################################
# VCS segment: shows the state of your repository, if you are in a folder under
# version control

# The vcs segment can have 4 different states - defaults to 'CLEAN'.
typeset -gA __p9k_vcs_states=(
  'CLEAN'         '2'
  'MODIFIED'      '3'
  'UNTRACKED'     '2'
  'LOADING'       '8'
  'CONFLICTED'    '3'
)

function +vi-git-untracked() {
  [[ -z "${vcs_comm[gitdir]}" || "${vcs_comm[gitdir]}" == "." ]] && return

  # get the root for the current repo or submodule
  local repoTopLevel="$(git rev-parse --show-toplevel 2> /dev/null)"
  # dump out if we're outside a git repository (which includes being in the .git folder)
  [[ $? != 0 || -z $repoTopLevel ]] && return

  local untrackedFiles="$(git ls-files --others --exclude-standard "${repoTopLevel}" 2> /dev/null)"

  if [[ -z $untrackedFiles && $_POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY == 1 ]]; then
    untrackedFiles+="$(git submodule foreach --quiet --recursive 'git ls-files --others --exclude-standard' 2> /dev/null)"
  fi

  [[ -z $untrackedFiles ]] && return

  hook_com[unstaged]+=" $(print_icon 'VCS_UNTRACKED_ICON')"
  VCS_WORKDIR_HALF_DIRTY=true
}

function +vi-git-aheadbehind() {
  local ahead behind
  local -a gitstatus

  # for git prior to 1.7
  # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
  ahead="$(git rev-list --count "${hook_com[branch]}"@{upstream}..HEAD 2>/dev/null)"
  (( ahead )) && gitstatus+=( " $(print_icon 'VCS_OUTGOING_CHANGES_ICON')${ahead// /}" )

  # for git prior to 1.7
  # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
  behind="$(git rev-list --count HEAD.."${hook_com[branch]}"@{upstream} 2>/dev/null)"
  (( behind )) && gitstatus+=( " $(print_icon 'VCS_INCOMING_CHANGES_ICON')${behind// /}" )

  hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
  local remote
  local branch_name="${hook_com[branch]}"

  # Are we on a remote-tracking branch?
  remote="$(git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)"
  remote=${remote/refs\/(remotes|heads)\/}

  if (( $+_POWERLEVEL9K_VCS_SHORTEN_LENGTH && $+_POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH )); then
    if (( ${#hook_com[branch]} > _POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH && ${#hook_com[branch]} > _POWERLEVEL9K_VCS_SHORTEN_LENGTH )); then
      case $_POWERLEVEL9K_VCS_SHORTEN_STRATEGY in
        truncate_middle)
          hook_com[branch]="${branch_name:0:$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}${_POWERLEVEL9K_VCS_SHORTEN_DELIMITER}${branch_name: -$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}"
        ;;
        truncate_from_right)
          hook_com[branch]="${branch_name:0:$_POWERLEVEL9K_VCS_SHORTEN_LENGTH}${_POWERLEVEL9K_VCS_SHORTEN_DELIMITER}"
        ;;
      esac
    fi
  fi

  if (( _POWERLEVEL9K_HIDE_BRANCH_ICON )); then
    hook_com[branch]="${hook_com[branch]}"
  else
    hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${hook_com[branch]}"
  fi
  # Always show the remote
  #if [[ -n ${remote} ]] ; then
  # Only show the remote if it differs from the local
  if [[ -n ${remote} ]] && [[ "${remote#*/}" != "${branch_name}" ]] ; then
     hook_com[branch]+="$(print_icon 'VCS_REMOTE_BRANCH_ICON')${remote// /}"
  fi
}

function +vi-git-tagname() {
  if (( !_POWERLEVEL9K_VCS_HIDE_TAGS )); then
    # If we are on a tag, append the tagname to the current branch string.
    local tag
    tag="$(git describe --tags --exact-match HEAD 2>/dev/null)"

    if [[ -n "${tag}" ]] ; then
      # There is a tag that points to our current commit. Need to determine if we
      # are also on a branch, or are in a DETACHED_HEAD state.
      if [[ -z "$(git symbolic-ref HEAD 2>/dev/null)" ]]; then
        # DETACHED_HEAD state. We want to append the tag name to the commit hash
        # and print it. Unfortunately, `vcs_info` blows away the hash when a tag
        # exists, so we have to manually retrieve it and clobber the branch
        # string.
        local revision
        revision="$(git rev-list -n 1 --abbrev-commit --abbrev=${_POWERLEVEL9K_CHANGESET_HASH_LENGTH} HEAD)"
        if (( _POWERLEVEL9K_HIDE_BRANCH_ICON )); then
          hook_com[branch]="${revision} $(print_icon 'VCS_TAG_ICON')${tag}"
        else
          hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${revision} $(print_icon 'VCS_TAG_ICON')${tag}"
        fi
      else
        # We are on both a tag and a branch; print both by appending the tag name.
        hook_com[branch]+=" $(print_icon 'VCS_TAG_ICON')${tag}"
      fi
    fi
  fi
}

# Show count of stashed changes
# Port from https://github.com/whiteinge/dotfiles/blob/5dfd08d30f7f2749cfc60bc55564c6ea239624d9/.zsh_shouse_prompt#L268
function +vi-git-stash() {
  if [[ -s "${vcs_comm[gitdir]}/logs/refs/stash" ]] ; then
    local -a stashes=( "${(@f)"$(<${vcs_comm[gitdir]}/logs/refs/stash)"}" )
    hook_com[misc]+=" $(print_icon 'VCS_STASH_ICON')${#stashes}"
  fi
}

function +vi-hg-bookmarks() {
  if [[ -n "${hgbmarks[@]}" ]]; then
    hook_com[hg-bookmark-string]=" $(print_icon 'VCS_BOOKMARK_ICON')${hgbmarks[@]}"

    # To signal that we want to use the sting we just generated, set the special
    # variable `ret' to something other than the default zero:
    ret=1
    return 0
  fi
}

function +vi-vcs-detect-changes() {
  if [[ "${hook_com[vcs]}" == "git" ]]; then

    local remote="$(git ls-remote --get-url 2> /dev/null)"
    if [[ "$remote" =~ "github" ]] then
      vcs_visual_identifier='VCS_GIT_GITHUB_ICON'
    elif [[ "$remote" =~ "bitbucket" ]] then
      vcs_visual_identifier='VCS_GIT_BITBUCKET_ICON'
    elif [[ "$remote" =~ "stash" ]] then
      vcs_visual_identifier='VCS_GIT_BITBUCKET_ICON'
    elif [[ "$remote" =~ "gitlab" ]] then
      vcs_visual_identifier='VCS_GIT_GITLAB_ICON'
    else
      vcs_visual_identifier='VCS_GIT_ICON'
    fi

  elif [[ "${hook_com[vcs]}" == "hg" ]]; then
    vcs_visual_identifier='VCS_HG_ICON'
  elif [[ "${hook_com[vcs]}" == "svn" ]]; then
    vcs_visual_identifier='VCS_SVN_ICON'
  fi

  if [[ -n "${hook_com[staged]}" ]] || [[ -n "${hook_com[unstaged]}" ]]; then
    VCS_WORKDIR_DIRTY=true
  else
    VCS_WORKDIR_DIRTY=false
  fi
}

function +vi-svn-detect-changes() {
  local svn_status="$(svn status)"
  if [[ -n "$(echo "$svn_status" | \grep \^\?)" ]]; then
    hook_com[unstaged]+=" $(print_icon 'VCS_UNTRACKED_ICON')"
    VCS_WORKDIR_HALF_DIRTY=true
  fi
  if [[ -n "$(echo "$svn_status" | \grep \^\M)" ]]; then
    hook_com[unstaged]+=" $(print_icon 'VCS_UNSTAGED_ICON')"
    VCS_WORKDIR_DIRTY=true
  fi
  if [[ -n "$(echo "$svn_status" | \grep \^\A)" ]]; then
    hook_com[staged]+=" $(print_icon 'VCS_STAGED_ICON')"
    VCS_WORKDIR_DIRTY=true
  fi
}

_p9k_vcs_info_init() {
  autoload -Uz vcs_info

  local prefix=''
  if (( _POWERLEVEL9K_SHOW_CHANGESET )); then
    _p9k_get_icon '' VCS_COMMIT_ICON
    prefix="$_p9k_ret%0.${_POWERLEVEL9K_CHANGESET_HASH_LENGTH}i "
  fi

  zstyle ':vcs_info:*' check-for-changes true

  zstyle ':vcs_info:*' formats "$prefix%b%c%u%m"
  zstyle ':vcs_info:*' actionformats "%b %F{$_POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}| %a%f"
  _p9k_get_icon '' VCS_STAGED_ICON
  zstyle ':vcs_info:*' stagedstr " $_p9k_ret"
  _p9k_get_icon '' VCS_UNSTAGED_ICON
  zstyle ':vcs_info:*' unstagedstr " $_p9k_ret"
  zstyle ':vcs_info:git*+set-message:*' hooks $_POWERLEVEL9K_VCS_GIT_HOOKS
  zstyle ':vcs_info:hg*+set-message:*' hooks $_POWERLEVEL9K_VCS_HG_HOOKS
  zstyle ':vcs_info:svn*+set-message:*' hooks $_POWERLEVEL9K_VCS_SVN_HOOKS

  # For Hg, only show the branch name
  if (( _POWERLEVEL9K_HIDE_BRANCH_ICON )); then
    zstyle ':vcs_info:hg*:*' branchformat "%b"
  else
    _p9k_get_icon '' VCS_BRANCH_ICON
    zstyle ':vcs_info:hg*:*' branchformat "$_p9k_ret%b"
  fi
  # The `get-revision` function must be turned on for dirty-check to work for Hg
  zstyle ':vcs_info:hg*:*' get-revision true
  zstyle ':vcs_info:hg*:*' get-bookmarks true
  zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks

  # TODO: fix the %b (branch) format for svn. Using %b breaks color-encoding of the foreground
  # for the rest of the powerline.
  zstyle ':vcs_info:svn*:*' formats "$prefix%c%u"
  zstyle ':vcs_info:svn*:*' actionformats "$prefix%c%u %F{$_POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND}| %a%f"

  if (( _POWERLEVEL9K_SHOW_CHANGESET )); then
    zstyle ':vcs_info:*' get-revision true
  else
    zstyle ':vcs_info:*' get-revision false
  fi
}

function _p9k_vcs_status_save() {
  local z=$'\0'
  _p9k__gitstatus_last[${${_p9k__git_dir:+GIT_DIR:$_p9k__git_dir}:-$VCS_STATUS_WORKDIR}]=\
$VCS_STATUS_ACTION$z$VCS_STATUS_COMMIT\
$z$VCS_STATUS_COMMITS_AHEAD$z$VCS_STATUS_COMMITS_BEHIND$z$VCS_STATUS_HAS_CONFLICTED\
$z$VCS_STATUS_HAS_STAGED$z$VCS_STATUS_HAS_UNSTAGED$z$VCS_STATUS_HAS_UNTRACKED\
$z$VCS_STATUS_INDEX_SIZE$z$VCS_STATUS_LOCAL_BRANCH$z$VCS_STATUS_NUM_CONFLICTED\
$z$VCS_STATUS_NUM_STAGED$z$VCS_STATUS_NUM_UNSTAGED$z$VCS_STATUS_NUM_UNTRACKED\
$z$VCS_STATUS_REMOTE_BRANCH$z$VCS_STATUS_REMOTE_NAME$z$VCS_STATUS_REMOTE_URL\
$z$VCS_STATUS_RESULT$z$VCS_STATUS_STASHES$z$VCS_STATUS_TAG$z$VCS_STATUS_NUM_UNSTAGED_DELETED
}

function _p9k_vcs_status_restore() {
  for VCS_STATUS_ACTION VCS_STATUS_COMMIT VCS_STATUS_COMMITS_AHEAD VCS_STATUS_COMMITS_BEHIND \
      VCS_STATUS_HAS_CONFLICTED VCS_STATUS_HAS_STAGED VCS_STATUS_HAS_UNSTAGED                \
      VCS_STATUS_HAS_UNTRACKED VCS_STATUS_INDEX_SIZE VCS_STATUS_LOCAL_BRANCH                 \
      VCS_STATUS_NUM_CONFLICTED VCS_STATUS_NUM_STAGED VCS_STATUS_NUM_UNSTAGED                \
      VCS_STATUS_NUM_UNTRACKED VCS_STATUS_REMOTE_BRANCH VCS_STATUS_REMOTE_NAME               \
      VCS_STATUS_REMOTE_URL VCS_STATUS_RESULT VCS_STATUS_STASHES VCS_STATUS_TAG              \
      VCS_STATUS_NUM_UNSTAGED_DELETED
      in "${(@0)1}"; do done
}

function _p9k_vcs_status_for_dir() {
  if [[ -n $GIT_DIR ]]; then
    _p9k_ret=$_p9k__gitstatus_last[GIT_DIR:$GIT_DIR]
    [[ -n $_p9k_ret ]]
  else
    local dir=$_p9k_pwd_a
    while true; do
      _p9k_ret=$_p9k__gitstatus_last[$dir]
      [[ -n $_p9k_ret ]] && return 0
      [[ $dir == / ]] && return 1
      dir=${dir:h}
    done
  fi
}

function _p9k_vcs_status_purge() {
  if [[ -n $_p9k__git_dir ]]; then
    _p9k__gitstatus_last[GIT_DIR:$_p9k__git_dir]=""
  else
    local dir=$1
    while true; do
      # unset doesn't work if $dir contains weird shit
      _p9k__gitstatus_last[$dir]=""
      _p9k_git_slow[$dir]=""
      [[ $dir == / ]] && break
      dir=${dir:h}
    done
  fi
}

function _p9k_vcs_icon() {
  case "$VCS_STATUS_REMOTE_URL" in
    *github*)    _p9k_ret=VCS_GIT_GITHUB_ICON;;
    *bitbucket*) _p9k_ret=VCS_GIT_BITBUCKET_ICON;;
    *stash*)     _p9k_ret=VCS_GIT_GITHUB_ICON;;
    *gitlab*)    _p9k_ret=VCS_GIT_GITLAB_ICON;;
    *)           _p9k_ret=VCS_GIT_ICON;;
  esac
}

function _p9k_vcs_render() {
  local state

  if (( $+_p9k__gitstatus_next_dir )); then
    if _p9k_vcs_status_for_dir; then
      _p9k_vcs_status_restore $_p9k_ret
      state=LOADING
    else
      _p9k_prompt_segment prompt_vcs_LOADING "${__p9k_vcs_states[LOADING]}" "$_p9k_color1" VCS_LOADING_ICON 0 '' "$_POWERLEVEL9K_VCS_LOADING_TEXT"
      return 0
    fi
  elif [[ $VCS_STATUS_RESULT != ok-* ]]; then
    return 1
  fi

  if (( _POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING )); then
    if [[ -z $state ]]; then
      if [[ $VCS_STATUS_HAS_CONFLICTED == 1 && $_POWERLEVEL9K_VCS_CONFLICTED_STATE == 1 ]]; then
        state=CONFLICTED
      elif [[ $VCS_STATUS_HAS_STAGED != 0 || $VCS_STATUS_HAS_UNSTAGED != 0 ]]; then
        state=MODIFIED
      elif [[ $VCS_STATUS_HAS_UNTRACKED != 0 ]]; then
        state=UNTRACKED
      else
        state=CLEAN
      fi
    fi
    _p9k_vcs_icon
    _p9k_prompt_segment prompt_vcs_$state "${__p9k_vcs_states[$state]}" "$_p9k_color1" "$_p9k_ret" 0 '' ""
    return 0
  fi

  (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-untracked]} )) || VCS_STATUS_HAS_UNTRACKED=0
  (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-aheadbehind]} )) || { VCS_STATUS_COMMITS_AHEAD=0 && VCS_STATUS_COMMITS_BEHIND=0 }
  (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-stash]} )) || VCS_STATUS_STASHES=0
  (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-remotebranch]} )) || VCS_STATUS_REMOTE_BRANCH=""
  (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-tagname]} )) || VCS_STATUS_TAG=""

  (( _POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM >= 0 && VCS_STATUS_COMMITS_AHEAD > _POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM )) &&
    VCS_STATUS_COMMITS_AHEAD=$_POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM

  (( _POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM >= 0 && VCS_STATUS_COMMITS_BEHIND > _POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM )) &&
    VCS_STATUS_COMMITS_BEHIND=$_POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM

  local -a cache_key=(
    "$VCS_STATUS_LOCAL_BRANCH"
    "$VCS_STATUS_REMOTE_BRANCH"
    "$VCS_STATUS_REMOTE_URL"
    "$VCS_STATUS_ACTION"
    "$VCS_STATUS_NUM_STAGED"
    "$VCS_STATUS_NUM_UNSTAGED"
    "$VCS_STATUS_NUM_UNTRACKED"
    "$VCS_STATUS_HAS_CONFLICTED"
    "$VCS_STATUS_HAS_STAGED"
    "$VCS_STATUS_HAS_UNSTAGED"
    "$VCS_STATUS_HAS_UNTRACKED"
    "$VCS_STATUS_COMMITS_AHEAD"
    "$VCS_STATUS_COMMITS_BEHIND"
    "$VCS_STATUS_STASHES"
    "$VCS_STATUS_TAG"
    "$VCS_STATUS_NUM_UNSTAGED_DELETED"
  )
  if [[ $_POWERLEVEL9K_SHOW_CHANGESET == 1 || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    cache_key+=$VCS_STATUS_COMMIT
  fi

  if ! _p9k_cache_ephemeral_get "$state" "${(@)cache_key}"; then
    local icon
    local content

    if (( ${_POWERLEVEL9K_VCS_GIT_HOOKS[(I)vcs-detect-changes]} )); then
      if [[ $VCS_STATUS_HAS_CONFLICTED == 1 && $_POWERLEVEL9K_VCS_CONFLICTED_STATE == 1 ]]; then
        : ${state:=CONFLICTED}
      elif [[ $VCS_STATUS_HAS_STAGED != 0 || $VCS_STATUS_HAS_UNSTAGED != 0 ]]; then
        : ${state:=MODIFIED}
      elif [[ $VCS_STATUS_HAS_UNTRACKED != 0 ]]; then
        : ${state:=UNTRACKED}
      fi

      # It's weird that removing vcs-detect-changes from POWERLEVEL9K_VCS_GIT_HOOKS gets rid
      # of the GIT icon. That's what vcs_info does, so we do the same in the name of compatiblity.
      case "$VCS_STATUS_REMOTE_URL" in
        *github*)    icon=VCS_GIT_GITHUB_ICON;;
        *bitbucket*) icon=VCS_GIT_BITBUCKET_ICON;;
        *stash*)     icon=VCS_GIT_GITHUB_ICON;;
        *gitlab*)    icon=VCS_GIT_GITLAB_ICON;;
        *)           icon=VCS_GIT_ICON;;
      esac
    fi

    : ${state:=CLEAN}

    function _$0_fmt() {
      _p9k_vcs_style $state $1
      content+="$_p9k_ret$2"
    }

    local ws
    if [[ $_POWERLEVEL9K_SHOW_CHANGESET == 1 || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      _p9k_get_icon prompt_vcs_$state VCS_COMMIT_ICON
      _$0_fmt COMMIT "$_p9k_ret${${VCS_STATUS_COMMIT:0:$_POWERLEVEL9K_CHANGESET_HASH_LENGTH}:-HEAD}"
      ws=' '
    fi

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=$ws
      if (( !_POWERLEVEL9K_HIDE_BRANCH_ICON )); then
        _p9k_get_icon prompt_vcs_$state VCS_BRANCH_ICON
        branch+=$_p9k_ret
      fi
      if (( $+_POWERLEVEL9K_VCS_SHORTEN_LENGTH && $+_POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH &&
            $#VCS_STATUS_LOCAL_BRANCH > _POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH &&
            $#VCS_STATUS_LOCAL_BRANCH > _POWERLEVEL9K_VCS_SHORTEN_LENGTH )) &&
         [[ $_POWERLEVEL9K_VCS_SHORTEN_STRATEGY == (truncate_middle|truncate_from_right) ]]; then
        branch+=${VCS_STATUS_LOCAL_BRANCH[1,_POWERLEVEL9K_VCS_SHORTEN_LENGTH]//\%/%%}${_POWERLEVEL9K_VCS_SHORTEN_DELIMITER}
        if [[ $_POWERLEVEL9K_VCS_SHORTEN_STRATEGY == truncate_middle ]]; then
          _p9k_vcs_style $state BRANCH
          branch+=${_p9k_ret}${VCS_STATUS_LOCAL_BRANCH[-_POWERLEVEL9K_VCS_SHORTEN_LENGTH,-1]//\%/%%}
        fi
      else
        branch+=${VCS_STATUS_LOCAL_BRANCH//\%/%%}
      fi
      _$0_fmt BRANCH $branch
    fi

    if [[ $_POWERLEVEL9K_VCS_HIDE_TAGS == 0 && -n $VCS_STATUS_TAG ]]; then
      _p9k_get_icon prompt_vcs_$state VCS_TAG_ICON
      _$0_fmt TAG " $_p9k_ret${VCS_STATUS_TAG//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_ACTION ]]; then
      _$0_fmt ACTION " | ${VCS_STATUS_ACTION//\%/%%}"
    else
      if [[ -n $VCS_STATUS_REMOTE_BRANCH &&
            $VCS_STATUS_LOCAL_BRANCH != $VCS_STATUS_REMOTE_BRANCH ]]; then
        _p9k_get_icon prompt_vcs_$state VCS_REMOTE_BRANCH_ICON
        _$0_fmt REMOTE_BRANCH " $_p9k_ret${VCS_STATUS_REMOTE_BRANCH//\%/%%}"
      fi
      if [[ $VCS_STATUS_HAS_STAGED == 1 || $VCS_STATUS_HAS_UNSTAGED == 1 || $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
        _p9k_get_icon prompt_vcs_$state VCS_DIRTY_ICON
        _$0_fmt DIRTY "$_p9k_ret"
        if [[ $VCS_STATUS_HAS_STAGED == 1 ]]; then
          _p9k_get_icon prompt_vcs_$state VCS_STAGED_ICON
          (( _POWERLEVEL9K_VCS_STAGED_MAX_NUM != 1 )) && _p9k_ret+=$VCS_STATUS_NUM_STAGED
          _$0_fmt STAGED " $_p9k_ret"
        fi
        if [[ $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
          _p9k_get_icon prompt_vcs_$state VCS_UNSTAGED_ICON
          (( _POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM != 1 )) && _p9k_ret+=$VCS_STATUS_NUM_UNSTAGED
          _$0_fmt UNSTAGED " $_p9k_ret"
        fi
        if [[ $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
          _p9k_get_icon prompt_vcs_$state VCS_UNTRACKED_ICON
          (( _POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM != 1 )) && _p9k_ret+=$VCS_STATUS_NUM_UNTRACKED
          _$0_fmt UNTRACKED " $_p9k_ret"
        fi
      fi
      if [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
        _p9k_get_icon prompt_vcs_$state VCS_INCOMING_CHANGES_ICON
        (( _POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM != 1 )) && _p9k_ret+=$VCS_STATUS_COMMITS_BEHIND
        _$0_fmt INCOMING_CHANGES " $_p9k_ret"
      fi
      if [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 ]]; then
        _p9k_get_icon prompt_vcs_$state VCS_OUTGOING_CHANGES_ICON
        (( _POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM != 1 )) && _p9k_ret+=$VCS_STATUS_COMMITS_AHEAD
        _$0_fmt OUTGOING_CHANGES " $_p9k_ret"
      fi
      if [[ $VCS_STATUS_STASHES -gt 0 ]]; then
        _p9k_get_icon prompt_vcs_$state VCS_STASH_ICON
        _$0_fmt STASH " $_p9k_ret$VCS_STATUS_STASHES"
      fi
    fi

    _p9k_cache_ephemeral_set "prompt_vcs_$state" "${__p9k_vcs_states[$state]}" "$_p9k_color1" "$icon" 0 '' "$content"
  fi

  _p9k_prompt_segment "$_p9k_cache_val[@]"
  return 0
}

function _p9k_maybe_ignore_git_repo() {
  if [[ $VCS_STATUS_RESULT == ok-* && $VCS_STATUS_WORKDIR == $~_POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN ]]; then
    VCS_STATUS_RESULT=norepo${VCS_STATUS_RESULT#ok}
  fi
}

function _p9k_vcs_resume() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases

  _p9k_maybe_ignore_git_repo

  if [[ $VCS_STATUS_RESULT == ok-async ]]; then
    local latency=$((EPOCHREALTIME - _p9k__gitstatus_start_time))
    if (( latency > _POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS )); then
      _p9k_git_slow[${${_p9k__git_dir:+GIT_DIR:$_p9k__git_dir}:-$VCS_STATUS_WORKDIR}]=1
    elif (( $1 && latency < 0.8 * _POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS )); then  # 0.8 to avoid flip-flopping
      _p9k_git_slow[${${_p9k__git_dir:+GIT_DIR:$_p9k__git_dir}:-$VCS_STATUS_WORKDIR}]=0
    fi
    _p9k_vcs_status_save
  fi

  if [[ -z $_p9k__gitstatus_next_dir ]]; then
    unset _p9k__gitstatus_next_dir
    case $VCS_STATUS_RESULT in
      norepo-async) (( $1 )) && _p9k_vcs_status_purge $_p9k_pwd_a;;
      ok-async) (( $1 )) || _p9k__gitstatus_next_dir=$_p9k_pwd_a;;
    esac
  fi

  if [[ -n $_p9k__gitstatus_next_dir ]]; then
    _p9k__git_dir=$GIT_DIR
    if ! gitstatus_query -d $_p9k__gitstatus_next_dir -t 0 -c '_p9k_vcs_resume 1' POWERLEVEL9K; then
      unset _p9k__gitstatus_next_dir
      unset VCS_STATUS_RESULT
    else
      _p9k_maybe_ignore_git_repo
      case $VCS_STATUS_RESULT in
        tout) _p9k__gitstatus_next_dir=''; _p9k__gitstatus_start_time=$EPOCHREALTIME;;
        norepo-sync) _p9k_vcs_status_purge $_p9k__gitstatus_next_dir; unset _p9k__gitstatus_next_dir;;
        ok-sync) _p9k_vcs_status_save; unset _p9k__gitstatus_next_dir;;
      esac
    fi
  fi

  _p9k_refresh_reason=gitstatus
  _p9k_set_prompt
  _p9k_refresh_reason=''
  _p9k_reset_prompt
}

function _p9k_vcs_gitstatus() {
  if [[ $_p9k_refresh_reason == precmd ]]; then
    if (( $+_p9k__gitstatus_next_dir )); then
      _p9k__gitstatus_next_dir=$_p9k_pwd_a
    else
      local -F timeout=_POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS
      if ! _p9k_vcs_status_for_dir; then
        _p9k__git_dir=$GIT_DIR
        gitstatus_query -d $_p9k_pwd_a -t $timeout -p -c '_p9k_vcs_resume 0' POWERLEVEL9K || return 1
        _p9k_maybe_ignore_git_repo
        case $VCS_STATUS_RESULT in
          tout) _p9k__gitstatus_next_dir=''; _p9k__gitstatus_start_time=$EPOCHREALTIME; return 0;;
          norepo-sync) return 0;;
          ok-sync) _p9k_vcs_status_save;;
        esac
      else
        if [[ -n $GIT_DIR ]]; then
          [[ $_p9k_git_slow[GIT_DIR:$GIT_DIR] == 1 ]] && timeout=0
        else
          local dir=$_p9k_pwd_a
          while true; do
            case $_p9k_git_slow[$dir] in
              "") [[ $dir == / ]] && break; dir=${dir:h};;
              0) break;;
              1) timeout=0; break;;
            esac
          done
        fi
      fi
      (( _p9k__prompt_idx == 1 )) && timeout=0
      _p9k__git_dir=$GIT_DIR
      if ! gitstatus_query -d $_p9k_pwd_a -t $timeout -c '_p9k_vcs_resume 1' POWERLEVEL9K; then
        unset VCS_STATUS_RESULT
        return 1
      fi
      _p9k_maybe_ignore_git_repo
      case $VCS_STATUS_RESULT in
        tout) _p9k__gitstatus_next_dir=''; _p9k__gitstatus_start_time=$EPOCHREALTIME;;
        norepo-sync) _p9k_vcs_status_purge $_p9k_pwd_a;;
        ok-sync) _p9k_vcs_status_save;;
      esac
    fi
  fi
  return 0
}

################################################################
# Segment to show VCS information

prompt_vcs() {
  local -a backends=($_POWERLEVEL9K_VCS_BACKENDS)
  if (( ${backends[(I)git]} && !_p9k__gitstatus_disabled )) && _p9k_vcs_gitstatus; then
    _p9k_vcs_render && return
    backends=(${backends:#git})
  fi
  if (( $#backends )); then
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
        current_state='MODIFIED'
      else
        if [[ "$VCS_WORKDIR_HALF_DIRTY" == true ]]; then
          current_state='UNTRACKED'
        else
          current_state='CLEAN'
        fi
      fi
      _p9k_prompt_segment "${0}_${(U)current_state}" "${__p9k_vcs_states[$current_state]}" "$_p9k_color1" "$vcs_visual_identifier" 0 '' "$vcs_prompt"
    fi
  fi
}

################################################################
# Vi Mode: show editing mode (NORMAL|INSERT|VISUAL)
prompt_vi_mode() {
  if (( __p9k_sh_glob )); then
    if (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING )); then
      if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
        _p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
      fi
      _p9k_prompt_segment $0_OVERWRITE "$_p9k_color1" blue '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' "$_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING"
    else
      if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
        _p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
      fi
    fi

    if (( $+_POWERLEVEL9K_VI_VISUAL_MODE_STRING )); then
      _p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
      _p9k_prompt_segment $0_VISUAL "$_p9k_color1" white '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' "$_POWERLEVEL9K_VI_VISUAL_MODE_STRING"
    else
      _p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${$((! ${#${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}})):#0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
    fi
  else
    if (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING )); then
      if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
        _p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
      fi
      _p9k_prompt_segment $0_OVERWRITE "$_p9k_color1" blue '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' "$_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING"
    else
      if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
        _p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
      fi
    fi

    if (( $+_POWERLEVEL9K_VI_VISUAL_MODE_STRING )); then
      _p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
      _p9k_prompt_segment $0_VISUAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' "$_POWERLEVEL9K_VI_VISUAL_MODE_STRING"
    else
      _p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)_p9k__keymap:#(vicmd|vivis|vivli)}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
    fi
  fi
}

instant_prompt_vi_mode() {
  if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
    _p9k_prompt_segment prompt_vi_mode_INSERT "$_p9k_color1" blue '' 0 '' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
  fi
}

################################################################
# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  [[ -n $VIRTUAL_ENV ]] || return
  local msg=''
  if (( _POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION )) && _p9k_python_version; then
    msg="${_p9k_ret//\%/%%} "
  fi
  local v=${VIRTUAL_ENV:t}
  (( _POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES[(I)$v] )) && v=${VIRTUAL_ENV:h:t}
  msg+="$_POWERLEVEL9K_VIRTUALENV_LEFT_DELIMITER${v//\%/%%}$_POWERLEVEL9K_VIRTUALENV_RIGHT_DELIMITER"
  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "$msg"
}

function _p9k_read_pyenv_version_file() {
  [[ -r $1 ]] || return
  local content
  IFS='' read -rd $'\0' content <$1 2>/dev/null
  _p9k_ret=${${(j.:.)${(@)${=content}#python-}:-system}}
}

function _p9k_pyenv_global_version() {
  _p9k_read_pyenv_version_file ${PYENV_ROOT:-$HOME/.pyenv}/version || _p9k_ret=system
}

################################################################
# Segment to display pyenv information
# https://github.com/pyenv/pyenv#choosing-the-python-version
prompt_pyenv() {
  (( $+commands[pyenv] || $+functions[pyenv] )) || return
  local v=${(j.:.)${(@)${(s.:.)PYENV_VERSION}#python-}}
  if [[ -n $v ]]; then
    (( ${_POWERLEVEL9K_PYENV_SOURCES[(I)shell]} )) || return
  else
    (( ${_POWERLEVEL9K_PYENV_SOURCES[(I)local|global]} )) || return
    [[ $PYENV_DIR == /* ]] && local dir=$PYENV_DIR || local dir="$_p9k_pwd_a/$PYENV_DIR"
    while true; do
      if _p9k_read_pyenv_version_file $dir/.python-version; then
        (( ${_POWERLEVEL9K_PYENV_SOURCES[(I)local]} )) || return
        v=$_p9k_ret
        break
      fi
      if [[ $dir == / ]]; then
        (( _POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW )) || return
        (( ${_POWERLEVEL9K_PYENV_SOURCES[(I)global]} )) || return
        _p9k_pyenv_global_version
        v=$_p9k_ret
        break
      fi
      dir=${dir:h}
    done
  fi

  if (( !_POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_pyenv_global_version
    [[ $v == $_p9k_ret ]] && return
  fi

  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "${v//\%/%%}"
}

function _p9k_read_goenv_version_file() {
  [[ -r $1 ]] || return
  local content
  IFS='' read -rd $'\0' content <$1 2>/dev/null
  _p9k_ret=${${(j.:.)${=content}:-system}}
}

function _p9k_goenv_global_version() {
  _p9k_read_goenv_version_file ${GOENV_ROOT:-$HOME/.goenv}/version || _p9k_ret=system
}

################################################################
# Segment to display goenv information: https://github.com/syndbg/goenv
prompt_goenv() {
  (( $+commands[goenv] || $+functions[goenv] )) || return
  local v=${(j.:.)${(s.:.)GOENV_VERSION}}
  if [[ -z $v ]]; then
    [[ $GOENV_DIR == /* ]] && local dir=$GOENV_DIR || local dir="$_p9k_pwd_a/$GOENV_DIR"
    while true; do
      if _p9k_read_goenv_version_file $dir/.go-version; then
        v=$_p9k_ret
        break
      fi
      if [[ $dir == / ]]; then
        (( _POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW )) || return
        _p9k_goenv_global_version
        v=$_p9k_ret
        break
      fi
      dir=${dir:h}
    done
  fi

  if (( !_POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW )); then
    _p9k_goenv_global_version
    [[ $v == $_p9k_ret ]] && return
  fi

  _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'GO_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Display openfoam information
prompt_openfoam() {
  local wm_project_version="$WM_PROJECT_VERSION"
  local wm_fork="$WM_FORK"
  if [[ -n "$wm_project_version" && -z "$wm_fork" ]] ; then
    _p9k_prompt_segment "$0" "yellow" "$_p9k_color1" '' 0 '' "OF: ${${wm_project_version:t}//\%/%%}"
  elif [[ -n "$wm_project_version" && -n "$wm_fork" ]] ; then
    _p9k_prompt_segment "$0" "yellow" "$_p9k_color1" '' 0 '' "F-X: ${${wm_project_version:t}//\%/%%}"
  fi
}

################################################################
# Segment to display Swift version
prompt_swift_version() {
  _p9k_cached_cmd_stdout swift --version || return
  [[ $_p9k_ret == (#b)[^[:digit:]]#([[:digit:].]##)* ]] || return
  _p9k_prompt_segment "$0" "magenta" "white" 'SWIFT_ICON' 0 '' "${match[1]//\%/%%}"
}

################################################################
# dir_writable: Display information about the user's permission to write in the current directory
prompt_dir_writable() {
  if [[ ! -w "$_p9k_pwd" ]]; then
    _p9k_prompt_segment "$0_FORBIDDEN" "red" "yellow1" 'LOCK_ICON' 0 '' ''
  fi
}

instant_prompt_dir_writable() { prompt_dir_writable; }

################################################################
# Kubernetes Current Context/Namespace
prompt_kubecontext() {
  (( $+commands[kubectl] )) || return

  if ! _p9k_cache_stat_get $0 ${(s.:.)${KUBECONFIG:-$HOME/.kube/config}}; then
    local name namespace cluster cloud_name cloud_account cloud_zone cloud_cluster text state
    () {
      local cfg && cfg=(${(f)"$(kubectl config view -o=yaml 2>/dev/null)"}) || return
      local ctx=(${(@M)cfg:#current-context: [^\"\'\|\>]*})
      (( $#ctx == 1 )) || return
      name=${ctx[1]#current-context: }
      local -i pos=${cfg[(i)contexts:]}
      (( pos <= $#cfg )) || return
      shift $pos cfg
      pos=${cfg[(i)  name: $name]}
      (( pos <= $#cfg )) || return
      (( --pos ))
      for ((; pos > 0; --pos)); do
        local line=$cfg[pos]
        if [[ $line == '- context:' ]]; then
          return 0
        elif [[ $line == (#b)'    cluster: '([^\"\'\|\>]*) ]]; then
          cluster=$match[1]
        elif [[ $line == (#b)'    namespace: '([^\"\'\|\>]*) ]]; then
          namespace=$match[1]
        fi
      done
    }
    if [[ -n $name ]]; then
      : ${namespace:=default}
      # gke_my-account_us-east1-a_cluster-01
      # gke_my-account_us-east1_cluster-01
      if [[ $cluster == (#b)gke_(?*)_(asia|australia|europe|northamerica|southamerica|us)-([a-z]##<->)(-[a-z]|)_(?*) ]]; then
        cloud_name=gke
        cloud_account=$match[1]
        cloud_zone=$match[2]-$match[3]-$match[4]
        cloud_cluster=$match[5]
        if (( ${_POWERLEVEL9K_KUBECONTEXT_SHORTEN[(I)gke]} )); then
          text=$cloud_cluster
        fi
      # arn:aws:eks:us-east-1:123456789012:cluster/cluster-01
      elif [[ $cluster == (#b)arn:aws:eks:([[:alnum:]-]##):([[:digit:]]##):cluster/(?*) ]]; then
        cloud_name=eks
        cloud_zone=$match[1]
        cloud_account=$match[2]
        cloud_cluster=$match[3]
        if (( ${_POWERLEVEL9K_KUBECONTEXT_SHORTEN[(I)eks]} )); then
          text=$cloud_cluster
        fi
      fi
      if [[ -z $text ]]; then
        text=$name
        if [[ $_POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE == 1 || $namespace != (default|$name) ]]; then
          text+="/$namespace"
        fi
      fi
      local pat class
      for pat class in "${_POWERLEVEL9K_KUBECONTEXT_CLASSES[@]}"; do
        if [[ $text == ${~pat} ]]; then
          [[ -n $class ]] && state=_${(U)class}
          break
        fi
      done
    fi
    _p9k_cache_stat_set "$name" "$namespace" "$cluster" "$cloud_name" "$cloud_account" "$cloud_zone" "$cloud_cluster" "$text" "$state"
  fi

  typeset -g P9K_KUBECONTEXT_NAME=$_p9k_cache_val[1]
  typeset -g P9K_KUBECONTEXT_NAMESPACE=$_p9k_cache_val[2]
  typeset -g P9K_KUBECONTEXT_CLUSTER=$_p9k_cache_val[3]
  typeset -g P9K_KUBECONTEXT_CLOUD_NAME=$_p9k_cache_val[4]
  typeset -g P9K_KUBECONTEXT_CLOUD_ACCOUNT=$_p9k_cache_val[5]
  typeset -g P9K_KUBECONTEXT_CLOUD_ZONE=$_p9k_cache_val[6]
  typeset -g P9K_KUBECONTEXT_CLOUD_CLUSTER=$_p9k_cache_val[7]
  [[ -n $_p9k_cache_val[8] ]] || return
  _p9k_prompt_segment $0$_p9k_cache_val[9] magenta white KUBERNETES_ICON 0 '' "${_p9k_cache_val[8]//\%/%%}"
}

################################################################
# Dropbox status
prompt_dropbox() {
  (( $+commands[dropbox-cli] )) || return
  # The first column is just the directory, so cut it
  local dropbox_status="$(dropbox-cli filestatus . | cut -d\  -f2-)"

  # Only show if the folder is tracked and dropbox is running
  if [[ "$dropbox_status" != 'unwatched' && "$dropbox_status" != "isn't running!" ]]; then
    # If "up to date", only show the icon
    if [[ "$dropbox_status" =~ 'up to date' ]]; then
      dropbox_status=""
    fi

    _p9k_prompt_segment "$0" "white" "blue" "DROPBOX_ICON" 0 '' "${dropbox_status//\%/%%}"
  fi
}

# print Java version number
prompt_java_version() {
  _p9k_cached_cmd_stdout_stderr java -fullversion || return
  local v=$_p9k_ret
  v=${${v#*\"}%\"*}
  (( _POWERLEVEL9K_JAVA_VERSION_FULL )) || v=${v%%-*}
  [[ -n $v ]] || return
  _p9k_prompt_segment "$0" "red" "white" "JAVA_ICON" 0 '' "${v//\%/%%}"
}

prompt_azure() {
  (( $+commands[az] )) || return
  local cfg=${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json
  if ! _p9k_cache_stat_get $0 $cfg; then
    local name
    if (( $+commands[jq] )) && name="$(jq -r '[.subscriptions[]|select(.isDefault==true)|.name][]|strings' $cfg 2>/dev/null)"; then
      name=${name%%$'\n'*}
    elif ! name="$(az account show --query name --output tsv 2>/dev/null)"; then
      name=
    fi
    _p9k_cache_stat_set "$name"
  fi
  [[ -n $_p9k_cache_val[1] ]] || return
  _p9k_prompt_segment "$0" "blue" "white" "AZURE_ICON" 0 '' "${_p9k_cache_val[1]//\%/%%}"
}

prompt_gcloud() {
  unset P9K_GCLOUD_PROJECT P9K_GCLOUD_ACCOUNT
  (( $+commands[gcloud] )) || return
  local cfg=${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json
  if ! _p9k_cache_stat_get $0 ~/.config/gcloud/active_config ~/.config/gcloud/configurations/config_default; then
    _p9k_cache_stat_set "$(gcloud config get-value account 2>/dev/null)" "$(gcloud config get-value project 2>/dev/null)"
  fi
  [[ -n $_p9k_cache_val[1] || -n $_p9k_cache_val[2] ]] || return
  P9K_GCLOUD_ACCOUNT=$_p9k_cache_val[1]
  P9K_GCLOUD_PROJECT=$_p9k_cache_val[2]
  _p9k_prompt_segment "$0" "blue" "white" "GCLOUD_ICON" 0 '' "${P9K_GCLOUD_ACCOUNT//\%/%%}:${P9K_GCLOUD_PROJECT//\%/%%}"
}

typeset -gra __p9k_nordvpn_tag=(
  P9K_NORDVPN_STATUS
  P9K_NORDVPN_TECHNOLOGY
  P9K_NORDVPN_PROTOCOL
  P9K_NORDVPN_IP_ADDRESS
  P9K_NORDVPN_SERVER
  P9K_NORDVPN_COUNTRY
  P9K_NORDVPN_CITY
)

function _p9k_fetch_nordvpn_status() {
  setopt err_return
  local REPLY
  zsocket /run/nordvpnd.sock
  local -i fd=$REPLY
  {
    >&$fd echo -nE - $'PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n\0\0\0\4\1\0\0\0\0\0\0N\1\4\0\0\0\1\203\206E\221bA\226\223\325\\k\337\31i=LnH\323j?A\223\266\243y\270\303\fYmLT{$\357]R.\203\223\257_\213\35u\320b\r&=LMedz\212\232\312\310\264\307`+\210K\203@\2te\206M\2035\5\261\37\0\0\5\0\1\0\0\0\1\0\0\0\0\0'
    local tag len val
    local -i n
    IFS='' read -t 0.25 -r tag <&3
    tag=$'\015'
    while true; do
      tag=$((#tag))
      (( (tag >>= 3) && tag <= $#__p9k_nordvpn_tag )) || break
      tag=$__p9k_nordvpn_tag[tag]
      sysread -c n -s 1 -t 0.25 len <&3
      len=$((#len))
      val=
      (( ! len )) || {
        sysread -c n -s $len -t 0.25 val <&3
        (( n == len ))
      }
      typeset -g $tag=$val
      sysread -c n -s 1 -t 0.25 tag <&3
    done
  } always {
    exec {fd}>&-
  }
}

# Shows the state of NordVPN connection. Works only on Linux. Can be in the following 5 states.
#
# MISSING: NordVPN is not installed or nordvpnd is not running. By default the segment is not
# shown in this state. To make it visible, override POWERLEVEL9K_NORDVPN_MISSING_CONTENT_EXPANSION
# and/or POWERLEVEL9K_NORDVPN_MISSING_VISUAL_IDENTIFIER_EXPANSION.
#
#   # Display this icon when NordVPN is not installed or nordvpnd is not running
#   POWERLEVEL9K_NORDVPN_MISSING_VISUAL_IDENTIFIER_EXPANSION='⭐'
#
# CONNECTED: NordVPN is connected. By default shows LOCK_ICON as icon and country code as content.
# In addition, the following variables are set for the use by
# POWERLEVEL9K_NORDVPN_CONNECTED_VISUAL_IDENTIFIER_EXPANSION and
# POWERLEVEL9K_NORDVPN_CONNECTED_CONTENT_EXPANSION:
#
#   - P9K_NORDVPN_STATUS
#   - P9K_NORDVPN_PROTOCOL
#   - P9K_NORDVPN_TECHNOLOGY
#   - P9K_NORDVPN_IP_ADDRESS
#   - P9K_NORDVPN_SERVER
#   - P9K_NORDVPN_COUNTRY
#   - P9K_NORDVPN_CITY
#   - P9K_NORDVPN_COUNTRY_CODE
#
# The last variable is trivially derived from P9K_NORDVPN_SERVER. The rest correspond to the output
# lines of `nordvpn status` command. Example of using these variables:
#
#   # Display the name of the city where VPN servers are located when connected to NordVPN.
#   POWERLEVEL9K_NORDVPN_CONNECTED_CONTENT_EXPANSION='${P9K_NORDVPN_CITY}'
#
# DISCONNECTED, CONNECTING, DISCONNECTING: NordVPN is disconnected/connecting/disconnecting. By
# default shows LOCK_ICON as icon and FAIL_ICON as content. In state CONNECTING the same
# P9K_NORDVPN_* variables are set as in CONNECTED. In states DISCONNECTED and DISCONNECTING only
# P9K_NORDVPN_STATUS is set. Example customizations:
#
#   # Hide NordVPN segment when disconnected (segments with no icon and no content are not shown).
#   POWERLEVEL9K_NORDVPN_DISCONNECTED_CONTENT_EXPANSION=
#   POWERLEVEL9K_NORDVPN_DISCONNECTED_VISUAL_IDENTIFIER_EXPANSION=
#
#   # When NordVPN is connecting, show country code on cyan background.
#   POWERLEVEL9K_NORDVPN_CONNECTING_CONTENT_EXPANSION='${P9K_NORDVPN_COUNTRY_CODE}'
#   POWERLEVEL9K_NORDVPN_CONNECTING_BACKGROUND=cyan
function prompt_nordvpn() {
  unset $__p9k_nordvpn_tag P9K_NORDVPN_COUNTRY_CODE
  if [[ $+commands[nordvpn] == 1 && -e /run/nordvpnd.sock ]]; then
    _p9k_fetch_nordvpn_status 2>/dev/null
    if [[ $P9K_NORDVPN_SERVER == (#b)([[:alpha:]]##)[[:digit:]]##.nordvpn.com ]]; then
      typeset -g P9K_NORDVPN_COUNTRY_CODE=${(U)match[1]}
    fi
  fi
  case $P9K_NORDVPN_STATUS in
    Connected)
      _p9k_prompt_segment $0_CONNECTED blue   white LOCK_ICON 0 '' "$P9K_NORDVPN_COUNTRY_CODE";;
    Disconnected|Connecting|Disconnecting)
      local state=${(U)P9K_NORDVPN_STATUS}
      _p9k_get_icon $0_$state FAIL_ICON
      _p9k_prompt_segment $0_$state    yellow white LOCK_ICON 0 '' "$_p9k_ret";;
    *)
      _p9k_prompt_segment $0_MISSING   blue   white ''        0 '' '';;
  esac
}

function prompt_ranger() {
  [[ -n $RANGER_LEVEL ]] || return
  _p9k_prompt_segment $0 $_p9k_color1 yellow RANGER_ICON 0 '' $RANGER_LEVEL
}

function instant_prompt_ranger() {
  _p9k_prompt_segment prompt_ranger $_p9k_color1 yellow RANGER_ICON 1 '$RANGER_LEVEL' '$RANGER_LEVEL'
}

function prompt_midnight_commander() {
  [[ -n $MC_TMPDIR ]] || return
  _p9k_prompt_segment $0 $_p9k_color1 yellow MIDNIGHT_COMMANDER_ICON 0 '' ''
}

function instant_prompt_midnight_commander() {
  _p9k_prompt_segment prompt_midnight_commander $_p9k_color1 yellow MIDNIGHT_COMMANDER_ICON 0 '$MC_TMPDIR' ''
}

function prompt_vim_shell() {
  [[ -n $VIMRUNTIME ]] || return
  _p9k_prompt_segment $0 green $_p9k_color1 VIM_ICON 0 '' ''
}

function instant_prompt_vim_shell() {
  _p9k_prompt_segment prompt_vim_shell green $_p9k_color1 VIM_ICON 0 '$VIMRUNTIME' ''
}

function prompt_terraform() {
  (( $+commands[terraform] )) || return
  local ws=default
  if [[ -n $TF_WORKSPACE ]]; then
    ws=$TF_WORKSPACE
  else
    local f=${TF_DATA_DIR:-.terraform}/environment
    [[ -r $f ]] && _p9k_read_file $f && ws=$_p9k_ret
  fi
  ws=${${ws##[[:space:]]#}%%[[:space:]]#}
  [[ $ws == default ]] || _p9k_prompt_segment $0 $_p9k_color1 blue TERRAFORM_ICON 0 '' $ws
}

function prompt_proxy() {
  local -U p=(
    $all_proxy $http_proxy $https_proxy $ftp_proxy
    $ALL_PROXY $HTTP_PROXY $HTTPS_PROXY $FTP_PROXY)
  p=(${(@)${(@)${(@)p#*://}##*@}%%/*})
  (( $#p )) || return
  (( $#p == 1 )) || p=("")
  _p9k_prompt_segment $0 $_p9k_color1 blue PROXY_ICON 0 '' "$p[1]"
}

function prompt_direnv() {
  if [[ -n $DIRENV_DIR ]]; then
    _p9k_prompt_segment $0 $_p9k_color1 yellow DIRENV_ICON 0 '' ''
  elif [[ $precmd_functions[-1] != _p9k_precmd ]]; then
    # DIRENV_DIR is set in a precmd hook. If our hook isn't the last, DIRENV_DIR might
    # still get set before prompt is expanded.
    _p9k_prompt_segment $0 $_p9k_color1 yellow DIRENV_ICON 0 '$DIRENV_DIR' ''
  fi
}

function instant_prompt_direnv() {
  if [[ -n $DIRENV_DIR && $precmd_functions[-1] == _p9k_precmd ]]; then
    _p9k_prompt_segment prompt_direnv $_p9k_color1 yellow DIRENV_ICON 0 '' ''
  fi
}

_p9k_preexec() {
  if (( $+_p9k_real_zle_rprompt_indent )); then
    if [[ -n $_p9k_real_zle_rprompt_indent ]]; then
      ZLE_RPROMPT_INDENT=$_p9k_real_zle_rprompt_indent
    else
      unset ZLE_RPROMPT_INDENT
    fi
    unset _p9k_real_zle_rprompt_indent
  fi
  _p9k__preexec_cmd=$2
  _p9k__timer_start=EPOCHREALTIME
}

function _p9k_set_iface() {
  _p9k_iface=()
  if [[ -x /sbin/ifconfig ]]; then
    local line
    local iface
    for line in ${(f)"$(/sbin/ifconfig 2>/dev/null)"}; do
      if [[ $line == (#b)([^[:space:]]##):[[:space:]]##flags=(<->)'<'* ]]; then
        [[ $match[2] == *[13579] ]] && iface=$match[1] || iface=
      elif [[ -n $iface && $line == (#b)[[:space:]]##inet[[:space:]]##([0-9.]##)* ]]; then
        _p9k_iface[$iface]=$match[1]
        iface=
      fi
    done
  elif [[ -x /sbin/ip ]]; then
    local line
    local iface
    for line in ${(f)"$(/sbin/ip -4 a show 2>/dev/null)"}; do
      if [[ $line == (#b)<->:[[:space:]]##([^:]##):[[:space:]]##\<([^\>]#)\>* ]]; then
        [[ ,$match[2], == *,UP,* ]] && iface=$match[1] || iface=
      elif [[ -n $iface && $line == (#b)[[:space:]]##inet[[:space:]]##([0-9.]##)* ]]; then
        _p9k_iface[$iface]=$match[1]
        iface=
      fi
    done
  fi
}

function _p9k_build_segment() {
  _p9k_segment_name=${_p9k_segment_name%_joined}
  local disabled=_POWERLEVEL9K_${(U)_p9k_segment_name}_DISABLED_DIR_PATTERN
  [[ $_p9k_pwd == ${(P)~disabled} ]] && return
  if [[ $_p9k_segment_name == custom_* ]]; then
    _p9k_custom_prompt $_p9k_segment_name[8,-1]
  elif (( $+functions[prompt_$_p9k_segment_name] )); then
    prompt_$_p9k_segment_name
  fi
  ((++_p9k_segment_index))
}

function _p9k_build_instant_segment() {
  _p9k_segment_name=${_p9k_segment_name%_joined}
  local disabled=_POWERLEVEL9K_${(U)_p9k_segment_name}_DISABLED_DIR_PATTERN
  [[ $_p9k_pwd == ${(P)~disabled} ]] && return
  if (( $+functions[instant_prompt_$_p9k_segment_name] )); then
    local -i len=$#_p9k__prompt
    _p9k_non_hermetic_expansion=0
    instant_prompt_$_p9k_segment_name
    if (( _p9k_non_hermetic_expansion )); then
      _p9k__prompt[len+1,-1]=
    fi
  fi
  ((++_p9k_segment_index))
}

function _p9k_set_prompt() {
  local ifs=$IFS
  IFS=$' \t\n\0'
  _p9k_pwd=${(%):-%/}
  _p9k_pwd_a=${_p9k_pwd:A}
  PROMPT=
  RPROMPT=
  [[ $1 == instant_ ]] || PROMPT+='${$((_p9k_on_expand()))+}'
  PROMPT+=$_p9k_prompt_prefix_left

  (( _p9k_fetch_iface )) && _p9k_set_iface

  local -i left_idx=1 right_idx=1 num_lines=$#_p9k_line_segments_left
  for _p9k_line_index in {1..$num_lines}; do
    local right=
    if (( !_POWERLEVEL9K_DISABLE_RPROMPT )); then
      _p9k_dir=
      _p9k__prompt=
      _p9k_segment_index=right_idx
      _p9k_prompt_side=right
      for _p9k_segment_name in ${(@0)_p9k_line_segments_right[_p9k_line_index]}; do
        _p9k_build_${1}segment
      done
      _p9k__prompt=${${_p9k__prompt//$' %{\b'/'%{%G'}//$' \b'}
      right_idx=_p9k_segment_index
      if [[ -n $_p9k__prompt || $_p9k_line_never_empty_right[_p9k_line_index] == 1 ]]; then
        right=$_p9k_line_prefix_right[_p9k_line_index]$_p9k__prompt$_p9k_line_suffix_right[_p9k_line_index]
      fi
    fi
    unset _p9k_dir
    _p9k__prompt=$_p9k_line_prefix_left[_p9k_line_index]
    _p9k_segment_index=left_idx
    _p9k_prompt_side=left
    for _p9k_segment_name in ${(@0)_p9k_line_segments_left[_p9k_line_index]}; do
      _p9k_build_${1}segment
    done
    _p9k__prompt=${${_p9k__prompt//$' %{\b'/'%{%G'}//$' \b'}
    left_idx=_p9k_segment_index
    _p9k__prompt+=$_p9k_line_suffix_left[_p9k_line_index]
    if (( $+_p9k_dir || (_p9k_line_index != num_lines && $#right) )); then
      _p9k__prompt='${${:-${_p9k_d::=0}${_p9k_rprompt::='$right'}${_p9k_lprompt::='$_p9k__prompt'}}+}'
      _p9k__prompt+=$_p9k_gap_pre
      if (( $+_p9k_dir )); then
        if (( _p9k_line_index == num_lines && (_POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS > 0 || _POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT > 0) )); then
          local a=$_POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS
          local f=$((0.01*_POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT))'*_p9k_clm'
          _p9k__prompt+="\${\${_p9k_g::=$((($a<$f)*$f+($a>=$f)*$a))}+}"
        else
          _p9k__prompt+='${${_p9k_g::=0}+}'
        fi
        if [[ $_POWERLEVEL9K_DIR_MAX_LENGTH == <->('%'|) ]]; then
          local lim=
          if [[ $_POWERLEVEL9K_DIR_MAX_LENGTH[-1] == '%' ]]; then
            lim="$_p9k_dir_len-$((0.01*$_POWERLEVEL9K_DIR_MAX_LENGTH[1,-2]))*_p9k_clm"
          else
            lim=$((_p9k_dir_len-_POWERLEVEL9K_DIR_MAX_LENGTH))
            ((lim <= 0)) && lim=
          fi
          if [[ -n $lim ]]; then
            _p9k__prompt+='${${${$((_p9k_g<_p9k_m+'$lim')):#1}:-${_p9k_g::=$((_p9k_m+'$lim'))}}+}'
          fi
        fi
        _p9k__prompt+='${${_p9k_d::=$((_p9k_m-_p9k_g))}+}'
        _p9k__prompt+='${_p9k_lprompt/\%\{d\%\}*\%\{d\%\}/'$_p9k_dir'}'
        _p9k__prompt+='${${_p9k_m::=$((_p9k_d+_p9k_g))}+}'
      else
        _p9k__prompt+='${_p9k_lprompt}'
      fi
      ((_p9k_line_index != num_lines && $#right)) && _p9k__prompt+=$_p9k_line_gap_post[_p9k_line_index]
    fi
    if (( _p9k_line_index == num_lines )); then
      [[ -n $right ]] && RPROMPT=$_p9k_prompt_prefix_right$right$_p9k_prompt_suffix_right
      _p9k__prompt='${_p9k__'$_p9k_line_index'-'$_p9k__prompt'}'$_p9k_prompt_suffix_left
      [[ $1 == instant_ ]] || PROMPT+=$_p9k__prompt
    else
      [[ -n $right ]] || _p9k__prompt+=$'\n'
      PROMPT+='${_p9k__'$_p9k_line_index'-'$_p9k__prompt'}'
    fi
  done

  _p9k_prompt_side=
  (( $#_p9k_cache < _POWERLEVEL9K_MAX_CACHE_SIZE )) || _p9k_cache=()
  (( $#_p9k__cache_ephemeral < _POWERLEVEL9K_MAX_CACHE_SIZE )) || _p9k__cache_ephemeral=()
  IFS=$ifs
}

_p9k_set_instant_prompt() {
  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  _p9k_set_prompt instant_
  typeset -g _p9k_instant_prompt=$PROMPT$'\x1f'$_p9k__prompt$'\x1f'$RPROMPT
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt
}

typeset -gri __p9k_instant_prompt_version=12

_p9k_dump_instant_prompt() {
  local user=${(%):-%n}
  local root_dir=${__p9k_dump_file:h}
  local prompt_dir=${root_dir}/p10k-$user
  local root_file=$root_dir/p10k-instant-prompt-$user.zsh
  local prompt_file=$prompt_dir/prompt-${#_p9k_pwd}
  [[ -d $prompt_dir ]] || mkdir -p $prompt_dir || return
  [[ -w $root_dir && -w $prompt_dir ]] || return

  if [[ ! -e $root_file  ]]; then
    local tmp=$root_file.tmp.$$
    local -i fd
    sysopen -a -o creat,trunc -u fd $tmp || return
    {
      [[ $TERM_PROGRAM == Hyper ]] && local hyper='==' || local hyper='!='
      local -a display_v=("${_p9k__display_v[@]}")
      local -i i
      for ((i = 6; i <= $#display_v; i+=2)); do display_v[i]=show; done
      display_v[2]=hide
      display_v[4]=hide
      >&$fd print -r -- "() {
  emulate -L zsh
  (( ! \$+__p9k_instant_prompt_disabled )) || return
  typeset -gi __p9k_instant_prompt_disabled=1 __p9k_instant_prompt_sourced=$__p9k_instant_prompt_version
  [[ -t 0 && -t 1 && -t 2 && \$ZSH_VERSION == ${(q)ZSH_VERSION} && \$ZSH_PATCHLEVEL == ${(q)ZSH_PATCHLEVEL} &&
     \$TERM_PROGRAM $hyper 'Hyper' && \$+VTE_VERSION == $+VTE_VERSION &&
     \$POWERLEVEL9K_DISABLE_INSTANT_PROMPT != 'true' &&
     \$POWERLEVEL9K_INSTANT_PROMPT != 'off' ]] || { __p9k_instant_prompt_sourced=0; return 1; }
  local -i ZLE_RPROMPT_INDENT=${ZLE_RPROMPT_INDENT:-1}
  local PROMPT_EOL_MARK=${(q)PROMPT_EOL_MARK-%B%S%#%s%b}
  [[ -n \$SSH_CLIENT || -n \$SSH_TTY || -n \$SSH_CONNECTION ]] && local ssh=1 || local ssh=0
  local cr=\$'\r' lf=\$'\n' esc=\$'\e[' rs=$'\x1e' us=$'\x1f'
  local -i height=$_POWERLEVEL9K_INSTANT_PROMPT_COMMAND_LINES
  local prompt_dir=${(q)prompt_dir}
  zmodload zsh/langinfo
  if [[ \${langinfo[CODESET]:-} != (utf|UTF)(-|)8 ]]; then
    local lc=${(q)${${${_p9k_locale:-${(M)LC_CTYPE:#*.(utf|UTF)(-|)8}}:-${(M)LC_ALL:#*.(utf|UTF)(-|)8}}}:-${(M)LANG:#*.(utf|UTF)(-|)8}}
    local LC_ALL=\${lc:-\${\${(@M)\$(locale -a 2>/dev/null):#*.(utf|UTF)(-|)8}[1]:-en_US.UTF-8}}
  fi"
      >&$fd print -r -- '
  zmodload zsh/terminfo
  (( $+terminfo[cuu] && $+terminfo[cuf] && $+terminfo[ed] && $+terminfo[sc] && $+terminfo[rc] )) || return
  local pwd=${(%):-%/}
  local prompt_file=$prompt_dir/prompt-${#pwd}
  local key=$pwd:$ssh:${(%):-%#}
  local content
  { content="$(<$prompt_file)" } 2>/dev/null || return
  local tail=${content##*$rs$key$us}
  [[ ${#tail} != ${#content} ]] || return
  local P9K_PROMPT=instant
  if (( ! $+P9K_TTY )); then'
      if (( _POWERLEVEL9K_NEW_TTY_MAX_AGE_SECONDS < 0 )); then
        >&$fd print -r -- '    typeset -gx P9K_TTY=new'
      else
        >&$fd print -r -- '
    typeset -gx P9K_TTY=old
    zmodload -F zsh/stat b:zstat
    zmodload zsh/datetime
    local -a stat
    if zstat -A stat +ctime -- $TTY 2>/dev/null &&
      (( EPOCHREALTIME - stat[1] < '$_POWERLEVEL9K_NEW_TTY_MAX_AGE_SECONDS' )); then
      P9K_TTY=new
    fi'
      fi
      >&$fd print -r -- '  fi
  local -i _p9k__empty_line_i=3 _p9k__ruler_i=3
  local -A _p9k__display_k=('${(j: :)${(@q)${(kv)_p9k__display_k}}}')
  local -a _p9k__display_v=('${(j: :)${(@q)display_v}}')
  function p10k() {
    emulate -L zsh
    setopt no_hist_expand extended_glob prompt_percent prompt_subst no_aliases
    [[ $1 == display ]] || return
    shift
    local opt match MATCH prev new pair list name var
    local -i k
    for opt; do
      pair=(${(s:=:)opt})
      list=(${(s:,:)${pair[2]}})
      for k in ${(u@)_p9k__display_k[(I)$pair[1]]:/(#m)*/$_p9k__display_k[$MATCH]}; do
        if (( $#list == 1 )); then
          [[ $_p9k__display_v[k+1] == $list[1] ]] && continue
          new=$list[1]
        else
          new=${list[list[(I)$_p9k__display_v[k+1]]+1]:-$list[1]}
          [[ $_p9k__display_v[k+1] == $new ]] && continue
        fi
        _p9k__display_v[k+1]=$new
        name=$_p9k__display_v[k]
        if [[ $name == (empty_line|ruler) ]]; then
          var=_p9k__${name}_i
          [[ $new == hide ]] && typeset -gi $var=3 || unset $var
        elif [[ $name == (#b)(<->)(*) ]]; then
          var=_p9k__${match[1]}${${${${match[2]//\/}/#left/l}/#right/r}/#gap/g}
          [[ $new == hide ]] && typeset -g $var= || unset $var
        fi
      done
    done
  }'
      if (( _POWERLEVEL9K_PROMPT_ADD_NEWLINE )); then
        >&$fd print -r -- '  [[ $P9K_TTY == old ]] && { unset _p9k__empty_line_i; _p9k__display_v[2]=print }'
      fi
      if (( _POWERLEVEL9K_SHOW_RULER )); then
        >&$fd print -r -- '[[ $P9K_TTY == old ]] && { unset _p9k__ruler_i; _p9k__display_v[4]=print }'
      fi
      if (( $+functions[p10k-on-pre-prompt] )); then
        >&$fd print -r -- '
  p10k-on-pre-prompt() { '$functions[p10k-on-pre-prompt]' }
  p10k-on-pre-prompt
  unfunction p10k-on-pre-prompt'
      fi
      >&$fd print -r -- '
  trap "unset -m _p9k__\*; unfunction p10k" EXIT
  local -a _p9k_t=("${(@ps:$us:)${tail%%$rs*}}")'
      if [[ $+VTE_VERSION == 1 || $TERM_PROGRAM == Hyper ]]; then
        if [[ $TERM_PROGRAM == Hyper ]]; then
          local bad_lines=40 bad_columns=100
        else
          local bad_lines=24 bad_columns=80
        fi
        >&$fd print -r -- '
  if (( LINES == '$bad_lines' && COLUMNS == '$bad_columns' )); then
    zmodload -F zsh/stat b:zstat
    zmodload zsh/datetime
    local -a tty_ctime
    if ! zstat -A tty_ctime +ctime -- $TTY 2>/dev/null || (( tty_ctime[1] + 2 > EPOCHREALTIME )); then
      zmodload zsh/datetime
      local -F deadline=$((EPOCHREALTIME+0.025))
      local tty_size
      while true; do
        if (( EPOCHREALTIME > deadline )) || ! tty_size="$(/bin/stty size 2>/dev/null)" || [[ $tty_size != <->" "<-> ]]; then
          (( $+_p9k__ruler_i )) || local -i _p9k__ruler_i=1
          local _p9k__g= _p9k__'$#_p9k_line_segments_right'r= _p9k__'$#_p9k_line_segments_right'r_frame=
          break
        fi
        if [[ $tty_size != "'$bad_lines' '$bad_columns'" ]]; then
          local lines_columns=(${=tty_size})
          local LINES=$lines_columns[1]
          local COLUMNS=$lines_columns[2]
          break
        fi
      done
    fi
  fi'
      fi
      (( __p9k_ksh_arrays )) && >&$fd print -r -- '  setopt ksh_arrays'
      (( __p9k_sh_glob )) && >&$fd print -r -- '  setopt sh_glob'
      >&$fd print -r -- '  typeset -ga __p9k_used_instant_prompt=("${(@e)_p9k_t[-3,-1]}")'
      (( __p9k_ksh_arrays )) && >&$fd print -r -- '  unsetopt ksh_arrays'
      (( __p9k_sh_glob )) && >&$fd print -r -- '  unsetopt sh_glob'
      >&$fd print -r -- '
  (( height += ${#${__p9k_used_instant_prompt[1]//[^$lf]}} ))
  local _p9k_ret
  function _p9k_prompt_length() {
    local COLUMNS=1024
    local -i x y=$#1 m
    if (( y )); then
      while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
        x=y
        (( y *= 2 ));
      done
      local xy
      while (( y > x + 1 )); do
        m=$(( x + (y - x) / 2 ))
        typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
      done
    fi
    _p9k_ret=$x
  }
  local out'
       [[ $+VTE_VERSION == 1 || $TERM_PROGRAM == Hyper ]] && >&$fd print -r -- '  if (( ! $+_p9k__g )); then'
       >&$fd print -r -- '
  [[ $PROMPT_EOL_MARK == "%B%S%#%s%b" ]] && _p9k_ret=1 || _p9k_prompt_length $PROMPT_EOL_MARK
  local -i fill=$((COLUMNS > _p9k_ret ? COLUMNS - _p9k_ret : 0))
  out+="${(%):-%b%k%f%s%u$PROMPT_EOL_MARK${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"'
        [[ $+VTE_VERSION == 1 || $TERM_PROGRAM == Hyper ]] && >&$fd print -r -- '  fi'
        >&$fd print -r -- '
  out+="${(pl.$height..$lf.)}$esc${height}A$terminfo[sc]"
  out+=${(%):-"$__p9k_used_instant_prompt[1]$__p9k_used_instant_prompt[2]"}
  if [[ -n $__p9k_used_instant_prompt[3] ]]; then
    _p9k_prompt_length "$__p9k_used_instant_prompt[2]"
    local -i left_len=_p9k_ret
    _p9k_prompt_length "$__p9k_used_instant_prompt[3]"
    local -i gap=$((COLUMNS - left_len - _p9k_ret - ZLE_RPROMPT_INDENT))
    if (( gap >= 40 )); then
      out+="${(pl.$gap.. .)}${(%):-${__p9k_used_instant_prompt[3]}%b%k%f%s%u}$cr$esc${left_len}C"
    fi
  fi
  typeset -g __p9k_instant_prompt_output=${TMPDIR:-/tmp}/p10k-instant-prompt-output-${(%):-%n}-$$
  { echo -n > $__p9k_instant_prompt_output } || return
  print -rn -- "$out" || return
  exec {__p9k_fd_0}<&0 {__p9k_fd_1}>&1 {__p9k_fd_2}>&2 0</dev/null 1>$__p9k_instant_prompt_output
  exec 2>&1
  typeset -gi __p9k_instant_prompt_active=1
  typeset -g __p9k_instant_prompt_dump_file=${XDG_CACHE_HOME:-~/.cache}/p10k-dump-${(%):-%n}.zsh
  if source $__p9k_instant_prompt_dump_file 2>/dev/null && (( $+functions[_p9k_preinit] )); then
    _p9k_preinit
  fi
  function _p9k_instant_prompt_precmd_first() {
    emulate -L zsh
    function _p9k_instant_prompt_sched_last() {
      (( $+__p9k_instant_prompt_active )) || return 0
      () {
        emulate -L zsh
        exec 0<&$__p9k_fd_0 1>&$__p9k_fd_1 2>&$__p9k_fd_2 {__p9k_fd_0}>&- {__p9k_fd_1}>&- {__p9k_fd_2}>&-
        unset __p9k_fd_0 __p9k_fd_1 __p9k_fd_2 __p9k_instant_prompt_active
        typeset -gi __p9k_instant_prompt_erased=1
        print -rn -- $terminfo[rc]${(%):-%b%k%f%s%u}$terminfo[ed]
        if [[ -s $__p9k_instant_prompt_output ]]; then
          cat $__p9k_instant_prompt_output 2>/dev/null
          local _p9k_ret mark="${PROMPT_EOL_MARK-%B%S%#%s%b}"
          _p9k_prompt_length $mark
          local -i fill=$((COLUMNS > _p9k_ret ? COLUMNS - _p9k_ret : 0))
          echo -nE - "${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"
        fi
        zmodload -F zsh/files b:zf_rm
        zf_rm -f -- $__p9k_instant_prompt_output ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh{,.zwc} 2>/dev/null
      }
      setopt no_local_options prompt_cr prompt_sp
    }
    zmodload zsh/sched
    sched +0 _p9k_instant_prompt_sched_last
    precmd_functions=(${(@)precmd_functions:#_p9k_instant_prompt_precmd_first})
  }
  precmd_functions=(_p9k_instant_prompt_precmd_first $precmd_functions)
} && unsetopt prompt_cr prompt_sp || true'
    } always {
      exec {fd}>&-
    }
    zf_mv -f $tmp $root_file || return
    zcompile $root_file || return
  fi

  local tmp=$prompt_file.tmp.$$
  zf_mv -f $prompt_file $tmp 2>/dev/null
  if [[ "$(<$prompt_file)" == *$'\x1e'$_p9k__instant_prompt_sig$'\x1f'* ]] 2>/dev/null; then
    echo -n >$tmp || return
  fi

  { print -rn -- entry=$'\x1e'$_p9k__instant_prompt_sig$'\x1f'${(pj:\x1f:)_p9k_t}$'\x1f'$_p9k_instant_prompt >>$tmp } 2>/dev/null || return
  zf_mv -f $tmp $prompt_file 2>/dev/null || return
}

powerlevel9k_refresh_prompt_inplace() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  (( __p9k_enabled )) || return
  _p9k_refresh_reason=precmd
  _p9k_set_prompt
  _p9k_refresh_reason=''
}

p9k_refresh_prompt_inplace() { powerlevel9k_refresh_prompt_inplace }

typeset -gi __p9k_sh_glob
typeset -gi __p9k_ksh_arrays
typeset -gi __p9k_new_status
typeset -ga __p9k_new_pipestatus

_p9k_save_status() {
  local -i pipe
  if (( !$+_p9k__line_finished )); then
    :  # SIGINT
  elif (( !$+_p9k__preexec_cmd )); then
    # Empty line, comment or parse error.
    #
    # This case is handled incorrectly:
    #
    #   true | false
    #   |
    #
    # Here status=1 and pipestatus=(0 1). Ideally we should ignore pipestatus but we won't.
    #
    # This works though (unless pipefail is set):
    #
    #   false | true
    #   |
    #
    # We get status=1 and pipestatus=(1 0) and correctly ignore pipestatus.
    (( _p9k__status == __p9k_new_status )) && return
  elif (( $__p9k_new_pipestatus[(I)$__p9k_new_status] )); then  # just in case
    local cmd=(${(z)_p9k__preexec_cmd})
    if [[ $#cmd != 0 && $cmd[1] != '!' && ${(Q)cmd[1]} != coproc ]]; then
      local arg
      for arg in ${(z)_p9k__preexec_cmd}; do
        # '()' is for functions, *';' is for complex commands.
        if [[ $arg == ('()'|'&&'|'||'|'&'|'&|'|'&!'|*';') ]]; then
          pipe=0
          break
        elif [[ $arg == *('|'|'|&')* ]]; then
          pipe=1
        fi
      done
    fi
  fi
  _p9k__status=$__p9k_new_status
  if (( pipe )); then
    _p9k__pipestatus=($__p9k_new_pipestatus)
  else
    _p9k__pipestatus=($_p9k__status)
  fi
}

function _p9k_dump_state() {
  local dir=${__p9k_dump_file:h}
  [[ -d $dir ]] || mkdir -p $dir || return
  [[ -w $dir ]] || return
  local tmp=$__p9k_dump_file.$$-$EPOCHREALTIME-$RANDOM
  local -i fd
  sysopen -a -m 600 -o creat,trunc -u fd $tmp || return
  {
    typeset -g __p9k_cached_param_pat=$_p9k__param_pat
    typeset -g __p9k_cached_param_sig=$_p9k__param_sig
    typeset -pm __p9k_cached_param_pat __p9k_cached_param_sig >&$fd || return
    unset __p9k_cached_param_pat __p9k_cached_param_sig
    (( $+_p9k_preinit )) && { print -r -- $_p9k_preinit >&$fd || return }
    print -r -- '_p9k_restore_state_impl() {' >&$fd || return
    typeset -pm '_POWERLEVEL9K_*|_p9k_[^_]*|icons|OS|DEFAULT_COLOR|DEFAULT_COLOR_INVERTED' >&$fd || return
    print -r -- '}' >&$fd || return
  } always {
    exec {fd}>&-
  }
  zf_mv -f $tmp $__p9k_dump_file || return
  zcompile $__p9k_dump_file
}

function _p9k_restore_state() {
  {
    [[ $__p9k_cached_param_pat == $_p9k__param_pat && $__p9k_cached_param_sig == $_p9k__param_sig ]] || return
    (( $+functions[_p9k_restore_state_impl] )) || return
    _p9k_restore_state_impl
    _p9k_state_restored=1
  } always {
    unset __p9k_cached_param_sig
    if (( !_p9k_state_restored )); then
      if (( $+functions[_p9k_preinit] )); then
        unfunction _p9k_preinit
        (( $+functions[gitstatus_stop] )) && gitstatus_stop POWERLEVEL9K
      fi
      local user=${(%):-%n}
      local root_dir=${__p9k_dump_file:h}
      zf_rm -f -- $root_dir/p10k-instant-prompt-$user.zsh{,.zwc} ${root_dir}/p10k-$user/prompt-*(N) 2>/dev/null
    fi
  }
}

function _p9k_clear_instant_prompt() {
  if (( $+__p9k_fd_0 )); then
    exec 0<&$__p9k_fd_0 {__p9k_fd_0}>&-
    unset __p9k_fd_0
  fi
  exec 1>&$__p9k_fd_1 2>&$__p9k_fd_2 {__p9k_fd_1}>&- {__p9k_fd_2}>&-
  unset __p9k_fd_1 __p9k_fd_2
  if (( _p9k__can_hide_cursor )); then
    echoti civis
    _p9k__cursor_hidden=1
  fi
  if [[ -s $__p9k_instant_prompt_output ]]; then
    {
      local content
      [[ $_POWERLEVEL9K_INSTANT_PROMPT == verbose ]] && content="$(<$__p9k_instant_prompt_output)"
      local mark="${PROMPT_EOL_MARK-%B%S%#%s%b}"
      _p9k_prompt_length $mark
      local -i fill=$((COLUMNS > _p9k_ret ? COLUMNS - _p9k_ret : 0))
      local cr=$'\r'
      local sp="${(%):-%b%k%f%s%u$mark${(pl.$fill.. .)}$cr%b%k%f%s%u%E}"
      print -rn -- $terminfo[rc]${(%):-%b%k%f%s%u}$terminfo[ed]
      if [[ -n ${(S)content//$'\e'*($'\a'|$'\e\\')} ]]; then
        echo -E - ""
        echo -E - "${(%):-[%3FWARNING%f]: Console output during zsh initialization detected.}"
        echo -E - ""
        echo -E - "${(%):-When using Powerlevel10k with instant prompt, console output during zsh}"
        echo -E - "${(%):-initialization may indicate issues.}"
        echo -E - ""
        echo -E - "${(%):-You can:}"
        echo -E - ""
        echo -E - "${(%):-  - %BRecommended%b: Change %B$__p9k_zshrc_u%b so that it does not perform console I/O}"
        echo -E - "${(%):-    after the instant prompt preamble. See the link below for details.}"
        echo -E - ""
        echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
        echo -E - "${(%):-    * Zsh will start %Bquickly%b and prompt will update %Bsmoothly%b.}"
        echo -E - ""
        echo -E - "${(%):-  - Suppress this warning either by running %Bp10k configure%b or by manually}"
        echo -E - "${(%):-    defining the following parameter:}"
        echo -E - ""
        echo -E - "${(%):-      %3Ftypeset%f -g POWERLEVEL9K_INSTANT_PROMPT=quiet}"
        echo -E - ""
        echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
        echo -E - "${(%):-    * Zsh will start %Bquickly%b but prompt will %Bjump down%b after initialization.}"
        echo -E - ""
        echo -E - "${(%):-  - Disable instant prompt either by running %Bp10k configure%b or by manually}"
        echo -E - "${(%):-    defining the following parameter:}"
        echo -E - ""
        echo -E - "${(%):-      %3Ftypeset%f -g POWERLEVEL9K_INSTANT_PROMPT=off}"
        echo -E - ""
        echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
        echo -E - "${(%):-    * Zsh will start %Bslowly%b.}"
        echo -E - ""
        echo -E - "${(%):-  - Do nothing.}"
        echo -E - ""
        echo -E - "${(%):-    * You %Bwill%b see this error message every time you start zsh.}"
        echo -E - "${(%):-    * Zsh will start %Bquickly%b but prompt will %Bjump down%b after initialization.}"
        echo -E - ""
        echo -E - "${(%):-For details, see:}"
        echo    - "${(%):-\e]8;;https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt\ahttps://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt\e]8;;\a}"
        echo -E - ""
        echo    - "${(%):-%3F-- console output produced during zsh initialization follows --%f}"
        echo -E - ""
      fi
      cat $__p9k_instant_prompt_output
      echo -nE - $sp
      zf_rm -f -- $__p9k_instant_prompt_output
    } 2>/dev/null
  else
    zf_rm -f -- $__p9k_instant_prompt_output 2>/dev/null
    print -rn -- $terminfo[rc]${(%):-%b%k%f%s%u}$terminfo[ed]
  fi
  prompt_opts=(percent subst sp cr)
  if [[ $_POWERLEVEL9K_DISABLE_INSTANT_PROMPT == 0 && -o prompt_cr ]]; then
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-[%1FERROR%f]: When using Powerlevel10k with instant prompt, %Bprompt_cr%b must be unset.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-You can:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - %BRecommended%b: call %Bp10k finalize%b at the end of %B$__p9k_zshrc_u%b.}"
    >&2 echo -E - "${(%):-    You can do this by running the following command:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-      %2Fecho%f %3F'(( ! \${+functions[p10k]\} )) || p10k finalize'%f >>! $__p9k_zshrc_u}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bquickly%b and %Bwithout%b prompt flickering.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Find where %Bprompt_cr%b option gets sets in your zsh configs and stop setting it.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bquickly%b and %Bwithout%b prompt flickering.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Disable instant prompt either by running %Bp10k configure%b or by manually}"
    >&2 echo -E - "${(%):-    defining the following parameter:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-      %3Ftypeset%f -g POWERLEVEL9K_INSTANT_PROMPT=off}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bslowly%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Do nothing.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill%b see this error message every time you start zsh.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bquckly%b but %Bwith%b prompt flickering.}"
    >&2 echo -E - ""
  fi
}

function _p9k_maybe_dump() {
  (( __p9k_dumps_enabled )) || return 0

  _p9k__instant_prompt_sig=$_p9k_pwd:$P9K_SSH:${(%):-%#}

  if (( ! _p9k__dump_pid )) || ! kill -0 $_p9k__dump_pid 2>/dev/null; then
    _p9k__dump_pid=0
    if (( _p9k__prompt_idx == 1 )) then
      (( _p9k__instant_prompt_disabled )) || _p9k_set_instant_prompt
      if (( !_p9k_state_restored )); then
        if (( !_p9k__instant_prompt_disabled )); then
          _p9k_dump_instant_prompt
          _p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig]=1
        fi
        _p9k_dump_state
        _p9k__state_dump_scheduled=0
      elif [[ $_p9k__instant_prompt_disabled == 0 &&
              "${(pj:\x1f:)__p9k_used_instant_prompt}" != "${(e)_p9k_instant_prompt}" ]]; then
        _p9k_dump_instant_prompt
        if (( ! $+_p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig] )); then
          _p9k_dump_state
          _p9k__state_dump_scheduled=0
          _p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig]=1
        fi
      fi
    elif (( _p9k__state_dump_scheduled || ! (_p9k__instant_prompt_disabled || $+_p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig]) )); then
      setopt no_bg_nice
      (
        if ! (( _p9k__instant_prompt_disabled || $+_p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig] )); then
          _p9k_set_instant_prompt
          _p9k_dump_instant_prompt
          _p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig]=1
        fi
        _p9k_dump_state
      ) &!
      _p9k__dump_pid=$!
      _p9k__state_dump_scheduled=0
      (( _p9k__instant_prompt_disabled )) || _p9k_dumped_instant_prompt_sigs[$_p9k__instant_prompt_sig]=1
    fi
  fi
}

function _p9k_on_expand() {
  (( _p9k__expanded && ! $+__p9k_instant_prompt_active )) && return

  () {
    emulate -L zsh
    setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases

    _p9k_maybe_dump
    (( $+__p9k_instant_prompt_active )) && _p9k_clear_instant_prompt

    (( _p9k__expanded )) && return
    _p9k__expanded=1

    if (( ! $+P9K_TTY )); then
      typeset -gx P9K_TTY=old
      if (( _POWERLEVEL9K_NEW_TTY_MAX_AGE_SECONDS < 0 )); then
        P9K_TTY=new
      else
        local -a stat
        if zstat -A stat +ctime -- $TTY 2>/dev/null &&
          (( EPOCHREALTIME - stat[1] < _POWERLEVEL9K_NEW_TTY_MAX_AGE_SECONDS )); then
          P9K_TTY=new
        fi
      fi
    fi

    __p9k_reset_state=1

    if (( _POWERLEVEL9K_PROMPT_ADD_NEWLINE )); then
      if [[ $P9K_TTY == new ]]; then
        _p9k__empty_line_i=3
        _p9k__display_v[2]=hide
      elif [[ -z $_p9k_transient_prompt ]]; then
        _p9k__empty_line_i=3
        _p9k__display_v[2]=print
      else
        unset _p9k__empty_line_i
        _p9k__display_v[2]=show
      fi
    fi

    if (( _POWERLEVEL9K_SHOW_RULER )); then
      if [[ $P9K_TTY == new ]]; then
        _p9k__ruler_i=3
        _p9k__display_v[4]=hide
      elif [[ -z $_p9k_transient_prompt ]]; then
        _p9k__ruler_i=3
        _p9k__display_v[4]=print
      else
        unset _p9k__ruler_i
        _p9k__display_v[4]=show
      fi
    fi

    typeset -g P9K_PROMPT=regular

    if (( $+functions[p10k-on-pre-prompt] )); then
      p10k-on-pre-prompt
    fi

    __p9k_reset_state=0
    P9K_TTY=old

    [[ $_p9k__display_v[2] == print ]] && print -rn -- $_p9k_t[_p9k_empty_line_idx]
    if [[ $_p9k__display_v[4] == print ]]; then
      local ruler=$_p9k_t[_p9k_ruler_idx]
      () {
        (( __p9k_ksh_arrays )) && setopt ksh_arrays
        (( __p9k_sh_glob )) && setopt sh_glob
        print -rP -- $ruler
      }
    fi
  }

  if (( $+__p9k_instant_prompt_active )); then
    unset __p9k_instant_prompt_active
    unsetopt localoptions
    setopt prompt_sp prompt_cr
  fi
}
functions -M _p9k_on_expand

_p9k_precmd_impl() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases

  (( __p9k_enabled )) || return

  if ! zle || [[ -z $_p9k__param_sig ]]; then
    if zle; then
      __p9k_new_status=0
      __p9k_new_pipestatus=(0)
      _p9k__expanded=1
    else
      _p9k__expanded=0
    fi

    if (( $+_p9k_real_zle_rprompt_indent )); then
      if [[ -n $_p9k_real_zle_rprompt_indent ]]; then
        ZLE_RPROMPT_INDENT=$_p9k_real_zle_rprompt_indent
      else
        unset ZLE_RPROMPT_INDENT
      fi
      unset _p9k_real_zle_rprompt_indent
    fi

    if _p9k_must_init; then
      local -i instant_prompt_disabled
      if (( !__p9k_configured )); then
        __p9k_configured=1
        if [[ "${parameters[(I)POWERLEVEL9K_*]}" == (POWERLEVEL9K_MODE|) ]]; then
          _p9k_can_configure -q
          case $? in
            0)
              (
                source "$__p9k_root_dir"/internal/wizard.zsh
              )
              if (( $? )); then
                instant_prompt_disabled=1
              else
                source "$__p9k_cfg_path"
                _p9k__force_must_init=1
                _p9k_must_init
              fi
            ;;
            2)
              zf_rm -f -- ${__p9k_dump_file:h}/p10k-instant-prompt-${(%):-%n}.zsh{,.zwc} 2>/dev/null
              instant_prompt_disabled=1
            ;;
          esac
        fi
      fi
      _p9k_init
      _p9k__instant_prompt_disabled=$((_POWERLEVEL9K_DISABLE_INSTANT_PROMPT || instant_prompt_disabled))
    fi

    if (( _p9k__timer_start )); then
      typeset -gF P9K_COMMAND_DURATION_SECONDS=$((EPOCHREALTIME - _p9k__timer_start))
    else
      unset P9K_COMMAND_DURATION_SECONDS
    fi
    _p9k_save_status

    _p9k__timer_start=0
    _p9k__region_active=0

    unset _p9k__line_finished
    unset _p9k__preexec_cmd
    _p9k__keymap=main
    _p9k__zle_state=insert

    (( ++_p9k__prompt_idx ))
  fi

  _p9k_refresh_reason=precmd
  _p9k_set_prompt
  _p9k_refresh_reason=''

  if [[ $precmd_functions[-1] != _p9k_precmd && $precmd_functions[(I)_p9k_precmd] != 0 ]]; then
    precmd_functions=(${(@)precmd_functions:#_p9k_precmd} _p9k_precmd)
  fi
  if [[ $precmd_functions[1] != _p9k_do_nothing && $precmd_functions[(I)_p9k_do_nothing] != 0 ]]; then
    precmd_functions=(_p9k_do_nothing ${(@)precmd_functions:#_p9k_do_nothing})
  fi
}

_p9k_trapint() {
  if (( __p9k_enabled )); then
    emulate -L zsh
    setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst}
    _p9k_zle_line_finish
  fi
}

_p9k_precmd() {
  __p9k_new_status=$?
  __p9k_new_pipestatus=($pipestatus)
  [[ -o ksh_arrays ]] && __p9k_ksh_arrays=1 || __p9k_ksh_arrays=0
  [[ -o sh_glob ]] && __p9k_sh_glob=1 || __p9k_sh_glob=0

  _p9k_precmd_impl

  unsetopt localoptions
  setopt nopromptbang prompt_percent prompt_subst

  if (( ! $+functions[TRAPINT] )); then
    trap '_p9k_trapint; return 130' INT
  fi
}

function _p9k_reset_prompt() {
  if zle && [[ -z $_p9k__line_finished ]]; then
    (( __p9k_ksh_arrays )) && setopt ksh_arrays
    (( __p9k_sh_glob )) && setopt sh_glob
    (( _p9k__can_hide_cursor )) && echoti civis
    zle .reset-prompt
    zle -R
    (( _p9k__can_hide_cursor )) && echoti cnorm
  fi
}

function _p9k_zle_keymap_select() {
  _p9k_reset_prompt
}

function _p9k_zle_state_changed() {
  _p9k_reset_prompt
}

_p9k_deinit_async_pump() {
  if (( _p9k__async_pump_lock_fd )); then
    zsystem flock -u $_p9k__async_pump_lock_fd
    _p9k__async_pump_lock_fd=0
  fi
  if (( _p9k__async_pump_fd )); then
    zle -F $_p9k__async_pump_fd
    exec {_p9k__async_pump_fd}>&-
    _p9k__async_pump_fd=0
  fi
  if (( _p9k__async_pump_pid )); then
    kill -- -$_p9k__async_pump_pid &>/dev/null
    _p9k__async_pump_pid=0
  fi
  if [[ -n $_p9k__async_pump_fifo ]]; then
    rm -f $_p9k__async_pump_fifo
    _p9k__async_pump_fifo=''
  fi
  if [[ -n $_p9k__async_pump_lock ]]; then
    rm -f $_p9k__async_pump_lock
    _p9k__async_pump_lock=''
  fi
  _p9k__async_pump_subshell=-1
  _p9k__async_pump_shell_pid=-1
  add-zsh-hook -D zshexit _p9k_kill_async_pump
}

function _p9k_on_async_message() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  if (( ARGC != 1 )); then
    _p9k_deinit_async_pump
    return 0
  fi
  local msg='' IFS=''
  while read -r -t -u $1 msg; do
    [[ $__p9k_enabled == 1 && $1 == $_p9k__async_pump_fd ]] && eval $_p9k__async_pump_line$msg
    _p9k__async_pump_line=
    msg=
  done
  _p9k__async_pump_line+=$msg
  [[ $__p9k_enabled == 1 && $1 == $_p9k__async_pump_fd ]] && _p9k_reset_prompt
}

function _p9k_async_pump() {
  emulate -L zsh                                 || return
  setopt no_aliases no_hist_expand extended_glob || return
  setopt no_prompt_bang prompt_{percent,subst}   || return
  zmodload zsh/system zsh/datetime               || return
  echo $$                                        || return

  local ip last_ip
  local -F next_ip_time
  while ! zsystem flock -t 0 $lock 2>/dev/null && kill -0 $parent_pid; do
    if (( time_realtime )); then
      echo || break
      # SIGWINCH is a workaround for a bug in zsh. After a background job completes, callbacks
      # registered with `zle -F` stop firing until the user presses any key or the process
      # receives a signal (any signal at all).
      # Fix: https://github.com/zsh-users/zsh/commit/5e11082349bf72897f93f3a4493a97a2caf15984.
      kill -WINCH $parent_pid
    fi
    if (( public_ip && EPOCHREALTIME >= next_ip_time )); then
      ip=
      local method=''
      local -F start=EPOCHREALTIME
      next_ip_time=$((start + 5))
      for method in $ip_methods $ip_methods; do
        case $method in
          dig)
            if (( $+commands[dig] )); then
              ip="$(dig +tries=1 +short -4 A myip.opendns.com @resolver1.opendns.com 2>/dev/null)"
              [[ $ip == ';'* ]] && ip=
              if [[ -z $ip ]]; then
                ip="$(dig +tries=1 +short -6 AAAA myip.opendns.com @resolver1.opendns.com 2>/dev/null)"
                [[ $ip == ';'* ]] && ip=
              fi
            fi
          ;;
          curl)
            if (( $+commands[curl] )); then
              ip="$(curl --max-time 5 -w '\n' "$ip_url" 2>/dev/null)"
            fi
          ;;
          wget)
            if (( $+commands[wget] )); then
              ip="$(wget -T 5 -qO- "$ip_url" 2>/dev/null)"
            fi
          ;;
        esac
        [[ $ip =~ '^[0-9a-f.:]+$' ]] || ip=''
        if [[ -n $ip ]]; then
          next_ip_time=$((start + tout))
          break
        fi
      done
      if [[ $ip != $last_ip ]]; then
        last_ip=$ip
        echo _p9k__public_ip=${(q)${${ip//\%/%%}//$'\n'}} || break
        kill -WINCH $parent_pid
      fi
    fi
    sleep 1
  done
  rm -f $lock $fifo
}

function _p9k_kill_async_pump() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  if [[ $ZSH_SUBSHELL == $_p9k__async_pump_subshell && $$ == $_p9k__async_pump_shell_pid ]]; then
    _p9k_deinit_async_pump
  fi
}

_p9k_init_async_pump() {
  local -i public_ip time_realtime
  _p9k_segment_in_use public_ip && public_ip=1
  _p9k_segment_in_use time && (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME )) && time_realtime=1
  (( public_ip || time_realtime )) || return

  _p9k_start_async_pump() {
    setopt err_return no_bg_nice

    _p9k__async_pump_lock=${TMPDIR:-/tmp}/p9k-$$-async-pump-lock.$EPOCHREALTIME.$RANDOM
    _p9k__async_pump_fifo=${TMPDIR:-/tmp}/p9k-$$-async-pump-fifo.$EPOCHREALTIME.$RANDOM
    echo -n >$_p9k__async_pump_lock
    mkfifo $_p9k__async_pump_fifo
    sysopen -rw -o cloexec,sync -u _p9k__async_pump_fd $_p9k__async_pump_fifo
    zle -F $_p9k__async_pump_fd _p9k_on_async_message
    zsystem flock -f _p9k__async_pump_lock_fd $_p9k__async_pump_lock

    local cmd="
      local -i public_ip=$public_ip time_realtime=$time_realtime parent_pid=$$
      local -a ip_methods=($_POWERLEVEL9K_PUBLIC_IP_METHODS)
      local -F tout=$_POWERLEVEL9K_PUBLIC_IP_TIMEOUT
      local ip_url=$_POWERLEVEL9K_PUBLIC_IP_HOST
      local lock=$_p9k__async_pump_lock
      local fifo=$_p9k__async_pump_fifo
      $functions[_p9k_async_pump]"

    local setsid=${commands[setsid]:-/usr/local/opt/util-linux/bin/setsid}
    [[ -f $setsid ]] && setsid=${(q)setsid} || setsid=
    local zsh=${${:-/proc/self/exe}:A}
    [[ -x $zsh ]] || zsh=zsh
    cmd="$setsid ${(q)zsh} -dfc ${(q)cmd} &!"
    $zsh --nobgnice -dfmc $cmd </dev/null >&$_p9k__async_pump_fd 2>/dev/null &!

    IFS='' read -t 5 -r -u $_p9k__async_pump_fd _p9k__async_pump_pid && (( _p9k__async_pump_pid ))

    _p9k__async_pump_subshell=$ZSH_SUBSHELL
    _p9k__async_pump_shell_pid=$$
    add-zsh-hook zshexit _p9k_kill_async_pump
  }

  if ! _p9k_start_async_pump ; then
     >&2 print -rP -- "%F{red}[ERROR]%f Powerlevel10k failed to start async worker. The following segments may malfunction: "
    (( public_ip     )) &&  >&2 print -rP -- "  - %F{green}public_ip%f"
    (( time_realtime )) &&  >&2 print -rP -- "  - %F{green}time%f"
    _p9k_deinit_async_pump
  fi
}

# Does ZSH have a certain off-by-one bug that triggers when PROMPT overflows to a new line?
#
# Bug: https://github.com/zsh-users/zsh/commit/d8d9fee137a5aa2cf9bf8314b06895bfc2a05518.
# ZSH_PATCHLEVEL=zsh-5.4.2-159-gd8d9fee13. Released in 5.5.
#
# Fix: https://github.com/zsh-users/zsh/commit/64d13738357c9b9c212adbe17f271716abbcf6ea.
# ZSH_PATCHLEVEL=zsh-5.7.1-50-g64d137383.
#
# Test: PROMPT="${(pl:$((COLUMNS))::-:)}<%1(l.%2(l.FAIL.PASS).FAIL)> " zsh -dfis <<<exit
# Workaround: PROMPT="${(pl:$((COLUMNS))::-:)}%{%G%}<%1(l.%2(l.FAIL.PASS).FAIL)> " zsh -dfis <<<exit
function _p9k_prompt_overflow_bug() {
  [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.4\.2-([0-9]+)-' ]] && return $(( match[1] < 159 ))
  [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.7\.1-([0-9]+)-' ]] && return $(( match[1] >= 50 ))
  is-at-least 5.5 && ! is-at-least 5.7.2
}

typeset -g  _p9k__param_pat
typeset -g  _p9k__param_sig

_p9k_init_vars() {
  typeset -gi _p9k__can_hide_cursor=$(( $+terminfo[civis] && $+terminfo[cnorm] ))
  typeset -gi _p9k__cursor_hidden
  typeset -gi _p9k__instant_prompt_disabled
  typeset -gi _p9k_non_hermetic_expansion
  typeset -g  _p9k_time
  typeset -g  _p9k_date
  typeset -gA _p9k_dumped_instant_prompt_sigs
  typeset -g  _p9k__instant_prompt_sig
  typeset -g  _p9k_instant_prompt
  typeset -gi _p9k__state_dump_scheduled
  typeset -gi _p9k__dump_pid
  typeset -gi _p9k__prompt_idx
  typeset -gi _p9k_state_restored
  typeset -gi _p9k_reset_on_line_finish
  typeset -gF _p9k__timer_start
  typeset -gi _p9k__status
  typeset -ga _p9k__pipestatus
  typeset -g  _p9k_ret
  typeset -g  _p9k_cache_key
  typeset -ga _p9k_cache_val
  typeset -g  _p9k__cache_stat_meta
  typeset -g  _p9k__cache_stat_fprint
  typeset -g  _p9k__cache_fprint_key
  typeset -gA _p9k_cache
  typeset -gA _p9k__cache_ephemeral
  typeset -ga _p9k_t
  typeset -g  _p9k_n
  typeset -gi _p9k_i
  typeset -g  _p9k_bg
  typeset -ga _p9k_left_join
  typeset -ga _p9k_right_join
  typeset -g  _p9k__public_ip
  typeset -g  _p9k_todo_file
  typeset -g  _p9k__git_dir
  # git workdir => 1 if gitstatus is slow on it, 0 if it's fast.
  typeset -gA _p9k_git_slow
  # git workdir => the last state we've seen for it
  typeset -gA _p9k__gitstatus_last
  typeset -gi _p9k__gitstatus_disabled
  typeset -gF _p9k__gitstatus_start_time
  typeset -g  _p9k__prompt
  typeset -g  _p9k_rprompt
  typeset -g  _p9k_lprompt
  typeset -g  _p9k_prompt_side
  typeset -g  _p9k_segment_name
  typeset -gi _p9k_segment_index
  typeset -gi _p9k_line_index
  typeset -g  _p9k_refresh_reason
  typeset -gi _p9k__region_active
  typeset -g  _p9k__async_pump_line
  typeset -g  _p9k__async_pump_fifo
  typeset -g  _p9k__async_pump_lock
  typeset -gi _p9k__async_pump_lock_fd
  typeset -gi _p9k__async_pump_fd
  typeset -gi _p9k__async_pump_pid
  typeset -gi _p9k__async_pump_subshell
  typeset -gi _p9k__async_pump_shell_pid
  typeset -ga _p9k_line_segments_left
  typeset -ga _p9k_line_segments_right
  typeset -ga _p9k_line_prefix_left
  typeset -ga _p9k_line_prefix_right
  typeset -ga _p9k_line_suffix_left
  typeset -ga _p9k_line_suffix_right
  typeset -ga _p9k_line_never_empty_right
  typeset -ga _p9k_line_gap_post
  typeset -g  _p9k_xy
  typeset -g  _p9k_clm
  typeset -g  _p9k_p
  typeset -gi _p9k_x
  typeset -gi _p9k_y
  typeset -gi _p9k_m
  typeset -gi _p9k_d
  typeset -gi _p9k_g
  typeset -gi _p9k_ind
  typeset -g  _p9k_gap_pre
  typeset -gi _p9k__ruler_i=3
  typeset -gi _p9k_ruler_idx
  typeset -gi _p9k__empty_line_i=3
  typeset -gi _p9k_empty_line_idx
  typeset -g  _p9k_prompt_prefix_left
  typeset -g  _p9k_prompt_prefix_right
  typeset -g  _p9k_prompt_suffix_left
  typeset -g  _p9k_prompt_suffix_right
  typeset -gi _p9k_emulate_zero_rprompt_indent
  typeset -gA _p9k_battery_states
  typeset -g  _p9k_os
  typeset -g  _p9k_os_icon
  typeset -g  _p9k_color1
  typeset -g  _p9k_color2
  typeset -g  _p9k_s
  typeset -g  _p9k_ss
  typeset -g  _p9k_sss
  typeset -g  _p9k_v
  typeset -g  _p9k_c
  typeset -g  _p9k_e
  typeset -g  _p9k_w
  typeset -gi _p9k_dir_len
  typeset -gi _p9k_num_cpus
  typeset -g  _p9k_pwd
  typeset -g  _p9k_pwd_a
  typeset -gA _p9k_iface
  typeset -gi _p9k_fetch_iface
  typeset -g  _p9k__keymap
  typeset -g  _p9k__zle_state
  typeset -g  _p9k_uname
  typeset -g  _p9k_uname_o
  typeset -g  _p9k_uname_m
  typeset -g  _p9k_transient_prompt
  typeset -g  _p9k__last_prompt_pwd
  typeset -gA _p9k__display_k
  typeset -ga _p9k__display_v

  typeset -gA _p9k__dotnet_stat_cache
  typeset -gA _p9k__dir_stat_cache
  typeset -gi _p9k__expanded
  typeset -gi _p9k__force_must_init

  typeset -g  P9K_VISUAL_IDENTIFIER
  typeset -g  P9K_CONTENT
  typeset -g  P9K_GAP
}

_p9k_init_params() {
  # invarint:  _POWERLEVEL9K_INSTANT_PROMPT == (verbose|quiet|off)
  # invariant: [[ ($_POWERLEVEL9K_INSTANT_PROMPT == off) == $_POWERLEVEL9K_DISABLE_INSTANT_PROMPT ]]
  _p9k_declare -s POWERLEVEL9K_INSTANT_PROMPT  # verbose, quiet, off
  if [[ $_POWERLEVEL9K_INSTANT_PROMPT == off ]]; then
    typeset -gi _POWERLEVEL9K_DISABLE_INSTANT_PROMPT=1
  else
    _p9k_declare -b POWERLEVEL9K_DISABLE_INSTANT_PROMPT 0
    if (( _POWERLEVEL9K_DISABLE_INSTANT_PROMPT )); then
      _POWERLEVEL9K_INSTANT_PROMPT=off
    elif [[ $_POWERLEVEL9K_INSTANT_PROMPT != quiet ]]; then
      _POWERLEVEL9K_INSTANT_PROMPT=verbose
    fi
  fi

  _p9k_declare -s POWERLEVEL9K_TRANSIENT_PROMPT off
  [[ $_POWERLEVEL9K_TRANSIENT_PROMPT == (off|always|same-dir) ]] || _POWERLEVEL9K_TRANSIENT_PROMPT=off

  _p9k_declare -b POWERLEVEL9K_DISABLE_HOT_RELOAD 0
  _p9k_declare -F POWERLEVEL9K_NEW_TTY_MAX_AGE_SECONDS 5
  _p9k_declare -i POWERLEVEL9K_INSTANT_PROMPT_COMMAND_LINES 1
  _p9k_declare -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS -- context dir vcs
  _p9k_declare -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS -- status root_indicator background_jobs history time
  _p9k_declare -b POWERLEVEL9K_DISABLE_RPROMPT 0
  _p9k_declare -b POWERLEVEL9K_PROMPT_ADD_NEWLINE 0
  _p9k_declare -b POWERLEVEL9K_PROMPT_ON_NEWLINE 0
  _p9k_declare -b POWERLEVEL9K_RPROMPT_ON_NEWLINE 0
  _p9k_declare -b POWERLEVEL9K_SHOW_RULER 0
  _p9k_declare -i POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT 1
  _p9k_declare -s POWERLEVEL9K_COLOR_SCHEME dark
  _p9k_declare -s POWERLEVEL9K_GITSTATUS_DIR ""
  _p9k_declare -s POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN
  _p9k_declare -b POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY 0
  _p9k_declare -i POWERLEVEL9K_VCS_SHORTEN_LENGTH
  _p9k_declare -i POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH
  _p9k_declare -s POWERLEVEL9K_VCS_SHORTEN_STRATEGY
  _p9k_declare -e POWERLEVEL9K_VCS_SHORTEN_DELIMITER '\u2026'
  _p9k_declare -b POWERLEVEL9K_VCS_CONFLICTED_STATE 0
  _p9k_declare -b POWERLEVEL9K_HIDE_BRANCH_ICON 0
  _p9k_declare -b POWERLEVEL9K_VCS_HIDE_TAGS 0
  _p9k_declare -i POWERLEVEL9K_CHANGESET_HASH_LENGTH 8
  # Specifies the maximum number of elements in the cache. When the cache grows over this limit,
  # it gets cleared. This is meant to avoid memory leaks when a rogue prompt is filling the cache
  # with data.
  _p9k_declare -i POWERLEVEL9K_MAX_CACHE_SIZE 10000
  _p9k_declare -e POWERLEVEL9K_ANACONDA_LEFT_DELIMITER "("
  _p9k_declare -e POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER ")"
  _p9k_declare -b POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION 1
  _p9k_declare -b POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE 1
  _p9k_declare -b POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS 0
  _p9k_declare -b POWERLEVEL9K_DISK_USAGE_ONLY_WARNING 0
  _p9k_declare -i POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL 90
  _p9k_declare -i POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL 95
  _p9k_declare -i POWERLEVEL9K_BATTERY_LOW_THRESHOLD 10
  _p9k_declare -i POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD 999
  _p9k_declare -a POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND --
  _p9k_declare -a POWERLEVEL9K_BATTERY_LEVEL_FOREGROUND --
  _p9k_declare -b POWERLEVEL9K_BATTERY_VERBOSE 1
  if [[ $parameters[POWERLEVEL9K_BATTERY_STAGES] == scalar ]]; then
    _p9k_declare -e POWERLEVEL9K_BATTERY_STAGES
  else
    [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
    _p9k_declare -a POWERLEVEL9K_BATTERY_STAGES --
    _POWERLEVEL9K_BATTERY_STAGES=("${(@g::)_POWERLEVEL9K_BATTERY_STAGES}")
  fi
  _p9k_declare -F POWERLEVEL9K_PUBLIC_IP_TIMEOUT 300
  _p9k_declare -a POWERLEVEL9K_PUBLIC_IP_METHODS -- dig curl wget
  _p9k_declare -e POWERLEVEL9K_PUBLIC_IP_NONE ""
  _p9k_declare -s POWERLEVEL9K_PUBLIC_IP_HOST "http://ident.me"
  _p9k_declare -s POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ""
  _p9k_declare -b POWERLEVEL9K_ALWAYS_SHOW_CONTEXT 0
  _p9k_declare -b POWERLEVEL9K_ALWAYS_SHOW_USER 0
  _p9k_declare -e POWERLEVEL9K_CONTEXT_TEMPLATE "%n@%m"
  _p9k_declare -e POWERLEVEL9K_USER_TEMPLATE "%n"
  _p9k_declare -e POWERLEVEL9K_HOST_TEMPLATE "%m"
  _p9k_declare -F POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD 3
  _p9k_declare -i POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION 2
  # Other options: "d h m s".
  _p9k_declare -s POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT "H:M:S"
  _p9k_declare -e POWERLEVEL9K_DIR_PATH_SEPARATOR "/"
  _p9k_declare -e POWERLEVEL9K_HOME_FOLDER_ABBREVIATION "~"
  _p9k_declare -b POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD 0
  _p9k_declare -b POWERLEVEL9K_DIR_ANCHOR_BOLD 0
  _p9k_declare -b POWERLEVEL9K_DIR_PATH_ABSOLUTE 0
  _p9k_declare -b POWERLEVEL9K_DIR_SHOW_WRITABLE 0
  _p9k_declare -b POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER 0
  _p9k_declare -b POWERLEVEL9K_DIR_HYPERLINK 0
  _p9k_declare -s POWERLEVEL9K_SHORTEN_STRATEGY ""
  _p9k_declare -s POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND
  _p9k_declare -s POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
  _p9k_declare -s POWERLEVEL9K_DIR_ANCHOR_FOREGROUND
  _p9k_declare -s POWERLEVEL9K_DIR_SHORTENED_FOREGROUND
  local markers=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .ruby-version
    .shorten_folder_marker
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
  )
  _p9k_declare -s POWERLEVEL9K_SHORTEN_FOLDER_MARKER "(${(j:|:)markers})"
  # Shorten directory if it's longer than this even if there is space for it.
  # The value can be either absolute (e.g., '80') or a percentage of terminal
  # width (e.g, '50%'). If empty, directory will be shortened only when prompt
  # doesn't fit. Applies only when POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique.
  _p9k_declare -s POWERLEVEL9K_DIR_MAX_LENGTH 0
  # Individual elements are patterns. They are expanded with the options set
  # by `emulate zsh && setopt extended_glob`.
  _p9k_declare -a POWERLEVEL9K_DIR_PACKAGE_FILES -- package.json composer.json
  # When dir is on the last prompt line, try to shorten it enough to leave at least this many
  # columns for typing commands. Applies only when POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique.
  _p9k_declare -i POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS 40
  # When dir is on the last prompt line, try to shorten it enough to leave at least
  # COLUMNS * POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT * 0.01 columns for typing commands. Applies
  # only when POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique.
  _p9k_declare -F POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT 50
  # POWERLEVEL9K_DIR_CLASSES allow you to specify custom styling and icons for different
  # directories.
  #
  # POWERLEVEL9K_DIR_CLASSES must be an array with 3 * N elements. Each triplet consists of:
  #
  #   1. A pattern against which the current directory is matched. Matching is done with
  #      extended_glob option enabled.
  #   2. Directory class for the purpose of styling.
  #   3. Icon.
  #
  # Triplets are tried in order. The first triplet whose pattern matches $PWD wins. If there are no
  # matches, there will be no icon and the styling is done according to POWERLEVEL9K_DIR_BACKGROUND,
  # POWERLEVEL9K_DIR_FOREGROUND, etc.
  #
  # Example:
  #
  #   POWERLEVEL9K_DIR_CLASSES=(
  #       '~/work(/*)#'  WORK     '(╯°□°）╯︵ ┻━┻'
  #       '~(/*)#'       HOME     '⌂'
  #       '*'            DEFAULT  '')
  #
  #   POWERLEVEL9K_DIR_WORK_BACKGROUND=red
  #   POWERLEVEL9K_DIR_HOME_BACKGROUND=blue
  #   POWERLEVEL9K_DIR_DEFAULT_BACKGROUND=yellow
  #
  # With these settings, the current directory in the prompt may look like this:
  #
  #   (╯°□°）╯︵ ┻━┻ ~/work/projects/important/urgent
  #
  #   ⌂ ~/best/powerlevel10k
  _p9k_declare -a POWERLEVEL9K_DIR_CLASSES
  _p9k_declare -i POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH
  _p9k_declare -e POWERLEVEL9K_SHORTEN_DELIMITER
  _p9k_declare -i POWERLEVEL9K_SHORTEN_DIR_LENGTH
  _p9k_declare -s POWERLEVEL9K_IP_INTERFACE ""
  _p9k_declare -s POWERLEVEL9K_VPN_IP_INTERFACE "(wg|(.*tun))[0-9]*"
  _p9k_declare -i POWERLEVEL9K_LOAD_WHICH 5
  _p9k_declare -b POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW 0
  _p9k_declare -b POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY 0
  _p9k_declare -b POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY 1
  _p9k_declare -b POWERLEVEL9K_GO_VERSION_PROJECT_ONLY 1
  _p9k_declare -b POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY 1
  _p9k_declare -b POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW 0
  _p9k_declare -a POWERLEVEL9K_RBENV_SOURCES -- shell local global
  _p9k_declare -b POWERLEVEL9K_RVM_SHOW_GEMSET 0
  _p9k_declare -b POWERLEVEL9K_RVM_SHOW_PREFIX 0
  _p9k_declare -b POWERLEVEL9K_CHRUBY_SHOW_VERSION 1
  _p9k_declare -b POWERLEVEL9K_CHRUBY_SHOW_ENGINE 1
  _p9k_declare -b POWERLEVEL9K_STATUS_CROSS 0
  _p9k_declare -b POWERLEVEL9K_STATUS_OK 1
  _p9k_declare -b POWERLEVEL9K_STATUS_OK_PIPE 1
  _p9k_declare -b POWERLEVEL9K_STATUS_ERROR 1
  _p9k_declare -b POWERLEVEL9K_STATUS_ERROR_PIPE 1
  _p9k_declare -b POWERLEVEL9K_STATUS_ERROR_SIGNAL 1
  _p9k_declare -b POWERLEVEL9K_STATUS_SHOW_PIPESTATUS 1
  _p9k_declare -b POWERLEVEL9K_STATUS_HIDE_SIGNAME 0
  _p9k_declare -b POWERLEVEL9K_STATUS_VERBOSE_SIGNAME 1
  _p9k_declare -b POWERLEVEL9K_STATUS_EXTENDED_STATES 0
  _p9k_declare -b POWERLEVEL9K_STATUS_VERBOSE 1
  _p9k_declare -b POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE 0
  # Format for the current time: 09:51:02. See `man 3 strftime`.
  _p9k_declare -e POWERLEVEL9K_TIME_FORMAT "%D{%H:%M:%S}"
  # If set to true, time will update every second.
  _p9k_declare -b POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME 0
  # If set to true, time will update when you hit enter. This way prompts for the past
  # commands will contain the start times of their commands as opposed to the default
  # behavior where they contain the end times of their preceding commands.
  _p9k_declare -b POWERLEVEL9K_TIME_UPDATE_ON_COMMAND 0
  _p9k_declare -e POWERLEVEL9K_DATE_FORMAT "%D{%d.%m.%y}"
  _p9k_declare -s POWERLEVEL9K_VCS_ACTIONFORMAT_FOREGROUND 1
  _p9k_declare -b POWERLEVEL9K_SHOW_CHANGESET 0
  _p9k_declare -e POWERLEVEL9K_VCS_LOADING_TEXT loading
  _p9k_declare -a POWERLEVEL9K_VCS_GIT_HOOKS -- vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname
  _p9k_declare -a POWERLEVEL9K_VCS_HG_HOOKS -- vcs-detect-changes
  _p9k_declare -a POWERLEVEL9K_VCS_SVN_HOOKS -- vcs-detect-changes svn-detect-changes
  # If it takes longer than this to fetch git repo status, display the prompt with a greyed out
  # vcs segment and fix it asynchronously when the results come it.
  _p9k_declare -F POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS 0.02
  _p9k_declare -a POWERLEVEL9K_VCS_BACKENDS -- git
  _p9k_declare -b POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING 0
  _p9k_declare -i POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY -1
  _p9k_declare -i POWERLEVEL9K_VCS_STAGED_MAX_NUM 1
  _p9k_declare -i POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM 1
  _p9k_declare -i POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM 1
  _p9k_declare -i POWERLEVEL9K_VCS_CONFLICTED_MAX_NUM 1
  _p9k_declare -i POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM -1
  _p9k_declare -i POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM -1
  _p9k_declare -b POWERLEVEL9K_VCS_RECURSE_UNTRACKED_DIRS 0
  _p9k_declare -b POWERLEVEL9K_DISABLE_GITSTATUS 0
  _p9k_declare -e POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
  _p9k_declare -e POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
  # VISUAL mode is shown as NORMAL unless POWERLEVEL9K_VI_VISUAL_MODE_STRING is explicitly set.
  _p9k_declare -e POWERLEVEL9K_VI_VISUAL_MODE_STRING
  # OVERWRITE mode is shown as INSERT unless POWERLEVEL9K_VI_OVERWRITE_MODE_STRING is explicitly set.
  _p9k_declare -e POWERLEVEL9K_VI_OVERWRITE_MODE_STRING
  _p9k_declare -b POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION 1
  _p9k_declare -e POWERLEVEL9K_VIRTUALENV_LEFT_DELIMITER "("
  _p9k_declare -e POWERLEVEL9K_VIRTUALENV_RIGHT_DELIMITER ")"
  _p9k_declare -a POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES -- virtualenv venv .venv
  _p9k_declare -b POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW 0
  _p9k_declare -a POWERLEVEL9K_PYENV_SOURCES -- shell local global
  _p9k_declare -b POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW 0
  _p9k_declare -b POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION 1
  _p9k_declare -e POWERLEVEL9K_NODEENV_LEFT_DELIMITER "["
  _p9k_declare -e POWERLEVEL9K_NODEENV_RIGHT_DELIMITER "]"
  _p9k_declare -b POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE 1
  _p9k_declare -a POWERLEVEL9K_KUBECONTEXT_SHORTEN --
  # Defines context classes for the purpose of applying different styling to different contexts.
  #
  # POWERLEVEL9K_KUBECONTEXT_CLASSES must be an array with even number of elements. The first
  # element in each pair defines a pattern against which the current context (in the format it is
  # displayed in the prompt) gets matched. The second element defines context class. Patterns are
  # tried in order. The first match wins.
  #
  # If a non-empty class <C> is assigned to a context, the segment is styled with
  # POWERLEVEL9K_KUBECONTEXT_<U>_BACKGROUND and POWERLEVEL9K_KUBECONTEXT_<U>_FOREGROUND where <U> is
  # uppercased <C>. Otherwise with POWERLEVEL9K_KUBECONTEXT_BACKGROUND and
  # POWERLEVEL9K_KUBECONTEXT_FOREGROUND.
  #
  # Example: Use red background for contexts containing "prod", green for "testing" and yellow for
  # everything else.
  #
  #   POWERLEVEL9K_KUBECONTEXT_CLASSES=(
  #       '*prod*'    prod
  #       '*testing*' testing
  #       '*'         other)
  #
  #   POWERLEVEL9K_KUBECONTEXT_PROD_BACKGROUND=red
  #   POWERLEVEL9K_KUBECONTEXT_TESTING_BACKGROUND=green
  #   POWERLEVEL9K_KUBECONTEXT_OTHER_BACKGROUND=yellow
  _p9k_declare -a POWERLEVEL9K_KUBECONTEXT_CLASSES --
  _p9k_declare -a POWERLEVEL9K_AWS_CLASSES --
  # Specifies the format of java version.
  #
  #   POWERLEVEL9K_JAVA_VERSION_FULL=true  => 1.8.0_212-8u212-b03-0ubuntu1.18.04.1-b03
  #   POWERLEVEL9K_JAVA_VERSION_FULL=false => 1.8.0_212
  #
  # These correspond to `java -fullversion` and `java -version` respectively.
  _p9k_declare -b POWERLEVEL9K_JAVA_VERSION_FULL 1
  _p9k_declare -b POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE 0

  local -i i=1
  while (( i <= $#_POWERLEVEL9K_LEFT_PROMPT_ELEMENTS )); do
    local segment=${(U)_POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[i]}
    local var=POWERLEVEL9K_${segment}_LEFT_DISABLED
    (( $+parameters[$var] )) || var=POWERLEVEL9K_${segment}_DISABLED
    if [[ ${(P)var} == true ]]; then
      _POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[i,i]=()
    else
      (( ++i ))
    fi
  done

  local -i i=1
  while (( i <= $#_POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS )); do
    local segment=${(U)_POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[i]}
    local var=POWERLEVEL9K_${segment}_RIGHT_DISABLED
    (( $+parameters[$var] )) || var=POWERLEVEL9K_${segment}_DISABLED
    if [[ ${(P)var} == true ]]; then
      _POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[i,i]=()
    else
      (( ++i ))
    fi
  done

  local var=
  for var in ${parameters[(I)POWERLEVEL9K_*]}; do
    local _var=_$var
    (( $+parameters[$_var] )) || typeset -g $_var=${(P)var}
  done
}

typeset -ga __p9k_wrapped_zle_widgets

# _p9k_wrap_zle_widget zle-keymap-select _p9k_zle_keymap_select
_p9k_wrap_zle_widget() {
  local widget=$1
  local hook=$2
  (( __p9k_wrapped_zle_widgets[(I)$widget:$hook] )) && return
  __p9k_wrapped_zle_widgets+=$widget:$hook
  local orig=p9k-orig-$widget
  case $widgets[$widget] in
    user:*)
      zle -N $orig ${widgets[$widget]#user:}
      ;;
    builtin)
      functions[_p9k_orig_$widget]="zle .${(q)widget}"
      zle -N $orig _p9k_orig_$widget
      ;;
  esac

  local wrapper=_p9k_wrapper_$widget_$hook
  functions[$wrapper]="
    emulate -L zsh
    setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst}
    (( __p9k_enabled )) && ${(q)hook} \"\$@\"
    (( \$+widgets[${(q)orig}] )) && zle ${(q)orig} -- \"\$@\""

  zle -N -- $widget $wrapper
}

function _p9k_zle_line_init() {
  (( _p9k__cursor_hidden )) || return 0
  _p9k__cursor_hidden=0
  echoti cnorm
}

function _p9k_zle_line_finish() {
  (( $+_p9k__line_finished )) && return

  _p9k__line_finished=
  local -i reset=_p9k_reset_on_line_finish

  if (( $+functions[p10k-on-post-prompt] )); then
    __p9k_reset_state=1
    p10k-on-post-prompt
    if (( __p9k_reset_state == 2 )); then
      reset=1
    fi
    __p9k_reset_state=0
  fi

  if [[ -n $_p9k_transient_prompt ]]; then
    if [[ $_POWERLEVEL9K_TRANSIENT_PROMPT == always || $_p9k_pwd == $_p9k__last_prompt_pwd ]]; then
      RPROMPT=
      PROMPT=$_p9k_transient_prompt
      reset=1
    else
      _p9k__last_prompt_pwd=$_p9k_pwd
    fi
  fi

  if (( reset )); then
    if zle && (( $+termcap[up] )); then
      (( _p9k__can_hide_cursor )) && local hide=$terminfo[civis] || local hide=
      echo -nE - $hide$'\n'$termcap[up]
    fi
    _p9k_reset_prompt
  fi

  _p9k__line_finished='%{%}'
}

function _p9k_zle_line_pre_redraw() {
  [[ ${KEYMAP:-} == vicmd ]] || return 0
  local region=${${REGION_ACTIVE:-0}/2/1}
  [[ $region != $_p9k__region_active ]] || return 0
  _p9k__region_active=$region
  _p9k_reset_prompt
}

prompt__p9k_internal_nothing() { _p9k__prompt+='${_p9k_sss::=}'; }
instant_prompt__p9k_internal_nothing() { prompt__p9k_internal_nothing; }

# _p9k_build_gap_post line_number
_p9k_build_gap_post() {
  [[ $1 == 1 ]] && local kind=first || local kind=newline
  _p9k_get_icon '' MULTILINE_${(U)kind}_PROMPT_GAP_CHAR
  local char=${_p9k_ret:- }
  _p9k_prompt_length $char
  if (( _p9k_ret != 1 || $#char != 1 )); then
    print -rP -- "%F{red}WARNING!%f %BMULTILINE_${(U)kind}_PROMPT_GAP_CHAR%b is not one character long. Will use ' '."
    print -rP -- "Either change the value of %BPOWERLEVEL9K_MULTILINE_${(U)kind}_PROMPT_GAP_CHAR%b or remove it."
    char=' '
  fi
  local style
  _p9k_color prompt_multiline_${kind}_prompt_gap BACKGROUND ""
  [[ -n $_p9k_ret ]] && _p9k_background $_p9k_ret
  style+=$_p9k_ret
  _p9k_color prompt_multiline_${kind}_prompt_gap FOREGROUND ""
  [[ -n $_p9k_ret ]] && _p9k_foreground $_p9k_ret
  style+=$_p9k_ret
  _p9k_escape_style $style
  style=$_p9k_ret
  local exp=_POWERLEVEL9K_MULTILINE_${(U)kind}_PROMPT_GAP_EXPANSION
  (( $+parameters[$exp] )) && exp=${(P)exp} || exp='${P9K_GAP}'
  [[ $char == '.' ]] && local s=',' || local s='.'
  _p9k_ret=$'${${_p9k__g+\n}:-'$style'${${${_p9k_m:#-*}:+'
  _p9k_ret+='${${_p9k__'$1'g+${(pl.$((_p9k_m+1)).. .)}}:-'
  if [[ $exp == '${P9K_GAP}' ]]; then
    _p9k_ret+='${(pl'$s'$((_p9k_m+1))'$s$s$char$s')}'
  else
    _p9k_ret+='${${P9K_GAP::=${(pl'$s'$((_p9k_m+1))'$s$s$char$s')}}+}'
    _p9k_ret+='${:-"'$exp'"}'
    style=1
  fi
  _p9k_ret+='}'
  if (( __p9k_ksh_arrays )); then
    _p9k_ret+=$'$_p9k_rprompt${_p9k_t[$((!_p9k_ind))]}}:-\n}'
  else
    _p9k_ret+=$'$_p9k_rprompt${_p9k_t[$((1+!_p9k_ind))]}}:-\n}'
  fi
  [[ -n $style ]] && _p9k_ret+='%b%k%f'
  _p9k_ret+='}'
}

_p9k_init_lines() {
  [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
  local -a left_segments=($_POWERLEVEL9K_LEFT_PROMPT_ELEMENTS)
  local -a right_segments=($_POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS)

  if (( _POWERLEVEL9K_PROMPT_ON_NEWLINE )); then
    left_segments+=(newline _p9k_internal_nothing)
  fi

  local -i num_left_lines=$((1 + ${#${(@M)left_segments:#newline}}))
  local -i num_right_lines=$((1 + ${#${(@M)right_segments:#newline}}))
  if (( num_right_lines > num_left_lines )); then
    repeat $((num_right_lines - num_left_lines)) left_segments=(newline $left_segments)
    local -i num_lines=num_right_lines
  else
    if (( _POWERLEVEL9K_RPROMPT_ON_NEWLINE )); then
      repeat $((num_left_lines - num_right_lines)) right_segments=(newline $right_segments)
    else
      repeat $((num_left_lines - num_right_lines)) right_segments+=newline
    fi
    local -i num_lines=num_left_lines
  fi

  local -i i
  for i in {1..$num_lines}; do
    local -i left_end=${left_segments[(i)newline]}
    local -i right_end=${right_segments[(i)newline]}
    _p9k_line_segments_left+="${(pj:\0:)left_segments[1,left_end-1]}"
    _p9k_line_segments_right+="${(pj:\0:)right_segments[1,right_end-1]}"
    (( left_end > $#left_segments )) && left_segments=() || shift left_end left_segments
    (( right_end > $#right_segments )) && right_segments=() || shift right_end right_segments

    _p9k_get_icon '' LEFT_SEGMENT_SEPARATOR
    _p9k_get_icon 'prompt_empty_line' LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL $_p9k_ret
    _p9k_escape $_p9k_ret
    _p9k_line_prefix_left+='${_p9k__'$i'l-${${:-${_p9k_bg::=NONE}${_p9k_i::=0}${_p9k_sss::=%f'$_p9k_ret'}}+}'
    _p9k_line_suffix_left+='%b%k$_p9k_sss%b%k%f'

    _p9k_escape ${(g::)_POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL}
    [[ -n $_p9k_ret ]] && _p9k_line_never_empty_right+=1 || _p9k_line_never_empty_right+=0
    _p9k_line_prefix_right+='${_p9k__'$i'r-${${:-${_p9k_bg::=NONE}${_p9k_i::=0}${_p9k_sss::='$_p9k_ret'}}+}'
    _p9k_line_suffix_right+='$_p9k_sss%b%k%f}'  # gets overridden for _p9k_emulate_zero_rprompt_indent
  done

  _p9k_get_icon '' LEFT_SEGMENT_END_SEPARATOR
  if [[ -n $_p9k_ret ]]; then
    _p9k_ret+=%b%k%f
    # Not escaped for historical reasons.
    _p9k_ret='${:-"'$_p9k_ret'"}'
    if (( _POWERLEVEL9K_PROMPT_ON_NEWLINE )); then
      _p9k_line_suffix_left[-2]+=$_p9k_ret
    else
      _p9k_line_suffix_left[-1]+=$_p9k_ret
    fi
  fi

  for i in {1..$num_lines}; do _p9k_line_suffix_left[i]+='}'; done

  if (( num_lines > 1 )); then
    for i in {1..$((num_lines-1))}; do
      _p9k_build_gap_post $i
      _p9k_line_gap_post+=$_p9k_ret
    done

    if [[ $+_POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX == 1 || $_POWERLEVEL9K_PROMPT_ON_NEWLINE == 1 ]]; then
      _p9k_get_icon '' MULTILINE_FIRST_PROMPT_PREFIX
      if [[ -n $_p9k_ret ]]; then
        [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
        # Not escaped for historical reasons.
        _p9k_ret='${_p9k__1l_frame-"'$_p9k_ret'"}'
        _p9k_line_prefix_left[1]=$_p9k_ret$_p9k_line_prefix_left[1]
      fi
    fi

    if [[ $+_POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX == 1 || $_POWERLEVEL9K_PROMPT_ON_NEWLINE == 1 ]]; then
      _p9k_get_icon '' MULTILINE_LAST_PROMPT_PREFIX
      if [[ -n $_p9k_ret ]]; then
        [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
        # Not escaped for historical reasons.
        _p9k_ret='${_p9k__'$num_lines'l_frame-"'$_p9k_ret'"}'
        _p9k_line_prefix_left[-1]=$_p9k_ret$_p9k_line_prefix_left[-1]
      fi
    fi

    _p9k_get_icon '' MULTILINE_FIRST_PROMPT_SUFFIX
    if [[ -n $_p9k_ret ]]; then
      [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
      _p9k_line_suffix_right[1]+='${_p9k__1r_frame-'${(qqq)_p9k_ret}'}'
      _p9k_line_never_empty_right[1]=1
    fi

    _p9k_get_icon '' MULTILINE_LAST_PROMPT_SUFFIX
    if [[ -n $_p9k_ret ]]; then
      [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
      _p9k_line_suffix_right[-1]+='${_p9k__'$num_lines'r_frame-'${(qqq)_p9k_ret}'}'
      _p9k_line_never_empty_right[-1]=1
    fi

    if (( num_lines > 2 )); then
      if [[ $+_POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX == 1 || $_POWERLEVEL9K_PROMPT_ON_NEWLINE == 1 ]]; then
        _p9k_get_icon '' MULTILINE_NEWLINE_PROMPT_PREFIX
        if [[ -n $_p9k_ret ]]; then
          [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
          for i in {2..$((num_lines-1))}; do
            # Not escaped for historical reasons.
            _p9k_line_prefix_left[i]='${_p9k__'$i'l_frame-"'$_p9k_ret'"}'$_p9k_line_prefix_left[i]
          done
        fi
      fi

      _p9k_get_icon '' MULTILINE_NEWLINE_PROMPT_SUFFIX
      if [[ -n $_p9k_ret ]]; then
        [[ _p9k_ret == *%* ]] && _p9k_ret+=%b%k%f
        for i in {2..$((num_lines-1))}; do
          _p9k_line_suffix_right[i]+='${_p9k__'$i'r_frame-'${(qqq)_p9k_ret}'}'
        done
        _p9k_line_never_empty_right[2,-2]=${(@)_p9k_line_never_empty_right[2,-2]/0/1}
      fi
    fi
  fi
}

_p9k_all_params_eq() {
  local key
  for key in ${parameters[(I)${~1}]}; do
    [[ ${(P)key} == $2 ]] || return
  done
}

_p9k_init_display() {
  _p9k__display_k=(empty_line 1 ruler 3)
  _p9k__display_v=(empty_line hide ruler hide)
  local -i n=3 i
  local name
  for i in {1..$#_p9k_line_segments_left}; do
    local -i j=$((-$#_p9k_line_segments_left+i-1))
    _p9k__display_k+=(
      $i              $((n+=2)) $j             $n
      $i/left_frame   $((n+=2)) $j/left_frame  $n
      $i/right_frame  $((n+=2)) $j/right_frame $n
      $i/left         $((n+=2)) $j/left        $n
      $i/right        $((n+=2)) $j/right       $n
      $i/gap          $((n+=2)) $j/gap         $n)
    _p9k__display_v+=(
      $i             show
      $i/left_frame  show
      $i/right_frame show
      $i/left        show
      $i/right       show
      $i/gap         show)
    for name in ${(@0)_p9k_line_segments_left[i]}; do
      _p9k__display_k+=($i/left/$name $((n+=2)) $j/left/$name $n)
      _p9k__display_v+=($i/left/$name show)
    done
    for name in ${(@0)_p9k_line_segments_right[i]}; do
      _p9k__display_k+=($i/right/$name $((n+=2)) $j/right/$name $n)
      _p9k__display_v+=($i/right/$name show)
    done
  done
}

_p9k_init_prompt() {
  _p9k_t=($'\n' $'%{\n%}' '')
  _p9k_prompt_overflow_bug && _p9k_t[2]=$'%{%G\n%}'

  _p9k_init_lines

  _p9k_gap_pre='${${:-${_p9k_x::=0}${_p9k_y::=1024}${_p9k_p::=$_p9k_lprompt$_p9k_rprompt}'
  repeat 10; do
    _p9k_gap_pre+='${_p9k_m::=$(((_p9k_x+_p9k_y)/2))}'
    _p9k_gap_pre+='${_p9k_xy::=${${(%):-$_p9k_p%$_p9k_m(l./$_p9k_m;$_p9k_y./$_p9k_x;$_p9k_m)}##*/}}'
    _p9k_gap_pre+='${_p9k_x::=${_p9k_xy%;*}}'
    _p9k_gap_pre+='${_p9k_y::=${_p9k_xy#*;}}'
  done
  _p9k_gap_pre+='${_p9k_m::=$((_p9k_clm-_p9k_x-_p9k_ind-1))}'
  _p9k_gap_pre+='}+}'

  _p9k_prompt_prefix_left='${${_p9k_clm::=$COLUMNS}+}${${COLUMNS::=1024}+}'
  _p9k_prompt_prefix_right='${_p9k__'$#_p9k_line_segments_left'-${${_p9k_clm::=$COLUMNS}+}${${COLUMNS::=1024}+}'
  _p9k_prompt_suffix_left='${${COLUMNS::=$_p9k_clm}+}'
  _p9k_prompt_suffix_right='${${COLUMNS::=$_p9k_clm}+}}'

  if _p9k_segment_in_use vi_mode || _p9k_segment_in_use prompt_char; then
    _p9k_prompt_prefix_left+='${${_p9k__keymap::=${KEYMAP:-$_p9k__keymap}}+}'
  fi
  if { _p9k_segment_in_use vi_mode && (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING )) } ||
     { _p9k_segment_in_use prompt_char && (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )) }; then
    _p9k_prompt_prefix_left+='${${_p9k__zle_state::=${ZLE_STATE:-$_p9k__zle_state}}+}'
  fi
  _p9k_prompt_prefix_left+='%b%k%f'

  # Bug fixed in: https://github.com/zsh-users/zsh/commit/3eea35d0853bddae13fa6f122669935a01618bf9.
  # If affects most terminals when RPROMPT is non-empty and ZLE_RPROMPT_INDENT is zero.
  # We can work around it as long as RPROMPT ends with a space.
  if [[ -n $_p9k_line_segments_right[-1] && $_p9k_line_never_empty_right[-1] == 0 &&
        $ZLE_RPROMPT_INDENT == 0 ]] &&
       _p9k_all_params_eq '_POWERLEVEL9K_*WHITESPACE_BETWEEN_RIGHT_SEGMENTS' ' ' &&
       _p9k_all_params_eq '_POWERLEVEL9K_*RIGHT_RIGHT_WHITESPACE' ' ' &&
       _p9k_all_params_eq '_POWERLEVEL9K_*RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL' '' &&
       ! is-at-least 5.7.2; then
    _p9k_emulate_zero_rprompt_indent=1
    _p9k_prompt_prefix_left+='${${:-${_p9k_real_zle_rprompt_indent:=$ZLE_RPROMPT_INDENT}${ZLE_RPROMPT_INDENT::=1}${_p9k_ind::=0}}+}'
    _p9k_line_suffix_right[-1]='${_p9k_sss:+${_p9k_sss% }%E}}'
  else
    _p9k_emulate_zero_rprompt_indent=0
    _p9k_prompt_prefix_left+='${${_p9k_ind::=${${ZLE_RPROMPT_INDENT:-1}/#-*/0}}+}'
  fi

  if [[ $ITERM_SHELL_INTEGRATION_INSTALLED == Yes ]]; then
    _p9k_prompt_prefix_left+=$'%{\e]133;A\a%}'
    _p9k_prompt_suffix_left+=$'%{\e]133;B\a%}'
  fi

  if (( _POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT > 0 )); then
    _p9k_t+=${(pl.$_POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT..\n.)}
  else
    _p9k_t+=''
  fi
  _p9k_empty_line_idx=$#_p9k_t
  if (( __p9k_ksh_arrays )); then
    _p9k_prompt_prefix_left+='${_p9k_t[${_p9k__empty_line_i:-'$#_p9k_t'}-1]}'
  else
    _p9k_prompt_prefix_left+='${_p9k_t[${_p9k__empty_line_i:-'$#_p9k_t'}]}'
  fi

  _p9k_get_icon '' RULER_CHAR
  local ruler_char=$_p9k_ret
  _p9k_prompt_length $ruler_char
  (( _p9k_ret == 1 && $#ruler_char == 1 )) || ruler_char=' '
  _p9k_color prompt_ruler BACKGROUND ""
  if [[ -z $_p9k_ret && $ruler_char == ' ' ]]; then
    local ruler=$'\n'
  else
    _p9k_background $_p9k_ret
    local ruler=%b$_p9k_ret
    _p9k_color prompt_ruler FOREGROUND ""
    _p9k_foreground $_p9k_ret
    ruler+=$_p9k_ret
    [[ $ruler_char == '.' ]] && local sep=',' || local sep='.'
    ruler+='${(pl'$sep'${$((_p9k_clm-_p9k_ind))/#-*/0}'$sep$sep$ruler_char$sep')}%k%f'
    if (( __p9k_ksh_arrays )); then
      ruler+='${_p9k_t[$((!_p9k_ind))]}'
    else
      ruler+='${_p9k_t[$((1+!_p9k_ind))]}'
    fi
  fi
  _p9k_t+=$ruler
  _p9k_ruler_idx=$#_p9k_t
  if (( __p9k_ksh_arrays )); then
    _p9k_prompt_prefix_left+='${(e)_p9k_t[${_p9k__ruler_i:-'$#_p9k_t'}-1]}'
  else
    _p9k_prompt_prefix_left+='${(e)_p9k_t[${_p9k__ruler_i:-'$#_p9k_t'}]}'
  fi

  ( _p9k_segment_in_use time && (( _POWERLEVEL9K_TIME_UPDATE_ON_COMMAND )) )
  _p9k_reset_on_line_finish=$((!$?))

  _p9k_t+=$_p9k_gap_pre
  _p9k_gap_pre='${(e)_p9k_t['$(($#_p9k_t - __p9k_ksh_arrays))']}'
  _p9k_t+=$_p9k_prompt_prefix_left
  _p9k_prompt_prefix_left='${(e)_p9k_t['$(($#_p9k_t - __p9k_ksh_arrays))']}'
}

_p9k_init_ssh() {
  # The following code is based on Pure:
  # https://github.com/sindresorhus/pure/blob/e8abf9d37185ec9b7b4398ca9c5eba555a1028eb/pure.zsh.
  #
  # License: https://github.com/sindresorhus/pure/blob/e8abf9d37185ec9b7b4398ca9c5eba555a1028eb/license.

  [[ -n $P9K_SSH ]] && return
  typeset -gix P9K_SSH=0
  if [[ -n $SSH_CLIENT || -n $SSH_TTY || -n $SSH_CONNECTION ]]; then
    P9K_SSH=1
    return 0
  fi

  # When changing user on a remote system, the $SSH_CONNECTION environment variable can be lost.
  # Attempt detection via `who`.
  (( $+commands[who] )) || return

  local ipv6='(([0-9a-fA-F]+:)|:){2,}[0-9a-fA-F]+'  # Simplified, only checks partial pattern.
  local ipv4='([0-9]{1,3}\.){3}[0-9]+'              # Simplified, allows invalid ranges.
  # Assume two non-consecutive periods represents a hostname. Matches `x.y.z`, but not `x.y`.
  local hostname='([.][^. ]+){2}'

  local w
  w="$(who -m 2>/dev/null)" || w=${(@M)${(f)"$(who 2>/dev/null)"}:#*[[:space:]]${TTY#/dev/}[[:space:]]*}

  # Usually the remote address is surrounded by parenthesis but not on all systems (e.g., Busybox).
  [[ $w =~ "\(?($ipv4|$ipv6|$hostname)\)?\$" ]] && P9K_SSH=1
}

_p9k_must_init() {
  (( _POWERLEVEL9K_DISABLE_HOT_RELOAD && !_p9k__force_must_init )) && return 1
  _p9k__force_must_init=0
  local IFS sig
  if [[ -n $_p9k__param_sig ]]; then
    IFS=$'\2' sig="${(e)_p9k__param_pat}"
    [[ $sig == $_p9k__param_sig ]] && return 1
    _p9k_deinit
  fi
  _p9k__param_pat=$'v15\1'${ZSH_VERSION}$'\1'${ZSH_PATCHLEVEL}$'\1'
  _p9k__param_pat+=$'${#parameters[(I)POWERLEVEL9K_*]}\1${(%):-%n%#}\1$GITSTATUS_LOG_LEVEL\1'
  _p9k__param_pat+=$'$GITSTATUS_ENABLE_LOGGING\1$GITSTATUS_DAEMON\1$GITSTATUS_NUM_THREADS\1'
  _p9k__param_pat+=$'$DEFAULT_USER\1${ZLE_RPROMPT_INDENT:-1}\1$P9K_SSH\1$__p9k_ksh_arrays'
  _p9k__param_pat+=$'$__p9k_sh_glob\1$ITERM_SHELL_INTEGRATION_INSTALLED\1'
  _p9k__param_pat+=$'${PROMPT_EOL_MARK-%B%S%#%s%b}\1$LANG\1$LC_ALL\1$LC_CTYPE\1'
  _p9k__param_pat+=$'$functions[p10k-on-pre-prompt]\1'
  local MATCH
  IFS=$'\1' _p9k__param_pat+="${(@)${(@o)parameters[(I)POWERLEVEL9K_*]}:/(#m)*/\${${(q)MATCH}-$IFS\}}"
  IFS=$'\2' _p9k__param_sig="${(e)_p9k__param_pat}"
}

function _p9k_set_os() {
  _p9k_os=$1
  _p9k_get_icon prompt_os_icon $2
  _p9k_os_icon=$_p9k_ret
}

function _p9k_init_cacheable() {
  (( $+functions[_p9k_init_icons] )) || source "${__p9k_root_dir}/internal/icons.zsh"
  _p9k_init_icons
  _p9k_init_params
  _p9k_init_prompt

  if [[ $_POWERLEVEL9K_TRANSIENT_PROMPT != off ]]; then
    _p9k_transient_prompt='%b%k%s%u%F{%(?.'
    _p9k_color prompt_prompt_char_OK_VIINS FOREGROUND 76
    _p9k_transient_prompt+=$_p9k_ret'.'
    _p9k_color prompt_prompt_char_ERROR_VIINS FOREGROUND 196
    _p9k_transient_prompt+=$_p9k_ret')}${${P9K_CONTENT::="❯"}+}'
    _p9k_param prompt_prompt_char_OK_VIINS CONTENT_EXPANSION '${P9K_CONTENT}'
    _p9k_transient_prompt+='${:-"'$_p9k_ret'"}%b%k%f%s%u '
    if [[ $ITERM_SHELL_INTEGRATION_INSTALLED == Yes ]]; then
      _p9k_transient_prompt=$'%{\e]133;A\a%}'$_p9k_transient_prompt$'%{\e]133;B\a%}'
    fi
  fi

  _p9k_uname="$(uname)"
  [[ $_p9k_uname == Linux ]] && _p9k_uname_o="$(uname -o 2>/dev/null)"
  _p9k_uname_m="$(uname -m)"

  if [[ $_p9k_uname == Linux && $_p9k_uname_o == Android ]]; then
    _p9k_set_os Android ANDROID_ICON
  else
    case $_p9k_uname in
      SunOS)                     _p9k_set_os Solaris SUNOS_ICON;;
      Darwin)                    _p9k_set_os OSX     APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   _p9k_set_os Windows WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) _p9k_set_os BSD     FREEBSD_ICON;;
      Linux)
        _p9k_os='Linux'
        local os_release_id
        if [[ -r /etc/os-release ]]; then
          local lines=(${(f)"$(</etc/os-release)"})
          lines=(${(@M)lines:#ID=*})
          (( $#lines == 1 )) && os_release_id=${lines[1]#ID=}
        fi
        case $os_release_id in
          *arch*)                  _p9k_set_os Linux LINUX_ARCH_ICON;;
          *debian*)                _p9k_set_os Linux LINUX_DEBIAN_ICON;;
          *raspbian*)              _p9k_set_os Linux LINUX_RASPBIAN_ICON;;
          *ubuntu*)                _p9k_set_os Linux LINUX_UBUNTU_ICON;;
          *elementary*)            _p9k_set_os Linux LINUX_ELEMENTARY_ICON;;
          *fedora*)                _p9k_set_os Linux LINUX_FEDORA_ICON;;
          *coreos*)                _p9k_set_os Linux LINUX_COREOS_ICON;;
          *gentoo*)                _p9k_set_os Linux LINUX_GENTOO_ICON;;
          *mageia*)                _p9k_set_os Linux LINUX_MAGEIA_ICON;;
          *centos*)                _p9k_set_os Linux LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) _p9k_set_os Linux LINUX_OPENSUSE_ICON;;
          *sabayon*)               _p9k_set_os Linux LINUX_SABAYON_ICON;;
          *slackware*)             _p9k_set_os Linux LINUX_SLACKWARE_ICON;;
          *linuxmint*)             _p9k_set_os Linux LINUX_MINT_ICON;;
          *alpine*)                _p9k_set_os Linux LINUX_ALPINE_ICON;;
          *aosc*)                  _p9k_set_os Linux LINUX_AOSC_ICON;;
          *nixos*)                 _p9k_set_os Linux LINUX_NIXOS_ICON;;
          *devuan*)                _p9k_set_os Linux LINUX_DEVUAN_ICON;;
          *manjaro*)               _p9k_set_os Linux LINUX_MANJARO_ICON;;
          *)                       _p9k_set_os Linux LINUX_ICON;;
        esac
        ;;
    esac
  fi

  if [[ $_POWERLEVEL9K_COLOR_SCHEME == light ]]; then
    _p9k_color1=7
    _p9k_color2=0
  else
    _p9k_color1=0
    _p9k_color2=7
  fi

  # Someone might be using these.
  typeset -g OS=$_p9k_os
  typeset -g DEFAULT_COLOR=$_p9k_color1
  typeset -g DEFAULT_COLOR_INVERTED=$_p9k_color2

  _p9k_battery_states=(
    'LOW'           'red'
    'CHARGING'      'yellow'
    'CHARGED'       'green'
    'DISCONNECTED'  "$_p9k_color2"
  )

  local -i i=0
  # This simpler construct doesn't work on zsh-5.1 with multi-line prompt:
  #
  #   ${(@0)_p9k_line_segments_left[@]}
  local -a left_segments=(${(@0)${(pj:\0:)_p9k_line_segments_left}})
  _p9k_left_join=(1)
  for ((i = 2; i <= $#left_segments; ++i)); do
    local elem=$left_segments[i]
    if [[ $elem == *_joined ]]; then
      _p9k_left_join+=$_p9k_left_join[((i-1))]
    else
      _p9k_left_join+=$i
    fi
  done

  local -a right_segments=(${(@0)${(pj:\0:)_p9k_line_segments_right}})
  _p9k_right_join=(1)
  for ((i = 2; i <= $#right_segments; ++i)); do
    local elem=$right_segments[i]
    if [[ $elem == *_joined ]]; then
      _p9k_right_join+=$_p9k_right_join[((i-1))]
    else
      _p9k_right_join+=$i
    fi
  done

  case $_p9k_os in
    OSX) (( $+commands[sysctl] )) && _p9k_num_cpus="$(sysctl -n hw.logicalcpu 2>/dev/null)";;
    BSD) (( $+commands[sysctl] )) && _p9k_num_cpus="$(sysctl -n hw.ncpu 2>/dev/null)";;
    *)   (( $+commands[nproc]  )) && _p9k_num_cpus="$(nproc 2>/dev/null)";;
  esac

  if _p9k_segment_in_use dir; then
    if (( $+_POWERLEVEL9K_DIR_CLASSES )); then
      [[ -z $_p9k_locale ]] || local LC_ALL=$_p9k_locale
      local -i i=3
      for ((; i <= $#_POWERLEVEL9K_DIR_CLASSES; i+=3)); do
        _POWERLEVEL9K_DIR_CLASSES[i]=${(g::)_POWERLEVEL9K_DIR_CLASSES[i]}
      done
    else
      typeset -ga _POWERLEVEL9K_DIR_CLASSES=()
      _p9k_get_icon prompt_dir_ETC ETC_ICON
      _POWERLEVEL9K_DIR_CLASSES+=('/etc|/etc/*' ETC "$_p9k_ret")
      _p9k_get_icon prompt_dir_HOME HOME_ICON
      _POWERLEVEL9K_DIR_CLASSES+=('~' HOME "$_p9k_ret")
      _p9k_get_icon prompt_dir_HOME_SUBFOLDER HOME_SUB_ICON
      _POWERLEVEL9K_DIR_CLASSES+=('~/*' HOME_SUBFOLDER "$_p9k_ret")
      _p9k_get_icon prompt_dir_DEFAULT FOLDER_ICON
      _POWERLEVEL9K_DIR_CLASSES+=('*' DEFAULT "$_p9k_ret")
    fi
  fi

  if _p9k_segment_in_use status; then
    typeset -g _p9k_exitcode2str=({0..255})
    local -i i=2
    if (( !_POWERLEVEL9K_STATUS_HIDE_SIGNAME )); then
      for ((; i <= $#signals; ++i)); do
        local sig=$signals[i]
        (( _POWERLEVEL9K_STATUS_VERBOSE_SIGNAME )) && sig="SIG${sig}($((i-1)))"
        _p9k_exitcode2str[$((128+i))]=$sig
      done
    fi
  fi

  if [[ -n $_POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]] && _p9k_segment_in_use public_ip ||
     _p9k_segment_in_use ip || _p9k_segment_in_use vpn_ip; then
     _p9k_fetch_iface=1
  fi
}

_p9k_init_vcs() {
  _p9k_segment_in_use vcs || return
  _p9k_vcs_info_init
  if (( $+functions[_p9k_preinit] )); then
    (( $+GITSTATUS_DAEMON_PID_POWERLEVEL9K )) && gitstatus_start POWERLEVEL9K || _p9k__gitstatus_disabled=1
    return 0
  fi
  if (( _POWERLEVEL9K_DISABLE_GITSTATUS )); then
    _p9k__gitstatus_disabled=1
    return 0
  fi
  (( $_POWERLEVEL9K_VCS_BACKENDS[(I)git] )) || return

  local gitstatus_dir=${_POWERLEVEL9K_GITSTATUS_DIR:-${__p9k_root_dir}/gitstatus}
  if [[ -z $GITSTATUS_DAEMON && $_p9k_uname_m == i686 && -z $gitstatus_dir/bin/*-i686(-static|)(#qN) ]]; then
    _p9k__gitstatus_disabled=1
    >&2 echo -E - "${(%):-[%1FERROR%f]: %BPowerlevel10k%b is unable to use %Bgitstatus%b. Git prompt will be slow.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-Reason: There is no %Bgitstatusd%b binary for i686 (32-bit Intel architecture).}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-You can:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Do nothing.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill%b see this error message every time you start zsh.}"
    >&2 echo -E - "${(%):-    * Git prompt will be %Bslow%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Set %BPOWERLEVEL9K_DISABLE_GITSTATUS=true%b at the bottom of %B$__p9k_zshrc_u%b.}"
    >&2 echo -E - "${(%):-    You can do this by running the following command:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-      %2Fecho%f %3F'POWERLEVEL9K_DISABLE_GITSTATUS=true'%f >>! $__p9k_zshrc_u}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Git prompt will be %Bslow%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Upgrade to a 64-bit OS.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Git prompt will be %Bfast%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Compile %Bgitstatusd%b and set %BGITSTATUS_DAEMON=/path/to/gitstatusd%b at}"
    >&2 echo -E - "${(%):-    the bottom of %B$__p9k_zshrc_u%b. See instructions at}"
    >&2 echo -E - "${(%):-    https://github.com/romkatv/gitstatus/blob/master/README.md#compiling.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Git prompt will be %Bfast%b.}"
    return 0
  fi

  local daemon=${GITSTATUS_DAEMON}
  if [[ -z $daemon ]]; then
    daemon=$gitstatus_dir/bin/gitstatusd-
    if [[ $_p9k_uname_o == Android ]]; then
      daemon+=android
    elif [[ ${(L)_p9k_uname} == (mingw|msys)* ]]; then
      daemon+=msys_nt-10.0
    else
      daemon+=${_p9k_uname:l}
    fi
    daemon+=-${_p9k_uname_m:l}
  fi
  local -i threads=${GITSTATUS_NUM_THREADS:-0}
  if (( threads <= 0 )); then
    threads=$(( _p9k_num_cpus * 2 ))
    (( threads > 0 )) || threads=8
    (( threads <= 32 )) || threads=32
  fi
  typeset -g _p9k_preinit="function _p9k_preinit() {
    [[ \$ZSH_VERSION == ${(q)ZSH_VERSION} ]]          || return
    [[ -r ${(q)gitstatus_dir}/gitstatus.plugin.zsh ]] || return
    source ${(q)gitstatus_dir}/gitstatus.plugin.zsh   || return
    GITSTATUS_DAEMON=${(q)daemon} GITSTATUS_NUM_THREADS=$threads              \
      GITSTATUS_LOG_LEVEL=${(q)GITSTATUS_LOG_LEVEL}                           \
      GITSTATUS_ENABLE_LOGGING=${(q)GITSTATUS_ENABLE_LOGGING} gitstatus_start \
        -s $_POWERLEVEL9K_VCS_STAGED_MAX_NUM                                  \
        -u $_POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM                                \
        -d $_POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM                               \
        -c $_POWERLEVEL9K_VCS_CONFLICTED_MAX_NUM                              \
        -m $_POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY                            \
        ${${_POWERLEVEL9K_VCS_RECURSE_UNTRACKED_DIRS:#0}:+-e}                 \
        -a POWERLEVEL9K
  }"
  source ${gitstatus_dir}/gitstatus.plugin.zsh
  GITSTATUS_DAEMON=$daemon GITSTATUS_NUM_THREADS=$threads gitstatus_start \
    -s $_POWERLEVEL9K_VCS_STAGED_MAX_NUM                                  \
    -u $_POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM                                \
    -d $_POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM                               \
    -c $_POWERLEVEL9K_VCS_CONFLICTED_MAX_NUM                              \
    -m $_POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY                            \
    ${${_POWERLEVEL9K_VCS_RECURSE_UNTRACKED_DIRS:#0}:+-e}                 \
    POWERLEVEL9K || _p9k__gitstatus_disabled=1
}

_p9k_init() {
  _p9k_init_vars
  _p9k_restore_state || _p9k_init_cacheable

  _p9k_init_display

  if (( $+functions[iterm2_decorate_prompt] )); then
    _p9k__iterm2_decorate_prompt=$functions[iterm2_decorate_prompt]
    function iterm2_decorate_prompt() {
      typeset -g ITERM2_PRECMD_PS1=$PROMPT
      typeset -g ITERM2_SHOULD_DECORATE_PROMPT=
    }
  fi
  if (( $+functions[iterm2_precmd] )); then
    _p9k__iterm2_precmd=$functions[iterm2_precmd]
    functions[iterm2_precmd]='local _p9k_status=$?; zle && return; () { return $_p9k_status; }; '$_p9k__iterm2_precmd
  fi

  if _p9k_segment_in_use todo; then
    local todo=$commands[todo.sh]
    if [[ -n $todo ]]; then
      local bash=${commands[bash]:-:}
      _p9k_todo_file="$($bash 2>/dev/null -c "
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/.todo/config
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/todo.cfg
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/.todo.cfg
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\${XDG_CONFIG_HOME:-\$HOME/.config}/todo/config
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=${(qqq)todo:h}/todo.cfg
        [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\${TODOTXT_GLOBAL_CFG_FILE:-/etc/todo/config}
        [ -r \"\$TODOTXT_CFG_FILE\" ] || exit
        source \"\$TODOTXT_CFG_FILE\" &>/dev/null
        echo \"\$TODO_FILE\"")"
    fi
  fi

  _p9k_wrap_zle_widget zle-line-finish _p9k_zle_line_finish
  _p9k_wrap_zle_widget zle-line-init _p9k_zle_line_init

  if _p9k_segment_in_use vi_mode || _p9k_segment_in_use prompt_char; then
    _p9k_wrap_zle_widget zle-keymap-select _p9k_zle_keymap_select
  fi

  if _p9k_segment_in_use vi_mode && (( $+_POWERLEVEL9K_VI_VISUAL_MODE_STRING )) || _p9k_segment_in_use prompt_char; then
    _p9k_wrap_zle_widget zle-line-pre-redraw _p9k_zle_line_pre_redraw
  fi

  if { _p9k_segment_in_use vi_mode && (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING )) } ||
     { _p9k_segment_in_use prompt_char && (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE )) }; then
    _p9k_wrap_zle_widget overwrite-mode _p9k_zle_state_changed
    _p9k_wrap_zle_widget vi-replace _p9k_zle_state_changed
  fi

  if _p9k_segment_in_use dir &&
     [[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name && $+commands[jq] == 0 ]]; then
    print -rP -- '%F{yellow}WARNING!%f %BPOWERLEVEL9K_SHORTEN_STRATEGY=truncate_with_package_name%b requires %F{green}jq%f.'
    print -rP -- 'Either install %F{green}jq%f or change the value of %BPOWERLEVEL9K_SHORTEN_STRATEGY%b.'
  fi

  _p9k_init_async_pump
  _p9k_init_vcs

  if (( _POWERLEVEL9K_DISABLE_INSTANT_PROMPT )); then
    unset __p9k_instant_prompt_erased
    zf_rm -f -- ${__p9k_dump_file:h}/p10k-instant-prompt-${(%):-%n}.zsh{,.zwc} 2>/dev/null
  fi

  if (( $+__p9k_instant_prompt_erased )); then
    unset __p9k_instant_prompt_erased
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-[%1FERROR%f]: When using instant prompt, Powerlevel10k must be loaded before the first prompt.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-You can:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - %BRecommended%b: Change the way Powerlevel10k is loaded from %B$__p9k_zshrc_u%b.}"
    >&2 echo    - "${(%):-    See \e]8;;https://github.com/romkatv/powerlevel10k/blob/master/README.md#installation\ahttps://github.com/romkatv/powerlevel10k/blob/master/README.md#installation\e]8;;\a.}"
    if (( $+functins[zplugin] )); then
      >&2 echo -E - "${(%):-    NOTE: If using %2Fzplugin%f to load %3F'romkatv/powerlevel10k'%f, %Bdo not apply%b %1Fice wait%f.}"
    fi
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bquickly%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Disable instant prompt either by running %Bp10k configure%b or by manually}"
    >&2 echo -E - "${(%):-    defining the following parameter:}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-      %3Ftypeset%f -g POWERLEVEL9K_INSTANT_PROMPT=off}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill not%b see this error message again.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bslowly%b.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-  - Do nothing.}"
    >&2 echo -E - ""
    >&2 echo -E - "${(%):-    * You %Bwill%b see this error message every time you start zsh.}"
    >&2 echo -E - "${(%):-    * Zsh will start %Bslowly%b.}"
    >&2 echo -E - ""
  fi
}

_p9k_deinit() {
  (( $+functions[_p9k_preinit] )) && unfunction _p9k_preinit
  (( $+functions[gitstatus_stop] )) && gitstatus_stop POWERLEVEL9K
  _p9k_deinit_async_pump
  (( _p9k__dump_pid )) && wait $_p9k__dump_pid 2>/dev/null
  (( $+_p9k__iterm2_precmd )) && functions[iterm2_precmd]=$_p9k__iterm2_precmd
  (( $+_p9k__iterm2_decorate_prompt )) && functions[iterm2_decorate_prompt]=$_p9k__iterm2_decorate_prompt
  unset -m '(_POWERLEVEL9K_|P9K_|_p9k_)*~(P9K_SSH|P9K_TTY)'
}

typeset -gi __p9k_enabled=0
typeset -gi __p9k_configured=0
typeset -gri __p9k_instant_prompt_disabled=1

# `typeset -g` doesn't roundtrip in zsh prior to 5.4.
if is-at-least 5.4; then
  typeset -gri __p9k_dumps_enabled=1
else
  typeset -gri __p9k_dumps_enabled=0
fi

_p9k_do_nothing() { true; }

prompt_powerlevel9k_setup() {
  (( __p9k_enabled )) && return

  prompt_opts=(percent subst)
  (( $+__p9k_instant_prompt_active )) || {
    [[ ! -o prompt_sp ]] || prompt_opts+=sp
    [[ ! -o prompt_cr ]] || prompt_opts+=cr
  }

  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  prompt_powerlevel9k_teardown
  __p9k_enabled=1
  add-zsh-hook preexec _p9k_preexec
  typeset -ga precmd_functions=(_p9k_do_nothing $precmd_functions _p9k_precmd)
}

prompt_powerlevel9k_teardown() {
  emulate -L zsh
  setopt no_hist_expand extended_glob no_prompt_bang prompt_{percent,subst} no_aliases
  add-zsh-hook -D precmd '(_p9k_|powerlevel9k_)*'
  add-zsh-hook -D preexec '(_p9k_|powerlevel9k_)*'
  PROMPT='%m%# '
  RPROMPT=
  if (( __p9k_enabled )); then
    _p9k_deinit
    __p9k_enabled=0
  fi
}

typeset -gr __p9k_p10k_usage="Usage: %2Fp10k%f %Bcommand%b [options]

Commands:

  %Bconfigure%b  run interactive configuration wizard
  %Breload%b     reload configuration
  %Bsegment%b    print a user-defined prompt segment
  %Bdisplay%b    show, hide or toggle prompt parts
  %Bhelp%b       print this help message

Print help for a specific command:

  %2Fp10k%f %Bhelp%b command"

typeset -gr __p9k_p10k_segment_usage="Usage: %2Fp10k%f %Bsegment%b [-h] [{+|-}re] [-s state] [-b bg] [-f fg] [-i icon] [-c cond] [-t text]

Print a user-defined prompt segment. Can be called only during prompt rendering.

Options:
  -t text   segment's main content; will undergo prompt expansion: '%%F{blue}%%*%%f' will
            show as %F{blue}%*%f; default is empty
  -i icon   segment's icon; default is empty
  -r        icon is a symbolic reference that needs to be resolved; for example, 'LOCK_ICON'
  +r        icon is already resolved and should be printed literally; for example, '⭐';
            this is the default; you can also use \$'\u2B50' if you don't want to have
            non-ascii characters in source code
  -b bg     background color; for example, 'blue', '4', or '#0000ff'; empty value means
            transparent background, as in '%%k'; default is black
  -f fg     foreground color; for example, 'blue', '4', or '#0000ff'; empty value means
            default foreground color, as in '%%f'; default is empty
  -s state  segment's state for the purpose of applying styling options; if you want to
            to be able to use POWERLEVEL9K parameters to specify different colors or icons
            depending on some property, use different states for different values of that
            property
  -c        condition; if empty after parameter expansion and process substitution, the
            segment is hidden; this is an advanced feature, use with caution; default is '1'
  -e        segment's main content will undergo parameter expansion and process
            substitution; the content will be surrounded with double quotes and thus
            should quote its own double quotes; this is an advanced feature, use with
            caution
  +e        segment's main content should not undergo parameter expansion and process
            substitution; this is the default
  -h        print this help message

Example: 'core' segment tells you if there is a file name 'core' in the current directory.

- Segment's icon is '⭐'.
- Segment's text is the file's size in bytes.
- If you have permissions to delete the file, state is DELETABLE. If not, it's PROTECTED.

  zmodload -F zsh/stat b:zstat

  function prompt_core() {
    local size=()
    if ! zstat -A size +size core 2>/dev/null; then
      # No 'core' file in the current directory.
      return
    fi
    if [[ -w . ]]; then
      local state=DELETABLE
    else
      local state=PROTECTED
    fi
    p10k segment -s \\\$state -i '⭐' -f blue -t \\\${size[1]}b
  }

To enable this segment, add 'core' to POWERLEVEL9K_LEFT_PROMPT_ELEMENTS or
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS.

Example customizations:

  # Override default foreground.
  POWERLEVEL9K_CORE_FOREGROUND=red

  # Override foreground when DELETABLE.
  POWERLEVEL9K_CORE_DELETABLE_BACKGROUND=green

  # Override icon when PROTECTED.
  POWERLEVEL9K_CORE_PROTECTED_VISUAL_IDENTIFIER_EXPANSION='❎'

  # Don't show file size when PROTECTED.
  POWERLEVEL9K_CORE_PROTECTED_CONTENT_EXPANSION=''"

typeset -gr __p9k_p10k_configure_usage="Usage: %2Fp10k%f %Bconfigure%b

Run interactive configuration wizard."

typeset -gr __p9k_p10k_reload_usage="Usage: %2Fp10k%f %Breload%b

Reload configuration."

typeset -gr __p9k_p10k_finalize_usage="Usage: %2Fp10k%f %Bfinalize%b

Perform the final stage of initialization. Must be called at the very end of zshrc."

typeset -gr __p9k_p10k_display_usage="Usage: %2Fp10k%f %Bdisplay%b part-pattern=state-list...

Show, hide or toggle prompt parts. If called from zle, the current
prompt is refreshed.

Parts:
  empty_line    empty line (duh)
  ruler         ruler; if POWERLEVEL9K_RULER_CHAR=' ', it's essentially another new_line
  N             prompt line number N, 1-based; counting from the top if positive,
                from the bottom if negative
  N/left_frame  left frame on the Nth line
  N/left        left prompt on the Nth line
  N/gap         gap between left and right prompts on the Nth line
  N/right       right prompt on the Nth line
  N/right_frame right frame on the Nth line
  N/left/S      segment S within N/left (dir, time, etc.)
  N/right/S     segment S within N/right (dir, time, etc.)

Part States:
  show          the part is displayed
  hide          the part is not displayed
  print         the part is printed in precmd; only applicable to empty_line and
                ruler; looks better than show after clear; unlike show, the effects
                of print cannot be undone with hide

Example: Bind Ctrl+P to toggle right prompt.

  function toggle-right-prompt() { p10k display '*/right'=hide,show; }
  zle -N toggle-right-prompt
  bindkey '^P' toggle-right-prompt"

# 0  -- reset-prompt not blocked
# 1  -- reset-prompt blocked and not needed
# 2  -- reset-prompt blocked and needed
typeset -gi __p9k_reset_state

function p10k() {
  [[ $# != 1 || $1 != finalize ]] || { p10k-instant-prompt-finalize; return 0 }

  emulate -L zsh
  setopt no_hist_expand extended_glob prompt_percent prompt_subst no_aliases

  if (( !ARGC )); then
    print -rP -- $__p9k_p10k_usage >&2
    return 1
  fi

  case $1 in
    segment)
      shift
      local opt state bg=0 fg icon cond text ref=0 expand=0
      while getopts ':s:b:f:i:c:t:reh' opt; do
        case $opt in
          s) state=$OPTARG;;
          b) bg=$OPTARG;;
          f) fg=$OPTARG;;
          i) icon=$OPTARG;;
          c) cond=${OPTARG:-'${:-}'};;
          t) text=$OPTARG;;
          r) ref=1;;
          e) expand=1;;
          +r) ref=0;;
          +e) expand=0;;
          h) print -rP -- $__p9k_p10k_segment_usage; return 0;;
          ?) print -rP -- $__p9k_p10k_segment_usage >&2; return 1;;
        esac
      done
      if (( OPTIND <= ARGC )); then
        print -rP -- $__p9k_p10k_segment_usage >&2
        return 1
      fi
      if [[ -z $_p9k_prompt_side ]]; then
        print -rP -- "%1F[ERROR]%f %Bp10k segment%b: can be called only during prompt rendering." >&2
        if (( !ARGC )); then
          print -rP -- ""
          print -rP -- "For help, type:" >&2
          print -rP -- ""
          print -rP -- "  %2Fp10k%f %Bhelp%b %Bsegment%b" >&2
        fi
        return 1
      fi
      (( ref )) || icon=$'\1'$icon
      "_p9k_${_p9k_prompt_side}_prompt_segment" "prompt_${_p9k_segment_name}${state:+_${(U)state}}" \
          "$bg" "${fg:-$_p9k_color1}" "$icon" "$expand" "$cond" "$text"
      return 0
      ;;
    display)
      if (( ARGC == 1 )); then
        print -rP -- $__p9k_p10k_display_usage >&2
        return 1
      fi
      if [[ $2 == -h ]]; then
        print -rP -- $__p9k_p10k_display_usage >&2
        return 0
      fi
      shift
      local opt match MATCH prev new pair list name var
      local -i k
      for opt; do
        pair=(${(s:=:)opt})
        list=(${(s:,:)${pair[2]}})
        for k in ${(u@)_p9k__display_k[(I)$pair[1]]:/(#m)*/$_p9k__display_k[$MATCH]}; do
          if (( $#list == 1 )); then  # this branch is purely for optimization
            [[ $_p9k__display_v[k+1] == $list[1] ]] && continue
            new=$list[1]
          else
            new=${list[list[(I)$_p9k__display_v[k+1]]+1]:-$list[1]}
            [[ $_p9k__display_v[k+1] == $new ]] && continue
          fi
          _p9k__display_v[k+1]=$new
          name=$_p9k__display_v[k]
          if [[ $name == (empty_line|ruler) ]]; then
            var=_p9k__${name}_i
            [[ $new == show ]] && unset $var || typeset -gi $var=3
          elif [[ $name == (#b)(<->)(*) ]]; then
            var=_p9k__${match[1]}${${${${match[2]//\/}/#left/l}/#right/r}/#gap/g}
            [[ $new == hide ]] && typeset -g $var= || unset $var
          fi
          if (( __p9k_reset_state > 0 )); then
            __p9k_reset_state=2
          else
            __p9k_reset_state=-1
          fi
        done
      done
      if (( __p9k_reset_state == -1 )); then
        _p9k_reset_prompt
        __p9k_reset_state=0
      fi
      ;;
    configure)
      if (( ARGC > 1 )); then
        print -rP -- $__p9k_p10k_configure_usage >&2
        return 1
      fi
      p9k_configure "$@" || return
      ;;
    reload)
      if (( ARGC > 1 )); then
        print -rP -- $__p9k_p10k_reload_usage >&2
        return 1
      fi
      (( $+_p9k__force_must_init )) || return 0
      _p9k__force_must_init=1
      ;;
    help)
      local var=__p9k_p10k_$2_usage
      if (( $+parameters[$var] )); then
        print -rP -- ${(P)var}
        return 0
      elif (( ARGC == 1 )); then
        print -rP -- $__p9k_p10k_usage
        return 0
      else
        print -rP -- $__p9k_p10k_usage >&2
        return 1
      fi
      ;;
    finalize)
      print -rP -- $__p9k_p10k_finalize_usage >&2
      return 1
      ;;
    *)
      print -rP -- $__p9k_p10k_usage >&2
      return 1
      ;;
  esac
}

# Hook for zplugin.
powerlevel10k_plugin_unload() { prompt_powerlevel9k_teardown; }

function p10k-instant-prompt-finalize() {
  (( ! __p9k_instant_prompt_active )) || unsetopt localoptions prompt_cr
}

autoload -Uz add-zsh-hook

zmodload zsh/datetime
zmodload zsh/mathfunc
zmodload zsh/parameter 2>/dev/null  # https://github.com/romkatv/gitstatus/issues/58#issuecomment-553407177
zmodload zsh/system
zmodload zsh/termcap
zmodload zsh/terminfo
zmodload -F zsh/stat b:zstat
zmodload -F zsh/net/socket b:zsocket
zmodload -F zsh/files b:zf_mv b:zf_rm

if [[ $__p9k_dump_file != $__p9k_instant_prompt_dump_file && -n $__p9k_instant_prompt_dump_file ]]; then
  zf_rm -f $__p9k_instant_prompt_dump_file 2>/dev/null
fi

if [[ $+__p9k_instant_prompt_sourced == 1 && $__p9k_instant_prompt_sourced != $__p9k_instant_prompt_version ]]; then
  zf_rm -f -- ${__p9k_dump_file:h}/p10k-instant-prompt-${(%):-%n}.zsh{,.zwc} 2>/dev/null
fi

_p9k_init_ssh
prompt_powerlevel9k_setup
