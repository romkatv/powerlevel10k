#!/usr/bin/env zsh

emulate -L zsh
setopt extended_glob noaliases

() {
typeset -gr __p9k_installation_dir=${1:-${0:h:h:A}}
source $__p9k_installation_dir/internal/configure.zsh || return

local POWERLEVEL9K_MODE cap_lock style config_backup
local -i cap_diamond cap_python cap_narrow_icons num_lines config_overwrite

function clear() {
  if (( $+commands[clear] )); then
    command clear
  elif zmodload zsh/termcap 2>/dev/null; then
    echotc cl
  else
    print -n "\e[H\e[J"
  fi
}

function href() {
  echo $'%{\e]8;;'${1//\%/%%}$'\a%}'${1//\%/%%}$'%{\e]8;;\a%}'
}

function ask_diamond() {
  while true; do
    clear
    print -P "This is %B%4FPowerlevel10k configuration wizard%f%b. You are seeing it because"
    print -P "you haven't defined any Powerlevel10k configuration options. It will"
    print -P "ask you a few questions and configure your prompt."
    print -P ""
    print -P "   %BDoes this look like a %2Fdiamond%f (square rotated 45 degrees)?%b"
    print -P "       reference: $(href https://graphemica.com/%E2%97%86)"
    print -P ""
    print -P "                   --->  %B\uE0B2\uE0B0%b  <---"
    print -P ""
    print -P "(%By%b)  Yes."
    print -P ""
    print -P "(%Bn%b)  No."
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
    print -P "      %BWhich of these icons looks like a %2Flock%f?%b"
    print -P "  reference: $(href https://fontawesome.com/icons/lock)"
    print -P ""
    print -P "                 Icon #1"
    print -P ""
    print -P "             --->  %B%3F\uE138%f%b  <---"
    print -P ""
    print -P "                 Icon #2"
    print -P ""
    print -P "             --->  %B%4F\uF023%f%b  <---"
    print -P ""
    print -P "(%B1%b)  Only icon #1 ( %B%3F\uE138%f%b )."
    print -P ""
    print -P "(%B2%b)  Only icon #2 ( %B%4F\uF023%f%b )."
    print -P ""
    print -P "(%Bn%b)  Neither."
    print -P ""
    print -P "(%Bb%b)  Both."
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12nbrq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      1|2) cap_lock=$key; break;;
      b) cap_lock=12; break;;
      n) cap_lock=; break;;
    esac
  done
}

