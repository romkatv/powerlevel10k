#!/usr/bin/env zsh

emulate -L zsh
setopt noaliases

() {
setopt extended_glob no_prompt_{bang,subst} prompt_{cr,percent,sp}

typeset -g __p9k_root_dir
typeset -gi force=0

local opt
while getopts 'd:f' opt; do
  case $opt in
    d)  __p9k_root_dir=$OPTARG;;
    f)  force=1;;
    +f) force=0;;
    '?') return 1;;
  esac
done

if (( OPTIND <= ARGC )); then
  print -lr -- "wizard.zsh: invalid arguments: $@" >&2
  return 1
fi

: ${__p9k_root_dir:=${0:h:h:A}}

typeset -gr __p9k_root_dir
typeset -gri force

source $__p9k_root_dir/internal/configure.zsh || return

typeset -ri prompt_indent=2

typeset -ra bg_color=(238 236 234)
typeset -ra frame_color=(242 240 238)
typeset -ra sep_color=(244 242 240)
typeset -ra prefix_color=(248 246 244)

typeset -ra lean_left=(
  '' '%31F$extra_icons[1]%B%39F~%b%31F/%B%39Fpowerlevel10k%b%f $prefixes[1]%76F$extra_icons[2]master ⇡2%f '
  '' '%76F❯%f █'
)

typeset -ra lean_right=(
  ' $prefixes[2]%134F⎈ minikube%f' ''
  '' ''
)

typeset -ra classic_left=(
  '%$frame_color[$color]F╭─' '%K{$bg_color[$color]} %31F$extra_icons[1]%B%39F~%b%K{$bg_color[$color]}%31F/%B%39Fpowerlevel10k%b%K{$bg_color[$color]} %$sep_color[$color]F\uE0B1%f %$prefix_color[$color]F$prefixes[1]%76F$extra_icons[2]master ⇡2 %k%$bg_color[$color]F\uE0B0%f'
  '%$frame_color[$color]F╰─' '%f █'
)

typeset -ra classic_right=(
  '%$bg_color[$color]F\uE0B2%K{$bg_color[$color]}%f %$prefix_color[$color]F$prefixes[2]%134Fminikube ⎈ %k%f' '%$frame_color[$color]F─╮%f'
  '' '%$frame_color[$color]F─╯%f'
)

function prompt_length() {
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
  print $x
}

