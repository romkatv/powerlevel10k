#!/usr/bin/env zsh

emulate -L zsh
setopt noaliases

() {
setopt extended_glob no_prompt_{bang,subst} prompt_percent typeset_silent
zmodload zsh/langinfo
if [[ ${langinfo[CODESET]:-} != (utf|UTF)(-|)8 ]]; then
  local LC_ALL=${${(@M)$(locale -a):#*.(utf|UTF)(-|)8}[1]:-en_US.UTF-8}
fi

typeset -g __p9k_root_dir
typeset -gi force=0

local opt
while getopts 'd:f' opt; do
  case $opt in
    d)  __p9k_root_dir=$OPTARG;;
    f)  force=1;;
    +f) force=0;;
    \?) return 1;;
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

typeset -r font_base_url='https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts'
typeset -ri wizard_columns=$((COLUMNS < 80 ? COLUMNS : 80))

typeset -ri prompt_indent=2

typeset -ra bg_color=(240 238 236 234)
typeset -ra frame_color=(244 242 240 238)
typeset -ra sep_color=(248 246 244 242)
typeset -ra prefix_color=(250 248 246 244)

typeset -r left_circle='\uE0B6'
typeset -r right_circle='\uE0B4'
typeset -r left_arc='\uE0B7'
typeset -r right_arc='\uE0B5'
typeset -r left_triangle='\uE0B2'
typeset -r right_triangle='\uE0B0'
typeset -r left_angle='\uE0B3'
typeset -r right_angle='\uE0B1'
typeset -r down_triangle='\uE0BC'
typeset -r up_triangle='\uE0BA'
typeset -r fade_in='░▒▓'
typeset -r fade_out='▓▒░'
typeset -r vertical_bar='|'
typeset -r slanted_bar='\uE0BD'

typeset -ra lean_left=(
  '' '${extra_icons[1]:+$extra_icons[1] }%31F$extra_icons[2]%B%39F~%b%31F/%B%39Fsrc%b%f $prefixes[1]%76F$extra_icons[3]master%f '
  '' '%76F❯%f █'
)

typeset -ra lean_right=(
  ' $prefixes[2]%101F$extra_icons[4]3s%f${show_time:+ $prefixes[3]%66F$extra_icons[5]16:23:42%f}' ''
  '' ''
)

typeset -ra classic_left=(
  '%$frame_color[$color]F╭─' '%F{$bg_color[$color]}$left_tail%K{$bg_color[$color]} ${extra_icons[1]:+$extra_icons[1]%K{$bg_color[$color]\} %$sep_color[$color]F$left_subsep%f }%31F$extra_icons[2]%B%39F~%b%K{$bg_color[$color]}%31F/%B%39Fsrc%b%K{$bg_color[$color]} %$sep_color[$color]F$left_subsep%f %$prefix_color[$color]F$prefixes[1]%76F$extra_icons[3]master %k%$bg_color[$color]F$left_head%f'
  '%$frame_color[$color]F╰─' '%f █'
)

