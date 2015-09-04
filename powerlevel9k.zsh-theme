# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# This theme was inspired by agnoster's Theme:
# https://gist.github.com/3712874
#
# The `vcs_info` hooks in this file are from Tom Upton:
# https://github.com/tupton/dotfiles/blob/master/zsh/zshrc
################################################################

################################################################
# Please see the README file located in the source repository for full docs.
# There are a lot of easy ways you can customize your prompt segments and
# theming with simple variables defined in your `~/.zshrc`.
################################################################

## Turn on for Debugging
#zstyle ':vcs_info:*+*:*' debug true
#set -o xtrace

################################################################
# Utility functions
################################################################

# Exits with 0 if a variable has been previously defined (even if empty)
# Takes the name of a variable that should be checked.
function defined() {
  local varname="$1"

  typeset -p "$varname" > /dev/null 2>&1
}

# Safety function for printing icons
# Prints the named icon, or if that icon is undefined, the string name.
function print_icon() {
  local icon_name=$1
  local ICON_USER_VARIABLE=POWERLEVEL9K_${icon_name}
  local USER_ICON=${(P)ICON_USER_VARIABLE}
  if defined "$ICON_USER_VARIABLE"; then
    echo -n $USER_ICON
  else
    echo -n ${icons[$icon_name]}
  fi
}

# Given the name of a variable and a default value, sets the variable
# value to the default only if it has not been defined.
#
# Typeset cannot set the value for an array, so this will only work
# for scalar values.
function set_default() {
  local varname="$1"
  local default_value="$2"

  defined "$varname" || typeset -g "$varname"="$default_value"
}

################################################################
# Icons
################################################################

# These characters require the Powerline fonts to work properly. If you see
# boxes or bizarre characters below, your fonts are not correctly installed. If
# you do not want to install a special font, you can set `POWERLEVEL9K_MODE` to
# `compatible`. This shows all icons in regular symbols.

# Initialize the icon list according to the user's `POWERLEVEL9K_MODE`.
typeset -gAH icons
case $POWERLEVEL9K_MODE in
  'flat'|'awesome-patched')
    # Awesome-Patched Font required!
    # See https://github.com/gabrielelana/awesome-terminal-fonts/tree/patching-strategy/patched
    icons=(
      LEFT_SEGMENT_SEPARATOR         "\UE0B0" # 
      RIGHT_SEGMENT_SEPARATOR        "\UE0B2" # 
      ROOT_ICON                      "\UE801" # 
      RUBY_ICON                      "\UE847" # 
      AWS_ICON                       "\UE895" # 
      BACKGROUND_JOBS_ICON           "\UE82F " # 
      TEST_ICON                      "\UE891" # 
      OK_ICON                        "\U2713" # ✓
      FAIL_ICON                      "\U2718" # ✘
      SYMFONY_ICON                   "SF"
      NODE_ICON                      $'\U2B22' # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\U256D'$'\U2500'
      MULTILINE_SECOND_PROMPT_PREFIX $'\U2570'$'\U2500 '
      APPLE_ICON                     $'\UF8FF' # 
      FREEBSD_ICON                   $'\U1F608 ' # 😈
      LINUX_ICON                     $'\U1F427 ' # 🐧
      SUNOS_ICON                     $'\U1F31E ' # 🌞
      HOME_ICON                      $'\UE12C ' # 
      VCS_UNTRACKED_ICON             "\UE16C" # 
      VCS_UNSTAGED_ICON              "\UE17C" # 
      VCS_STAGED_ICON                "\UE168" # 
      VCS_STASH_ICON                 "\UE133 " # 
      #VCS_INCOMING_CHANGES_ICON     "\UE1EB " # 
      #VCS_INCOMING_CHANGES_ICON     "\UE80D " # 
      VCS_INCOMING_CHANGES_ICON      "\UE131 " # 
      #VCS_OUTGOING_CHANGES_ICON     "\UE1EC " # 
      #VCS_OUTGOING_CHANGES_ICON     "\UE80E " # 
      VCS_OUTGOING_CHANGES_ICON      "\UE132 " # 
      VCS_TAG_ICON                   "\UE817 " # 
      VCS_BOOKMARK_ICON              "\UE87B" # 
      VCS_COMMIT_ICON                "\UE821 " # 
      VCS_BRANCH_ICON                $'\UE220' # 
      VCS_REMOTE_BRANCH_ICON         " \UE804 " # 
      VCS_GIT_ICON                   "\UE20E  " # 
      VCS_HG_ICON                    "\UE1C3  " # 
    )
  ;;
  *)
    # Powerline-Patched Font required!
    # See https://github.com/Lokaltog/powerline-fonts
    icons=(
      LEFT_SEGMENT_SEPARATOR         "\uE0B0" # 
      RIGHT_SEGMENT_SEPARATOR        "\uE0B2" # 
      ROOT_ICON                      "\u26A1" # ⚡
      RUBY_ICON                      ''
      AWS_ICON                       "AWS:"
      BACKGROUND_JOBS_ICON           "\u2699" # ⚙
      TEST_ICON                      ''
      OK_ICON                        "\u2713" # ✓
      FAIL_ICON                      "\u2718" # ✘
      SYMFONY_ICON                   "SF"
      NODE_ICON                      $'\u2B22' # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\u2500'
      MULTILINE_SECOND_PROMPT_PREFIX $'\u2570'$'\u2500 '
      APPLE_ICON                     'OSX'
      FREEBSD_ICON                   'BSD'
      LINUX_ICON                     'Lx'
      SUNOS_ICON                     'Sun'
      HOME_ICON                      ''
      VCS_UNTRACKED_ICON             '?'
      VCS_UNSTAGED_ICON              "\u25CF" # ●
      VCS_STAGED_ICON                "\u271A" # ✚
      VCS_STASH_ICON                 "\u235F" # ⍟
      VCS_INCOMING_CHANGES_ICON      "\u2193" # ↓
      VCS_OUTGOING_CHANGES_ICON      "\u2191" # ↑
      VCS_TAG_ICON                   ''
      VCS_BOOKMARK_ICON              "\u263F" # ☿
      VCS_COMMIT_ICON                ''
      VCS_BRANCH_ICON                "\uE0A0 " # 
      VCS_REMOTE_BRANCH_ICON         "\u2192" # →
      VCS_GIT_ICON                   ""
      VCS_HG_ICON                    ""
    )
  ;;
