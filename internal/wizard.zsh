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
  if [[ $1 == (powerline|compatible) ]]; then
    typeset -gi _p9k_caps_narrow_icons=0
    return
  fi
  local text=$(
    POWERLEVEL9K_MODE=$1
    _p9k_init_icons
    echo -n "X%1F${icons[VCS_GIT_ICON]// }%fX"
    echo -n "%2F${icons[VCS_GIT_GITHUB_ICON]// }%fX"
    echo -n "%3F${icons[DATE_ICON]// }%fX"
    echo -n "%4F${icons[TIME_ICON]// }%fX"
    echo -n "%5F${icons[RUBY_ICON]// }%fX"
    echo -n "%6F${icons[AWS_EB_ICON]// }%fX"
  )
  while true; do
    _p9k_clear
    print -P "      %BDo all these icons %2Ffit between the crosses%f?"
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
  print -P "  %2Fecho%f %3F'POWERLEVEL9K_MODE='%f %15F>>! ${ZDOTDIR:-~}/.zshrc%f"
  print -P ""
}

function _p9k_configure() {
  emulate -L zsh && setopt no_hist_expand extended_glob

  local zd=${ZDOTDIR:-$HOME}
  [[ -w $zd ]] || return 1
  [[ -t 0 && -t 1 ]] || return 1
  (( LINES > 20 && COLUMNS > 70 )) || return 1

  while true; do
    _p9k_ask_diamond || { (( $? == 2 )) && continue || return }
    local mode
    if [[ -n $AWESOME_GLYPHS_LOADED ]]; then
      mode=awesome-mapped-fontconfig
    else
      _p9k_ask_lock || { (( $? == 2 )) && continue || return }
      if [[ $_p9k_caps_lock == 1 ]]; then
        (( _p9k_caps_diamond )) && mode=awesome-patched || mode=flat
      elif [[ -z $_p9k_caps_lock ]]; then
        (( _p9k_caps_diamond )) && mode=powerline || mode=compatible
      else
        _p9k_ask_python || { (( $? == 2 )) && continue || return }
        (( _p9k_caps_python )) && mode=awesome-fontconfig || mode=nerdfont-complete
      fi
    fi
    _p9k_ask_icon_width $mode || { (( $? == 2 )) && continue || return }
    break
  done
  _p9k_clear

  typeset -p mode _p9k_caps_diamond _p9k_caps_narrow_icons
}

_p9k_configure