typeset -ra classic_right=(
  '%$bg_color[$color]F$right_head%K{$bg_color[$color]}%f %$prefix_color[$color]F$prefixes[2]%101F3s $extra_icons[4]${show_time:+%$sep_color[$color]F$right_subsep %$prefix_color[$color]F$prefixes[3]%66F16:23:42 $extra_icons[5]}%k%F{$bg_color[$color]}$right_tail%f' '%$frame_color[$color]F─╮%f'
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
    (( left_frame )) || left=('' $left[2] '' '%76F❯%f █')
    (( right_frame )) || right=($right[1] '' '' '')
  fi
  local -i right_indent=prompt_indent
  local -i width=$(prompt_length ${(g::):-$left[1]$left[2]$right[1]$right[2]})
  while (( wizard_columns - width <= prompt_indent + right_indent )); do
    (( --right_indent ))
  done
  local -i i
  for ((i = 1; i < $#left; i+=2)); do
    local l=${(g::):-$left[i]$left[i+1]}
    local r=${(g::):-$right[i]$right[i+1]}
    local -i gap=$((wizard_columns - prompt_indent - right_indent - $(prompt_length $l$r)))
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

function flowing() {
  local opt
  local -i centered indentation
  while getopts 'ci:' opt; do
    case $opt in
      i)  indentation=$OPTARG;;
      c)  centered=1;;
      +c) centered=0;;
      \?) exit 1;;
    esac
  done
  shift $((OPTIND-1))
  local line word lines=()
  for word in "$@"; do
    local n=$(prompt_length ${(g::):-"$line $word"})
    if (( n > wizard_columns )); then
      [[ -z $line ]] || lines+=$line
      line=
    fi
    if [[ -n $line ]]; then
      line+=' '
    elif (( $#lines )); then
      line=${(pl:$indentation:: :)}
    fi
    line+=$word
  done
  [[ -z $line ]] || lines+=$line
  for line in $lines; do
    local n=$(prompt_length ${(g::)line})
    (( centered && n < wizard_columns )) && print -n -- ${(pl:$(((wizard_columns - n) / 2)):: :)}
    print -P -- $line
  done
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
  if [[ $1 == '-c' ]]; then
    print -P ""
  else
    clear
  fi
  if (( force )); then
    print -P "Powerlevel10k configuration wizard has been aborted. To run it again, type:"
    print -P ""
    print -P "  %2Fp10k%f %Bconfigure%b"
    print -P ""
  else
    print -P "Powerlevel10k configuration wizard has been aborted. It will run again"
    print -P "next time unless you define at least one Powerlevel10k configuration option."
    print -P "To define an option that does nothing except for disabling Powerlevel10k"
    print -P "configuration wizard, type the following command:"
    print -P ""
    print -P "  %2Fecho%f %3F'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true'%f >>! $__p9k_zshrc_u"
    print -P ""
    print -P "To run Powerlevel10k configuration wizard right now, type:"
    print -P ""
    print -P "  %2Fp10k%f %Bconfigure%b"
    print -P ""
  fi
  exit 1
}

local -i greeting_printed=0

function print_greeting() {
  (( greeting_printed )) && return
  if (( force )); then
    flowing -c This is %4FPowerlevel10k configuration wizard%f. \
               It will ask you a few questions and configure your prompt.
  else
    flowing -c This is %4FPowerlevel10k configuration wizard%f.   \
               You are seeing it because you haven\'t defined any \
               Powerlevel10k configuration options. It will ask   \
               you a few questions and configure your prompt.
  fi
  print -P ""
}

function iterm_get() {
  /usr/libexec/PlistBuddy -c "Print :$1" ~/Library/Preferences/com.googlecode.iterm2.plist
}

local terminal iterm2_font_size

function can_install_font() {
  [[ $P9K_SSH == 0 ]] || return
  if [[ "$(uname)" == Linux && "$(uname -o)" == Android ]]; then
    (( $+commands[termux-reload-settings] )) || return
    (( $+commands[curl] )) || return
    if [[ -f ~/.termux/font.ttf ]]; then
      [[ -r ~/.termux/font.ttf ]] || return
      [[ -w ~/.termux/font.ttf ]] || return
      ! grep -q 'MesloLGS NF' ~/.termux/font.ttf 2>/dev/null || return
    fi
    if [[ -f ~/.termux ]]; then
      [[ -d ~/.termux && -w ~/.termux ]] || return
    else
      [[ -w ~ ]] || return
    fi
    terminal=Termux
    return
  fi
  if [[ "$(uname)" == Darwin && $TERM_PROGRAM == iTerm.app ]]; then
    (( $+commands[curl] )) || return
    [[ $TERM_PROGRAM_VERSION == [2-9]* ]] || return
    if [[ -f ~/Library/Fonts ]]; then
      [[ -d ~/Library/Fonts && -w ~/Library/Fonts ]] || return
    else
      [[ -d ~/Library && -w ~/Library ]] || return
    fi
    [[ -x /usr/libexec/PlistBuddy ]] || return
    [[ -x /usr/bin/plutil ]] || return
    [[ -x /usr/bin/defaults ]] || return
    [[ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    [[ -r ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    [[ -w ~/Library/Preferences/com.googlecode.iterm2.plist ]] || return
    local guid1 && guid1="$(iterm_get '"Default Bookmark Guid"' 2>/dev/null)" || return
    local guid2 && guid2="$(iterm_get '"New Bookmarks":0:"Guid"' 2>/dev/null)" || return
    local font && font="$(iterm_get '"New Bookmarks":0:"Normal Font"' 2>/dev/null)" || return
    [[ $guid1 == $guid2 ]] || return
    [[ $font != 'MesloLGSNer-Regular '<-> ]] || return
    [[ $font == (#b)*' '(<->) ]] || return
    iterm2_font_size=$match[1]
    terminal=iTerm2
    return
  fi
  return 1
}

function run_command() {
  local msg=$1
  shift
  [[ -n $msg ]] && print -nP -- "$msg ..."
  local err && err="$("$@" 2>&1)" || {
    print -P " %1FERROR%f"
    print -P ""
    print -nP "%BCommand:%b "
    print -r -- "${(@q)*}"
    if [[ -n $err ]]; then
      print -P ""
      print -r -- $err
    fi
    quit -c
  }
  [[ -n $msg ]] && print -P " %2FOK%f"
}

function install_font() {
  clear
  case $terminal in
    Termux)
      mkdir -p ~/.termux || quit -c
      run_command "Downloading %BMesloLGS NF Regular.ttf%b" \
        curl -fsSL -o ~/.termux/font.ttf "$font_base_url/MesloLGS%20NF%20Regular.ttf"
      run_command "Reloading %BTermux%b settings" termux-reload-settings
    ;;
    iTerm2)
      mkdir -p ~/Library/Fonts || quit -c
      local style
      for style in Regular Bold Italic 'Bold Italic'; do
        local file="MesloLGS NF ${style}.ttf"
        run_command "Downloading %B$file%b" \
          curl -fsSL -o ~/Library/Fonts/$file "$font_base_url/${file// /%20}"
      done
      print -nP -- "Changing %BiTerm2%b settings ..."
      local k v settings=(
        '"Normal Font"' '"MesloLGSNer-Regular '$iterm2_font_size'"'
        '"Horizontal Spacing"' 1
        '"Vertical Spacing"' 1
        '"Use Bold Font"' 1
        '"Use Bright Bold"' 1
        '"Use Italic Font"' 1
        '"Use Non-ASCII Font"' 0
        '"Ambiguous Double Width"' 0
        '"Terminal Type"' '"xterm-256color"'
      )
      for k v in $settings; do
        run_command "" /usr/libexec/PlistBuddy -c \
          "Set :\"New Bookmarks\":0:$k $v" ~/Library/Preferences/com.googlecode.iterm2.plist
      done
      print -P " %2FOK%f"
      run_command "Updating %BiTerm2%b settings cache" /usr/bin/defaults read com.googlecode.iterm2
      clear
      print -P "%2FMeslo Nerd Font%f successfully installed."
      print -P ""
      print -P "Please %Brestart iTerm2%b for the changes to take effect."
      print -P ""
      flowing +c -i 5 "  1. Click" "%BiTerm2 → Quit iTerm2%b" or press "%B⌘ Q%b."
      flowing +c -i 5 "  2. Open %BiTerm2%b."
      print -P ""
      exit 69
    ;;
  esac
}

function ask_font() {
  can_install_font || return 0
  while true; do
    clear
    print_greeting
    flowing -c "%BInstall %b%2FMeslo Nerd Font%f%B?%b"
    print -P ""
    print -P ""
    print -P "%B(y)  Yes (recommended).%b"
    print -P ""
    print -P "%B(n)  No. Use the current font.%b"
    print -P ""
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynq]: %b"} || quit -c
    case $key in
      q) quit;;
      y) install_font; break;;
      n) break;;
    esac
  done
  greeting_printed=1
}

function ask_diamond() {
  while true; do
    local extra=
    clear
    print_greeting
    flowing -c "%BDoes this look like a %b%2Fdiamond%f%B (rotated square)?%b"
    flowing -c "reference: $(href https://graphemica.com/%E2%97%86)"
    print -P ""
    flowing -c -- "--->  \uE0B2\uE0B0  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    if can_install_font; then
      extra+=r
      print -P "(r)  Restart from the beginning."
    fi
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yn${extra}q]: %b"} || quit -c
    case $key in
      q) quit;;
      r) [[ $extra == *r* ]] && { greeting_printed=1; return 1 };;
      y) cap_diamond=1; break;;
      n) cap_diamond=0; break;;
    esac
  done
  greeting_printed=1
}