esac

# Override the above icon settings with any user-defined variables.
case $POWERLEVEL9K_MODE in
  'flat')
    icons[LEFT_SEGMENT_SEPARATOR]=''
    icons[RIGHT_SEGMENT_SEPARATOR]=''
  ;;
  'compatible')
    icons[LEFT_SEGMENT_SEPARATOR]="\u2B80" # ⮀
    icons[RIGHT_SEGMENT_SEPARATOR]="\u2B82" # ⮂
    icons[VCS_BRANCH_ICON]='@'
  ;;
esac

if [[ "$POWERLEVEL9K_HIDE_BRANCH_ICON" == true ]]; then
    icons[VCS_BRANCH_ICON]=''
fi

# OS detection for the `os_icon` segment
case $(uname) in
    Darwin)
      OS='OSX'
      OS_ICON=$(print_icon 'APPLE_ICON')
      ;;
    FreeBSD)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    OpenBSD)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    DragonFly)
      OS='BSD'
      OS_ICON=$(print_icon 'FREEBSD_ICON')
      ;;
    Linux)
      OS='Linux'
      OS_ICON=$(print_icon 'LINUX_ICON')
      ;;
    SunOS)
      OS='Solaris'
      OS_ICON=$(print_icon 'SUNOS_ICON')
      ;;
    *)
      OS=''
      OS_ICON=''
      ;;
esac

# Determine the correct sed parameter.
#
# `sed` is unfortunately not consistent across OSes when it comes to flags.
SED_EXTENDED_REGEX_PARAMETER="-r"
if [[ "$OS" == 'OSX' ]]; then
  local IS_BSD_SED=$(sed --version &>> /dev/null || echo "BSD sed")
  if [[ -n "$IS_BSD_SED" ]]; then
    SED_EXTENDED_REGEX_PARAMETER="-E"
  fi
fi

################################################################
# Color Scheme
################################################################

if [[ "$POWERLEVEL9K_COLOR_SCHEME" == "light" ]]; then
  DEFAULT_COLOR=white
  DEFAULT_COLOR_INVERTED=black
  DEFAULT_COLOR_DARK="252"
else
  DEFAULT_COLOR=black
  DEFAULT_COLOR_INVERTED=white
  DEFAULT_COLOR_DARK="236"
fi

