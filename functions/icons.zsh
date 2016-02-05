# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# icons
# This file holds the icon definitions and
# icon-functions for the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

# These characters require the Powerline fonts to work properly. If you see
# boxes or bizarre characters below, your fonts are not correctly installed. If
# you do not want to install a special font, you can set `POWERLEVEL9K_MODE` to
# `compatible`. This shows all icons in regular symbols.

# Initialize the icon list according to the user's `POWERLEVEL9K_MODE`.
typeset -gAH icons
case $POWERLEVEL9K_MODE in
  'flat'|'awesome-patched')
    # Awesome-Patched Font required! See:
    # https://github.com/gabrielelana/awesome-terminal-fonts/tree/patching-strategy/patched
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\UE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\UE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\UE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\UE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\U21B5'              # ↵
      ROOT_ICON                      $'\UE801'              # 
      RUBY_ICON                      $'\UE847 '             # 
      AWS_ICON                       $'\UE895'              # 
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\UE82F '             # 
      TEST_ICON                      $'\UE891'              # 
      TODO_ICON                      $'\U2611'              # ☑
      BATTERY_ICON                   $'\UE894'              # 
      OK_ICON                        $'\U2713'              # ✓
      FAIL_ICON                      $'\U2718'              # ✘
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\U2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\U256D'$'\U2500'
      MULTILINE_SECOND_PROMPT_PREFIX $'\U2570'$'\U2500 '
      APPLE_ICON                     $'\UE26E'              # 
      FREEBSD_ICON                   $'\U1F608 '            # 😈
      LINUX_ICON                     $'\UE271'              # 
      SUNOS_ICON                     $'\U1F31E '            # 🌞
      HOME_ICON                      $'\UE12C'              # 
      HOME_SUB_ICON                  $'\UE18D'              # 
      FOLDER_ICON                    $'\UE818'              # 
      NETWORK_ICON                   $'\UE1AD'              # 
      LOAD_ICON                      $'\UE190 '             # 
      SWAP_ICON                      $'\UE87D'              # 
      RAM_ICON                       $'\UE1E2 '             # 
      VCS_UNTRACKED_ICON             $'\UE16C'              # 
      VCS_UNSTAGED_ICON              $'\UE17C'              # 
      VCS_STAGED_ICON                $'\UE168'              # 
      VCS_STASH_ICON                 $'\UE133 '             # 
      #VCS_INCOMING_CHANGES_ICON     $'\UE1EB '             # 
      #VCS_INCOMING_CHANGES_ICON     $'\UE80D '             # 
      VCS_INCOMING_CHANGES_ICON      $'\UE131 '             # 
      #VCS_OUTGOING_CHANGES_ICON     $'\UE1EC '             # 
      #VCS_OUTGOING_CHANGES_ICON     $'\UE80E '             # 
      VCS_OUTGOING_CHANGES_ICON      $'\UE132 '             # 
      VCS_TAG_ICON                   $'\UE817 '             # 
      VCS_BOOKMARK_ICON              $'\UE87B'              # 
      VCS_COMMIT_ICON                $'\UE821 '             # 
      VCS_BRANCH_ICON                $'\UE220'              # 
      VCS_REMOTE_BRANCH_ICON         ' '$'\UE804 '          # 
      VCS_GIT_ICON                   $'\UE20E '             # 
      VCS_HG_ICON                    $'\UE1C3 '             # 
    )
  ;;
  'awesome-fontconfig')
    # fontconfig with awesome-font required! See
    # https://github.com/gabrielelana/awesome-terminal-fonts
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\UE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\UE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\UE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\UE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\U21B5'              # ↵
      ROOT_ICON                      $'\uF201'              # 
      RUBY_ICON                      $'\UF219 '             # 
      AWS_ICON                       $'\UF296'              # 
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\UF013 '             # 
      TEST_ICON                      $'\UF291'              # 
      TODO_ICON                      $'\U2611'              # ☑
      BATTERY_ICON                   $'\u1F50B'             # 🔋
      OK_ICON                        $'\UF23A'              # 
      FAIL_ICON                      $'\UF281'              # 
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\U2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\U256D'$'\U2500'     # ╭─
      MULTILINE_SECOND_PROMPT_PREFIX $'\U2570'$'\U2500 '    # ╰─
      APPLE_ICON                     $'\UF179'              # 
      FREEBSD_ICON                   $'\U1F608 '            # 😈
      LINUX_ICON                     $'\UF17C'              # 
      SUNOS_ICON                     $'\UF185 '             # 
      HOME_ICON                      $'\UF015'              # 
      HOME_SUB_ICON                  $'\UF07C'              # 
      FOLDER_ICON                    $'\UF115'              # 
      NETWORK_ICON                   $'\UF09E'              # 
      LOAD_ICON                      $'\UF080 '             # 
      SWAP_ICON                      $'\UF0E4'              # 
      RAM_ICON                       $'\UF0E4'              # 
      VCS_UNTRACKED_ICON             $'\UF059'              # 
      VCS_UNSTAGED_ICON              $'\UF06A'              # 
      VCS_STAGED_ICON                $'\UF055'              # 
      VCS_STASH_ICON                 $'\UF01C '             # 
      VCS_INCOMING_CHANGES_ICON      $'\UF01A '             # 
      VCS_OUTGOING_CHANGES_ICON      $'\UF01B '             # 
      VCS_TAG_ICON                   $'\UF217 '             # 
      VCS_BOOKMARK_ICON              $'\UF27B'              # 
      VCS_COMMIT_ICON                $'\UF221 '             # 
      VCS_BRANCH_ICON                $'\UF126'              # 
      VCS_REMOTE_BRANCH_ICON         ' '$'\UF204 '          # 
      VCS_GIT_ICON                   $'\UF113 '             # 
      VCS_HG_ICON                    $'\UF0C3 '             # 
    )
  ;;
  *)
    # Powerline-Patched Font required!
    # See https://github.com/Lokaltog/powerline-fonts
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\uE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\uE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\UE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\UE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\U21B5'              # ↵
      ROOT_ICON                      $'\u26A1'              # ⚡
      RUBY_ICON                      ''
      AWS_ICON                       'AWS:'
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\u2699'              # ⚙
      TEST_ICON                      ''
      TODO_ICON                      $'\U2611'              # ☑
      BATTERY_ICON                   $'\u1F50B'             # 🔋
      OK_ICON                        $'\u2713'              # ✓
      FAIL_ICON                      $'\u2718'              # ✘
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\u2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\u2500'
      MULTILINE_SECOND_PROMPT_PREFIX $'\u2570'$'\u2500 '
      APPLE_ICON                     'OSX'
      FREEBSD_ICON                   'BSD'
      LINUX_ICON                     'Lx'
      SUNOS_ICON                     'Sun'
      HOME_ICON                      ''
      HOME_SUB_ICON                  ''
      FOLDER_ICON                    ''
      NETWORK_ICON                   'IP'
      LOAD_ICON                      'L'
      SWAP_ICON                      'SWP'
      RAM_ICON                       'RAM'
      VCS_UNTRACKED_ICON             '?'
      VCS_UNSTAGED_ICON              $'\u25CF'              # ●
      VCS_STAGED_ICON                $'\u271A'              # ✚
      VCS_STASH_ICON                 $'\u235F'              # ⍟
      VCS_INCOMING_CHANGES_ICON      $'\u2193'              # ↓
      VCS_OUTGOING_CHANGES_ICON      $'\u2191'              # ↑
      VCS_TAG_ICON                   ''
      VCS_BOOKMARK_ICON              $'\u263F'              # ☿
      VCS_COMMIT_ICON                ''
      VCS_BRANCH_ICON                $'\uE0A0 '             # 
      VCS_REMOTE_BRANCH_ICON         $'\u2192'              # →
      VCS_GIT_ICON                   ''
      VCS_HG_ICON                    ''
    )
  ;;