function ask_lock() {
  while true; do
    clear
    [[ -n $2 ]] && flowing -c "$2"
    flowing -c "%BDoes this look like a %b%2Flock%f%B?%b"
    flowing -c "reference: $(href https://fontawesome.com/icons/lock)"
    print -P ""
    flowing -c -- "--->  $1  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_lock=1; break;;
      n) cap_lock=0; break;;
    esac
  done
}

function ask_python() {
  while true; do
    clear
    flowing -c "%BDoes this look like a %b%2FPython logo%f%B?%b"
    flowing -c "reference: $(href https://fontawesome.com/icons/python)"
    print -P ""
    flowing -c -- "--->  \uE63C  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_python=1; break;;
      n) cap_python=0; break;;
    esac
  done
}

function ask_debian() {
  while true; do
    clear
    flowing -c "%BDoes this look like a %b%2FDebian logo%f%B (swirl/spiral)?%b"
    flowing -c "reference: $(href https://debian.org/logos/openlogo-nd.svg)"
    print -P ""
    flowing -c -- "--->  \uF306  <---"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_debian=1; break;;
      n) cap_debian=0; break;;
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
  text+="%6F${icons[HOME_ICON]// }%fX"
  text+="%1F${icons[HOME_SUB_ICON]// }%fX"
  text+="%2F${icons[FOLDER_ICON]// }%fX"
  text+="%3F${icons[RAM_ICON]// }%fX"
  while true; do
    clear
    flowing -c "%BDo all these icons %b%2Ffit between the crosses%f%B?%b"
    print -P ""
    flowing -c -- "--->  $text  <---"
    print -P ""
    flowing +c -i 5 "%B(y)  Yes." Icons are very close to the crosses but there is "%b%2Fno overlap%f%B.%b"
    print -P ""
    print -P "%B(n)  No. Some icons %b%2Foverlap%f%B neighbouring crosses.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) cap_narrow_icons=1; options+='small icons'; break;;
      n) cap_narrow_icons=0; options+='large icons'; break;;
    esac
  done
}

