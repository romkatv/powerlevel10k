#!/usr/bin/env zsh

emulate -L zsh
setopt extended_glob noaliases

() {
typeset -gr __p9k_root_dir=${1:-${0:h:h:A}}
source $__p9k_root_dir/internal/configure.zsh || return

typeset -ra lean_left=(
  '' '%B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2%f '
  '' '%76F❯%f █'
)

typeset -ra lean_right=(
  ' %5F⎈ minikube%f' ''
  '' ''
)

typeset -ra classic_left=(
  '%8F╭─' '%K{236} %B%39F~%b%K{236}%12F/%B%39Fpowerlevel10k%b%K{236} %244F\uE0B1 %76Fmaster ⇡2 %k%236F\uE0B0%f'
  '%8F╰─' '%f █'
)

typeset -ra classic_right=(
  '%236F\uE0B2%K{236}%13F minikube ⎈ %k%f' '%8F─╮%f'
  '' '%8F─╯%f'
)

typeset -ri prompt_indent=4

local POWERLEVEL9K_MODE style config_backup gap_char
local -i num_lines write_config flat_sep empty_line
local -i cap_diamond cap_python cap_narrow_icons cap_lock

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
  if (( num_lines == 1)); then
    left=($left[2] $left[4])
    right=($right[1] $right[3])
  fi
  if (( flat_sep )); then
    left=("${(@)${(@)left//\\uE0B1/|}//\\uE0B0/▓▒░}")
    right=("${(@)${(@)right//\\uE0B3/|}//\\uE0B2/░▒▓}")
  fi
  local -i i
  for ((i = 1; i < $#left; i+=2)); do
    local l=${(g::):-$left[i]$left[i+1]}
    local r=${(g::):-$right[i]$right[i+1]}
    local -i gap=$((__p9k_wizard_columns - 2 * prompt_indent - $(prompt_length $l$r)))
    (( num_lines == 2 && i == 1 )) && local fill=${gap_char:-' '} || local fill=' '
    print -n  -- ${(pl:$prompt_indent:: :)}
    print -nP -- $l
    print -nP -- "%8F${(pl:$gap::$fill:)}%f"
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
  print -P "Powerlevel10k configuration wizard will run again next time unless"
  print -P "you define at least one Powerlevel10k configuration option. To define"
  print -P "an option that does nothing except for disabling Powerlevel10k"
  print -P "configuration wizard, type the following command:"
  print -P ""
  print -P "  %2Fecho%f %3F'POWERLEVEL9K_MODE='%f %15F>>! $__p9k_zshrc_u%f"
  print -P ""
}

function ask_diamond() {
  while true; do
    clear
    print -P "This is %B%4FPowerlevel10k configuration wizard%f%b. You are seeing it because"
    print -P "you haven't defined any Powerlevel10k configuration options. It will"
    print -P "ask you a few questions and configure your prompt."
    print -P ""
    centered "%BDoes this look like a %2Fdiamond%f (square rotated 45 degrees)?%b"
    centered "reference: $(href https://graphemica.com/%E2%97%86)"
    print -P ""
    centered "--->  %B\uE0B2\uE0B0%b  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [ynq]: " || return 1
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
    centered "%BDoes this look like a %2Flock%f?%b"
    centered "reference: $(href https://fontawesome.com/icons/lock)"
    print -P ""
    centered "--->  %B$1%b  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [ynrq]: " || return 1
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
    centered "%BDoes this look like a %2FPython logo%f?%b"
    centered "reference: $(href https://fontawesome.com/icons/python)"
    print -P ""
    centered "--->  %B\uE63C%b  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [ynrq]: " || return 1
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
    centered "%BDo all these icons %2Ffit between the crosses%f?%b"
    print -P ""
    centered "--->  %B$text%b  <---"
    print -P ""
    print -P "%B(y)  Yes. Icons are very close to the crosses but there is %2Fno overlap%f%b."
    print -P ""
    print -P "%B(n)  No. Some icons %2Foverlap%f neighbouring crosses.%b"
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [ynrq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      y) cap_narrow_icons=1; break;;
      n) cap_narrow_icons=2; break;;
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
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) style=lean; break;;
      2) style=classic; break;;
    esac
  done
}

function ask_flat_sep() {
  if [[ $style != classic || $cap_diamond == 0 ]]; then
    flat_sep=1
    return
  fi
  while true; do
    clear
    centered "%BPrompt Separators%b"
    print -P ""
    print -P "%B(1)  Angled%b"
    print -P ""
    flat_sep=0 print_prompt
    print -P ""
    print -P "%B(2)  Flat%b"
    print -P ""
    flat_sep=1 print_prompt
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) flat_sep=0; break;;
      2) flat_sep=1; break;;
    esac
  done
}