function print_prompt() {
  local left=${style}_left
  local right=${style}_right
  left=("${(@P)left}")
  right=("${(@P)right}")
  eval "left=(${(@)left:/(#b)(*)/\"$match[1]\"})"
  eval "right=(${(@)right:/(#b)(*)/\"$match[1]\"})"
  if (( num_lines == 1)); then
    left=($left[2] $left[4])
    right=($right[1] $right[3])
  else
    (( frame < 1 )) && left=('' $left[2] '' '%76F❯%f █')
    (( frame < 2 )) && right=($right[1] '' '' '')
  fi
  if (( straight )); then
    [[ $POWERLEVEL9K_MODE == nerdfont-complete ]] && local subsep='\uE0BD' || local subsep='|'
    left=("${(@)${(@)left//\\uE0B1/$subsep}//\\uE0B0/▓▒░}")
    right=("${(@)${(@)right//\\uE0B3/$subsep}//\\uE0B2/░▒▓}")
  fi
  local -i i
  for ((i = 1; i < $#left; i+=2)); do
    local l=${(g::):-$left[i]$left[i+1]}
    local r=${(g::):-$right[i]$right[i+1]}
    local -i gap=$((__p9k_wizard_columns - 2 * prompt_indent - $(prompt_length $l$r)))
    (( num_lines == 2 && i == 1 )) && local fill=$gap_char || local fill=' '
    print -n  -- ${(pl:$prompt_indent:: :)}
    print -nP -- $l
    print -nP -- "%$frame_color[$color]F${(pl:$gap::$fill:)}%f"
    print -P  -- $r
  done
}

function href() {
  print -r -- $'%{\e]8;;'${1//\%/%%}$'\a%}'${1//\%/%%}$'%{\e]8;;\a%}'
}

function centered() {
  local n=$(prompt_length ${(g::)1})
  print -n -- ${(pl:$(((__p9k_wizard_columns - n) / 2)):: :)}
  print -P -- $1
}

function clear() {
  if (( $+commands[clear] )); then
    command clear
  elif zmodload zsh/termcap 2>/dev/null; then
    echotc cl
  else
    print -n -- "\e[H\e[J"
  fi
}

function quit() {
  clear
  if (( force )); then
    print -P "Powerlevel10k configuration wizard has been aborted. To run it again, type:"
    print -P ""
    print -P "  %2Fp9k_configure%f"
  else
    print -P "Powerlevel10k configuration wizard will run again next time unless"
    print -P "you define at least one Powerlevel10k configuration option. To define"
    print -P "an option that does nothing except for disabling Powerlevel10k"
    print -P "configuration wizard, type the following command:"
    print -P ""
    print -P "  %2Fecho%f %3F'POWERLEVEL9K_MODE='%f >>! $__p9k_zshrc_u"
    print -P ""
    print -P "To run Powerlevel10k configuration wizard right now, type:"
    print -P ""
    print -P "  %2Fp9k_configure%f"
  fi
}

function ask_diamond() {
  while true; do
    clear
    if (( force )); then
      print -P "This is %4FPowerlevel10k configuration wizard%f. It will ask you a few"
      print -P "questions and configure your prompt."
    else
      print -P "This is %4FPowerlevel10k configuration wizard%f. You are seeing it because"
      print -P "you haven't defined any Powerlevel10k configuration options. It will"
      print -P "ask you a few questions and configure your prompt."
    fi
    print -P ""
    centered "%BDoes this look like a %b%2Fdiamond%f%B (square rotated 45 degrees)?%b"
    centered "reference: $(href https://graphemica.com/%E2%97%86)"
    print -P ""
    centered "--->  \uE0B2\uE0B0  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      y) cap_diamond=1; break;;
      n) cap_diamond=0; break;;
    esac
  done
}

function ask_lock() {
  while true; do
    clear
    [[ -n $2 ]] && centered "$2"
    centered "%BDoes this look like a %b%2Flock%f%B?%b"
    centered "reference: $(href https://fontawesome.com/icons/lock)"
    print -P ""
    centered "--->  $1  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y) cap_lock=1; break;;
      n) cap_lock=0; break;;
    esac
  done
}

function ask_python() {
  while true; do
    clear
    centered "%BDoes this look like a %b%2FPython logo%f%B?%b"
    centered "reference: $(href https://fontawesome.com/icons/python)"
    print -P ""
    centered "--->  \uE63C  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y) cap_python=1; break;;
      n) cap_python=0; break;;
    esac
  done
}

function ask_narrow_icons() {
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) ]]; then
    cap_narrow_icons=0
    return
  fi
  local text="X"
  text+="%1F${icons[VCS_GIT_ICON]// }%fX"
  text+="%2F${icons[VCS_GIT_GITHUB_ICON]// }%fX"
  text+="%3F${icons[DATE_ICON]// }%fX"
  text+="%4F${icons[TIME_ICON]// }%fX"
  text+="%5F${icons[RUBY_ICON]// }%fX"
  text+="%6F${icons[AWS_EB_ICON]// }%fX"
  while true; do
    clear
    centered "%BDo all these icons %b%2Ffit between the crosses%f%B?%b"
    print -P ""
    centered "--->  $text  <---"
    print -P ""
    print -P "%B(y)  Yes. Icons are very close to the crosses but there is %b%2Fno overlap%f%B.%b"
    print -P ""
    print -P "%B(n)  No. Some icons %b%2Foverlap%f%B neighbouring crosses.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y) cap_narrow_icons=1; break;;
      n) cap_narrow_icons=0; break;;
    esac
  done
}

function ask_style() {
  while true; do
    clear
    centered "%BPrompt Style%b"
    print -P ""
    print -P "%B(1)  Lean.%b"
    print -P ""
    style=lean print_prompt
    print -P ""
    print -P "%B(2)  Classic.%b"
    print -P ""
    style=classic print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) style=lean; break;;
      2) style=classic; break;;
    esac
  done
}