function ask_style() {
  while true; do
    clear
    flowing -c "%BPrompt Style%b"
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
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) style=lean; options+=lean; break;;
      2) style=classic; options+=classic; break;;
    esac
  done
}

function ask_color() {
  [[ $style != classic ]] && return
  if [[ $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    clear
    flowing -c "%BPrompt Color%b"
    print -n $nl
    print -P "%B(1)  Lightest.%b"
    print -n $nl
    color=1 print_prompt
    print -P ""
    print -P "%B(2)  Light.%b"
    print -n $nl
    color=2 print_prompt
    print -P ""
    print -P "%B(3)  Dark.%b"
    print -n $nl
    color=3 print_prompt
    print -P ""
    print -P "%B(4)  Darkest.%b"
    print -n $nl
    color=4 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [1234rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) color=1; options+=lightest; break;;
      2) color=2; options+=light; break;;
      3) color=3; options+=dark; break;;
      4) color=4; options+=darkest; break;;
    esac
  done
}

function ask_time() {
  if (( wizard_columns < 80 )); then
    show_time=
    return
  fi

  while true; do
    clear
    flowing -c "%BShow current time?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    show_time=1 print_prompt
    print -P ""
    print -P "%B(n)  No.%b"
    print -P ""
    show_time= print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [ynrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y) show_time=1; options+=time; break;;
      n) show_time=; break;;
    esac
  done
}

function os_icon_name() {
  local uname="$(uname)"
  if [[ $uname == Linux && "$(uname -o 2>/dev/null)" == Android ]]; then
    echo ANDROID_ICON
  else
    case $uname in
      SunOS)                     echo SUNOS_ICON;;
      Darwin)                    echo APPLE_ICON;;
      CYGWIN_NT-* | MSYS_NT-*)   echo WINDOWS_ICON;;
      FreeBSD|OpenBSD|DragonFly) echo FREEBSD_ICON;;
      Linux)
        local os_release_id
        if [[ -r /etc/os-release ]]; then
          local lines=(${(f)"$(</etc/os-release)"})
          lines=(${(@M)lines:#ID=*})
          (( $#lines == 1 )) && os_release_id=${lines[1]#ID=}
        fi
        case $os_release_id in
          *arch*)                  echo LINUX_ARCH_ICON;;
          *debian*)                echo LINUX_DEBIAN_ICON;;
          *raspbian*)              echo LINUX_RASPBIAN_ICON;;
          *ubuntu*)                echo LINUX_UBUNTU_ICON;;
          *elementary*)            echo LINUX_ELEMENTARY_ICON;;
          *fedora*)                echo LINUX_FEDORA_ICON;;
          *coreos*)                echo LINUX_COREOS_ICON;;
          *gentoo*)                echo LINUX_GENTOO_ICON;;
          *mageia*)                echo LINUX_MAGEIA_ICON;;
          *centos*)                echo LINUX_CENTOS_ICON;;
          *opensuse*|*tumbleweed*) echo LINUX_OPENSUSE_ICON;;
          *sabayon*)               echo LINUX_SABAYON_ICON;;
          *slackware*)             echo LINUX_SLACKWARE_ICON;;
          *linuxmint*)             echo LINUX_MINT_ICON;;
          *alpine*)                echo LINUX_ALPINE_ICON;;
          *aosc*)                  echo LINUX_AOSC_ICON;;
          *nixos*)                 echo LINUX_NIXOS_ICON;;
          *devuan*)                echo LINUX_DEVUAN_ICON;;
          *manjaro*)               echo LINUX_MANJARO_ICON;;
          *)                       echo LINUX_ICON;;
        esac
        ;;
    esac
  fi
}