function ask_python() {
  while true; do
    clear
    print -P "         %BDoes this look like a %2FPython logo%f?%b"
    print -P "  reference: $(href https://fontawesome.com/icons/python)"
    print -P ""
    print -P "                  --->  %B\uE63C%b  <---"
    print -P ""
    print -P "(%By%b)  Yes."
    print -P ""
    print -P "(%Bn%b)  No."
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
  text+="X%1F${icons[VCS_GIT_ICON]// }%fX"
  text+="%2F${icons[VCS_GIT_GITHUB_ICON]// }%fX"
  text+="%3F${icons[DATE_ICON]// }%fX"
  text+="%4F${icons[TIME_ICON]// }%fX"
  text+="%5F${icons[RUBY_ICON]// }%fX"
  text+="%6F${icons[AWS_EB_ICON]// }%fX"
  while true; do
    clear
    print -P "      %BDo all these icons %2Ffit between the crosses%f?%b"
    print -P ""
    print -P "                  --->  %B$text%b  <---"
    print -P ""
    print -P "(%By%b)  Yes. Icons are very close to the crosses but there is %B%2Fno overlap%f%b."
    print -P ""
    print -P "(%Bn%b)  No. Some icons %B%2Foverlap%f%b neighbouring crosses."
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

function quit() {
  clear
  print -P "Powerlevel10k configuration wizard will run again next time unless"
  print -P "you define at least one Powerlevel10k configuration option. To define"
  print -P "an option that does nothing except for disabling Powerlevel10k"
  print -P "configuration wizard, type the following command:"
  print -P ""
  print -P "  %2Fecho%f %3F'POWERLEVEL9K_MODE='%f %15F>>! $__p9k_zd_u/.zshrc%f"
  print -P ""
}

function ask_style() {
  if (( ! cap_diamond )); then
    style=lean
    return
  fi
  while true; do
    clear
    print -P "            %BChoose your prompt style%b"
    print -P ""
    print -P "                    %BLean%b"
    print -P ""
    print -P "         %B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2%f"
    print -P "         %76F❯%f █"
    print -P ""
    print -P "                  %BClassic%b"
    print -P ""
    print -P "     %8F╭─%K{0} %B%39F~%b%K{0}%12F/%B%39Fpowerlevel10k%b%K{0} %244F\uE0B1 %76Fmaster ⇡2 %k%0F\uE0B0"
    print -P "     %8F╰─%f █"
    print -P ""
    print -P "(%B1%b)  Lean."
    print -P ""
    print -P "(%B2%b)  Classic."
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

function ask_num_lines() {
  while true; do
    clear
    print -P "             %BOne or two prompt lines?%b"
    print -P ""
    print -P "                    %BOne Line%b"
    print -P ""
    if [[ $style == lean ]]; then
      print -P "         %B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2 %76F❯%f █"
    else
      print -P "       %K{0} %B%39F~%b%K{0}%12F/%B%39Fpowerlevel10k%b%K{0} %244F\uE0B1 %76Fmaster ⇡2 %k%0F\uE0B0%f █"
    fi
    print -P ""
    print -P "                   %BTwo Lines%b"
    print -P ""
    if [[ $style == lean ]]; then
      print -P "         %B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2%f"
      print -P "         %76F❯%f █"
    else
      print -P "     %8F╭─%K{0} %B%39F~%b%K{0}%12F/%B%39Fpowerlevel10k%b%K{0} %244F\uE0B1 %76Fmaster ⇡2 %k%0F\uE0B0"
      print -P "     %8F╰─%f █"
    fi
    print -P ""
    print -P "(%B1%b)  %BOne Line%b."
    print -P ""
    print -P "(%B2%b)  %BTwo lines%b."
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

function ask_config_overwrite() {
  config_backup=
  if [[ ! -e $__p9k_cfg_path ]]; then
    config_overwrite=1
    return
  fi
  while true; do
    clear
    print -P "      %BConfig already exists: $__p9k_cfg_path_u%b"
    print -P ""
    print -P "(%Bw%b)  %B%1FOverwrite%f $__p9k_cfg_path_u%b with the new config."
    print -P ""
    print -P "(%Bk%b)  %B%2FKeep%f $__p9k_cfg_path_u%b and discard the new content."
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [wkrq]: " || return 1
    case $key in
      q) quit; return 1;;
      r) return 2;;
      w)
        config_backup="$(mktemp ${TMPDIR:-/tmp}/$__p9k_cfg_basename.XXXXXXXXXX)" || return 1
        cp $__p9k_cfg_path $config_backup
        config_overwrite=1
        break
        ;;
      k) config_overwrite=0; break;;
    esac
  done
}

function generate_config() {
  local base && base="$(<$__p9k_installation_dir/config/p10k-$style.zsh)" || return
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

_p9k_can_configure || return
source $__p9k_installation_dir/internal/icons.zsh || return

while true; do
  ask_diamond || { (( $? == 2 )) && continue || return }
  if [[ -n $AWESOME_GLYPHS_LOADED ]]; then
    POWERLEVEL9K_MODE=awesome-mapped-fontconfig
  else
    ask_lock || { (( $? == 2 )) && continue || return }
    if [[ $cap_lock == 1 ]]; then
      (( cap_diamond )) && POWERLEVEL9K_MODE=awesome-patched || POWERLEVEL9K_MODE=flat
    elif [[ -z $cap_lock ]]; then
      (( cap_diamond )) && POWERLEVEL9K_MODE=powerline || POWERLEVEL9K_MODE=compatible
    else
      ask_python || { (( $? == 2 )) && continue || return }
      (( cap_python )) && POWERLEVEL9K_MODE=awesome-fontconfig || POWERLEVEL9K_MODE=nerdfont-complete
    fi
  fi
  _p9k_init_icons
  ask_narrow_icons || { (( $? == 2 )) && continue || return }
  ask_style || { (( $? == 2 )) && continue || return }
  ask_num_lines || { (( $? == 2 )) && continue || return }
  ask_config_overwrite || { (( $? == 2 )) && continue || return }
  break
done

clear

if [[ -n $config_backup ]]; then
  print -P "The previous version of your %B%2F$__p9k_cfg_path_u%f%b has been moved"
  print -P "to %B%2F$config_backup%f%b."
fi

if (( config_overwrite )); then
  generate_config || return
fi

local comments=(
  "# Apply the personalized Powerlevel10k configuration."
  "# You can customize your prompt by editing this file."
  "# To run configuration wizard again, remove the next line."
)

print -lr -- "" $comments "source $__p9k_cfg_path_u" >>$__p9k_zd/.zshrc

print -P ""
print -P "The following lines have been appended to your %B%2F$__p9k_zd_u/.zshrc%f%b:"
print -P ""
print -lP -- '  %8F'${^comments}'%f' "  %2Fsource%f %15F$__p9k_cfg_path_u%f"

} "$@"