function ask_color() {
  [[ $style != classic ]] && return
  while true; do
    clear
    centered "%BPrompt Color%b"
    print -P ""
    print -P "%B(1)  Light.%b"
    print -P ""
    color=1 print_prompt
    print -P ""
    print -P "%B(2)  Medium.%b"
    print -P ""
    color=2 print_prompt
    print -P ""
    print -P "%B(3)  Dark.%b"
    print -P ""
    color=3 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1|2|3) color=$key; break;;
    esac
  done
}

function ask_extra_icons() {
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) ]]; then
    extra_icons=('' '')
    return
  fi
  local dir_icon=${(g::)icons[HOME_SUB_ICON]}
  local vcs_icon=${(g::)icons[VCS_GIT_GITHUB_ICON]}
  local branch_icon=${(g::)icons[VCS_BRANCH_ICON]}
  if (( cap_narrow_icons )); then
    dir_icon=${dir_icon// }
    vcs_icon=${vcs_icon// }
    branch_icon=${branch_icon// }
  fi
  local many=("$dir_icon " "$vcs_icon $branch_icon ")
  while true; do
    clear
    centered "%BIcons%b"
    print -P ""
    print -P "%B(1)  Few icons.%b"
    print -P ""
    extra_icons=('' '') print_prompt
    print -P ""
    print -P "%B(2)  Many icons.%b"
    print -P ""
    extra_icons=("$many[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) extra_icons=('' ''); break;;
      2) extra_icons=("$many[@]"); break;;
    esac
  done
}

function ask_prefixes() {
  local fluent=('on ' 'at ')
  while true; do
    clear
    centered "%BPrompt Flow%b"
    print -P ""
    print -P "%B(1)  Concise.%b"
    print -P ""
    prefixes=('' '') print_prompt
    print -P ""
    print -P "%B(2)  Fluent.%b"
    print -P ""
    prefixes=("$fluent[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) prefixes=('' ''); break;;
      2) prefixes=("$fluent[@]"); break;;
    esac
  done
}

function ask_straight() {
  if [[ $style != classic || $cap_diamond == 0 ]]; then
    straight=1
    return
  fi
  while true; do
    clear
    centered "%BPrompt Separators%b"
    print -P ""
    print -P "%B(1)  Angled.%b"
    print -P ""
    straight=0 print_prompt
    print -P ""
    print -P "%B(2)  Straight.%b"
    print -P ""
    straight=1 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) straight=0; break;;
      2) straight=1; break;;
    esac
  done
}

function ask_num_lines() {
  while true; do
    clear
    centered "%BPrompt Height%b"
    print -P ""
    print -P "%B(1)  One line.%b"
    print -P ""
    num_lines=1 print_prompt
    print -P ""
    print -P "%B(2)  Two lines.%b"
    print -P ""
    num_lines=2 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1|2) num_lines=$key; break;;
    esac
  done
}

function ask_gap_char() {
  if [[ $num_lines != 2 ]]; then
    gap_char=" "
    return
  fi
  while true; do
    clear
    centered "%BPrompt Connection%b"
    print -P ""
    print -P "%B(1)  Disconnected.%b"
    print -P ""
    gap_char=" " print_prompt
    print -P ""
    print -P "%B(2)  Dotted.%b"
    print -P ""
    gap_char="·" print_prompt
    print -P ""
    print -P "%B(3)  Solid.%b"
    print -P ""
    gap_char="─" print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) gap_char=" "; break;;
      2) gap_char="·"; break;;
      3) gap_char="─"; break;;
    esac
  done
}

function ask_frame() {
  if [[ $style != classic || $num_lines != 2 ]]; then
    frame=0
    return
  fi
  while true; do
    clear
    centered "%BPrompt Frame%b"
    print -P ""
    print -P "%B(1)  No frame.%b"
    print -P ""
    frame=0 print_prompt
    print -P ""
    print -P "%B(2)  Only left.%b"
    print -P ""
    frame=1 print_prompt
    print -P ""
    print -P "%B(3)  Left and right.%b"
    print -P ""
    frame=2 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1|2|3) frame=$((key-1)); break;;
    esac
  done
}