function ask_extra_icons() {
  if [[ $POWERLEVEL9K_MODE == (powerline|compatible) ]]; then
    return
  fi
  local os_icon=${(g::)icons[$(os_icon_name)]}
  local dir_icon=${(g::)icons[HOME_SUB_ICON]}
  local vcs_icon=${(g::)icons[VCS_GIT_GITHUB_ICON]}
  local branch_icon=${(g::)icons[VCS_BRANCH_ICON]}
  local duration_icon=${(g::)icons[EXECUTION_TIME_ICON]}
  local time_icon=${(g::)icons[TIME_ICON]}
  if (( cap_narrow_icons )); then
    os_icon=${os_icon// }
    dir_icon=${dir_icon// }
    vcs_icon=${vcs_icon// }
    duration_icon=${duration_icon// }
    time_icon=${time_icon// }
  fi
  branch_icon=${branch_icon// }
  if [[ $style == classic ]]; then
    os_icon="%255F$os_icon%f"
  else
    os_icon="%f$os_icon"
  fi
  os_icon="%B$os_icon%b"
  local few=('' '' '' '' '')
  local many=("$os_icon" "$dir_icon " "$vcs_icon $branch_icon " "$duration_icon " "$time_icon ")
  while true; do
    clear
    flowing -c "%BIcons%b"
    print -P ""
    print -P "%B(1)  Few icons.%b"
    print -P ""
    extra_icons=("$few[@]") print_prompt
    print -P ""
    print -P "%B(2)  Many icons.%b"
    print -P ""
    extra_icons=("$many[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) extra_icons=("$few[@]"); options+='few icons'; break;;
      2) extra_icons=("$many[@]"); options+='many icons'; break;;
    esac
  done
}

function ask_prefixes() {
  local concise=('' '' '')
  local fluent=('on ' 'took ' 'at ')
  if (( wizard_columns < 80 )); then
    prefixes=("$concise[@]")
    options+=concise
    return
  fi
  while true; do
    clear
    flowing -c "%BPrompt Flow%b"
    print -P ""
    print -P "%B(1)  Concise.%b"
    print -P ""
    prefixes=("$concise[@]") print_prompt
    print -P ""
    print -P "%B(2)  Fluent.%b"
    print -P ""
    prefixes=("$fluent[@]") print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) prefixes=("$concise[@]"); options+=concise; break;;
      2) prefixes=("$fluent[@]"); options+=fluent; break;;
    esac
  done
}

function ask_separators() {
  if [[ $style != classic || $cap_diamond != 1 ]]; then
    return
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Separators%b"
    if [[ -n $nl ]]; then
      print -P "              separator"
      print -P "%B(1)  Angled.%b /"
      print -P "            /"
    else
      print -P "%B(1)  Angled.%b"
    fi
    left_sep=$right_triangle right_sep=$left_triangle left_subsep=$right_angle right_subsep=$left_angle print_prompt
    print -P ""
    print -P "%B(2)  Vertical.%b"
    print -n $nl
    left_sep='' right_sep='' left_subsep=$vertical_bar right_subsep=$vertical_bar print_prompt
    print -P ""
    if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
      extra+=3
      print -P "%B(3)  Slanted.%b"
      print -n $nl
      left_sep=$down_triangle right_sep=$up_triangle left_subsep=$slanted_bar right_subsep=$slanted_bar print_prompt
      print -P ""
      extra+=4
      print -P "%B(4)  Round.%b"
      print -n $nl
      left_sep=$right_circle right_sep=$left_circle left_subsep=$right_arc right_subsep=$left_arc print_prompt
      print -P ""
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1)
        left_sep=$right_triangle
        right_sep=$left_triangle
        left_subsep=$right_angle
        right_subsep=$left_angle
        options+='angled separators'
        break
        ;;
      2)
        left_sep=''
        right_sep=''
        left_subsep=$vertical_bar
        right_subsep=$vertical_bar
        options+='vertical separators'
        break
        ;;
      3)
        if [[ $extra == *3* ]]; then
          left_sep=$down_triangle
          right_sep=$up_triangle
          left_subsep=$slanted_bar
          right_subsep=$slanted_bar
          options+='slanted separators'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_sep=$right_circle
          right_sep=$left_circle
          left_subsep=$right_arc
          right_subsep=$left_arc
          options+='round separators'
          break
        fi
        ;;
    esac
  done
}

function ask_heads() {
  if [[ $style != classic || $cap_diamond != 1 ]]; then
    return
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 26 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Heads%b"
    if [[ -n $nl ]]; then
      print -P "                   head"
      print -P "%B(1)  Sharp.%b         |"
      print -P "                    v"
    else
      print -P "%B(1)  Sharp.%b"
    fi
    left_head=$right_triangle right_head=$left_triangle print_prompt
    print -P ""
    print -P "%B(2)  Blurred.%b"
    print -n $nl
    left_head=$fade_out right_head=$fade_in print_prompt
    print -P ""
    if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
      extra+=3
      print -P "%B(3)  Slanted.%b"
      print -n $nl
      left_head=$down_triangle right_head=$up_triangle print_prompt
      print -P ""
      extra+=4
      print -P "%B(4)  Round.%b"
      print -n $nl
      left_head=$right_circle right_head=$left_circle print_prompt
      print -P ""
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) left_head=$right_triangle; right_head=$left_triangle; options+='sharp heads';   break;;
      2) left_head=$fade_out;       right_head=$fade_in;       options+='blurred heads'; break;;
      3)
        if [[ $extra == *3* ]]; then
          left_head=$down_triangle
          right_head=$up_triangle
          options+='slanted heads'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_head=$right_circle
          right_head=$left_circle
          options+='round heads'
          break
        fi
        ;;
    esac
  done
}