set_default POWERLEVEL9K_VCS_FOREGROUND "$DEFAULT_COLOR"
set_default POWERLEVEL9K_VCS_DARK_FOREGROUND "$DEFAULT_COLOR_DARK"

################################################################
# VCS Information Settings
################################################################

setopt prompt_subst
autoload -Uz vcs_info

VCS_WORKDIR_DIRTY=false
VCS_CHANGESET_PREFIX=''
if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
  # Default: Just display the first 12 characters of our changeset-ID.
  local VCS_CHANGESET_HASH_LENGTH=12
  if [[ -n "$POWERLEVEL9K_CHANGESET_HASH_LENGTH" ]]; then
    VCS_CHANGESET_HASH_LENGTH="$POWERLEVEL9K_CHANGESET_HASH_LENGTH"
  fi

  VCS_CHANGESET_PREFIX="%F{$POWERLEVEL9K_VCS_DARK_FOREGROUND}$(print_icon 'VCS_COMMIT_ICON')%0.$VCS_CHANGESET_HASH_LENGTH""i%f "
fi

zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true

VCS_DEFAULT_FORMAT="$VCS_CHANGESET_PREFIX%F{$POWERLEVEL9K_VCS_FOREGROUND}%b%c%u%m%f"
zstyle ':vcs_info:git*:*' formats "%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_GIT_ICON')%f$VCS_DEFAULT_FORMAT"
zstyle ':vcs_info:hg*:*' formats "%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_HG_ICON')%f$VCS_DEFAULT_FORMAT"

zstyle ':vcs_info:*' actionformats " %b %F{red}| %a%f"

zstyle ':vcs_info:*' stagedstr " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_STAGED_ICON')%f"
zstyle ':vcs_info:*' unstagedstr " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_UNSTAGED_ICON')%f"

zstyle ':vcs_info:git*+set-message:*' hooks vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tagname
zstyle ':vcs_info:hg*+set-message:*' hooks vcs-detect-changes

# For Hg, only show the branch name
zstyle ':vcs_info:hg*:*' branchformat "$(print_icon 'VCS_BRANCH_ICON')%b"
# The `get-revision` function must be turned on for dirty-check to work for Hg
zstyle ':vcs_info:hg*:*' get-revision true
zstyle ':vcs_info:hg*:*' get-bookmarks true
zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks

if [[ "$POWERLEVEL9K_SHOW_CHANGESET" == true ]]; then
  zstyle ':vcs_info:*' get-revision true
fi

################################################################
# Prompt Segment Constructors
#
# Methodology behind user-defined variables overwriting colors:
#     The first parameter to the segment constructors is the calling function's
#     name.  From this function name, we strip the "prompt_"-prefix and
#     uppercase it.  This is then prefixed with "POWERLEVEL9K_" and suffixed
#     with either "_BACKGROUND" or "_FOREGROUND", thus giving us the variable
#     name. So each new segment is user-overwritable by a variable following
#     this naming convention.
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# Begin a left prompt segment
# Takes four arguments:
#   * $1: Name of the function that was orginally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: Background color
#   * $3: Foreground color
#   * $4: The segment content
# The latter three can be omitted,
left_prompt_segment() {
  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 2=$BG_COLOR_MODIFIER

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 3=$FG_COLOR_MODIFIER

  local bg fg
  [[ -n $2 ]] && bg="%K{$2}" || bg="%k"
  [[ -n $3 ]] && fg="%F{$3}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $2 != $CURRENT_BG ]]; then
    # Middle segment
    echo -n "%{$bg%F{$CURRENT_BG}%}$(print_icon 'LEFT_SEGMENT_SEPARATOR')%{$fg%} "
  else
    # First segment
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$2
  [[ -n $4 ]] && echo -n "$4 "
}

# End the left prompt, closes the final segment.
left_prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}$(print_icon 'LEFT_SEGMENT_SEPARATOR')"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%} "
  CURRENT_BG=''
}

