#!/usr/bin/env zsh

emulate -L zsh
setopt extended_glob noaliases

readonly _p9k_root_dir=${1:-${0:h:h}}

source $_p9k_root_dir/internal/icons.zsh || return

readonly zd=${ZDOTDIR:-$HOME}
readonly zdu=${zd/#(#b)$HOME(|\/*)/'~'$match[1]}

POWERLEVEL9K_MODE=

function _p9k_clear() {
  if (( $+commands[clear] )); then
    clear
  elif zmodload zsh/termcap 2>/dev/null; then
    echotc cl
  else
    print -n "\e[H\e[J"
  fi
}

function _p9k_make_link() {
  echo $'%{\e]8;;'${1//\%/%%}$'\a%}'${1//\%/%%}$'%{\e]8;;\a%}'
}

function _p9k_ask_diamond() {
  while true; do
    _p9k_clear
    print -P "This is %B%4FPowerlevel10k configuration wizard%f%b. You are seeing it because"
    print -P "you haven't defined any Powerlevel10k configuration options. It will"
    print -P "ask you a few questions and configure your prompt."
    print -P ""
    print -P "   %BDoes this look like a %2Fdiamond%f (square rotated 45 degrees)?%b"
    print -P "       reference: $(_p9k_make_link https://graphemica.com/%E2%97%86)"
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
      q) _p9k_configure_quit; return 1;;
      y) typeset -gi _p9k_caps_diamond=1; break;;
      n) typeset -gi _p9k_caps_diamond=0; break;;
    esac
  done
}

function _p9k_ask_lock() {
  while true; do
    _p9k_clear
    print -P "      %BWhich of these icons looks like a %2Flock%f?%b"
    print -P "  reference: $(_p9k_make_link https://fontawesome.com/icons/lock)"
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
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      1|2) typeset -g _p9k_caps_lock=$key; break;;
      b) typeset -g _p9k_caps_lock=12; break;;
      n) typeset -g _p9k_caps_lock=; break;;
    esac
  done
}

function _p9k_ask_python() {
  while true; do
    _p9k_clear
    print -P "         %BDoes this look like a %2FPython logo%f?%b"
    print -P "  reference: $(_p9k_make_link https://fontawesome.com/icons/python)"
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
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      y) typeset -gi _p9k_caps_python=1; break;;
      n) typeset -gi _p9k_caps_python=0; break;;
    esac
  done
}

function _p9k_ask_icon_width() {
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) ]]; then
    typeset -gi _p9k_caps_narrow_icons=0
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
    _p9k_clear
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
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      y) typeset -gi _p9k_caps_narrow_icons=1; break;;
      n) typeset -gi _p9k_caps_narrow_icons=2; break;;
    esac
  done
}

function _p9k_configure_quit() {
  _p9k_clear
  print -P "Powerlevel10k configuration wizard will run again next time unless"
  print -P "you define at least one Powerlevel10k configuration option. To define"
  print -P "an option that does nothing except for disabling Powerlevel10k"
  print -P "configuration wizard, type the following command:"
  print -P ""
  print -P "  %2Fecho%f %3F'POWERLEVEL9K_MODE='%f %15F>>! $zdu/.zshrc%f"
  print -P ""
}

function _p9k_ask_style() {
  if (( ! _p9k_caps_diamond )); then
    typeset -g _p9k_style=lean
    return
  fi
  while true; do
    _p9k_clear
    print -P "            %BChoose your prompt style%b"
    print -P ""
    print -P "                    %B%3FLean%f%b"
    print -P ""
    print -P "         %B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2%f"
    print -P "         %76F❯%f █"
    print -P ""
    print -P "                  %B%3FClassic%f%b"
    print -P ""
    print -P "     %8F╭─%K{0} %B%39F~%b%K{0}%12F/%B%39Fpowerlevel10k%b%K{0} %244F\uE0B1 %76Fmaster ⇡2 %k%0F\uE0B0"
    print -P "     %8F╰─%f █"
    print -P ""
    print -P "(%B1%b)  %B%3FLean%f%b."
    print -P ""
    print -P "(%B2%b)  %B%4FClassic%f%b."
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [12rq]: " || return 1
    case $key in
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      1) typeset -g _p9k_style=lean; break;;
      2) typeset -g _p9k_style=classic; break;;
    esac
  done
}

function _p9k_ask_lines() {
  while true; do
    _p9k_clear
    print -P "             %BOne or two prompt lines?%b"
    print -P ""
    print -P "                    %BOne Line%b"
    print -P ""
    if [[ $_p9k_style == lean ]]; then
      print -P "         %B%39F~%b%12F/%B%39Fpowerlevel10k%b %76Fmaster ⇡2 %76F❯%f █"
    else
      print -P "       %K{0} %B%39F~%b%K{0}%12F/%B%39Fpowerlevel10k%b%K{0} %244F\uE0B1 %76Fmaster ⇡2 %k%0F\uE0B0%f █"
    fi
    print -P ""
    print -P "                    %BTwo Lines%b"
    print -P ""
    if [[ $_p9k_style == lean ]]; then
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
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      1|2) typeset -gi _p9k_lines=$key; break;;
    esac
  done
}