function ask_tails() {
  if [[ $style != classic ]]; then
    return
  fi
  if [[ $POWERLEVEL9K_MODE == nerdfont-complete && $LINES -lt 31 ]]; then
    local nl=''
  else
    local nl=$'\n'
  fi
  while true; do
    local extra=
    clear
    flowing -c "%BPrompt Tails%b"
    print -n $nl
    print -P "%B(1)  Flat.%b"
    print -n $nl
    left_tail='' right_tail='' print_prompt
    print -P ""
    print -P "%B(2)  Blurred.%b"
    print -n $nl
    left_tail=$fade_in right_tail=$fade_out print_prompt
    print -P ""
    if (( cap_diamond )); then
      extra+=3
      print -P "%B(3)  Sharp.%b"
      print -n $nl
      left_tail=$left_triangle right_tail=$right_triangle print_prompt
      print -P ""
      if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
        extra+=4
        print -P "%B(4)  Slanted.%b"
        print -n $nl
        left_tail=$up_triangle right_tail=$down_triangle print_prompt
        print -P ""
        if (( LINES >= 25 )); then
          extra+=5
          print -P "%B(5)  Round.%b"
          print -n $nl
          left_tail=$left_circle right_tail=$right_circle print_prompt
          print -P ""
        fi
      fi
    fi
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12${extra}rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) left_tail='';       right_tail='';        options+='flat tails';    break;;
      2) left_tail=$fade_in; right_tail=$fade_out; options+='blurred tails'; break;;
      3)
        if [[ $extra == *3* ]]; then
          left_tail=$left_triangle
          right_tail=$right_triangle
          options+='sharp tails'
          break
        fi
        ;;
      4)
        if [[ $extra == *4* ]]; then
          left_tail=$up_triangle
          right_tail=$down_triangle
          options+='slanted tails'
          break
        fi
        ;;
      5)
        if [[ $extra == *5* ]]; then
          left_tail=$left_circle
          right_tail=$right_circle
          options+='round tails'
          break
        fi
        ;;
    esac
  done
}

function ask_num_lines() {
  while true; do
    clear
    flowing -c "%BPrompt Height%b"
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
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) num_lines=1; options+='1 line'; break;;
      2) num_lines=2; options+='2 lines'; break;;
    esac
  done
}

function ask_gap_char() {
  if [[ $num_lines != 2 ]]; then
    return
  fi
  while true; do
    clear
    flowing -c "%BPrompt Connection%b"
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
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [123rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) gap_char=" "; options+=disconnected; break;;
      2) gap_char="·"; options+=dotted; break;;
      3) gap_char="─"; options+=solid; break;;
    esac
  done
}

function ask_frame() {
  if [[ $style != classic || $num_lines != 2 ]]; then
    return
  fi

  (( LINES >= 26 )) && local nl=$'\n' || local nl=''
  while true; do
    clear
    flowing -c "%BPrompt Frame%b"
    print -n $nl
    print -P "%B(1)  No frame.%b"
    print -n $nl
    left_frame=0 right_frame=0 print_prompt
    print -P ""
    print -P "%B(2)  Left.%b"
    print -n $nl
    left_frame=1 right_frame=0 print_prompt
    print -P ""
    print -P "%B(3)  Right.%b"
    print -n $nl
    left_frame=0 right_frame=1 print_prompt
    print -P ""
    print -P "%B(4)  Full.%b"
    print -n $nl
    left_frame=1 right_frame=1 print_prompt
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [1234rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) left_frame=0; right_frame=0; options+='no frame';    break;;
      2) left_frame=1; right_frame=0; options+='left frame';  break;;
      3) left_frame=0; right_frame=1; options+='right frame'; break;;
      4) left_frame=1; right_frame=1; options+='full frame';  break;;
    esac
  done
}