# Begin a right prompt segment
# Takes four arguments:
#   * $1: Name of the function that was orginally invoked (mandatory).
#         Necessary, to make the dynamic color-overwrite mechanism work.
#   * $2: Background color
#   * $3: Foreground color
#   * $4: The segment content
# No ending for the right prompt segment is needed (unlike the left prompt, above).
right_prompt_segment() {
  # Overwrite given background-color by user defined variable for this segment.
  local BACKGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_BACKGROUND
  local BG_COLOR_MODIFIER=${(P)BACKGROUND_USER_VARIABLE}
  [[ -n $BG_COLOR_MODIFIER ]] && 2=$BG_COLOR_MODIFIER

  # Overwrite given foreground-color by user defined variable for this segment.
  local FOREGROUND_USER_VARIABLE=POWERLEVEL9K_${(U)1#prompt_}_FOREGROUND
  local FG_COLOR_MODIFIER=${(P)FOREGROUND_USER_VARIABLE}
  [[ -n $FG_COLOR_MODIFIER ]] && 3=$FG_COLOR_MODIFIER

  local bg fg
  [[ -n $2 ]] && bg="%K{$2}" || bg="%k"
  [[ -n $3 ]] && fg="%F{$3}" || fg="%f"
  echo -n "%f%F{$2}$(print_icon 'RIGHT_SEGMENT_SEPARATOR')%f%{$bg%}%{$fg%} "
  [[ -n $4 ]] && echo -n "$4 "
}

################################################################
# The `vcs` Segment and VCS_INFO hooks / helper functions
################################################################
prompt_vcs() {
  local vcs_prompt="${vcs_info_msg_0_}"

  if [[ -n "$vcs_prompt" ]]; then
    if [[ "$VCS_WORKDIR_DIRTY" == true ]]; then
      $1_prompt_segment "$0_MODIFIED" "yellow" "$DEFAULT_COLOR"
    else
      $1_prompt_segment "$0" "green" "$DEFAULT_COLOR"
    fi

    echo -n "%F{$POWERLEVEL9K_VCS_FOREGROUND}%f$vcs_prompt "
  fi
}

function +vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' && \
            -n $(git ls-files --others --exclude-standard | sed q) ]]; then
        hook_com[unstaged]+=" %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_UNTRACKED_ICON')%f"
    fi
}

function +vi-git-aheadbehind() {
    local ahead behind branch_name
    local -a gitstatus

    branch_name=${$(git symbolic-ref --short HEAD 2>/dev/null)}

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${branch_name}..HEAD | wc -l)
    ahead=$(git rev-list ${branch_name}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_OUTGOING_CHANGES_ICON')${ahead// /}%f" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${branch_name} | wc -l)
    behind=$(git rev-list HEAD..${branch_name}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_INCOMING_CHANGES_ICON')${behind// /}%f" )

    hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
    local remote branch_name

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)/refs\/(remotes|heads)\/}
    branch_name=${$(git symbolic-ref --short HEAD 2>/dev/null)}

    hook_com[branch]="%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_BRANCH_ICON')${hook_com[branch]}%f"
    # Always show the remote
    #if [[ -n ${remote} ]] ; then
    # Only show the remote if it differs from the local
    if [[ -n ${remote} && ${remote#*/} != ${branch_name} ]] ; then
        hook_com[branch]+="%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_REMOTE_BRANCH_ICON')%f%F{$POWERLEVEL9K_VCS_FOREGROUND}${remote// /}%f"
    fi
}

function +vi-git-tagname() {
    local tag

    tag=$(git describe --tags --exact-match HEAD 2>/dev/null)
    [[ -n "${tag}" ]] && hook_com[branch]=" %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_TAG_ICON')${tag}%f"
}

# Show count of stashed changes
# Port from https://github.com/whiteinge/dotfiles/blob/5dfd08d30f7f2749cfc60bc55564c6ea239624d9/.zsh_shouse_prompt#L268
function +vi-git-stash() {
  local -a stashes

  if [[ -s $(git rev-parse --git-dir)/refs/stash ]] ; then
    stashes=$(git stash list 2>/dev/null | wc -l)
    hook_com[misc]+=" %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_STASH_ICON')${stashes// /}%f"
  fi
}

function +vi-hg-bookmarks() {
  if [[ -n "${hgbmarks[@]}" ]]; then
    hook_com[hg-bookmark-string]=" %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_BOOKMARK_ICON')${hgbmarks[@]}%f"

    # To signal that we want to use the sting we just generated, set the special
    # variable `ret' to something other than the default zero:
    ret=1
    return 0
  fi
}

function +vi-vcs-detect-changes() {
  if [[ -n "${hook_com[staged]}" ]] || [[ -n "${hook_com[unstaged]}" ]]; then
    VCS_WORKDIR_DIRTY=true
  else
    VCS_WORKDIR_DIRTY=false
  fi
}

################################################################
# Prompt Segment Definitions
################################################################

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# AWS Profile
prompt_aws() {
  local aws_profile="$AWS_DEFAULT_PROFILE"
  if [[ -n "$aws_profile" ]];
  then
    $1_prompt_segment "$0" red white "$(print_icon 'AWS_ICON') $aws_profile"
  fi
}

# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    if [[ $(print -P "%#") == '#' ]]; then
      # Shell runs as root
      $1_prompt_segment "$0_ROOT" "$DEFAULT_COLOR" "yellow" "$USER@%m"
    else
      $1_prompt_segment "$0_DEFAULT" "$DEFAULT_COLOR" "011" "$USER@%m"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  local current_path='%~'
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" ]]; then

    case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
      truncate_middle)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})\//\1\.\.\2\//g")
      ;;
      truncate_from_right)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+\//\1..\//g")
      ;;
      *)
        current_path="%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:.../:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c"
      ;;
    esac

  fi

  $1_prompt_segment "$0" "blue" "$DEFAULT_COLOR" "$(print_icon 'HOME_ICON')$current_path"
}