function ask_empty_line() {
  while true; do
    clear
    centered "%BPrompt Spacing%b"
    print -P ""
    print -P "%B(1)  Compact.%b"
    print -P ""
    print_prompt
    print_prompt
    print -P ""
    print -P "%B(2)  Sparse.%b"
    print -P ""
    print_prompt
    print -P ""
    print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) empty_line=0; break;;
      2) empty_line=1; break;;
    esac
  done
}

function ask_confirm() {
  while true; do
    clear
    centered "%BLooks good?%b"
    print -P ""
    print_prompt
    (( empty_line )) && print -P ""
    print_prompt
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y) break;;
    esac
  done
}

function ask_config_overwrite() {
  config_backup=
  if [[ ! -e $__p9k_cfg_path ]]; then
    write_config=1
    return
  fi
  while true; do
    clear
    centered "Powerlevel10k config file already exists."
    centered "%BOverwrite %b%2F$__p9k_cfg_path_u%f%B?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y)
        config_backup="$(mktemp ${TMPDIR:-/tmp}/$__p9k_cfg_basename.XXXXXXXXXX)" || return 1
        cp $__p9k_cfg_path $config_backup
        write_config=1
        break
        ;;
    esac
  done
}

function generate_config() {
  local base && base="$(<$__p9k_root_dir/config/p10k-$style.zsh)" || return
  local lines=("${(@f)base}")

  function sub() {
    lines=("${(@)lines/#(#b)([[:space:]]#)typeset -g POWERLEVEL9K_$1=*/$match[1]typeset -g POWERLEVEL9K_$1=$2}")
  }

  function uncomment() {
    lines=("${(@)lines/#(#b)([[:space:]]#)\# $1(  |)/$match[1]$1$match[2]$match[2]}")
  }

  sub MODE $POWERLEVEL9K_MODE

  if (( cap_narrow_icons )); then
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER// }'"
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER// }'"
  else
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER}'"
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER}'"
  fi

  if [[ $POWERLEVEL9K_MODE == compatible ]]; then
    # Many fonts don't have the gear icon.
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'⇶'"
  fi

  if [[ $style == classic ]]; then
    sub BACKGROUND $bg_color[$color]
    sub MULTILINE_FIRST_PROMPT_GAP_FOREGROUND $frame_color[$color]
    sub MULTILINE_FIRST_PROMPT_PREFIX "'%$frame_color[$color]F╭─'"
    sub MULTILINE_NEWLINE_PROMPT_PREFIX "'%$frame_color[$color]F├─'"
    sub MULTILINE_LAST_PROMPT_PREFIX "'%$frame_color[$color]F╰─'"
    sub MULTILINE_FIRST_PROMPT_SUFFIX "'%$frame_color[$color]F─╮'"
    sub MULTILINE_NEWLINE_PROMPT_SUFFIX "'%$frame_color[$color]F─┤'"
    sub MULTILINE_LAST_PROMPT_SUFFIX "'%$frame_color[$color]F─╯'"

    local left_sep='\uE0B0'
    local right_sep='\uE0B2'
    local left_subsep='\uE0B1'
    local right_subsep='\uE0B3'
    local left_end='\uE0B0'
    local right_start='\uE0B2'

    if (( straight )); then
      if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
        left_subsep='\uE0BD'
        right_subsep='\uE0BD'
      else
        left_subsep='|'
        right_subsep'|'
      fi
      left_end='▓▒░'
      right_start='░▒▓'
    fi

    sub LEFT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$left_subsep'"
    sub RIGHT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$right_subsep'"
    sub LEFT_SEGMENT_SEPARATOR "'$left_subsep'"
    sub RIGHT_SEGMENT_SEPARATOR "'$right_subsep'"
    sub LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL "'$left_end'"
    sub RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL "'$right_start'"
  fi

  if [[ -n ${(j::)extra_icons} ]]; then
    local branch_icon=$icons[VCS_BRANCH_ICON]
    (( cap_narrow_icons )) && branch_icon=${branch_icon// }
    sub VCS_BRANCH_ICON "'$branch_icon '"
  else
    uncomment 'typeset -g POWERLEVEL9K_DIR_CLASSES'
    uncomment 'typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION'
    uncomment 'typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION'
    uncomment 'typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION'
    sub VCS_VISUAL_IDENTIFIER_EXPANSION ''
    sub COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION ''
    sub TIME_VISUAL_IDENTIFIER_EXPANSION ''
  fi

  if [[ -n ${(j::)prefixes} ]]; then
    uncomment 'typeset -g POWERLEVEL9K_VCS_PREFIX'
    uncomment 'typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX'
    uncomment 'typeset -g POWERLEVEL9K_CONTEXT_PREFIX'
    uncomment 'typeset -g POWERLEVEL9K_KUBECONTEXT_PREFIX'
    uncomment 'typeset -g POWERLEVEL9K_TIME_PREFIX'
    [[ $style == classic ]] && local fg="%$prefix_color[$color]F" || local fg="%f"
    sub VCS_PREFIX "'${fg}on '"
    sub COMMAND_EXECUTION_TIME_PREFIX "'${fg}took '"
    sub CONTEXT_PREFIX "'${fg}with '"
    sub KUBECONTEXT_PREFIX "'${fg}at '"
    sub TIME_PREFIX "'${fg}at '"
    sub CONTEXT_TEMPLATE "'%n$fg at %180F%m'"
    sub CONTEXT_ROOT_TEMPLATE "'%n$fg at %227F%m'"
  fi

  if (( num_lines == 1 )); then
    local -a tmp
    local line
    for line in "$lines[@]"; do
      [[ $line == ('      newline'|*'===[ Line #'*) ]] || tmp+=$line
    done
    lines=("$tmp[@]")
  fi

  sub MULTILINE_FIRST_PROMPT_GAP_CHAR "'$gap_char'"

  if (( num_lines == 2 && frame < 2 )); then
    sub MULTILINE_FIRST_PROMPT_SUFFIX ''
    sub MULTILINE_NEWLINE_PROMPT_SUFFIX ''
    sub MULTILINE_LAST_PROMPT_SUFFIX ''
    if (( frame < 1 )); then
      sub MULTILINE_FIRST_PROMPT_PREFIX ''
      sub MULTILINE_NEWLINE_PROMPT_PREFIX ''
      sub MULTILINE_LAST_PROMPT_PREFIX ''
      uncomment prompt_char
      sub STATUS_OK false
      sub STATUS_ERROR false
    fi
  fi

  (( empty_line )) && sub PROMPT_ADD_NEWLINE true || sub PROMPT_ADD_NEWLINE false

  local header=${(%):-"# Generated by Powerlevel10k configuration wizard on %D{%Y-%m-%d at %H:%M %Z}."}$'\n'
  header+="# Based on romkatv/powerlevel10k/config/p10k-$style.zsh"
  if [[ $commands[sum] == ('/bin'|'/usr/bin'|'/usr/local/bin')'/sum' ]]; then
    local -a sum
    if sum=($(sum <<<${base//$'\r\n'/$'\n'} 2>/dev/null)) && (( $#sum == 2 )); then
      header+=", checksum $sum[1]"
    fi
  fi
  header+=$'.\n'
  header+="# Wizard options: $POWERLEVEL9K_MODE"
  (( cap_narrow_icons )) && header+=", small icons" || header+=", big icons"
  [[ $style == classic ]] && header+=", color $color"
  [[ -n ${(j::)extra_icons} ]] && header+=", many icons" || header+=", few icons"
  [[ -n ${(j::)prefixes} ]] && header+=", fluent" || header+=", concise"
  if [[ $style == classic ]]; then
    (( straight )) && header+=", straight" || header+=", angled"
  fi
  (( num_lines == 1 )) && header+=", 1 line" || header+=", $num_lines lines"
  if (( num_lines == 2 )); then
    case $gap_char in
      ' ') header+=", disconnected";;
      '·') header+=", dotted";;
      '─') header+=", solid";;
    esac
    case $frame in
      0) header+=", no frame";;
      1) header+=", left frame";;
      2) header+=", full frame";;
    esac
  fi
  (( empty_line )) && header+=", sparse" || header+=", compact";
  header+=$'.\n#'

  if [[ -e $__p9k_cfg_path ]]; then
    unlink $__p9k_cfg_path || return 1
  fi
  print -lr -- "$header" "$lines[@]" >$__p9k_cfg_path
}