function ask_empty_line() {
  while true; do
    clear
    flowing -c "%BPrompt Spacing%b"
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
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [12rq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      1) empty_line=0; options+='compact'; break;;
      2) empty_line=1; options+='sparse';  break;;
    esac
  done
}

function ask_confirm() {
  while true; do
    clear
    flowing -c "%BLooks good?%b"
    print -P ""
    print_prompt
    (( empty_line )) && print -P ""
    print_prompt
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
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
    flowing -c "Powerlevel10k config file already exists."
    flowing -c "%BOverwrite" "%b%2F${__p9k_cfg_path_u//\\/\\\\}%f%B?%b"
    print -P ""
    print -P "%B(y)  Yes.%b"
    print -P ""
    print -P "(r)  Restart from the beginning."
    print -P "(q)  Quit and do nothing."
    print -P ""

    local key=
    read -k key${(%):-"?%BChoice [yrq]: %b"} || quit -c
    case $key in
      q) quit;;
      r) return 1;;
      y)
        config_backup="$(mktemp ${TMPDIR:-/tmp}/$__p9k_cfg_basename.XXXXXXXXXX)" || exit 1
        cp $__p9k_cfg_path $config_backup                                        || exit 1
        config_backup_u=${${TMPDIR:+\$TMPDIR}:-/tmp}/${(q-)config_backup:t}
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

  function rep() {
    lines=("${(@)lines//$1/$2}")
  }

  sub MODE $POWERLEVEL9K_MODE

  if (( cap_narrow_icons )); then
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER// }'"
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER// }'"
    sub OS_ICON_CONTENT_EXPANSION "'%B\${P9K_CONTENT// }'"
  else
    sub VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER}'"
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'\${P9K_VISUAL_IDENTIFIER}'"
  fi

  if [[ $POWERLEVEL9K_MODE == compatible ]]; then
    # Many fonts don't have the gear or the lock icon.
    sub BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION "'⇶'"
    uncomment 'typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION'
    sub DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION "'∅'"
  fi

  if [[ $POWERLEVEL9K_MODE == (awesome-patched|awesome-fontconfig) && $cap_python == 0 ]]; then
    uncomment 'typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION'
    uncomment 'typeset -g POWERLEVEL9K_ANACONDA_VISUAL_IDENTIFIER_EXPANSION'
    uncomment 'typeset -g POWERLEVEL9K_PYENV_VISUAL_IDENTIFIER_EXPANSION'
    sub VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
    sub ANACONDA_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
    sub PYENV_VISUAL_IDENTIFIER_EXPANSION "'🐍'"
  fi

  if [[ $POWERLEVEL9K_MODE == nerdfont-complete ]]; then
    sub BATTERY_STAGES "\$'\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'"
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
    sub LEFT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$left_subsep'"
    sub RIGHT_SUBSEGMENT_SEPARATOR "'%$sep_color[$color]F$right_subsep'"
    sub LEFT_SEGMENT_SEPARATOR "'$left_sep'"
    sub RIGHT_SEGMENT_SEPARATOR "'$right_sep'"
    sub LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL "'$left_tail'"
    sub LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL "'$left_head'"
    sub RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL "'$right_head'"
    sub RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL "'$right_tail'"
    sub VCS_LOADING_FOREGROUND $sep_color[$color]
    rep '%248F' "%$prefix_color[$color]F"
  fi

  if [[ -n $show_time ]]; then
    uncomment time
  fi

  if [[ -n ${(j::)extra_icons} ]]; then
    local branch_icon=${icons[VCS_BRANCH_ICON]// }
    sub VCS_BRANCH_ICON "'$branch_icon '"
    uncomment os_icon
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

  if [[ $style == classic && $num_lines == 2 ]]; then
    if (( ! right_frame )); then
      sub MULTILINE_FIRST_PROMPT_SUFFIX ''
      sub MULTILINE_NEWLINE_PROMPT_SUFFIX ''
      sub MULTILINE_LAST_PROMPT_SUFFIX ''
    fi
    if (( ! left_frame )); then
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
  local line="# Wizard options: $options[1]"
  local opt
  for opt in $options[2,-1]; do
    if (( $#line + $#opt > 85 )); then
      header+=$line
      header+=$',\n'
      line="# $opt"
    else
      line+=", $opt"
    fi
  done
  header+=$line
  header+=$'.\n# Type `p10k configure` to generate another config.\n#'

  if [[ -e $__p9k_cfg_path ]]; then
    unlink $__p9k_cfg_path || return 1
  fi
  print -lr -- "$header" "$lines[@]" >$__p9k_cfg_path
}

function write_zshrc() {
  if [[ -e $__p9k_zshrc ]]; then
    local lines=(${(f)"$(<$__p9k_zshrc)"})
    local f0=$__p9k_cfg_path
    local f1=${(q)f0}
    local f2=${(q-)f0}
    local f3=${(qq)f0}
    local f4=${(qqq)f0}
    local g1=${${(q)__p9k_cfg_path}/#(#b)${(q)HOME}\//'~/'}
    if [[ -n ${(@M)lines:#(#b)[^#]#([^[:IDENT:]]|)source[[:space:]]##($f1|$f2|$f3|$f4|$g1)(|[[:space:]]*|'#'*)} ]]; then
      flowing +c No changes have been made to %4F$__p9k_zshrc_u%f because it already sources %2F$__p9k_cfg_path_u%f.
      return
    fi
  fi

  local comments=(
    "# To customize prompt, run \`p10k configure\` or edit $__p9k_cfg_path_u."
  )
  print -lrP -- "" $comments "[[ -f $__p9k_cfg_path_u ]] && source $__p9k_cfg_path_u" >>$__p9k_zshrc

  print -rP ""
  flowing +c The following lines have been appended to %4F$__p9k_zshrc_u%f:
  print -rP ""
  print -lrP -- '  '${^comments} "  %3F[[%f %B-f $__p9k_cfg_path_u%b %3F]]%f && %2Fsource%f %B$__p9k_cfg_path_u%b"
}

if (( force )); then
  _p9k_can_configure || return
else
  _p9k_can_configure -q || return
fi

source $__p9k_root_dir/internal/icons.zsh || return

while true; do
  local POWERLEVEL9K_MODE= style= config_backup= config_backup_u= gap_char=' '
  local left_subsep= right_subsep= left_tail= right_tail= left_head= right_head= show_time=
  local -i num_lines=0 write_config=0 empty_line=0 color=2 left_frame=1 right_frame=1
  local -i cap_diamond=0 cap_python=0 cap_debian=0 cap_narrow_icons=0 cap_lock=0
  local -a extra_icons=('' '' '')
  local -a prefixes=('' '')
  local -a options=()

  ask_font || continue
  ask_diamond || continue
  if [[ $AWESOME_GLYPHS_LOADED == 1 ]]; then
    POWERLEVEL9K_MODE=awesome-mapped-fontconfig
  else
    ask_lock '\uF023' || continue
    if (( ! cap_lock )); then
      ask_lock '\uE138' "Let's try another one." || continue
      if (( cap_lock )); then
        if (( cap_diamond )); then
          POWERLEVEL9K_MODE=awesome-patched
          ask_python || continue
        else
          POWERLEVEL9K_MODE=flat
        fi
      else
        (( cap_diamond )) && POWERLEVEL9K_MODE=powerline || POWERLEVEL9K_MODE=compatible
      fi
    elif (( ! cap_diamond )); then
      POWERLEVEL9K_MODE=awesome-fontconfig
    else
      ask_debian || continue
      if (( cap_debian )); then
        POWERLEVEL9K_MODE=nerdfont-complete
      else
        POWERLEVEL9K_MODE=awesome-fontconfig
        ask_python || continue
      fi
    fi
  fi
  if [[ $POWERLEVEL9K_MODE == powerline ]]; then
    options+=powerline
  elif (( cap_diamond )); then
    options+="$POWERLEVEL9K_MODE + powerline"
  else
    options+="$POWERLEVEL9K_MODE"
  fi
  (( cap_python )) && options[-1]+=' + python'
  if (( cap_diamond )); then
    left_subsep=$right_angle
    right_subsep=$left_angle
    left_head=$right_triangle
    right_head=$left_triangle
  else
    left_subsep=$vertical_bar
    right_subsep=$vertical_bar
    left_head=$fade_out
    right_head=$fade_in
  fi
  _p9k_init_icons
  ask_narrow_icons     || continue
  ask_style            || continue
  ask_color            || continue
  ask_time             || continue
  ask_separators       || continue
  ask_heads            || continue
  ask_tails            || continue
  ask_num_lines        || continue
  ask_gap_char         || continue
  ask_frame            || continue
  ask_empty_line       || continue
  ask_extra_icons      || continue
  ask_prefixes         || continue
  ask_confirm          || continue
  ask_config_overwrite || continue
  break
done

clear

flowing +c Powerlevel10k configuration has been written to %2F$__p9k_cfg_path_u%f.
if [[ -n $config_backup ]]; then
  flowing +c The backup of the previous version is at %3F$config_backup_u%f.
fi

if (( write_config )); then
  generate_config || return
fi

write_zshrc || return

print -rP ""
flowing +c File feature requests and bug reports at "$(href https://github.com/romkatv/powerlevel10k/issues)."
print -rP ""

} "$@"