# Command number (in local history)
prompt_history() {
  $1_prompt_segment "$0" "244" "$DEFAULT_COLOR" '%h'
}

prompt_icons_test() {
  for key in "${(@k)icons}"; do
    # The lower color spectrum in ZSH makes big steps. Choosing
    # the next color has enough contrast to read.
    local random_color=$((RANDOM % 8))
    local next_color=$((random_color+1))
    $1_prompt_segment "$0" "$random_color" "$next_color" "$key: ${icons[$key]}"
  done
}

# Right Status: (return code, root status, background jobs)
# This creates a status segment for the *right* prompt. Exact same thing as
# above - just other side.
prompt_longstatus() {
  local symbols bg
  symbols=()

  if [[ "$RETVAL" -ne 0 ]]; then
    symbols+="%F{226}%? ↵"
    bg="009"
  else
    symbols+="%{%F{"046"}%}$(print_icon 'OK_ICON')"
    bg="008"
  fi

  [[ "$UID" -eq 0 ]] && symbols+="%{%F{yellow}%} $(print_icon 'ROOT_ICON')"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$(print_icon 'BACKGROUND_JOBS_ICON')"

  [[ -n "$symbols" ]] && $1_prompt_segment "$0" "$bg" "$DEFAULT_COLOR" "$symbols"
}

# Node version
prompt_node_version() {
  local nvm_prompt=$(node -v 2>/dev/null)
  [[ -z "${nvm_prompt}" ]] && return

  $1_prompt_segment "$0" "green" "white" "${nvm_prompt:1} $(print_icon 'NODE_ICON')"
}

# print a little OS icon
prompt_os_icon() {
  $1_prompt_segment "$0" "008" "255" "$OS_ICON"
}

# rbenv information
prompt_rbenv() {
  if [[ -n "$RBENV_VERSION" ]]; then
    $1_prompt_segment "$0" "red" "$DEFAULT_COLOR" "$RBENV_VERSION"
  fi
}

# RSpec test ratio
prompt_rspec_stats() {
  if [[ (-d app && -d spec) ]]; then
    local code_amount=$(ls -1 app/**/*.rb | wc -l)
    local tests_amount=$(ls -1 spec/**/*.rb | wc -l)

    build_test_stats "$1" $0 "$code_amount" $tests_amount "RSpec $(print_icon 'TEST_ICON')"
  fi
}

# Ruby Version Manager information
prompt_rvm() {
  local rvm_prompt
  rvm_prompt=`rvm-prompt`
  if [ "$rvm_prompt" != "" ]; then
    $1_prompt_segment "$0" "240" "$DEFAULT_COLOR" "$rvm_prompt $(print_icon 'RUBY_ICON') "
  fi
}

# Left Status: (return code, root status, background jobs)
# This creates a status segment for the *left* prompt
prompt_status() {
  local symbols
  symbols=()
  [[ "$RETVAL" -ne 0 ]] && symbols+="%{%F{red}%}$(print_icon 'FAIL_ICON')"
  [[ "$UID" -eq 0 ]] && symbols+="%{%F{yellow}%} $(print_icon 'ROOT_ICON')"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$(print_icon 'BACKGROUND_JOBS_ICON')"

  [[ -n "$symbols" ]] && $1_prompt_segment "$0" "$DEFAULT_COLOR" "default" "$symbols"
}