function write_zshrc() {
  if [[ -e $__p9k_zshrc ]]; then
    local lines=(${(f)"$(<$__p9k_zshrc)"})
    local f1=$__p9k_cfg_path
    local f2=$__p9k_cfg_path_u
    local f3=${__p9k_cfg_path_u/#\~\//\$HOME\/}
    local f4=${__p9k_cfg_path_u/#\~\//\"\$HOME\"\/}
    local f5="'$f1'"
    local f6="\"$f1\""
    local f7="\"$f3\""
    if [[ -n ${(@M)lines:#(#b)source[[:space:]]##($f1|$f2|$f3|$f4|$f5|$f6|$f7)*} ]]; then
      print -P "No changes have been made to %4F$__p9k_zshrc_u%f because it already sources %2F$__p9k_cfg_path_u%f."
      return
    fi
  fi

  local comments=(
    "# You can customize your prompt by editing $__p9k_cfg_path_u."
    "# To run Powerlevel10k configuration wizard, type 'p9k_configure'."
  )
  print -lr -- "" $comments "source $__p9k_cfg_path_u" >>$__p9k_zshrc

  print -P ""
  print -P "The following lines have been appended to %4F$__p9k_zshrc_u%f:"
  print -P ""
  print -lP -- '  %240F'${^comments}'%f' "  %2Fsource%f $__p9k_cfg_path_u"
}

_p9k_can_configure || return
source $__p9k_root_dir/internal/icons.zsh || return

while true; do
  local POWERLEVEL9K_MODE= style= config_backup= gap_char=' '
  local -i num_lines=0 write_config=0 straight=0 empty_line=0 frame=1 color=1
  local -i cap_diamond=0 cap_python=0 cap_narrow_icons=0 cap_lock=0
  local -a extra_icons=('' '')
  local -a prefixes=('' '')

  ask_diamond || { (( $? == 2 )) && continue || return }
  (( cap_diamond )) || straight=1
  if [[ -n $AWESOME_GLYPHS_LOADED ]]; then
    POWERLEVEL9K_MODE=awesome-mapped-fontconfig
  else
    ask_lock '\uF023' || { (( $? == 2 )) && continue || return }
    if (( ! cap_lock )); then
      ask_lock '\uE138' "Let's try another one." || { (( $? == 2 )) && continue || return }
      if (( cap_lock )); then
        (( cap_diamond )) && POWERLEVEL9K_MODE=awesome-patched || POWERLEVEL9K_MODE=flat
      else
        (( cap_diamond )) && POWERLEVEL9K_MODE=powerline || POWERLEVEL9K_MODE=compatible
      fi
    elif (( ! cap_diamond )); then
      POWERLEVEL9K_MODE=awesome-fontconfig
    else
      ask_python || { (( $? == 2 )) && continue || return }
      (( cap_python )) && POWERLEVEL9K_MODE=awesome-fontconfig || POWERLEVEL9K_MODE=nerdfont-complete
    fi
  fi
  _p9k_init_icons
  ask_narrow_icons     || { (( $? == 2 )) && continue || return }
  ask_style            || { (( $? == 2 )) && continue || return }
  ask_color            || { (( $? == 2 )) && continue || return }
  ask_extra_icons      || { (( $? == 2 )) && continue || return }
  ask_prefixes         || { (( $? == 2 )) && continue || return }
  ask_straight         || { (( $? == 2 )) && continue || return }
  ask_num_lines        || { (( $? == 2 )) && continue || return }
  ask_gap_char         || { (( $? == 2 )) && continue || return }
  ask_frame            || { (( $? == 2 )) && continue || return }
  ask_empty_line       || { (( $? == 2 )) && continue || return }
  ask_confirm          || { (( $? == 2 )) && continue || return }
  ask_config_overwrite || { (( $? == 2 )) && continue || return }
  break
done

clear

print -P "Powerlevel10k configuration has been written to %2F$__p9k_cfg_path_u%f."
if [[ -n $config_backup ]]; then
  print -P "The backup of the previuos version is at %3F$config_backup%f."
fi

if (( write_config )); then
  generate_config || return
fi

write_zshrc || return

print -P ""

} "$@"