function _p9k_ask_overwrite() {
  typeset -g _p9k_config_backup
  if [[ ! -e $zd/.p10k.zsh ]]; then
    typeset -gi _p9k_overwrite=1
    return
  fi
  while true; do
    _p9k_clear
    print -P "      %BConfig already exists: %2F$zdu/.p10k.zsh%f%b"
    print -P ""
    print -P "(%Bw%b)  %B%2FOverwrite%f $zdu/.p10k.zsh%b with the new config."
    print -P ""
    print -P "(%Bk%b)  %B%2FKeep%f $zdu/.p10k.zsh%b and discard the new content."
    print -P ""
    print -P "%248F(r)  Restart from the beginning.%f"
    print -P ""
    print -P "%248F(q)  Quit and do nothing.%f"
    print -P ""

    local key=
    read -k key"?Choice [wkrq]: " || return 1
    case $key in
      q) _p9k_configure_quit; return 1;;
      r) return 2;;
      w)
        _p9k_config_backup=$(mktemp ${TMPDIR:-/tmp}/.p10k.zsh.XXXXXXXXXX) || return 1
        cp $zd/.p10k.zsh $_p9k_config_backup
        typeset -gi _p9k_overwrite=1
        break
        ;;
      k) typeset -gi _p9k_overwrite=0; break;;
    esac
  done
}

function _p9k_generate_config() {
  local -a cfg && cfg=("${(@f)$(< $_p9k_root_dir/config/p10k-$_p9k_style.zsh)}") || return
  cfg=("${(@)cfg/#  typeset -g POWERLEVEL9K_MODE=*/  typeset -g POWERLEVEL9K_MODE=$POWERLEVEL9K_MODE}")
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) && $_p9k_style == lean ]]; then
    local exp="''"
  elif (( _p9k_caps_narrow_icons )); then
    local exp="'\${P9K_VISUAL_IDENTIFIER// }'"
  else
    local exp="'\${P9K_VISUAL_IDENTIFIER}'"
  fi
  cfg=("${(@)cfg/#  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=*/  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=$exp}")
  if (( _p9k_lines == 1 )); then
    local -a tmp
    local line
    for line in "$cfg[@]"; do
      [[ $line == ('      newline'|*'===[ Line #'*) ]] || tmp+=$line
    done
    cfg=("$tmp[@]")
  fi
  print -lr -- "$cfg[@]" >$zd/.p10k.zsh
}

function _p9k_configure() {
  local zd=${ZDOTDIR:-$HOME}
  [[ -w $zd ]] || return 1
  [[ -t 0 && -t 1 ]] || return 1
  (( LINES > 20 && COLUMNS > 70 )) || return 1

  while true; do
    _p9k_ask_diamond || { (( $? == 2 )) && continue || return }
    if [[ -n $AWESOME_GLYPHS_LOADED ]]; then
      POWERLEVEL9K_MODE=awesome-mapped-fontconfig
    else
      _p9k_ask_lock || { (( $? == 2 )) && continue || return }
      if [[ $_p9k_caps_lock == 1 ]]; then
        (( _p9k_caps_diamond )) && POWERLEVEL9K_MODE=awesome-patched || POWERLEVEL9K_MODE=flat
      elif [[ -z $_p9k_caps_lock ]]; then
        (( _p9k_caps_diamond )) && POWERLEVEL9K_MODE=powerline || POWERLEVEL9K_MODE=compatible
      else
        _p9k_ask_python || { (( $? == 2 )) && continue || return }
        (( _p9k_caps_python )) && POWERLEVEL9K_MODE=awesome-fontconfig || POWERLEVEL9K_MODE=nerdfont-complete
      fi
    fi
    _p9k_init_icons
    _p9k_ask_icon_width || { (( $? == 2 )) && continue || return }
    _p9k_ask_style || { (( $? == 2 )) && continue || return }
    _p9k_ask_lines || { (( $? == 2 )) && continue || return }
    _p9k_ask_overwrite || { (( $? == 2 )) && continue || return }
    break
  done

  _p9k_clear

  if [[ -n $_p9k_config_backup ]]; then
    print -P "The previous version of your %B%2F$zdu/.p10k.zsh%f%b has been moved"
    print -P "to %B%2F$_p9k_config_backup%f%b."
  fi

  if (( _p9k_overwrite )); then
    _p9k_generate_config || return
  fi

  local comments=(
    "# Apply the personalized Powerlevel10k configuration."
    "# You can customize your prompt by editing this file."
    "# To run configuration wizard again, remove the next line."
  )

  print -lr -- "" $comments "source $zdu/.p10k.zsh" >>$zd/.zshrc

  print -P ""
  print -P "The following lines have been appended to your %B%2F$zdu/.zshrc%f%b:"
  print -P ""
  print -lP -- '  %8F'${^comments}'%f' "  %2Fsource%f %15F$zdu/.p10k.zsh%f"
}

_p9k_configure