esac

# Override the above icon settings with any user-defined variables.
case $POWERLEVEL9K_MODE in
  'flat')
    icons[LEFT_SEGMENT_SEPARATOR]=''
    icons[RIGHT_SEGMENT_SEPARATOR]=''
    icons[LEFT_SUBSEGMENT_SEPARATOR]='|'
    icons[RIGHT_SUBSEGMENT_SEPARATOR]='|'
  ;;
  'compatible')
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    icons[LEFT_SEGMENT_SEPARATOR]=$'\u2B80'                 # ⮀
    icons[RIGHT_SEGMENT_SEPARATOR]=$'\u2B82'                # ⮂
    icons[VCS_BRANCH_ICON]='@'
  ;;
esac

if [[ "$POWERLEVEL9K_HIDE_BRANCH_ICON" == true ]]; then
    icons[VCS_BRANCH_ICON]=''
fi

# Safety function for printing icons
# Prints the named icon, or if that icon is undefined, the string name.
function print_icon() {
  local icon_name=$1
  local ICON_USER_VARIABLE=POWERLEVEL9K_${icon_name}
  if defined "$ICON_USER_VARIABLE"; then
    echo -n "${(P)ICON_USER_VARIABLE}"
  else
    echo -n "${icons[$icon_name]}"
  fi
}

get_icon_names() {
  for key in ${(@k)icons}; do
    echo "POWERLEVEL9K_$key: ${icons[$key]}"
  done
}