# Symfony2-PHPUnit test ratio
prompt_symfony2_tests() {
  if [[ (-d src && -d app && -f app/AppKernel.php) ]]; then
    local code_amount=$(ls -1 src/**/*.php | grep -v Tests | wc -l)
    local tests_amount=$(ls -1 src/**/*.php | grep Tests | wc -l)

    build_test_stats "$1" "$0" "$code_amount" "$tests_amount" "SF2 $(print_icon 'TEST_ICON')"
  fi
}

# Symfony2-Version
prompt_symfony2_version() {
  if [[ -f app/bootstrap.php.cache ]]; then
    local symfony2_version=$(grep " VERSION " app/bootstrap.php.cache | sed -e 's/[^.0-9]*//g')
    $1_prompt_segment "$0" "240" "$DEFAULT_COLOR" "$(print_icon 'SYMFONY_ICON') $symfony2_version"
  fi
}

# Show a ratio of tests vs code
build_test_stats() {
  local code_amount="$3"
  local tests_amount="$4"+0.00001
  local headline="$5"

  # Set float precision to 2 digits:
  typeset -F 2 ratio
  local ratio=$(( (tests_amount/code_amount) * 100 ))

  [[ ratio -ge 0.75 ]] && $1_prompt_segment "${2}_GOOD" "cyan" "$DEFAULT_COLOR" "$headline: $ratio%%"
  [[ ratio -ge 0.5 && ratio -lt 0.75 ]] && $1_prompt_segment "$2_AVG" "yellow" "$DEFAULT_COLOR" "$headline: $ratio%%"
  [[ ratio -lt 0.5 ]] && $1_prompt_segment "$2_BAD" "red" "$DEFAULT_COLOR" "$headline: $ratio%%"
}

# System time
prompt_time() {
  local time_format="%D{%H:%M:%S}"
  if [[ -n "$POWERLEVEL9K_TIME_FORMAT" ]]; then
    time_format="$POWERLEVEL9K_TIME_FORMAT"
  fi

  $1_prompt_segment "$0" "$DEFAULT_COLOR_INVERTED" "$DEFAULT_COLOR" "$time_format"
}

# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n "$virtualenv_path" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    $1_prompt_segment "$0" "blue" "$DEFAULT_COLOR" "(`basename $virtualenv_path`)"
  fi
}

################################################################
# Prompt processing and drawing
################################################################

# Main prompt
build_left_prompt() {
  RETVAL=$?

  defined POWERLEVEL9K_LEFT_PROMPT_ELEMENTS || POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)

  for element in $POWERLEVEL9K_LEFT_PROMPT_ELEMENTS; do
    prompt_$element "left"
  done

  left_prompt_end
}

# Right prompt
build_right_prompt() {
  RETVAL=$?

  defined POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(longstatus history time)

  for element in $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS; do
    prompt_$element "right"
  done
}

powerlevel9k_init() {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent subst)

  # initialize colors
  autoload -U colors && colors

  # initialize VCS
  autoload -Uz add-zsh-hook

  add-zsh-hook precmd vcs_info

  if [[ "$POWERLEVEL9K_PROMPT_ON_NEWLINE" == true ]]; then
    PROMPT="$(print_icon 'MULTILINE_FIRST_PROMPT_PREFIX')%{%f%b%k%}"'$(build_left_prompt)'"
$(print_icon 'MULTILINE_SECOND_PROMPT_PREFIX')"
    # The right prompt should be on the same line as the first line of the left
    # prompt.  To do so, there is just a quite ugly workaround: Before zsh draws
    # the RPROMPT, we advise it, to go one line up. At the end of RPROMPT, we
    # advise it to go one line down. See:
    # http://superuser.com/questions/357107/zsh-right-justify-in-ps1
    RPROMPT_PREFIX='%{'$'\e[1A''%}' # one line up
    RPROMPT_SUFFIX='%{'$'\e[1B''%}' # one line down
  else
    PROMPT="%{%f%b%k%}"'$(build_left_prompt)'
    RPROMPT_PREFIX=''
    RPROMPT_SUFFIX=''
  fi

  if [[ "$POWERLEVEL9K_DISABLE_RPROMPT" != true ]]; then
    RPROMPT=$RPROMPT_PREFIX"%{%f%b%k%}"'$(build_right_prompt)'"%{$reset_color%}"$RPROMPT_SUFFIX
  fi
}

powerlevel9k_init "$@"
