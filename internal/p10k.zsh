if ! autoload -U is-at-least || ! is-at-least 5.1; then
  () {
    >&2 echo -E "You are using ZSH version $ZSH_VERSION. The minimum required version for Powerlevel10k is 5.1."
    >&2 echo -E "Type 'echo \$ZSH_VERSION' to see your current zsh version."
    local def=${SHELL:c:A}
    local cur=${${ZSH_ARGZERO#-}:c:A}
    local cur_v=$($cur -c 'echo -E $ZSH_VERSION' 2>/dev/null)
    if [[ $cur_v == $ZSH_VERSION && $cur != $def ]]; then
      >&2 echo -E "The shell you are currently running is likely $cur."
    fi
    local other=${${:-zsh}:c}
    if [[ -n $other ]] && $other -c 'autoload -U is-at-least && is-at-least 5.1' &>/dev/null; then
      local other_v=$($other -c 'echo -E $ZSH_VERSION' 2>/dev/null)
      if [[ -n $other_v && $other_v != $ZSH_VERSION ]]; then
        >&2 echo -E "You have $other with version $other_v but this is not what you are using."
        if [[ -n $def && $def != ${other:A} ]]; then
          >&2 echo -E "To change your user shell, type the following command:"
          >&2 echo -E ""
          if [[ $(grep -F $other /etc/shells 2>/dev/null) != $other ]]; then
            >&2 echo -E "  echo ${(q-)other} | sudo tee -a /etc/shells"
          fi
          >&2 echo -E "  chsh -s ${(q-)other}"
        fi
      fi
    fi
  }
  return 1
fi

source "${_p9k_installation_dir}/functions/utilities.zsh"
source "${_p9k_installation_dir}/functions/icons.zsh"
source "${_p9k_installation_dir}/functions/colors.zsh"
source "${_p9k_installation_dir}/functions/vcs.zsh"

typeset -g _P9K_RETVAL
typeset -g _P9K_CACHE_KEY
typeset -ga _P9K_CACHE_VAL
typeset -gA _P9K_CACHE
typeset -ga _P9K_T
typeset -g _P9K_N
typeset -gi _P9K_I
typeset -g _P9K_BG
typeset -g _P9K_F

# Specifies the maximum number of elements in the cache. When the cache grows over this limit,
# it gets cleared. This is meant to avoid memory leaks when a rogue prompt is filling the cache
# with data.
set_default -i POWERLEVEL9K_MAX_CACHE_SIZE 10000

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
  _P9K_CACHE[$_P9K_CACHE_KEY]="${(pj:\0:)*}0"
  _P9K_CACHE_VAL=("$@")
  (( $#_P9K_CACHE < POWERLEVEL9K_MAX_CACHE_SIZE )) || typeset -gAH _P9K_CACHE=()
}

_p9k_cache_get() {
  _P9K_CACHE_KEY="${(pj:\0:)*}"
  local v=$_P9K_CACHE[$_P9K_CACHE_KEY]
  [[ -n $v ]] && _P9K_CACHE_VAL=("${(@0)${v[1,-2]}}")
}

# Sets _P9K_RETVAL to the icon whose name is supplied via $1.
_p9k_get_icon() {
  local var_name=POWERLEVEL9K_$1
  _P9K_RETVAL=${(g::)${${(P)var_name}-$icons[$1]}}
  [[ $_P9K_RETVAL != $'\b'? ]] || _P9K_RETVAL="%{$_P9K_RETVAL%}"  # penance for past sins
}

typeset -ga _P9K_LEFT_JOIN=(1)
typeset -ga _P9K_RIGHT_JOIN=(1)

_p9k_translate_color() {
  if [[ $1 == <-> ]]; then     # decimal color code: 255
    _P9K_RETVAL=$1
  elif [[ $1 == '#'* ]]; then  # hexademical color code: #ffffff
    _P9K_RETVAL=$1
  else                         # named color: red
    # Strip prifixes if there are any.
    _P9K_RETVAL=$__P9K_COLORS[${${${1#bg-}#fg-}#br}]
  fi
}

# Resolves a color to its numerical value, or an empty string. Communicates the result back
# by setting _P9K_RETVAL.
_p9k_color() {
  local user_var=POWERLEVEL9K_${(U)${2}#prompt_}_${3}
  _p9k_translate_color ${${(P)user_var}:-${1}}
}

_p9k_background() {
  [[ -n $1 ]] && _P9K_RETVAL="%K{$1}" || _P9K_RETVAL="%k"
}

_p9k_foreground() {
  [[ -n $1 ]] && _P9K_RETVAL="%F{$1}" || _P9K_RETVAL="%f"
}

_p9k_escape_rcurly() {
  _P9K_RETVAL=${${1//\\/\\\\}//\}/\\\}}
}

# Begin a left prompt segment.
#
#    * $1: Name of the function that was originally invoked.
#          Necessary, to make the dynamic color-overwrite mechanism work.
#    * $2: The array index of the current segment.
#    * $3: Background color.
#    * $4: Foreground color.
#    * $5: An identifying icon (must be a key of the icons array).
#    * $6: 1 to to perform parameter expansion and process substitution.
#    * $7: If not empty but becomes empty after parameter expansion and process substitution,
#          the segment isn't rendered.
#   * $8+: The segment content
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS " "
left_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$5"; then
    _p9k_color $3 $1 BACKGROUND
    local bg_color=$_P9K_RETVAL
    _p9k_background $bg_color
    local bg=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local fg_color=$_P9K_RETVAL
    _p9k_foreground $fg_color
    local fg=$_P9K_RETVAL

    _p9k_get_icon LEFT_SUBSEGMENT_SEPARATOR
    local subsep=$_P9K_RETVAL

    _p9k_escape_rcurly $POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
    local space=$_P9K_RETVAL

    local icon
    local -i has_icon
    if [[ -n $5 ]]; then
      _p9k_get_icon $5
      if [[ -n $_P9K_RETVAL ]]; then
        local glyph=$_P9K_RETVAL
        _p9k_color $fg_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        icon=$_P9K_RETVAL$glyph
        has_icon=1
      fi
    fi

    # Segment separator logic:
    #
    #   if [[ $_P9K_BG == NONE ]]; then
    #     1
    #   elif (( joined )); then
    #     2
    #   elif [[ $bg_color == $_P9K_BG ]]; then
    #     3
    #   else
    #     4
    #   fi

    local t=$#_P9K_T
    _P9K_T+=$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon                         # 1
    _P9K_T+=$bg$icon                                                                       # 2
    if [[ -z $fg_color ]]; then
      _p9k_foreground $DEFAULT_COLOR
      _P9K_T+=$bg$_P9K_RETVAL$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon    # 3
    else
      _P9K_T+=$bg$fg$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon             # 3
    fi
    _p9k_get_icon LEFT_SEGMENT_SEPARATOR
    _P9K_T+=$bg$_P9K_RETVAL$POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS$icon             # 4

    local pre
    pre+="\${_P9K_N::=}\${_P9K_F::=}"
    pre+="\${\${\${_P9K_BG:-0}:#NONE}:-\${_P9K_N::=$((t+1))}}"                        # 1
    pre+="\${_P9K_N:=\${\${\$((_P9K_I>=$_P9K_LEFT_JOIN[$2])):#0}:+$((t+2))}}"         # 2
    pre+="\${_P9K_N:=\${\${\$((!\${#\${:-0\$_P9K_BG}:#0$bg_color})):#0}:+$((t+3))}}"  # 3
    pre+="\${_P9K_N:=\${\${_P9K_F::=%F{\$_P9K_BG\}}+$((t+4))}}}+}"                    # 4
    pre+="%b\${_P9K_F}\${_P9K_T[\$_P9K_N]}"

    _p9k_escape_rcurly %b$bg$fg
    local post="\${_P9K_C}$_P9K_RETVAL$space\${\${_P9K_I::=$2}+}\${\${_P9K_BG::=$bg_color}+}}"

    _p9k_cache_set $has_icon $_P9K_RETVAL $pre $post
  fi

  local name=$1
  local -i has_icon=${_P9K_CACHE_VAL[1]}
  local style=${_P9K_CACHE_VAL[2]}
  local -i expand=$6
  local cond=${7:-1}
  shift 7

    local content="${(j::):-$style${^@}}"
  (( expand )) || content="\${(Q)\${:-${(qqq)content}}}"

  _P9K_PROMPT+="\${\${:-$cond}:+\${\${:-\${_P9K_C::=${content}}${_P9K_CACHE_VAL[3]}"
  (( has_icon )) && _P9K_PROMPT+='${${(%):-$_P9K_C%1(l. .x)}[-1]%x}'
  _P9K_PROMPT+=${_P9K_CACHE_VAL[4]}
}

# The same as left_prompt_segment above but for the right prompt.
set_default POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS " "
right_prompt_segment() {
  if ! _p9k_cache_get "$0" "$1" "$2" "$3" "$4" "$5"; then
    _p9k_color $3 $1 BACKGROUND
    local bg_color=$_P9K_RETVAL
    _p9k_background $bg_color
    local bg=$_P9K_RETVAL

    _p9k_color $4 $1 FOREGROUND
    local fg_color=$_P9K_RETVAL
    _p9k_foreground $fg_color
    local fg=$_P9K_RETVAL

    _p9k_get_icon RIGHT_SUBSEGMENT_SEPARATOR
    local subsep=$_P9K_RETVAL

    local icon_style icon
    local -i has_icon
    if [[ -n $5 ]]; then
      _p9k_get_icon $5
      if [[ -n $_P9K_RETVAL ]]; then
        _p9k_escape_rcurly $_P9K_RETVAL
        icon=$_P9K_RETVAL
        _p9k_color $fg_color $1 VISUAL_IDENTIFIER_COLOR
        _p9k_foreground $_P9K_RETVAL
        _p9k_escape_rcurly %b$bg$_P9K_RETVAL
        icon_style=$_P9K_RETVAL
        has_icon=1
      fi
    fi

    # Segment separator logic is the same as in left_prompt_segment except that here #4 and #1 are
    # identical.

    local t=$#_P9K_T
    _p9k_get_icon RIGHT_SEGMENT_SEPARATOR
    _P9K_T+="%F{$bg_color}$_P9K_RETVAL$bg$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS$fg"  # 1
    _P9K_T+=$fg                                                                               # 2
    if [[ -z $fg_color ]]; then
      _p9k_foreground $DEFAULT_COLOR
      _P9K_T+=$bg$_P9K_RETVAL$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS$fg        # 3
    else
      _P9K_T+=$bg$fg$subsep$POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS                    # 3
    fi

    local pre
    pre+="\${_P9K_N::=}"
    pre+="\${\${\${_P9K_BG:-0}:#NONE}:-\${_P9K_N::=$((t+1))}}"                        # 1
    pre+="\${_P9K_N:=\${\${\$((_P9K_I>=$_P9K_RIGHT_JOIN[$2])):#0}:+$((t+2))}}"        # 2
    pre+="\${_P9K_N:=\${\${\$((!\${#\${:-0\$_P9K_BG}:#0$bg_color})):#0}:+$((t+3))}}"  # 3
    pre+="\${_P9K_N:=$((t+1))}}+}"                                                    # 4 == 1
    pre+="\${_P9K_T[\$_P9K_N]}\${_P9K_C}$icon_style"

    _p9k_escape_rcurly $POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS
    local space=$_P9K_RETVAL
    _p9k_escape_rcurly %b$bg$fg
    local post="$icon$_P9K_RETVAL$space\${\${_P9K_I::=$2}+}\${\${_P9K_BG::=$bg_color}+}}"

    _p9k_cache_set $has_icon $_P9K_RETVAL $pre $post
  fi

  local -i has_icon=${_P9K_CACHE_VAL[1]}
  local style=${_P9K_CACHE_VAL[2]}
  local -i expand=$6
  local cond=${7:-1}
  shift 7

  _p9k_escape_rcurly $style
  local content="${(j::):-$_P9K_RETVAL${^@}}"
  (( expand )) || content="\${(Q)\${:-${(qqq)content}}}"

  _P9K_PROMPT+="\${\${:-$cond}:+\${\${:-\${_P9K_C::=${content}}${_P9K_CACHE_VAL[3]}"
  (( has_icon )) && _P9K_PROMPT+='${${(%):-$_P9K_C%1(l. .x)}[-1]%x}'
  _P9K_PROMPT+=${_P9K_CACHE_VAL[4]}
}

################################################################
# Prompt Segment Definitions
################################################################

################################################################
# Anaconda Environment
set_default POWERLEVEL9K_ANACONDA_LEFT_DELIMITER "("
set_default POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER ")"
prompt_anaconda() {
  local p=${CONDA_PREFIX:-$CONDA_ENV_PATH}
  if [[ -n $p ]]; then
    local msg="$POWERLEVEL9K_ANACONDA_LEFT_DELIMITER${${p:t}//\%/%%}$POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER"
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "$msg"
  fi
}

################################################################
# AWS Profile
prompt_aws() {
  local aws_profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [[ -n "$aws_profile" ]]; then
    "$1_prompt_segment" "$0" "$2" red white 'AWS_ICON' 0 '' "${aws_profile//\%/%%}"
  fi
}

################################################################
# Current Elastic Beanstalk environment
prompt_aws_eb_env() {
  [[ -r .elasticbeanstalk/config.yml ]] || return
  local v=${=$(command grep environment .elasticbeanstalk/config.yml 2>/dev/null)[2]}
  [[ -n $v ]] && "$1_prompt_segment" "$0" "$2" black green 'AWS_EB_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to indicate background jobs with an icon.
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE true
set_default POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS false
prompt_background_jobs() {
  local msg
  if [[ $POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE == true ]]; then
    if [[ $POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS == true ]]; then
      msg='${(%):-%j}'
    else
      msg='${${(%):-%j}:#1}'
    fi
  fi
  $1_prompt_segment $0 $2 "$DEFAULT_COLOR" cyan BACKGROUND_JOBS_ICON 1 '${${(%):-%j}:#0}' "$msg"
}

typeset -g _P9K_XY _P9K_CLM _P9K_ALIGNED_RPROMPT
typeset -gi _P9K_X _P9K_Y _P9K_M _P9K_RPROMPT_DONE _P9K_IND

# Returns 1 if the cursor is at the very end of the screen.
function _p9k_left_prompt_end_line() {
  _p9k_get_icon LEFT_SEGMENT_SEPARATOR
  _p9k_escape_rcurly $_P9K_RETVAL
  _P9K_PROMPT+="%k%b"
  _P9K_PROMPT+="\${_P9K_N::=}"
  _P9K_PROMPT+="\${\${\${_P9K_BG:#NONE}:-\${_P9K_N:=1}}+}"
  _P9K_PROMPT+="\${\${_P9K_N:=2}+}"
  _P9K_PROMPT+="\${\${_P9K_T[2]::=%F{\$_P9K_BG\}$_P9K_RETVAL}+}"
  _P9K_PROMPT+="\${_P9K_T[\$_P9K_N]}"
  _P9K_PROMPT+="%f$1%f%k%b"

  if (( ! _P9K_RPROMPT_DONE )); then
    _P9K_PROMPT+=$_P9K_ALIGNED_RPROMPT
    _P9K_RPROMPT_DONE=1
    return 1
  fi
}

################################################################
# A newline in your prompt, so you can segments on multiple lines.
set_default POWERLEVEL9K_PROMPT_ON_NEWLINE false
set_default POWERLEVEL9K_RPROMPT_ON_NEWLINE false
prompt_newline() {
  [[ "$1" == "right" ]] && return
  _p9k_left_prompt_end_line && _P9K_PROMPT+=$'\n'
  _P9K_PROMPT+='${${_P9K_BG::=NONE}+}'
  if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE == true ]]; then
    _p9k_get_icon MULTILINE_NEWLINE_PROMPT_PREFIX
    _P9K_PROMPT+=$_P9K_RETVAL
  fi
}

################################################################
# Segment that indicates usage level of current partition.
set_default POWERLEVEL9K_DISK_USAGE_ONLY_WARNING false
set_default -i POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL 90
set_default -i POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL 95
prompt_disk_usage() {
  (( $+commands[df] )) || return
  local disk_usage=${${=${(f)"$(command df -P . 2>/dev/null)"}[2]}[5]%%%}
  local state bg fg
  if (( disk_usage >= POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL )); then
    state=critical
    bg=red
    fg=white
  elif (( disk_usage >= POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL )); then
    state=warning
    bg=yellow
    fg=$DEFAULT_COLOR
  else
    [[ "$POWERLEVEL9K_DISK_USAGE_ONLY_WARNING" == true ]] && return
    state=normal
    bg=$DEFAULT_COLOR
    fg=yellow
  fi
  $1_prompt_segment $0_$state $2 $bg $fg DISK_ICON 0 '' "$disk_usage%%"
}

################################################################
# Segment that displays the battery status in levels and colors
set_default -i POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10
set_default -i POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD 999
set_default -a POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND
set_default    POWERLEVEL9K_BATTERY_VERBOSE true
typeset     -g POWERLEVEL9K_BATTERY_STAGES

typeset -gA _P9K_BATTERY_STATES=(
  'low'           'red'
  'charging'      'yellow'
  'charged'       'green'
  'disconnected'  "$DEFAULT_COLOR_INVERTED"
)

function _p9k_read_file() {
  _P9K_RETVAL=''
  [[ -n $1 ]] && read -r _P9K_RETVAL <$1
  [[ -n $_P9K_RETVAL ]]
}

prompt_battery() {
  local state remain
  local -i bat_percent

  case $OS in
    OSX)
      (( $+commands[pmset] )) || return
      local raw_data=${${(f)$(command pmset -g batt 2>/dev/null)}[2]}
      [[ $raw_data == *InternalBattery* ]] || return
      remain=${${(s: :)${${(s:; :)raw_data}[3]}}[1]}
      [[ $remain == *no* ]] && remain="..."
      [[ $raw_data =~ '([0-9]+)%' ]] && bat_percent=$match[1]

      case "${${(s:; :)raw_data}[2]}" in
        'charging'|'finishing charge'|'AC attached')
          state=charging
        ;;
        'discharging')
          (( bat_percent < POWERLEVEL9K_BATTERY_LOW_THRESHOLD )) && state=low || state=disconnected
        ;;
        *)
          state=charged
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
        local -i pow=0
        _p9k_read_file $dir/(energy|charge)_now(N)  && (( energy_now+=_P9K_RETVAL ))
        _p9k_read_file $dir/(energy|charge)_full(N) && (( energy_full+=_P9K_RETVAL ))
        _p9k_read_file $dir/(power|current)_now(N)  && (( power_now+=${pow::=$_P9K_RETVAL} ))
        _p9k_read_file $dir/status(N) && local bat_status=$_P9K_RETVAL || continue
        [[ $bat_status != Full                                ]] && is_full=0
        [[ $bat_status == Charging                            ]] && is_charching=1
        [[ $bat_status == (Charging|Discharging) && $pow == 0 ]] && is_calculating=1
      done

      if (( energy_full )); then
        bat_percent=$(( 100 * energy_now / energy_full ))
        (( bat_percent > 100 )) && bat_percent=100
      fi

      if (( is_full || bat_percent == 100 )); then
        state=charged
      else
        if (( is_charching )); then
          state=charging
        elif (( bat_percent < POWERLEVEL9K_BATTERY_LOW_THRESHOLD )); then
          state=low
        else
          state=disconnected
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
      return
    ;;
  esac

  (( bat_percent >= POWERLEVEL9K_BATTERY_HIDE_ABOVE_THRESHOLD )) && return

  local msg="$bat_percent%%"
  [[ $POWERLEVEL9K_BATTERY_VERBOSE == true && -n $remain ]] && msg+=" ($remain)"

  local icon=BATTERY_ICON bg=$DEFAULT_COLOR
  if (( $#POWERLEVEL9K_BATTERY_STAGES || $#POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND )); then
    local -i idx=$#POWERLEVEL9K_BATTERY_STAGES
    (( bat_percent < 100 )) && idx=$((bat_percent * $#POWERLEVEL9K_BATTERY_STAGES / 100 + 1))
    if (( $#POWERLEVEL9K_BATTERY_STAGES )); then
      icon+=_$idx
      typeset -g POWERLEVEL9K_$icon=$POWERLEVEL9K_BATTERY_STAGES[idx]
    fi
    (( $#POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND )) && bg=$POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND[idx]
  fi

  $1_prompt_segment $0_$state $2 "$bg" "$_P9K_BATTERY_STATES[$state]" $icon 0 '' $msg
}

typeset -gF _P9K_PUBLIC_IP_TIMESTAMP
typeset -g  _P9K_PUBLIC_IP

################################################################
# Public IP segment
set_default -i POWERLEVEL9K_PUBLIC_IP_TIMEOUT 300
set_default -a POWERLEVEL9K_PUBLIC_IP_METHODS dig curl wget
set_default    POWERLEVEL9K_PUBLIC_IP_NONE ""
set_default    POWERLEVEL9K_PUBLIC_IP_HOST "http://ident.me"
set_default    POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ""

prompt_public_ip() {
  if (( ! $#_P9K_PUBLIC_IP || EPOCHREALTIME >= _P9K_PUBLIC_IP_TIMESTAMP + POWERLEVEL9K_PUBLIC_IP_TIMEOUT )); then
    _P9K_PUBLIC_IP=''
    local method
    for method in $POWERLEVEL9K_PUBLIC_IP_METHODS; do
      case $method in
        'dig')
          if (( $+commands[dig] )); then
            _P9K_PUBLIC_IP="$(command dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com 2> /dev/null)"
            [[ $_P9K_PUBLIC_IP == ';'* ]] && _P9K_PUBLIC_IP=''
          fi
        ;;
        'curl')
          if (( $+commands[curl] )); then
            _P9K_PUBLIC_IP="$(command curl --max-time 10 -w '\n' "$POWERLEVEL9K_PUBLIC_IP_HOST" 2> /dev/null)"
          fi
        ;;
        'wget')
          if (( $+commands[wget] )); then
            _P9K_PUBLIC_IP="$(wget -T 10 -qO- "$POWERLEVEL9K_PUBLIC_IP_HOST" 2> /dev/null)"
          fi
        ;;
      esac
      if [[ -n $_P9K_PUBLIC_IP ]]; then
        _P9K_PUBLIC_IP_TIMESTAMP=$EPOCHREALTIME
        break
      fi
    done
  fi

  local ip=${_P9K_PUBLIC_IP:-$POWERLEVEL9K_PUBLIC_IP_NONE}
  [[ -n $ip ]] || return

  local icon='PUBLIC_IP_ICON'
  if [[ -n $POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]]; then
    _p9k_parse_ip $POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE && icon='VPN_ICON'
  fi

  $1_prompt_segment "$0" "$2" "$DEFAULT_COLOR" "$DEFAULT_COLOR_INVERTED" "$icon" 0 '' "${ip//\%/%%}"
}

################################################################
# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_ALWAYS_SHOW_CONTEXT false
set_default POWERLEVEL9K_ALWAYS_SHOW_USER false
set_default POWERLEVEL9K_CONTEXT_TEMPLATE "%n@%m"
prompt_context() {
  local content
  if [[ $POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == true || -z $DEFAULT_USER || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    content=$POWERLEVEL9K_CONTEXT_TEMPLATE
  else
    local user=$(whoami)
    if [[ $user != $DEFAULT_USER ]]; then
      content="${POWERLEVEL9K_CONTEXT_TEMPLATE}"
    elif [[ $POWERLEVEL9K_ALWAYS_SHOW_USER == true ]]; then
      content="${user//\%/%%}"
    else
      return
    fi
  fi

  local current_state="DEFAULT"
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

  "$1_prompt_segment" "${0}_${current_state}" "$2" "$DEFAULT_COLOR" yellow '' 0 '' "${content}"
}

################################################################
# User: user (who am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
set_default POWERLEVEL9K_USER_TEMPLATE "%n"
prompt_user() {
  local user=$(whoami)
  [[ $POWERLEVEL9K_ALWAYS_SHOW_USER != true && $user == $DEFAULT_USER ]] && return
  if [[ "${(%):-%#}" == '#' ]]; then
    "$1_prompt_segment" "${0}_ROOT" "$2" "${DEFAULT_COLOR}" yellow ROOT_ICON 0 '' "${POWERLEVEL9K_USER_TEMPLATE}"
  elif [[ -n "$SUDO_COMMAND" ]]; then
    "$1_prompt_segment" "${0}_SUDO" "$2" "${DEFAULT_COLOR}" yellow SUDO_ICON 0 '' "${POWERLEVEL9K_USER_TEMPLATE}"
  else
    "$1_prompt_segment" "${0}_DEFAULT" "$2" "${DEFAULT_COLOR}" yellow USER_ICON 0 '' "${user//\%/%%}"
  fi
}

################################################################
# Host: machine (where am I)
set_default POWERLEVEL9K_HOST_TEMPLATE "%m"
prompt_host() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0_REMOTE" "$2" "${DEFAULT_COLOR}" yellow SSH_ICON 0 '' "${POWERLEVEL9K_HOST_TEMPLATE}"
  else
    "$1_prompt_segment" "$0_LOCAL" "$2" "${DEFAULT_COLOR}" yellow HOST_ICON 0 '' "${POWERLEVEL9K_HOST_TEMPLATE}"
  fi
}

################################################################
# The 'custom` prompt provides a way for users to invoke commands and display
# the output in a segment.
prompt_custom() {
  local segment_name="${3:u}"
  # Get content of custom segment
  local command="POWERLEVEL9K_CUSTOM_${segment_name}"
  local -a cmd=("${(@Q)${(z)${(P):-POWERLEVEL9K_CUSTOM_${segment_name}}}}")
  whence $cmd[1] &>/dev/null || return
  local content=$("$cmd[@]")
  [[ -n $content ]] || return
  "$1_prompt_segment" "${0}_${3:u}" "$2" $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR "CUSTOM_${segment_name}_ICON" 0 '' "$content"
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

  "$1_prompt_segment" "$0" "$2" "red" "yellow1" 'EXECUTION_TIME_ICON' 0 '' "${humanReadableDuration}"
}

set_default POWERLEVEL9K_DIR_PATH_SEPARATOR "/"
set_default POWERLEVEL9K_HOME_FOLDER_ABBREVIATION "~"
set_default POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD false
set_default POWERLEVEL9K_DIR_PATH_ABSOLUTE false
set_default POWERLEVEL9K_DIR_SHOW_WRITABLE false
set_default POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER false
set_default POWERLEVEL9K_SHORTEN_STRATEGY ""
set_default POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND ""
set_default POWERLEVEL9K_SHORTEN_FOLDER_MARKER "(.shorten_folder_marker|.bzr|CVS|.git|.hg|.svn|.terraform|.citc)"

# Stop shortening the directory once its length is no greater than this. The value can be either
# absolute (e.g., '50') or a percentage of terminal width (e.g, '50%').
#
# Currently only applied when POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique. If you want to use
# it with another shortening strategy, open an issue.
set_default POWERLEVEL9K_DIR_MAX_LENGTH 0

# Individual elements are patterns. They are expanded with the options set
# by `emulate zsh && setopt extended_glob`.
set_default -a POWERLEVEL9K_DIR_PACKAGE_FILES package.json composer.json

function _p9k_shorten_delim_len() {
  local def=$1
  _P9K_RETVAL=${POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
  (( _P9K_RETVAL >= 0 )) || _p9k_prompt_length $1
}

################################################################
# Dir: current working directory
prompt_dir() {
  emulate -L zsh && setopt extended_glob

  [[ $POWERLEVEL9K_DIR_PATH_ABSOLUTE == true ]] && local p=$PWD || local p=${(%):-%~}

  if [[ $p == '~['* ]]; then
    # If "${(%):-%~}" expands to "~[a]/]/b", is the first component "~[a]" or "~[a]/]"?
    # One would expect "${(%):-%-1~}" to give the right answer but alas it always simply
    # gives the segment before the first slash, which would be "~[a]" in this case. Worse,
    # for "~[a/b]" it'll give the nonsensical "~a[". To solve this problem we have to
    # repeat what "${(%):-%~}" does and hope that it produces the same result.
    local func=''
    local -a parts=()
    for func in zsh_directory_name $zsh_directory_name_functions; do
      if (( $+functions[$func] )) && $func d $PWD && [[ $p == '~['$reply[1]']'* ]]; then
        parts+='~['$reply[1]']'
        break
      fi
    done
    if (( $#parts )); then
      parts+=(${(s:/:)${p#$parts[1]}})
    else
      p=$PWD
      parts=("${(s:/:)p}")
    fi
  else
    local -a parts=("${(s:/:)p}")
  fi

  local -i fake_first=0
  local delim=${POWERLEVEL9K_SHORTEN_DELIMITER-$'\u2026'}
  local -i shortenlen=${POWERLEVEL9K_SHORTEN_DIR_LENGTH:--1}

  case $POWERLEVEL9K_SHORTEN_STRATEGY in
    truncate_absolute|truncate_absolute_chars)
      if (( shortenlen > 0 && $#p > shortenlen )); then
        _p9k_shorten_delim_len $delim
        if (( $#p > shortenlen + $_P9K_RETVAL )); then
          local -i n=shortenlen
          local -i i=$#parts
          while true; do
            local dir=$parts[i]
            local -i len=$(( $#dir + (i > 1) ))
            if (( len <= n )); then
              (( n -= len ))
              (( --i ))
            else
              parts[i]=$'\0'$dir[-n,-1]
              parts[1,i-1]=()
              break
            fi
          done
        fi
      fi
    ;;
    truncate_with_package_name|truncate_middle|truncate_from_right)
      () {
        [[ $POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name &&
           $+commands[jq] == 1 && $#POWERLEVEL9K_DIR_PACKAGE_FILES > 0 ]] || return
        local pat="(${(j:|:)POWERLEVEL9K_DIR_PACKAGE_FILES})"
        local -i i=$#parts
        local dir=$PWD
        for (( ; i > 0; --i )); do
          local pkg_file=''
          for pkg_file in $dir/${~pat}(N); do
            local -H stat=()
            zstat -H stat -- $pkg_file 2>/dev/null || return
            if ! _p9k_cache_get $0_pkg $stat[inode] $stat[mtime] $stat[size]; then
              local pkg_name=''
              pkg_name=$(command jq -j '.name' <$pkg_file 2>/dev/null) || pkg_name=''
              _p9k_cache_set "$pkg_name"
            fi
            [[ -n $_P9K_CACHE_VAL[1] ]] || return
            parts[1,i]=($_P9K_CACHE_VAL[1])
            fake_first=1
            return
          done
          dir=${dir:h}
        done
      }
      if (( shortenlen > 0 )); then
        _p9k_shorten_delim_len $delim
        local -i d=_P9K_RETVAL pref=shortenlen suf=0 i=2
        [[ $POWERLEVEL9K_SHORTEN_STRATEGY == truncate_middle ]] && suf=pref
        for (( ; i < $#parts; ++i )); do
          local dir=$parts[i]
          if (( $#dir > pref + suf + d )); then
            dir[pref+1,-suf-1]=$'\0'
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
          parts[i]=$'\0'
        done
      fi
    ;;
    truncate_to_unique)
      local -i i=2 n=1
      [[ $p == /* ]] && (( ++i ))
      delim=${POWERLEVEL9K_SHORTEN_DELIMITER-'*'}
      _p9k_prompt_length $delim
      local -i real_delim_len=_P9K_RETVAL
      local -i d=${POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1}
      (( d >= 0 )) || d=real_delim_len
      shortenlen=${POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1}
      (( shortenlen >= 0 )) && n=shortenlen
      if [[ $POWERLEVEL9K_DIR_MAX_LENGTH == *% ]]; then
        local -i max_len=$(( COLUMNS * $POWERLEVEL9K_DIR_MAX_LENGTH[1,-2] / 100 ))
      else
        local -i max_len=POWERLEVEL9K_DIR_MAX_LENGTH
      fi
      local -i len=$#p
      local parent="${PWD%/${(pj./.)parts[i,-1]}}"
      for (( ; len > max_len && i <= $#parts - n; ++i )); do
        local dir=$parts[i]
        if [[ -n $POWERLEVEL9K_SHORTEN_FOLDER_MARKER &&
              -n $parent/$dir/${~POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]]; then
          parent+=/$dir
          continue
        fi
        local -i j=1
        for (( ; j + d < $#dir; ++j )); do
          local -a matching=($parent/$dir[1,j]*/(N))
          (( $#matching == 1 )) && break
        done
        if (( j + d < $#dir )); then
          (( len -= ($#dir - j - real_delim_len) ))
          parts[i]=$dir[1,j]$'\0'
        fi
        parent+=/$dir
      done
    ;;
    truncate_with_folder_marker)
      if [[ -n $POWERLEVEL9K_SHORTEN_FOLDER_MARKER ]]; then
        local dir=$PWD
        local -a m=()
        local -i i=$(($#parts - 1))
        for (( ; i > 1; --i )); do
          dir=${dir:h}
          [[ -n $dir/${~POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]] && m+=$i
        done
        m+=1
        for (( i=1; i < $#m; ++i )); do
          (( m[i] - m[i+1] > 2 )) && parts[m[i+1]+1,m[i]-1]=($'\0')
        done
      fi
    ;;
    *)
      if (( shortenlen > 0 )); then
        local -i len=$#parts
        [[ -z $parts[1] ]] && (( --len ))
        if (( len > shortenlen )); then
          parts[1,-shortenlen-1]=($'\0')
        fi
      fi
    ;;
  esac

  [[ $POWERLEVEL9K_DIR_SHOW_WRITABLE == true && ! -w $PWD ]]
  local w=$?
  if ! _p9k_cache_get $0 $w $fake_first "$delim" "${parts[@]}"; then
    local state='' icon=''
    if (( ! w )); then
      state=NOT_WRITABLE
      icon=LOCK_ICON
    else
      case $PWD in
        /etc|/etc/*) state=ETC;            icon=ETC_ICON;;
        ~)           state=HOME;           icon=HOME_ICON;;
        ~/*)         state=HOME_SUBFOLDER; icon=HOME_SUB_ICON;;
        *)           state=DEFAULT;        icon=FOLDER_ICON;;
      esac
    fi

    local style=%b
    _p9k_color blue $0_$state BACKGROUND
    _p9k_background $_P9K_RETVAL
    style+=$_P9K_RETVAL
    _p9k_color "$DEFAULT_COLOR" "$0_$state" FOREGROUND
    _p9k_foreground $_P9K_RETVAL
    style+=$_P9K_RETVAL

    parts=("${(@)parts//\%/%%}")
    [[ $fake_first == 0 && $parts[1] == '~' ]] && parts[1]=$POWERLEVEL9K_HOME_FOLDER_ABBREVIATION$style
    [[ $POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == true && $#parts > 1 && -n $parts[2] ]] && parts[1]=()

    local last_fg=
    [[ $POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD == true ]] && last_fg+=%B
    if [[ -n $POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND ]]; then
      _p9k_translate_color $POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND
      _p9k_foreground $_P9K_RETVAL
      last_fg+=$_P9K_RETVAL
    fi
    parts[-1]=$last_fg${parts[-1]//$'\0'/$'\0'$last_fg}$style
    parts=("${(@)parts//$'\0'/$delim$style}")

    local sep=$POWERLEVEL9K_DIR_PATH_SEPARATOR$style
    if [[ -n $POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND ]]; then
      _p9k_translate_color $POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND
      _p9k_foreground $_P9K_RETVAL
      sep=$_P9K_RETVAL$sep
    fi

    _p9k_cache_set "$0_$state" "$2" blue "$DEFAULT_COLOR" "$icon" 0 "" "${(pj.$sep.)parts}"
  fi
  "$1_prompt_segment" "$_P9K_CACHE_VAL[@]"
}

################################################################
# Docker machine
prompt_docker_machine() {
  if [[ -n "$DOCKER_MACHINE_NAME" ]]; then
    "$1_prompt_segment" "$0" "$2" "magenta" "$DEFAULT_COLOR" 'SERVER_ICON' 0 '' "${DOCKER_MACHINE_NAME//\%/%%}"
  fi
}

################################################################
# GO prompt
prompt_go_version() {
  _p9k_cached_cmd_stdout go version || return
  emulate -L zsh && setopt extendedglob
  local -a match
  [[ $_P9K_RETVAL == (#b)*(go[[:digit:].]##)* ]] || return
  local v=$match[1]
  local p=$GOPATH
  if [[ -z $p ]]; then
    if [[ -d $HOME/go ]]; then
      p=$HOME/go
    else
      p=$(command go env GOPATH 2>/dev/null) && [[ -n $p ]] || return
    fi
  fi
  if [[ $PWD/ != $p/* ]]; then
    local dir=$PWD
    while [[ ! -e $dir/go.mod ]]; do
      [[ $dir == / ]] && return
      dir=${dir:h}
    done
  fi
  "$1_prompt_segment" "$0" "$2" "green" "grey93" "GO_ICON" 0 '' "${v//\%/%%}"
}

################################################################
# Command number (in local history)
prompt_history() {
  "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" '' 0 '' '%h'
}

################################################################
# Detection for virtualization (systemd based systems only)
prompt_detect_virt() {
  (( $+commands[systemd-detect-virt] )) || return
  local virt=$(command systemd-detect-virt 2>/dev/null)
  if [[ "$virt" == "none" ]]; then
    [[ "$(command ls -di /)" != "2 /" ]] && virt="chroot"
  fi
  if [[ -n "${virt}" ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" '' 0 '' "${virt//\%/%%}"
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
    "$1_prompt_segment" "$0" "$2" "$random_color" "$next_color" "$key" 0 '' "$key"
  done
}

################################################################
# Segment to display the current IP address
set_default POWERLEVEL9K_IP_INTERFACE "^[^ ]+"
prompt_ip() {
  _p9k_parse_ip $POWERLEVEL9K_IP_INTERFACE || return
  "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" 'NETWORK_ICON' 0 '' "${_P9K_RETVAL//\%/%%}"
}

################################################################
# Segment to display if VPN is active
set_default POWERLEVEL9K_VPN_IP_INTERFACE "tun"
# prompt if vpn active
prompt_vpn_ip() {
  _p9k_parse_ip $POWERLEVEL9K_VPN_IP_INTERFACE || return
  "$1_prompt_segment" "$0" "$2" "cyan" "$DEFAULT_COLOR" 'VPN_ICON' 0 '' "${_P9K_RETVAL//\%/%%}"
}

################################################################
# Segment to display laravel version
prompt_laravel_version() {
  local laravel_version="$(php artisan --version 2> /dev/null)"
  if [[ -n "${laravel_version}" && "${laravel_version}" =~ "Laravel Framework" ]]; then
    # Strip out everything but the version
    laravel_version="${laravel_version//Laravel Framework /}"
    "$1_prompt_segment" "$0" "$2" "maroon" "white" 'LARAVEL_ICON' 0 '' "${laravel_version//\%/%%}"
  fi
}

################################################################
# Segment to display load
set_default -i POWERLEVEL9K_LOAD_WHICH 5
prompt_load() {
  local bucket=2
  case $POWERLEVEL9K_LOAD_WHICH in
    1) bucket=1;;
    5) bucket=2;;
    15) bucket=3;;
  esac

  local load
  case $OS in
    OSX|BSD)
      (( $+commands[sysctl] )) || return
      load=$(command sysctl -n vm.loadavg 2>/dev/null) || return
      load=${${(A)=load}[bucket+1]//,/.}
    ;;
    *)
      [[ -r /proc/loadavg ]] || return
      _p9k_read_file /proc/loadavg || return
      load=${${(A)=_P9K_RETVAL}[bucket]//,/.}
    ;;
  esac

  if (( ! $+_P9K_NUM_CPUS )); then
    case $OS in
      OSX) (( $+commands[sysctl] )) && _P9K_NUM_CPUS=$(command sysctl -n hw.logicalcpu 2>/dev/null) || return;;
      BSD) (( $+commands[sysctl] )) && _P9K_NUM_CPUS=$(command sysctl -n hw.ncpu 2>/dev/null) || return;;
      *)   (( $+commands[nproc]  )) && _P9K_NUM_CPUS=$(command nproc 2>/dev/null) || return;;
    esac
  fi

  if (( load > 0.7 * _P9K_NUM_CPUS )); then
    local state=critical bg=red
  elif (( load > 0.5 * _P9K_NUM_CPUS )); then
    local state=warning bg=yellow
  else
    local state=normal bg=green
  fi

  $1_prompt_segment $0_$state $2 $bg "$DEFAULT_COLOR" LOAD_ICON 0 '' $load
}

function _p9k_cached_cmd_stdout() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _p9k_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>/dev/null)
    _p9k_cache_set $(( ! $? )) "$out"
  fi
  (( $_P9K_CACHE_VAL[1] )) || return
  _P9K_RETVAL=$_P9K_CACHE_VAL[2]
}

function _p9k_cached_cmd_stdout_stderr() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _p9k_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>&1)  # this line is the only diff with _p9k_cached_cmd_stdout
    _p9k_cache_set $(( ! $? )) "$out"
  fi
  (( $_P9K_CACHE_VAL[1] )) || return
  _P9K_RETVAL=$_P9K_CACHE_VAL[2]
}

################################################################
# Segment to diplay Node version
set_default P9K_NODE_VERSION_PROJECT_ONLY false
prompt_node_version() {
  (( $+commands[node] )) || return

  if [[ $P9K_NODE_VERSION_PROJECT_ONLY == true ]] ; then
    local dir=$PWD
    while true; do
      [[ $dir == / ]] && return
      [[ -e $dir/package.json ]] && break
      dir=${dir:h}
    done
  fi

  _p9k_cached_cmd_stdout node --version && [[ $_P9K_RETVAL == v?* ]] || return
  "$1_prompt_segment" "$0" "$2" "green" "white" 'NODE_ICON' 0 '' "${_P9K_RETVAL#v}"
}

# Almost the same as `nvm_version default` but faster. The differences shouldn't affect
# the observable behavior of Powerlevel10k.
function _p9k_nvm_ls_default() {
  local v=default
  local -a seen=($v)
  local target
  while [[ -r $NVM_DIR/alias/$v ]] && read target <$NVM_DIR/alias/$v; do
    [[ -n $target && ${seen[(I)$target]} == 0 ]] || return
    seen+=$target
    v=$target
  done

  case $v in
    default|N/A)
      return 1
    ;;
    system|v)
      _P9K_RETVAL=system
      return
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
      _P9K_RETVAL=$v
      return
    elif [[ -x $NVM_DIR/versions/io.js/$v/bin/node ]]; then
      _P9K_RETVAL=iojs-$v
      return
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

  emulate -L zsh && setopt extendedglob

  local max path
  local -a match
  for path in ${(Oa)matches}; do
    [[ ${path:t} == (#b)v(*).(*).(*) ]] || continue
    v=${(j::)${(@l:6::0:)match}}
    [[ $v > $max ]] || continue
    max=$v
    _P9K_RETVAL=${path:t}
    [[ ${path:h:t} != io.js ]] || _P9K_RETVAL=iojs-$_P9K_RETVAL
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
    _P9K_RETVAL=iojs-v${_P9K_RETVAL#v}
  elif [[ -n $nvm_dir && $node_path == $nvm_dir/* ]]; then
    _p9k_cached_cmd_stdout node --version || return
    _P9K_RETVAL=v${_P9K_RETVAL#v}
  else
    _P9K_RETVAL=system
  fi
}

################################################################
# Segment to display Node version from NVM
# Only prints the segment if different than the default value
prompt_nvm() {
  [[ -n $NVM_DIR ]] && _p9k_nvm_ls_current || return
  local current=$_P9K_RETVAL
  ! _p9k_nvm_ls_default || [[ $_P9K_RETVAL != $current ]] || return
  $1_prompt_segment "$0" "$2" "magenta" "black" 'NODE_ICON' 0 '' "${${current#v}//\%/%%}"
}

################################################################
# Segment to display NodeEnv
prompt_nodeenv() {
  if [[ -n "$NODE_VIRTUAL_ENV" ]]; then
    _p9k_cached_cmd_stdout node --version || return
    local info="${_P9K_RETVAL}[${NODE_VIRTUAL_ENV:t}]"
    "$1_prompt_segment" "$0" "$2" "black" "green" 'NODE_ICON' 0 '' "${info//\%/%%}"
  fi
}

################################################################
# Segment to print a little OS icon
prompt_os_icon() {
  "$1_prompt_segment" "$0" "$2" "black" "white" '' 0 '' "$OS_ICON"
}

################################################################
# Segment to display PHP version number
prompt_php_version() {
  _p9k_cached_cmd_stdout php --version || return
  emulate -L zsh && setopt extendedglob
  local -a match
  [[ $_P9K_RETVAL == (#b)(*$'\n')#(PHP [[:digit:].]##)* ]] || return
  local v=$match[2]
  "$1_prompt_segment" "$0" "$2" "fuchsia" "grey93" '' 0 '' "${v//\%/%%}"
}

################################################################
# Segment to display free RAM and used Swap
prompt_ram() {
  local -F free_bytes

  case $OS in
    OSX)
      (( $+commands[vm_stat] )) || return
      local stat && stat=$(command vm_stat 2>/dev/null) || return
      [[ $stat =~ 'Pages free:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes+=match[1] ))
      [[ $stat =~ 'Pages inactive:[[:space:]]+([0-9]+)' ]] || return
      (( free_bytes+=match[1] ))
      (( free_bytes *= 4096 ))
    ;;
    BSD)
      local stat && stat=$(command grep -F 'avail memory' /var/run/dmesg.boot 2>/dev/null) || return
      free_bytes=${${(A)=stat}[4]}
    ;;
    *)
      local stat && stat=$(command grep -F MemAvailable /proc/meminfo 2>/dev/null) || return
      free_bytes=$(( ${${(A)=stat}[2]} * 1024 ))
    ;;
  esac

  _p9k_human_readable_bytes $free_bytes
  $1_prompt_segment $0 $2 yellow "$DEFAULT_COLOR" RAM_ICON 0 '' $_P9K_RETVAL
}

function _p9k_read_rbenv_version_file() {
  [[ -r $1 ]] || return
  local content
  read -r content <$1 2>/dev/null
  _P9K_RETVAL="${${(A)=content}[1]}"
  [[ -n $_P9K_RETVAL ]]
}

function _p9k_rbenv_global_version() {
  _p9k_read_rbenv_version_file ${RBENV_ROOT:-$HOME/.rbenv}/version || _P9K_RETVAL=system
}

################################################################
# Segment to display rbenv information
# https://github.com/rbenv/rbenv#choosing-the-ruby-version
set_default POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW false
prompt_rbenv() {
  local v=$RBENV_VERSION
  if [[ -z $v ]]; then
    [[ $RBENV_DIR == /* ]] && local dir=$RBENV_DIR || local dir="$PWD/$RBENV_DIR"
    while true; do
      if _p9k_read_rbenv_version_file $dir/.ruby-version; then
        v=$_P9K_RETVAL
        break
      fi
      if [[ $dir == / ]]; then
        [[ $POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW == true ]] || return
        _p9k_rbenv_global_version
        v=$_P9K_RETVAL
        break
      fi
      dir=${dir:h}
    done
  fi

  if [[ $POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW == false ]]; then
    _p9k_rbenv_global_version
    [[ $v == $_P9K_RETVAL ]] && return
  fi

  "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${v//\%/%%}"
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
    "$1_prompt_segment" "$0" "$2" "red" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${chruby_label//\%/%%}"
  fi
}

################################################################
# Segment to print an icon if user is root.
prompt_root_indicator() {
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" 'ROOT_ICON' 0 '${${(%):-%#}:#%}' ''
}

# This segment is a demo. It can disappear any time. Use prompt_dir instead.
prompt_simple_dir() {
  if ! _p9k_cache_get "$0" "$1" "$2" ; then
    local p=$_P9K_PROMPT
    local key=$_P9K_CACHE_KEY
    _P9K_PROMPT=''
    $1_prompt_segment $0_HOME $2 blue "$DEFAULT_COLOR" HOME_ICON 0 '${$((!${#${(%):-%~}:#\~})):#0}' "%~"
    $1_prompt_segment $0_HOME_SUBFOLDER $2 blue "$DEFAULT_COLOR" HOME_SUB_ICON 0 '${$((!${#${(%):-%~}:#\~?*})):#0}' "%~"
    $1_prompt_segment $0_ETC $2 blue "$DEFAULT_COLOR" ETC_ICON 0 '${$((!${#${(%):-%~}:#/etc*})):#0}' "%~"
    $1_prompt_segment $0_DEFAULT $2 blue "$DEFAULT_COLOR" FOLDER_ICON 0 '${${${(%):-%~}:#\~*}:#/etc*}' "%~"
    _P9K_CACHE_KEY=$key
    _p9k_cache_set "$_P9K_PROMPT"
    _P9K_PROMPT=$p
  fi
  _P9K_PROMPT+=${_P9K_CACHE_VAL[1]}
}

################################################################
# Segment to display Rust version number
prompt_rust_version() {
  _p9k_cached_cmd_stdout rustc --version || return
  local v=${${_P9K_RETVAL#rustc }%% *}
  [[ -n $v ]] || return
  "$1_prompt_segment" "$0" "$2" "darkorange" "$DEFAULT_COLOR" 'RUST_ICON' 0 '' "${v//\%/%%}"
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ -d app && -d spec ]]; then
    local -a code=(app/**/*.rb(N))
    (( $#code )) || return
    local tests=(spec/**/*.rb(N))
    build_test_stats "$1" "$0" "$2" "$#code" "$#tests" "RSpec" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Ruby Version Manager information
prompt_rvm() {
  if [ $commands[rvm-prompt] ]; then
    local version_and_gemset=${$(rvm-prompt v p)/ruby-}

    if [[ -n "$version_and_gemset" ]]; then
      "$1_prompt_segment" "$0" "$2" "240" "$DEFAULT_COLOR" 'RUBY_ICON' 0 '' "${version_and_gemset//\%/%%}"
    fi
  fi
}

################################################################
# Segment to display SSH icon when connected
prompt_ssh() {
  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR" "yellow" 'SSH_ICON' 0 '' ''
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
    _P9K_RETVAL="SIG${signals[$((ec - 127))]}($((ec - 128)))"
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
        _P9K_CACHE_VAL=("$0_ERROR" "$2" red yellow1 CARRIAGE_RETURN_ICON 0 '' "$ec_text")
      else
        _P9K_CACHE_VAL=("$0_ERROR" "$2" "$DEFAULT_COLOR" red FAIL_ICON 0 '' '')
      fi
    elif [[ "$POWERLEVEL9K_STATUS_OK" == true ]] && [[ "$POWERLEVEL9K_STATUS_VERBOSE" == true || "$POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE" == true ]]; then
      _P9K_CACHE_VAL=("$0_OK" "$2" "$DEFAULT_COLOR" green OK_ICON 0 '' '')
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
  local -F used_bytes

  if [[ "$OS" == "OSX" ]]; then
    (( $+commands[sysctl] )) || return
    [[ "$(command sysctl vm.swapusage 2>/dev/null)" =~ "used = ([0-9,.]+)([A-Z]+)" ]] || return
    used_bytes=${match[1]//,/.}
    case ${match[2]} in
      'K') (( used_bytes *= 1024 ));;
      'M') (( used_bytes *= 1048576 ));;
      'G') (( used_bytes *= 1073741824 ));;
      'T') (( used_bytes *= 1099511627776 ));;
      *) return;;
    esac
  else
    local meminfo && meminfo=$(command grep -F 'Swap' /proc/meminfo 2>/dev/null) || return
    [[ $meminfo =~ 'SwapTotal:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes+=match[1] ))
    [[ $meminfo =~ 'SwapFree:[[:space:]]+([0-9]+)' ]] || return
    (( used_bytes-=match[1] ))
    (( used_bytes *= 1024 ))
  fi

  _p9k_human_readable_bytes $used_bytes
  $1_prompt_segment $0 $2 yellow "$DEFAULT_COLOR" SWAP_ICON 0 '' $_P9K_RETVAL
}

################################################################
# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ -d src && -d app && -f app/AppKernel.php ]]; then
    local -a all=(src/**/*.php(N))
    local -a code=(${(@)all##*Tests*})
    (( $#code )) || return
    build_test_stats "$1" "$0" "$2" "$#code" "$(($#all - $#code))" "SF2" 'TEST_ICON'
  fi
}

################################################################
# Segment to display Symfony2-Version
prompt_symfony2_version() {
  if [[ -r app/bootstrap.php.cache ]]; then
    local v="${$(command grep -F " VERSION " app/bootstrap.php.cache 2>/dev/null)//[![:digit:].]}"
    "$1_prompt_segment" "$0" "$2" "grey35" "$DEFAULT_COLOR" 'SYMFONY_ICON' 0 '' "${v//\%/%%}"
  fi
}

################################################################
# Show a ratio of tests vs code
build_test_stats() {
  local code_amount="$4"
  local tests_amount="$5"
  local headline="$6"

  (( code_amount > 0 )) || return
  local -F 2 ratio=$(( 100. * tests_amount / code_amount ))

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
}

################################################################
# System time

# If set to true, `time` prompt will update every second.
set_default POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME false
set_default POWERLEVEL9K_TIME_FORMAT "%D{%H:%M:%S}"
prompt_time() {
  local t=$POWERLEVEL9K_TIME_FORMAT
  [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]] || t=${(%)t}
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "TIME_ICON" 0 '' "${t//\%/%%}"
}

################################################################
# System date
set_default POWERLEVEL9K_DATE_FORMAT "%D{%d.%m.%y}"
prompt_date() {
  local d=$POWERLEVEL9K_DATE_FORMAT
  [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]] || d=${(%)d}
  "$1_prompt_segment" "$0" "$2" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "DATE_ICON" 0 '' "${d//\%/%%}"
}

################################################################
# todo.sh: shows the number of tasks in your todo.sh file
prompt_todo() {
  local todo=$commands[todo.sh]
  [[ -n $todo ]] || return
  if (( ! $+_P9K_TODO_FILE )); then
    local bash=${commands[bash]:-:}
    typeset -g _P9K_TODO_FILE=$($bash 2>/dev/null -c "
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/.todo/config
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/todo.cfg
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\$HOME/.todo.cfg
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\${XDG_CONFIG_HOME:-\$HOME/.config}/todo/config
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=${(qqq)todo:h}/todo.cfg
      [ -e \"\$TODOTXT_CFG_FILE\" ] || TODOTXT_CFG_FILE=\${TODOTXT_GLOBAL_CFG_FILE:-/etc/todo/config}
      [ -r \"\$TODOTXT_CFG_FILE\" ] || exit
      source \"\$TODOTXT_CFG_FILE\" &>/dev/null
      echo \"\$TODO_FILE\"")
  fi
  [[ -r $_P9K_TODO_FILE ]] || return
  local -H stat
  zstat -H stat -- $_P9K_TODO_FILE 2>/dev/null || return
  if ! _p9k_cache_get $0 $stat[inode] $stat[mtime] $stat[size]; then
    local count=$($todo -p ls | command tail -1)
    emulate -L zsh && setopt extendedglob
    if [[ $count == (#b)'TODO: '[[:digit:]]##' of '([[:digit:]]##)' '* ]]; then
      _p9k_cache_set 1 $match[1]
    else
      _p9k_cache_set 0 0
    fi
  fi
  (( $_P9K_CACHE_VAL[1] )) || return
  "$1_prompt_segment" "$0" "$2" "grey50" "$DEFAULT_COLOR" 'TODO_ICON' 0 '' "${_P9K_CACHE_VAL[2]}"
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
set_default POWERLEVEL9K_VCS_LOADING_TEXT loading
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

  local component state
  for component in REMOTE_URL COMMIT BRANCH TAG REMOTE_BRANCH STAGED UNSTAGED UNTRACKED \
                   OUTGOING_CHANGES INCOMING_CHANGES STASH ACTION; do
    local color=${(P)${:-POWERLEVEL9K_VCS_${component}FORMAT_FOREGROUND}}
    if [[ -n $color ]]; then
      for state in "${(@k)vcs_states}"; do
        local var=POWERLEVEL9K_VCS_${(U)state}_${component}FORMAT_FOREGROUND
        if [[ -z ${(P)var} ]]; then
          typeset -g $var=$color
        fi
      done
    fi
  done

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

function _p9k_vcs_style() {
  local color=${(P)${:-POWERLEVEL9K_VCS_${1}_${2}FORMAT_FOREGROUND}}
  if [[ -z $color ]]; then
    _P9K_RETVAL=""
    return
  fi
  if [[ $color != <-> ]]; then
    color=$__P9K_COLORS[${${${color#bg-}#fg-}#br}]
    if [[ -z $color ]]; then
      _P9K_RETVAL=""
      return
    fi
  fi
  _P9K_RETVAL="%F{$color}"
}

function _p9k_vcs_render() {
  if (( $+_P9K_NEXT_VCS_DIR )); then
    local -a msg
    local dir=${${GIT_DIR:a}:-$PWD}
    while true; do
      msg=("${(@0)${_P9K_LAST_GIT_PROMPT[$dir]}}")
      [[ $#msg -gt 1 || -n ${msg[1]} ]] && break
      [[ $dir == / ]] && msg=() && break
      dir=${dir:h}
    done
    if (( $#msg )); then
      $2_prompt_segment $1_LOADING $3 "${vcs_states[loading]}" "$DEFAULT_COLOR" '' 0 '' "${msg[@]}"
    else
      _p9k_get_icon VCS_LOADING_ICON
      if [[ -n $_P9K_RETVAL || -n $POWERLEVEL9K_VCS_LOADING_TEXT ]]; then
        $2_prompt_segment $1_LOADING $3 "${vcs_states[loading]}" "$DEFAULT_COLOR" VCS_LOADING_ICON 0 '' "$POWERLEVEL9K_VCS_LOADING_TEXT"
      fi
    fi
    return 0
  fi

  [[ $VCS_STATUS_RESULT == ok-* ]] || return 1

  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-untracked]} )) || VCS_STATUS_HAS_UNTRACKED=0
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-aheadbehind]} )) || { VCS_STATUS_COMMITS_AHEAD=0 && VCS_STATUS_COMMITS_BEHIND=0 }
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-stash]} )) || VCS_STATUS_STASHES=0
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-remotebranch]} )) || VCS_STATUS_REMOTE_BRANCH=""
  (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)git-tagname]} )) || VCS_STATUS_TAG=""

  (( POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM >= 0 && VCS_STATUS_COMMITS_AHEAD > POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM )) &&
    VCS_STATUS_COMMITS_AHEAD=$POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM

  (( POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM >= 0 && VCS_STATUS_COMMITS_BEHIND > POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM )) &&
    VCS_STATUS_COMMITS_BEHIND=$POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM

  local -a cache_key=(
    "$VCS_STATUS_LOCAL_BRANCH"
    "$VCS_STATUS_REMOTE_BRANCH"
    "$VCS_STATUS_REMOTE_URL"
    "$VCS_STATUS_ACTION"
    "$VCS_STATUS_NUM_STAGED"
    "$VCS_STATUS_NUM_UNSTAGED"
    "$VCS_STATUS_NUM_UNTRACKED"
    "$VCS_STATUS_HAS_STAGED"
    "$VCS_STATUS_HAS_UNSTAGED"
    "$VCS_STATUS_HAS_UNTRACKED"
    "$VCS_STATUS_COMMITS_AHEAD"
    "$VCS_STATUS_COMMITS_BEHIND"
    "$VCS_STATUS_STASHES"
    "$VCS_STATUS_TAG"
  )
  if [[ $POWERLEVEL9K_SHOW_CHANGESET == true || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    cache_key+=$VCS_STATUS_COMMIT
  fi

  if ! _p9k_cache_get "${(@)cache_key}"; then
    local state=CLEAN
    local -a cur_prompt
    local -a stale_prompt

    function _$0_fmt() {
      _p9k_vcs_style $state $1
      cur_prompt+=$_P9K_RETVAL$2
      _p9k_vcs_style LOADING $1
      stale_prompt+=$_P9K_RETVAL$2
    }

    trap "unfunction _$0_fmt" EXIT

    if (( ${POWERLEVEL9K_VCS_GIT_HOOKS[(I)vcs-detect-changes]} )); then
      if [[ $VCS_STATUS_HAS_STAGED != 0 || $VCS_STATUS_HAS_UNSTAGED != 0 ]]; then
        state=MODIFIED
      elif [[ $VCS_STATUS_HAS_UNTRACKED != 0 ]]; then
        state=UNTRACKED
      fi

      # It's weird that removing vcs-detect-changes from POWERLEVEL9K_VCS_GIT_HOOKS gets rid
      # of the GIT icon. That's what vcs_info does, so we do the same in the name of compatiblity.
      if [[ "$VCS_STATUS_REMOTE_URL" == *github* ]] then
        _p9k_get_icon VCS_GIT_GITHUB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *bitbucket* ]] then
        _p9k_get_icon VCS_GIT_BITBUCKET_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *stash* ]] then
        _p9k_get_icon VCS_GIT_GITHUB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      elif [[ "$VCS_STATUS_REMOTE_URL" == *gitlab* ]] then
        _p9k_get_icon VCS_GIT_GITLAB_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      else
        _p9k_get_icon VCS_GIT_ICON
        _$0_fmt REMOTE_URL $_P9K_RETVAL
      fi
    fi

    local ws
    if [[ $POWERLEVEL9K_SHOW_CHANGESET == true || -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      _p9k_get_icon VCS_COMMIT_ICON
      _$0_fmt COMMIT "$_P9K_RETVAL${${VCS_STATUS_COMMIT:0:$POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH}:-HEAD}"
      ws=' '
    fi

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      _p9k_get_icon VCS_BRANCH_ICON
      _$0_fmt BRANCH "$ws$_P9K_RETVAL${VCS_STATUS_LOCAL_BRANCH//\%/%%}"
    fi

    if [[ $POWERLEVEL9K_VCS_HIDE_TAGS == false && -n $VCS_STATUS_TAG ]]; then
      _p9k_get_icon VCS_TAG_ICON
      _$0_fmt TAG " $_P9K_RETVAL${VCS_STATUS_TAG//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_ACTION ]]; then
      _$0_fmt ACTION " | ${VCS_STATUS_ACTION//\%/%%}"
    else
      if [[ -n $VCS_STATUS_REMOTE_BRANCH &&
            $VCS_STATUS_LOCAL_BRANCH != $VCS_STATUS_REMOTE_BRANCH ]]; then
        _p9k_get_icon VCS_REMOTE_BRANCH_ICON
        _$0_fmt REMOTE_BRANCH " $_P9K_RETVAL${VCS_STATUS_REMOTE_BRANCH//\%/%%}"
      fi
      if [[ $VCS_STATUS_HAS_STAGED == 1 ]]; then
        _p9k_get_icon VCS_STAGED_ICON
        (( ${POWERLEVEL9K_VCS_MAX_NUM_STAGED:-$POWERLEVEL9K_VCS_STAGED_MAX_NUM} != 1 )) && _P9K_RETVAL+=$VCS_STATUS_NUM_STAGED
        _$0_fmt STAGED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNSTAGED == 1 ]]; then
        _p9k_get_icon VCS_UNSTAGED_ICON
        (( ${POWERLEVEL9K_VCS_MAX_NUM_UNSTAGED:-$POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM} != 1 )) && _P9K_RETVAL+=$VCS_STATUS_NUM_UNSTAGED
        _$0_fmt UNSTAGED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_HAS_UNTRACKED == 1 ]]; then
        _p9k_get_icon VCS_UNTRACKED_ICON
        (( ${POWERLEVEL9K_VCS_MAX_NUM_UNTRACKED:-$POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM} != 1 )) && _P9K_RETVAL+=$VCS_STATUS_NUM_UNTRACKED
        _$0_fmt UNTRACKED " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_COMMITS_BEHIND -gt 0 ]]; then
        _p9k_get_icon VCS_INCOMING_CHANGES_ICON
        (( POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM != 1 )) && _P9K_RETVAL+=$VCS_STATUS_COMMITS_BEHIND
        _$0_fmt INCOMING_CHANGES " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_COMMITS_AHEAD -gt 0 ]]; then
        _p9k_get_icon VCS_OUTGOING_CHANGES_ICON
        (( POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM != 1 )) && _P9K_RETVAL+=$VCS_STATUS_COMMITS_AHEAD
        _$0_fmt OUTGOING_CHANGES " $_P9K_RETVAL"
      fi
      if [[ $VCS_STATUS_STASHES -gt 0 ]]; then
        _p9k_get_icon VCS_STASH_ICON
        _$0_fmt STASH " $_P9K_RETVAL$VCS_STATUS_STASHES"
      fi
    fi

    _p9k_cache_set "${1}_$state" "${vcs_states[${(L)state}]}" "${stale_prompt[@]}" "${cur_prompt[@]}"
  fi

  local id=${_P9K_CACHE_VAL[1]}
  local bg=${_P9K_CACHE_VAL[2]}
  shift 2 _P9K_CACHE_VAL
  local -i n=$(($#_P9K_CACHE_VAL / 2))
  _P9K_LAST_GIT_PROMPT[$VCS_STATUS_WORKDIR]="${(pj:\0:)_P9K_CACHE_VAL[1,$n]}"
  shift $n _P9K_CACHE_VAL
  $2_prompt_segment "$id" "$3" "$bg" "$DEFAULT_COLOR" '' 0 '' "${(@)_P9K_CACHE_VAL}"
  return 0
}

function _p9k_vcs_resume() {
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

function _p9k_vcs_gitstatus() {
  [[ $POWERLEVEL9K_DISABLE_GITSTATUS == true ]] && return 1
  if [[ $_P9K_REFRESH_REASON == precmd ]]; then
    if (( $+_P9K_NEXT_VCS_DIR )); then
      typeset -gH _P9K_NEXT_VCS_DIR=${${GIT_DIR:a}:-$PWD}
    else
      local dir=${${GIT_DIR:a}:-$PWD}
      local -F timeout=$POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS
      while true; do
        case "$_P9K_GIT_SLOW[$dir]" in
          "") [[ $dir == / ]] && break; dir=${dir:h};;
          0) break;;
          1) timeout=0; break;;
        esac
      done
      typeset -gFH _P9K_GITSTATUS_START_TIME=$EPOCHREALTIME
      gitstatus_query -d ${${GIT_DIR:a}:-$PWD} -t $timeout -c _p9k_vcs_resume POWERLEVEL9K || return 1
      [[ $VCS_STATUS_RESULT == tout ]] && typeset -gH _P9K_NEXT_VCS_DIR=""
    fi
  fi
  return 0
}

################################################################
# Segment to show VCS information

prompt_vcs() {
  local -a backends=($POWERLEVEL9K_VCS_BACKENDS)
  if (( ${backends[(I)git]} )) && _p9k_vcs_gitstatus; then
    _p9k_vcs_render $0 $1 $2 && return
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
        current_state='modified'
      else
        if [[ "$VCS_WORKDIR_HALF_DIRTY" == true ]]; then
          current_state='untracked'
        else
          current_state='clean'
        fi
      fi
      $1_prompt_segment "${0}_${(U)current_state}" "$2" "${vcs_states[$current_state]}" "$DEFAULT_COLOR" "$vcs_visual_identifier" 0 '' "$vcs_prompt"
    fi
  fi
}

################################################################
# Vi Mode: show editing mode (NORMAL|INSERT|VISUAL)
#
# VISUAL mode is shown as NORMAL unless POWERLEVEL9K_VI_VISUAL_MODE_STRING is explicitly set.
# Your ZSH version must be >= 5.3 if you set this parameter.
set_default POWERLEVEL9K_VI_INSERT_MODE_STRING "INSERT"
set_default POWERLEVEL9K_VI_COMMAND_MODE_STRING "NORMAL"
prompt_vi_mode() {
  $1_prompt_segment $0_NORMAL $2 "$DEFAULT_COLOR" white '' 0 '${$((!${#${:-$KEYMAP$_P9K_REGION_ACTIVE}:#vicmd0})):#0}' "$POWERLEVEL9K_VI_COMMAND_MODE_STRING"
  $1_prompt_segment $0_VISUAL $2 "$DEFAULT_COLOR" white '' 0 '${$((!${#${:-$KEYMAP$_P9K_REGION_ACTIVE}:#vicmd1})):#0}' "$POWERLEVEL9K_VI_VISUAL_MODE_STRING"
  if [[ -n $POWERLEVEL9K_VI_INSERT_MODE_STRING ]]; then
    $1_prompt_segment $0_INSERT $2 "$DEFAULT_COLOR" blue '' 0 '${${KEYMAP:-0}:#vicmd}' "$POWERLEVEL9K_VI_INSERT_MODE_STRING"
  fi
}

################################################################
# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "${${VIRTUAL_ENV:t}//\%/%%}"
  fi
}

function _p9k_read_pyenv_version_file() {
  [[ -r $1 ]] || return
  local content
  read -rd $'\0' content <$1 2>/dev/null
  _P9K_RETVAL=${${(j.:.)${(@)${=content}#python-}:-system}}
}

function _p9k_pyenv_global_version() {
  _p9k_read_pyenv_version_file ${PYENV_ROOT:-$HOME/.pyenv}/version || _P9K_RETVAL=system
}

################################################################
# Segment to display pyenv information
# https://github.com/pyenv/pyenv#choosing-the-python-version
set_default POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW false
prompt_pyenv() {
  local v=${(j.:.)${(@)${(s.:.)PYENV_VERSION}#python-}}
  if [[ -z $v ]]; then
    [[ $PYENV_DIR == /* ]] && local dir=$PYENV_DIR || local dir="$PWD/$PYENV_DIR"
    while true; do
      if _p9k_read_pyenv_version_file $dir/.python-version; then
        v=$_P9K_RETVAL
        break
      fi
      if [[ $dir == / ]]; then
        [[ $POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW == true ]] || return
        _p9k_pyenv_global_version
        v=$_P9K_RETVAL
        break
      fi
      dir=${dir:h}
    done
  fi

  if [[ $POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW == false ]]; then
    _p9k_pyenv_global_version
    [[ $v == $_P9K_RETVAL ]] && return
  fi

  "$1_prompt_segment" "$0" "$2" "blue" "$DEFAULT_COLOR" 'PYTHON_ICON' 0 '' "${v//\%/%%}"
}

################################################################
# Display openfoam information
prompt_openfoam() {
  local wm_project_version="$WM_PROJECT_VERSION"
  local wm_fork="$WM_FORK"
  if [[ -n "$wm_project_version" && -z "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" '' 0 '' "OF: ${${wm_project_version:t}//\%/%%}"
  elif [[ -n "$wm_project_version" && -n "$wm_fork" ]] ; then
    "$1_prompt_segment" "$0" "$2" "yellow" "$DEFAULT_COLOR" '' 0 '' "F-X: ${${wm_project_version:t}//\%/%%}"
  fi
}

################################################################
# Segment to display Swift version
prompt_swift_version() {
  _p9k_cached_cmd_stdout swift --version || return
  emulate -L zsh && setopt extendedglob
  [[ $_P9K_RETVAL == (#b)[^[:digit:]]#([[:digit:].]##)* ]] || return
  "$1_prompt_segment" "$0" "$2" "magenta" "white" 'SWIFT_ICON' 0 '' "${match[1]//\%/%%}"
}

################################################################
# dir_writable: Display information about the user's permission to write in the current directory
prompt_dir_writable() {
  if [[ ! -w "$PWD" ]]; then
    "$1_prompt_segment" "$0_FORBIDDEN" "$2" "red" "yellow1" 'LOCK_ICON' 0 '' ''
  fi
}

################################################################
# Kubernetes Current Context/Namespace

# Set to false to truncate trailing "/default": "mycontext/default" will become "mycontext".
set_default POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE true

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
set_default -a POWERLEVEL9K_KUBECONTEXT_CLASSES

prompt_kubecontext() {
  (( $+commands[kubectl] )) || return
  local cfg
  local -a key
  for cfg in ${(s.:.)${KUBECONFIG:-$HOME/.kube/config}}; do
    local -H stat
    zstat -H stat -- $cfg 2>/dev/null || continue
    key+=($cfg $stat[inode] $stat[mtime] $stat[size] $stat[mode])
  done

  if ! _p9k_cache_get $0 "${key[@]}"; then
    local ctx=$(command kubectl config view -o=jsonpath='{.current-context}')
    if [[ -n $ctx ]]; then
      local p="{.contexts[?(@.name==\"$ctx\")].context.namespace}"
      local ns="${$(command kubectl config view -o=jsonpath=$p):-default}"
      if [[ $ctx != $ns && ($ns != default || $POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE == true) ]]; then
        ctx+="/$ns"
      fi
    fi
    local suf
    if [[ -n $ctx ]]; then
      local pat class
      for pat class in $POWERLEVEL9K_KUBECONTEXT_CLASSES; do
        if [[ $ctx == ${~pat} ]]; then
          [[ -n $class ]] && suf=_${(U)class}
          break
        fi
      done
    fi
    _p9k_cache_set "$ctx" "$suf"
  fi

  [[ -n $_P9K_CACHE_VAL[1] ]] || return
  $1_prompt_segment $0$_P9K_CACHE_VAL[2] $2 magenta white KUBERNETES_ICON 0 '' "${_P9K_CACHE_VAL[1]//\%/%%}"
}

################################################################
# Dropbox status
prompt_dropbox() {
  (( $+commands[dropbox-cli] )) || return
  # The first column is just the directory, so cut it
  local dropbox_status="$(command dropbox-cli filestatus . | cut -d\  -f2-)"

  # Only show if the folder is tracked and dropbox is running
  if [[ "$dropbox_status" != 'unwatched' && "$dropbox_status" != "isn't running!" ]]; then
    # If "up to date", only show the icon
    if [[ "$dropbox_status" =~ 'up to date' ]]; then
      dropbox_status=""
    fi

    "$1_prompt_segment" "$0" "$2" "white" "blue" "DROPBOX_ICON" 0 '' "${dropbox_status//\%/%%}"
  fi
}

# Specifies the format of java version.
#
#   POWERLEVEL9K_JAVA_VERSION_FULL=true  => 1.8.0_212-8u212-b03-0ubuntu1.18.04.1-b03
#   POWERLEVEL9K_JAVA_VERSION_FULL=false => 1.8.0_212
#
# These correspond to `java -fullversion` and `java -version` respectively.
set_default POWERLEVEL9K_JAVA_VERSION_FULL true

# print Java version number
prompt_java_version() {
  _p9k_cached_cmd_stdout_stderr java -fullversion || return
  local v=$_P9K_RETVAL
  v=${${v#*\"}%\"*}
  [[ $POWERLEVEL9K_JAVA_VERSION_FULL == true ]] || v=${v%%-*}
  [[ -n $v ]] || return
  "$1_prompt_segment" "$0" "$2" "red" "white" "JAVA_ICON" 0 '' "${v//\%/%%}"
}

################################################################
# Prompt processing and drawing
################################################################
# Main prompt
set_default -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS context dir vcs

# Returns 1 if the cursor is at the very end of the screen.
build_left_prompt() {
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
      (( $+functions[prompt_$element] )) && "prompt_$element" "left" "$index"
    fi

    ((++index))
  done

  _p9k_get_icon LEFT_SEGMENT_END_SEPARATOR
  _p9k_left_prompt_end_line $_P9K_RETVAL
}

# Right prompt
set_default -a POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS status root_indicator background_jobs history time
build_right_prompt() {
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
      (( $+functions[prompt_$element] )) && "prompt_$element" "right" "$index"
    fi

    ((++index))
  done
}

typeset -gF _P9K_TIMER_START

powerlevel9k_preexec() { _P9K_TIMER_START=$EPOCHREALTIME }

typeset -g _P9K_PROMPT
typeset -g _P9K_RPROMPT
typeset -g _P9K_LEFT_PREFIX
typeset -g _P9K_LEFT_SUFFIX
typeset -g _P9K_RIGHT_PREFIX
typeset -g _P9K_RIGHT_SUFFIX

set_default POWERLEVEL9K_DISABLE_RPROMPT false
function _p9k_set_prompt() {
  emulate -L zsh
  PROMPT=
  RPROMPT=
  if [[ $POWERLEVEL9K_DISABLE_RPROMPT == true ]]; then
    _P9K_RPROMPT_DONE=1
  else
    _P9K_PROMPT=
    build_right_prompt
    local right=$_P9K_RIGHT_PREFIX$_P9K_PROMPT$_P9K_RIGHT_SUFFIX
    if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE != true || $POWERLEVEL9K_RPROMPT_ON_NEWLINE == true ]]; then
      RPROMPT=$right
      _P9K_RPROMPT_DONE=1
    else
      unset _P9K_RPROMPT_OVERRIDE
      PROMPT="\${\${_P9K_RPROMPT::=\${_P9K_RPROMPT_OVERRIDE-$right}}+}"
      _P9K_RPROMPT_DONE=0
    fi
  fi

  _P9K_PROMPT=''
  if build_left_prompt; then
    PROMPT+=$_P9K_LEFT_PREFIX$_P9K_PROMPT$_P9K_LEFT_SUFFIX
  else
    PROMPT+=$_P9K_LEFT_PREFIX$_P9K_PROMPT${_P9K_LEFT_SUFFIX#$'\n'}
  fi

  PROMPT=${PROMPT//$' %{\b'/'%{%G'}
  RPROMPT=${RPROMPT//$' %{\b'/'%{%G'}
}

typeset -g _P9K_REFRESH_REASON

function _p9k_update_prompt() {
  (( _P9K_ENABLED )) || return
  _P9K_REFRESH_REASON=$1
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
  zle && zle .reset-prompt && zle -R
}

typeset -gi _P9K_REGION_ACTIVE

set_default POWERLEVEL9K_PROMPT_ADD_NEWLINE false
set_default POWERLEVEL9K_SHOW_RULER false

powerlevel9k_refresh_prompt_inplace() {
  emulate -L zsh

  _p9k_init

  _P9K_REFRESH_REASON=precmd
  _p9k_set_prompt
  _P9K_REFRESH_REASON=''
}

powerlevel9k_prepare_prompts() {
  _P9K_EXIT_CODE=$?
  _P9K_PIPE_EXIT_CODES=( "$pipestatus[@]" )
  _P9K_COMMAND_DURATION=$((EPOCHREALTIME - _P9K_TIMER_START))
  _P9K_TIMER_START=1e10
  _P9K_REGION_ACTIVE=0

  unsetopt localoptions
  prompt_opts=(cr percent sp subst)
  setopt nopromptbang prompt{cr,percent,sp,subst}

  powerlevel9k_refresh_prompt_inplace
}

function _p9k_zle_keymap_select() {
  zle && zle .reset-prompt && zle -R
}

set_default POWERLEVEL9K_IGNORE_TERM_COLORS false
set_default POWERLEVEL9K_IGNORE_TERM_LANG false
set_default POWERLEVEL9K_DISABLE_GITSTATUS false
set_default -i POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY -1
set_default -i POWERLEVEL9K_VCS_STAGED_MAX_NUM 1
set_default -i POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM 1
set_default -i POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM 1
set_default -i POWERLEVEL9K_VCS_COMMITS_AHEAD_MAX_NUM -1
set_default -i POWERLEVEL9K_VCS_COMMITS_BEHIND_MAX_NUM -1

typeset -g DEFAULT_COLOR
typeset -g DEFAULT_COLOR_INVERTED
typeset -gi _P9K_INITIALIZED=0

typeset -g OS
typeset -g OS_ICON
typeset -g SED_EXTENDED_REGEX_PARAMETER

typeset -g  _P9K_TIMER_FIFO
typeset -gi _P9K_TIMER_FD=0
typeset -gi _P9K_TIMER_PID=0
typeset -gi _P9K_TIMER_SUBSHELL=0

_p9k_init_timer() {
  _p9k_start_timer() {
    emulate -L zsh
    setopt err_return no_bg_nice

    _P9K_TIMER_FIFO=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.timer.pipe.XXXXXXXXXX)
    mkfifo $_P9K_TIMER_FIFO
    sysopen -rw -o cloexec,sync -u _P9K_TIMER_FD $_P9K_TIMER_FIFO
    zsystem flock $_P9K_TIMER_FIFO

    function _p9k_on_timer() {
      emulate -L zsh
      local dummy
      while IFS='' read -t -u $_P9K_TIMER_FD dummy; do true; done
      zle && zle .reset-prompt && zle -R
    }

    zle -F $_P9K_TIMER_FD _p9k_on_timer

    # `kill -WINCH $$` is a workaround for a bug in zsh. After a background job completes, callbacks
    # registered with `zle -F` stop firing until the user presses any key or the process receives a
    # signal (any signal at all).
    zsh -c "
      zmodload zsh/system
      while sleep 1 && ! zsystem flock -t 0 ${(q)_P9K_TIMER_FIFO} && kill -WINCH $$ && echo; do
        true
      done
      command rm -f ${(q)_P9K_TIMER_FIFO}
    " </dev/null >&$_P9K_TIMER_FD 2>/dev/null &!

    _P9K_TIMER_PID=$!
    _P9K_TIMER_SUBSHELL=$ZSH_SUBSHELL

    function _p9k_kill_timer() {
      emulate -L zsh
      if (( ZSH_SUBSHELL == _P9K_TIMER_SUBSHELL )); then
        (( _P9K_TIMER_PID )) && kill -- -$_P9K_TIMER_PID &>/dev/null
        command rm -f $_P9K_TIMER_FIFO
      fi
    }
    add-zsh-hook zshexit _p9k_kill_timer
  }

  if ! _p9k_start_timer ; then
    echo "powerlevel10k: failed to initialize background timer" >&2
    if (( _P9K_TIMER_FD )); then
      zle -F $_P9K_TIMER_FD
      exec {_P9K_TIMER_FD}>&-
      _P9K_TIMER_FD=0
    fi
    if (( _P9K_TIMER_PID )); then
      kill -- -$_P9K_TIMER_PID &>/dev/null
      _P9K_TIMER_PID=0
    fi
    command rm -f $_P9K_TIMER_FIFO
    _P9K_TIMER_FIFO=''
    unset -f _p9k_on_timer
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

# Some people write POWERLEVEL9K_DIR_PATH_SEPARATOR='\uNNNN' instead of
# POWERLEVEL9K_DIR_PATH_SEPARATOR=$'\uNNNN'. There is no good reason for it and if we were
# starting from scratch we wouldn't perform automatic conversion from the former to the latter.
# But we aren't starting from scratch, so convert we do.
_p9k_init_strings() {
  # To find candidates:
  #
  #   egrep 'set_default [^-]' powerlevel9k.zsh-theme | egrep -v '(true|false)$'
  _p9k_g_expand POWERLEVEL9K_ANACONDA_LEFT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_CONTEXT_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_DATE_FORMAT
  _p9k_g_expand POWERLEVEL9K_DIR_PATH_SEPARATOR
  _p9k_g_expand POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
  _p9k_g_expand POWERLEVEL9K_HOST_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_SHORTEN_DELIMITER
  _p9k_g_expand POWERLEVEL9K_TIME_FORMAT
  _p9k_g_expand POWERLEVEL9K_USER_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_VCS_LOADING_TEXT
  _p9k_g_expand POWERLEVEL9K_VI_COMMAND_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_VI_INSERT_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS
}

_p9k_init() {
  (( _P9K_INITIALIZED )) && return

  _p9k_init_icons
  _p9k_init_strings

  function _$0_set_os() {
    OS=$1
    _p9k_get_icon $2
    OS_ICON=$_P9K_RETVAL
  }

  trap "unfunction _$0_set_os" EXIT

  if [[ $(uname -o 2>/dev/null) == Android ]]; then
    _$0_set_os Android ANDROID_ICON
  else
    case $(uname) in
      SunOS)                     _$0_set_os Solaris SUNOS_ICON;;
      Darwin)                    _$0_set_os OSX     APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   _$0_set_os Windows WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) _$0_set_os BSD     FREEBSD_ICON;;
      Linux)
        OS='Linux'
        local os_release_id
        [[ -f /etc/os-release &&
          "${(f)$((</etc/os-release) 2>/dev/null)}" =~ "ID=([A-Za-z]+)" ]] && os_release_id="${match[1]}"
        case "$os_release_id" in
          *arch*)                  _$0_set_os Linux LINUX_ARCH_ICON;;
          *debian*)                _$0_set_os Linux LINUX_DEBIAN_ICON;;
          *raspbian*)              _$0_set_os Linux LINUX_RASPBIAN_ICON;;
          *ubuntu*)                _$0_set_os Linux LINUX_UBUNTU_ICON;;
          *elementary*)            _$0_set_os Linux LINUX_ELEMENTARY_ICON;;
          *fedora*)                _$0_set_os Linux LINUX_FEDORA_ICON;;
          *coreos*)                _$0_set_os Linux LINUX_COREOS_ICON;;
          *gentoo*)                _$0_set_os Linux LINUX_GENTOO_ICON;;
          *mageia*)                _$0_set_os Linux LINUX_MAGEIA_ICON;;
          *centos*)                _$0_set_os Linux LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) _$0_set_os Linux LINUX_OPENSUSE_ICON;;
          *sabayon*)               _$0_set_os Linux LINUX_SABAYON_ICON;;
          *slackware*)             _$0_set_os Linux LINUX_SLACKWARE_ICON;;
          *linuxmint*)             _$0_set_os Linux LINUX_MINT_ICON;;
          *alpine*)                _$0_set_os Linux LINUX_ALPINE_ICON;;
          *aosc*)                  _$0_set_os Linux LINUX_AOSC_ICON;;
          *nixos*)                 _$0_set_os Linux LINUX_NIXOS_ICON;;
          *devuan*)                _$0_set_os Linux LINUX_DEVUAN_ICON;;
          *manjaro*)               _$0_set_os Linux LINUX_MANJARO_ICON;;
          *)                       _$0_set_os Linux LINUX_ICON;;
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

  if [[ $POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME == true ]]; then
    _p9k_init_timer
  fi

  _P9K_ALIGNED_RPROMPT='${${:-${_P9K_X::=0}${_P9K_Y::=1024}${_P9K_CLM::=$COLUMNS}${COLUMNS::=1024}'
  repeat 10; do
    _P9K_ALIGNED_RPROMPT+='${_P9K_M::=$(((_P9K_X+_P9K_Y)/2))}'
    _P9K_ALIGNED_RPROMPT+='${_P9K_XY::=${${(%):-$_P9K_RPROMPT%$_P9K_M(l./$_P9K_M;$_P9K_Y./$_P9K_X;$_P9K_M)}##*/}}'
    _P9K_ALIGNED_RPROMPT+='${_P9K_X::=${_P9K_XY%;*}}'
    _P9K_ALIGNED_RPROMPT+='${_P9K_Y::=${_P9K_XY#*;}}'
  done
  _P9K_ALIGNED_RPROMPT+='${COLUMNS::=_P9K_CLM}'
  _P9K_ALIGNED_RPROMPT+='${_P9K_X::=$((_P9K_X+2+_P9K_IND))}'
  _P9K_ALIGNED_RPROMPT+='${_P9K_Y::=$((_P9K_X+31))}}+}'

  repeat 32; do
    _P9K_ALIGNED_RPROMPT+='%-$_P9K_Y(l.                                .)'
  done
  repeat 32; do
    _P9K_ALIGNED_RPROMPT+='%-$_P9K_X(l. .)'
  done
  _P9K_ALIGNED_RPROMPT+='%$(((COLUMNS-_P9K_X+2)*(COLUMNS+2>=_P9K_X)))'
  _P9K_ALIGNED_RPROMPT+=$'(l.\n. ${_P9K_RPROMPT//)/%)}$_P9K_T[$((3+!_P9K_IND))])'

  _P9K_LEFT_PREFIX+='${${_P9K_IND::=${${ZLE_RPROMPT_INDENT:-1}/#-*/0}}+}'

  if [[ $POWERLEVEL9K_PROMPT_ADD_NEWLINE == true ]]; then
    repeat ${POWERLEVEL9K_PROMPT_ADD_NEWLINE_COUNT:-1} _P9K_LEFT_PREFIX+=$'\n'
  fi

  if [[ $POWERLEVEL9K_SHOW_RULER == true ]]; then
    _p9k_get_icon RULER_CHAR
    local ruler_char=$_P9K_RETVAL
    _p9k_prompt_length $ruler_char
    if (( _P9K_RETVAL == 1 && $#ruler_char == 1 )); then
      _p9k_color "" prompt_ruler BACKGROUND
      _p9k_background $_P9K_RETVAL
      _P9K_LEFT_PREFIX+=$_P9K_RETVAL
      _p9k_color "" prompt_ruler FOREGROUND
      _p9k_foreground $_P9K_RETVAL
      _P9K_LEFT_PREFIX+=$_P9K_RETVAL
      [[ $ruler_char == '.' ]] && local sep=',' || local sep='.'
      local ruler_len='${$((COLUMNS-_P9K_IND))/#-*/0}'
      _P9K_LEFT_PREFIX+="%b\${(pl$sep$ruler_len$sep$sep${(q)ruler_char}$sep)}%k%f"
      _P9K_LEFT_PREFIX+='$_P9K_T[$((3+!_P9K_IND))]'
    else
      print -P "%F{red}WARNING!%f %BPOWERLEVEL9K_RULER_CHAR%b is not one character long. Ruler won't be rendered."
      print -P "Either change the value of %BPOWERLEVEL9K_RULER_CHAR%b or set %BPOWERLEVEL9K_SHOW_RULER=false%b to"
      print -P "disable ruler."
    fi
  fi

  if [[ $ITERM_SHELL_INTEGRATION_INSTALLED == Yes ]]; then
    _P9K_LEFT_PREFIX+="%{$(iterm2_prompt_mark)%}"
  fi

  _P9K_LEFT_PREFIX+='${${_P9K_BG::=NONE}+}${${_P9K_I::=0}+}'
  _P9K_RIGHT_PREFIX+='${${_P9K_BG::=NONE}+}${${_P9K_I::=0}+}'

  _p9k_get_icon LEFT_SEGMENT_SEPARATOR
  _P9K_T=("%f$_P9K_RETVAL" "" $'\n')
  _p9k_prompt_overflow_bug && _P9K_T+='%{%G%}' || _P9K_T+=''

  _P9K_RIGHT_SUFFIX+='%f%b%k'
  _P9K_RIGHT_PREFIX+='%f%b%k'

  if [[ $POWERLEVEL9K_PROMPT_ON_NEWLINE == true ]]; then
    _p9k_get_icon MULTILINE_FIRST_PROMPT_PREFIX
    _P9K_LEFT_PREFIX+="$_P9K_RETVAL%f%b%k"
    _p9k_get_icon MULTILINE_LAST_PROMPT_PREFIX
    _P9K_LEFT_SUFFIX+=$'\n'$_P9K_RETVAL
    if [[ $POWERLEVEL9K_RPROMPT_ON_NEWLINE != true ]]; then
      if is-at-least 5.3; then
        function _p9k_zle_line_finish() {
          [[ -o TRANSIENT_RPROMPT ]] || return
          _P9K_RPROMPT_OVERRIDE=
          zle && zle .reset-prompt && zle -R
        }
        autoload -Uz add-zle-hook-widget
        zle -N _p9k_zle_line_finish
        add-zle-hook-widget line-finish _p9k_zle_line_finish
        add-zle-hook-widget -D line-finish user:_zsh_highlight_widget_orig-\*
        add-zle-hook-widget -D line-finish user:_zsh_autosuggest_bound_\*
      fi
    fi
  else
    _P9K_LEFT_PREFIX+="%f%b%k"
  fi

  # If the terminal `LANG` is set to `C`, this theme will not work at all.
  if [[ $LANG == "C" && $POWERLEVEL9K_IGNORE_TERM_LANG == false ]]; then
    print -P "\t%F{red}WARNING!%f Your terminal's 'LANG' is set to 'C', which breaks this theme!"
    print -P "\t%F{red}WARNING!%f Please set your 'LANG' to a UTF-8 language, like 'en_US.UTF-8'"
    print -P "\t%F{red}WARNING!%f _before_ loading this theme in your \~\.zshrc. Putting"
    print -P "\t%F{red}WARNING!%f %F{blue}export LANG=\"en_US.UTF-8\"%f at the top of your \~\/.zshrc is sufficient."
    print -P 'Set POWERLEVEL9K_IGNORE_TERM_LANG=true to suppress this warning.'
  fi

  # Display a warning if the terminal does not support 256 colors.
  if [[ $POWERLEVEL9K_IGNORE_TERM_COLORS == false ]]; then
    if zmodload zsh/terminfo 2>/dev/null && (( $+terminfo[colors] && $terminfo[colors] < 256 )); then
      print -P '%F{red}WARNING!%f Your terminal appears to support fewer than 256 colors!'
      print -P 'If your terminal supports 256 colors, please export the appropriate environment variable.'
      print -P 'In most terminal emulators, adding %F{blue}export TERM=xterm-256color%f to your %F{yellow}~/.zshrc%f is sufficient.'
      print -P 'Set %F{blue}POWERLEVEL9K_IGNORE_TERM_COLORS=true%f to suppress this warning.'
    fi
  fi

  if segment_in_use longstatus; then
    print -P '%F{yellow}WARNING!%f The "longstatus" segment is deprecated. Use "%F{blue}status%f" instead.'
    print -P 'For more informations, have a look at https://github.com/bhilburn/powerlevel9k/blob/master/CHANGELOG.md.'
  fi

  if segment_in_use vcs; then
    powerlevel9k_vcs_init
    if [[ $POWERLEVEL9K_DISABLE_GITSTATUS != true ]] && (( ${POWERLEVEL9K_VCS_BACKENDS[(I)git]} )); then
      source ${POWERLEVEL9K_GITSTATUS_DIR:-${_p9k_installation_dir}/gitstatus}/gitstatus.plugin.zsh
      gitstatus_start                                                                 \
        -s ${POWERLEVEL9K_VCS_MAX_NUM_STAGED:-$POWERLEVEL9K_VCS_STAGED_MAX_NUM}       \
        -u ${POWERLEVEL9K_VCS_MAX_NUM_UNSTAGED:-$POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM}   \
        -d ${POWERLEVEL9K_VCS_MAX_NUM_UNTRACKED:-$POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM} \
        -m $POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY                                     \
        POWERLEVEL9K
    fi
  fi

  if segment_in_use vi_mode && (( $+POWERLEVEL9K_VI_VISUAL_MODE_STRING )); then
    if is-at-least 5.3; then
      function _p9k_zle_line_pre_redraw() {
        [[ $KEYMAP == vicmd ]] &&
          [[ ${REGION_ACTIVE:-0} != $_P9K_REGION_ACTIVE ]] &&
          _P9K_REGION_ACTIVE=${REGION_ACTIVE:-0} &&
          zle && zle .reset-prompt && zle -R
      }
      autoload -Uz add-zle-hook-widget
      add-zle-hook-widget line-pre-redraw _p9k_zle_line_pre_redraw
      add-zle-hook-widget -D line-pre-redraw user:_zsh_highlight_widget_orig-\*
      add-zle-hook-widget -D line-pre-redraw user:_zsh_autosuggest_bound_\*
      _p9k_g_expand POWERLEVEL9K_VI_VISUAL_MODE_STRING
    else
      >&2 print -P '%F{yellow}WARNING!%f POWERLEVEL9K_VI_VISUAL_MODE_STRING requires ZSH >= 5.3.'
      >&2 print -r "Your zsh version is $ZSH_VERSION. Either upgrade zsh or unset POWERLEVEL9K_VI_VISUAL_MODE_STRING."
    fi
  fi

  if segment_in_use dir &&
     [[ $POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name && $+commands[jq] == 0 ]]; then
    >&2 print -P '%F{yellow}WARNING!%f %BPOWERLEVEL9K_SHORTEN_STRATEGY=truncate_with_package_name%b requires %F{green}jq%f.'
    >&2 print -P 'Either install %F{green}jq%f or change the value of %BPOWERLEVEL9K_SHORTEN_STRATEGY%b.'
  fi

  zle -N zle-keymap-select _p9k_zle_keymap_select

  _P9K_INITIALIZED=1
}

typeset -gi _P9K_ENABLED=0

prompt_powerlevel9k_setup() {
  prompt_powerlevel9k_teardown

  add-zsh-hook precmd powerlevel9k_prepare_prompts
  add-zsh-hook preexec powerlevel9k_preexec

  _P9K_TIMER_START=1e10
  _P9K_ENABLED=1
}

prompt_powerlevel9k_teardown() {
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
zmodload zsh/system
zmodload -F zsh/stat b:zstat

prompt_powerlevel9k_setup