function ask_num_lines() {
  while true; do
    clear
    centered "%BPrompt Height%b"
    print -P ""
    print -P "%B(1)  One Line%b"
    print -P ""
    num_lines=1 print_prompt
    print -P ""
    print -P "%B(2)  Two Lines%b"
    print -P ""
    num_lines=2 print_prompt
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
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
    print -P "%B(1)  Disconnected%b"
    print -P ""
    gap_char=" " print_prompt
    print -P ""
    print -P "%B(2)  Dotted%b"
    print -P ""
    gap_char="·" print_prompt
    print -P ""
    print -P "%B(3)  Solid%b"
    print -P ""
    gap_char="─" print_prompt
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1) gap_char=" "; break;;
      2) gap_char="·"; break;;
      3) gap_char="─"; break;;
    esac
  done
}

function ask_empty_line() {
  while true; do
    clear
    centered "%BPrompt Spacing%b"
    print -P ""
    print -P "%B(1)  Compact%b"
    print -P ""
    print_prompt
    print_prompt
    print -P ""
    print -P "%B(2)  Sparse%b"
    print -P ""
    print_prompt
    print -P ""
    print_prompt
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
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
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [yrq]: " || return 1
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
    centered "%BOverwrite %2F$__p9k_cfg_path_u%f?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [yrq]: " || return 1
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
    lines=("${(@)lines/#  typeset -g POWERLEVEL9K_$1=*/  typeset -g POWERLEVEL9K_$1=$2}")
  }
  sub MODE $POWERLEVEL9K_MODE
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) && $style == lean ]]; then
    sub VISUAL_IDENTIFIER_EXPANSION "''"
  elif (( cap_narrow_icons )); then
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER// }'"
  else
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER}'"
  fi
  if (( num_lines == 1 )); then
    local -a tmp
    local line
    for line in "$lines[@]"; do
      [[ $line == ('      newline'|*'===[ Line #'*) ]] || tmp+=$line
    done
    lines=("$tmp[@]")
  fi
  local header=${(%):-"# Generated by Powerlevel10k configuration wizard on %D{%Y-%m-%d at %H:%M %Z}."}$'\n'
  header+="# Based on romkatv/powerlevel10k/config/p10k-$style.zsh"
  if [[ $commands[sum] == ('/bin'|'/usr/bin'|'/usr/local/bin')'/sum' ]]; then
    local -a sum
    if sum=($(sum <<<${base//$'\r\n'/$'\n'} 2>/dev/null)) && (( $#sum == 2 )); then
      header+=", checksum $sum[1]"
    fi
  fi
  header+=$'.\n'
  header+="# Wizard options: font=$POWERLEVEL9K_MODE, lines=$num_lines, narrow-icons=$cap_narrow_icons."$'\n#'
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
      print -P "No changes have been made to %B%4F$__p9k_zshrc_u%f%b because it already sources %B%2F$__p9k_cfg_path_u%f%b."
      return
    fi
  fi

  local comments=(
    "# You can customize your prompt by editing $__p9k_cfg_path_u."
    "# To run configuration wizard again, remove the next line."
  )
  print -lr -- "" $comments "source $__p9k_cfg_path_u" >>$__p9k_zshrc

  print -P ""
  print -P "The following lines have been appended to your %B%4F$__p9k_zshrc_u%f%b:"
  print -P ""
  print -lP -- '  %8F'${^comments}'%f' "  %2Fsource%f %15F$__p9k_cfg_path_u%f"
}

_p9k_can_configure || return
source $__p9k_root_dir/internal/icons.zsh || return

while true; do
  ask_diamond || { (( $? == 2 )) && continue || return }
  (( cap_diamond )) || flat_sep=1
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
    else
      ask_python || { (( $? == 2 )) && continue || return }
      (( cap_python )) && POWERLEVEL9K_MODE=awesome-fontconfig || POWERLEVEL9K_MODE=nerdfont-complete
    fi
  fi
  _p9k_init_icons
  ask_narrow_icons     || { (( $? == 2 )) && continue || return }
  ask_style            || { (( $? == 2 )) && continue || return }
  ask_flat_sep         || { (( $? == 2 )) && continue || return }
  ask_num_lines        || { (( $? == 2 )) && continue || return }
  ask_gap_char         || { (( $? == 2 )) && continue || return }
  ask_empty_line       || { (( $? == 2 )) && continue || return }
  ask_confirm          || { (( $? == 2 )) && continue || return }
  ask_config_overwrite || { (( $? == 2 )) && continue || return }
  break
done

clear

print -P "Powerlevel10k configuration has been written to %B%2F$__p9k_cfg_path_u%f%b."
if [[ -n $config_backup ]]; then
  print -P "The backup of the previuos version is at %B%3F$config_backup%f%b."
fi

if (( write_config )); then
  generate_config || return
fi

write_zshrc || return

} "$@"
