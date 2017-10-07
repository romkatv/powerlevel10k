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
      LEFT_SEGMENT_SEPARATOR         $'\uE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\uE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\uE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\uE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\u21B5'              # ↵
      ROOT_ICON                      $'\uE801'              # 
      RUBY_ICON                      $'\uE847 '             # 
      AWS_ICON                       $'\uE895'              # 
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\uE82F '             # 
      TEST_ICON                      $'\uE891'              # 
      TODO_ICON                      $'\u2611'              # ☑
      BATTERY_ICON                   $'\uE894'              # 
      DISK_ICON                      $'\uE1AE '             # 
      OK_ICON                        $'\u2714'              # ✔
      FAIL_ICON                      $'\u2718'              # ✘
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\u2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\U2500'     # ╭─
      MULTILINE_NEWLINE_PROMPT_PREFIX  $'\u251C'$'\U2500'   # ├─
      MULTILINE_LAST_PROMPT_PREFIX   $'\u2570'$'\U2500 '    # ╰─
      APPLE_ICON                     $'\uE26E'              # 
      WINDOWS_ICON                   $'\uE26F'              # 
      FREEBSD_ICON                   $'\U1F608 '            # 😈
      ANDROID_ICON                   $'\uE270'              # 
      LINUX_ICON                     $'\uE271'              # 
      SUNOS_ICON                     $'\U1F31E '            # 🌞
      HOME_ICON                      $'\uE12C'              # 
      HOME_SUB_ICON                  $'\uE18D'              # 
      FOLDER_ICON                    $'\uE818'              # 
      NETWORK_ICON                   $'\uE1AD'              # 
      LOAD_ICON                      $'\uE190 '             # 
      SWAP_ICON                      $'\uE87D'              # 
      RAM_ICON                       $'\uE1E2 '             # 
      SERVER_ICON                    $'\uE895'              # 
      VCS_UNTRACKED_ICON             $'\uE16C'              # 
      VCS_UNSTAGED_ICON              $'\uE17C'              # 
      VCS_STAGED_ICON                $'\uE168'              # 
      VCS_STASH_ICON                 $'\uE133 '             # 
      #VCS_INCOMING_CHANGES_ICON     $'\uE1EB '             # 
      #VCS_INCOMING_CHANGES_ICON     $'\uE80D '             # 
      VCS_INCOMING_CHANGES_ICON      $'\uE131 '             # 
      #VCS_OUTGOING_CHANGES_ICON     $'\uE1EC '             # 
      #VCS_OUTGOING_CHANGES_ICON     $'\uE80E '             # 
      VCS_OUTGOING_CHANGES_ICON      $'\uE132 '             # 
      VCS_TAG_ICON                   $'\uE817 '             # 
      VCS_BOOKMARK_ICON              $'\uE87B'              # 
      VCS_COMMIT_ICON                $'\uE821 '             # 
      VCS_BRANCH_ICON                $'\uE220 '             # 
      VCS_REMOTE_BRANCH_ICON         $'\u2192'              # →
      VCS_GIT_ICON                   $'\uE20E '             # 
      VCS_GIT_GITHUB_ICON            $'\uE20E '             #
      VCS_GIT_BITBUCKET_ICON         $'\uE20E '             #
      VCS_GIT_GITLAB_ICON            $'\uE20E '             #
      VCS_HG_ICON                    $'\uE1C3 '             # 
      VCS_SVN_ICON                   '(svn) '
      RUST_ICON                      ''
      PYTHON_ICON                    $'\ue63c'             # 
      SWIFT_ICON                     ''
      GO_ICON                        ''
      PUBLIC_IP_ICON                 ''
      LOCK_ICON                      $'\UE138'              # 
      EXECUTION_TIME_ICON            $'\UE89C'              # 
      SSH_ICON                       '(ssh)'
      VPN_ICON                       '(vpn)'
      KUBERNETES_ICON                $'\U2388'              # ⎈
    )
  ;;
  'awesome-fontconfig')
    # fontconfig with awesome-font required! See
    # https://github.com/gabrielelana/awesome-terminal-fonts
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\uE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\uE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\uE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\uE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\u21B5'              # ↵
      ROOT_ICON                      $'\uF201'              # 
      RUBY_ICON                      $'\uF219 '             # 
      AWS_ICON                       $'\uF270'              # 
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\uF013 '             # 
      TEST_ICON                      $'\uF291'              # 
      TODO_ICON                      $'\u2611'              # ☑
      BATTERY_ICON                   $'\U1F50B'             # 🔋
      DISK_ICON                      $'\uF0A0 '             # 
      OK_ICON                        $'\u2714'              # ✔
      FAIL_ICON                      $'\u2718'              # ✘
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\u2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\U2500'     # ╭─
      MULTILINE_NEWLINE_PROMPT_PREFIX  $'\u251C'$'\U2500'   # ├─
      MULTILINE_LAST_PROMPT_PREFIX   $'\u2570'$'\U2500 '    # ╰─
      APPLE_ICON                     $'\uF179'              # 
      WINDOWS_ICON                   $'\uF17A'              # 
      FREEBSD_ICON                   $'\U1F608 '            # 😈
      ANDROID_ICON                   $'\uE17B'              # 
      LINUX_ICON                     $'\uF17C'              # 
      SUNOS_ICON                     $'\uF185 '             # 
      HOME_ICON                      $'\uF015'              # 
      HOME_SUB_ICON                  $'\uF07C'              # 
      FOLDER_ICON                    $'\uF115'              # 
      NETWORK_ICON                   $'\uF09E'              # 
      LOAD_ICON                      $'\uF080 '             # 
      SWAP_ICON                      $'\uF0E4'              # 
      RAM_ICON                       $'\uF0E4'              # 
      SERVER_ICON                    $'\uF233'              # 
      VCS_UNTRACKED_ICON             $'\uF059'              # 
      VCS_UNSTAGED_ICON              $'\uF06A'              # 
      VCS_STAGED_ICON                $'\uF055'              # 
      VCS_STASH_ICON                 $'\uF01C '             # 
      VCS_INCOMING_CHANGES_ICON      $'\uF01A '             # 
      VCS_OUTGOING_CHANGES_ICON      $'\uF01B '             # 
      VCS_TAG_ICON                   $'\uF217 '             # 
      VCS_BOOKMARK_ICON              $'\uF27B'              # 
      VCS_COMMIT_ICON                $'\uF221 '             # 
      VCS_BRANCH_ICON                $'\uF126 '             # 
      VCS_REMOTE_BRANCH_ICON         $'\u2192'              # →
      VCS_GIT_ICON                   $'\uF1D3 '             # 
      VCS_GIT_GITHUB_ICON            $'\uF113 '             # 
      VCS_GIT_BITBUCKET_ICON         $'\uF171 '             # 
      VCS_GIT_GITLAB_ICON            $'\uF296 '             # 
      VCS_HG_ICON                    $'\uF0C3 '             # 
      VCS_SVN_ICON                   '(svn) '
      RUST_ICON                      $'\uE6A8'              #  
      PYTHON_ICON                    $'\ue63c'             # 
      SWIFT_ICON                     ''
      GO_ICON                        ''
      PUBLIC_IP_ICON                 ''
      LOCK_ICON                      $'\UF023'              # 
      EXECUTION_TIME_ICON            $'\uF253'
      SSH_ICON                       '(ssh)'
      VPN_ICON                       $'\uF023'
      KUBERNETES_ICON                $'\U2388'              # ⎈
    )
  ;;
  'nerdfont-complete'|'nerdfont-fontconfig')
    # nerd-font patched (complete) font required! See
    # https://github.com/ryanoasis/nerd-fonts
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\uE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\uE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\uE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\uE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\u21B5'              # ↵
      ROOT_ICON                      $'\uE614 '             # 
      RUBY_ICON                      $'\uF219 '             # 
      AWS_ICON                       $'\uF270'              # 
      AWS_EB_ICON                    $'\UF1BD  '            # 
      BACKGROUND_JOBS_ICON           $'\uF013 '             # 
      TEST_ICON                      $'\uF188'              # 
      TODO_ICON                      $'\uF133'              # 
      BATTERY_ICON                   $'\UF240 '             # 
      DISK_ICON                      $'\uF0A0'              # 
      OK_ICON                        $'\uF00C'              # 
      FAIL_ICON                      $'\uF00D'              # 
      SYMFONY_ICON                   $'\uE757'              # 
      NODE_ICON                      $'\uE617 '             # 
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\U2500'     # ╭─
      MULTILINE_NEWLINE_PROMPT_PREFIX  $'\u251C'$'\U2500'   # ├─
      MULTILINE_LAST_PROMPT_PREFIX   $'\u2570'$'\U2500 '    # ╰─
      APPLE_ICON                     $'\uF179'              # 
      WINDOWS_ICON                   $'\uF17A'              # 
      FREEBSD_ICON                   $'\UF30E '             # 
      ANDROID_ICON                   $'\uF17B'              # 
      LINUX_ICON                     $'\uF17C'              # 
      SUNOS_ICON                     $'\uF185 '             # 
      HOME_ICON                      $'\uF015'              # 
      HOME_SUB_ICON                  $'\uF07C'              # 
      FOLDER_ICON                    $'\uF115'              # 
      NETWORK_ICON                   $'\uF1EB'              # 
      LOAD_ICON                      $'\uF080 '             # 
      SWAP_ICON                      $'\uF464'              # 
      RAM_ICON                       $'\uF0E4'              # 
      SERVER_ICON                    $'\uF0AE'              # 
      VCS_UNTRACKED_ICON             $'\uF059'              # 
      VCS_UNSTAGED_ICON              $'\uF06A'              # 
      VCS_STAGED_ICON                $'\uF055'              # 
      VCS_STASH_ICON                 $'\uF01C '             # 
      VCS_INCOMING_CHANGES_ICON      $'\uF01A '             # 
      VCS_OUTGOING_CHANGES_ICON      $'\uF01B '             # 
      VCS_TAG_ICON                   $'\uF02B '             # 
      VCS_BOOKMARK_ICON              $'\uF461 '             # 
      VCS_COMMIT_ICON                $'\uE729 '             # 
      VCS_BRANCH_ICON                $'\uF126 '             # 
      VCS_REMOTE_BRANCH_ICON         $'\uE728 '             # 
      VCS_GIT_ICON                   $'\uF113 '             # 
      VCS_GIT_GITHUB_ICON            $'\uE709 '             # 
      VCS_GIT_BITBUCKET_ICON         $'\uE703 '             # 
      VCS_GIT_GITLAB_ICON            $'\uF296 '             # 
      VCS_HG_ICON                    $'\uF0C3 '             # 
      VCS_SVN_ICON                   $'\uE72D '             # 
      RUST_ICON                      $'\uE7A8 '             # 
      PYTHON_ICON                    $'\UE73C '             # 
      SWIFT_ICON                     $'\uE755'              # 
      GO_ICON                        $'\uE626'              # 
      PUBLIC_IP_ICON                 $'\UF0AC'              # 
      LOCK_ICON                      $'\UF023'              # 
      EXECUTION_TIME_ICON            $'\uF252'              # 
      SSH_ICON                       $'\uF489'              # 
      VPN_ICON                       '(vpn)'
      KUBERNETES_ICON                $'\U2388'              # ⎈
    )
  ;;
  *)
    # Powerline-Patched Font required!
    # See https://github.com/Lokaltog/powerline-fonts
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    icons=(
      LEFT_SEGMENT_SEPARATOR         $'\uE0B0'              # 
      RIGHT_SEGMENT_SEPARATOR        $'\uE0B2'              # 
      LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
      LEFT_SUBSEGMENT_SEPARATOR      $'\uE0B1'              # 
      RIGHT_SUBSEGMENT_SEPARATOR     $'\uE0B3'              # 
      CARRIAGE_RETURN_ICON           $'\u21B5'              # ↵
      ROOT_ICON                      $'\u26A1'              # ⚡
      RUBY_ICON                      ''
      AWS_ICON                       'AWS:'
      AWS_EB_ICON                    $'\U1F331 '            # 🌱
      BACKGROUND_JOBS_ICON           $'\u2699'              # ⚙
      TEST_ICON                      ''
      TODO_ICON                      $'\u2611'              # ☑
      BATTERY_ICON                   $'\U1F50B'             # 🔋
      DISK_ICON                      $'hdd '
      OK_ICON                        $'\u2714'              # ✔
      FAIL_ICON                      $'\u2718'              # ✘
      SYMFONY_ICON                   'SF'
      NODE_ICON                      $'\u2B22'              # ⬢
      MULTILINE_FIRST_PROMPT_PREFIX  $'\u256D'$'\U2500'     # ╭─
      MULTILINE_NEWLINE_PROMPT_PREFIX  $'\u251C'$'\U2500'   # ├─
      MULTILINE_LAST_PROMPT_PREFIX   $'\u2570'$'\U2500 '    # ╰─
      APPLE_ICON                     'OSX'
      WINDOWS_ICON                   'WIN'
      FREEBSD_ICON                   'BSD'
      ANDROID_ICON                   'And'
      LINUX_ICON                     'Lx'
      SUNOS_ICON                     'Sun'
      HOME_ICON                      ''
      HOME_SUB_ICON                  ''
      FOLDER_ICON                    ''
      NETWORK_ICON                   'IP'
      LOAD_ICON                      'L'
      SWAP_ICON                      'SWP'
      RAM_ICON                       'RAM'
      SERVER_ICON                    ''
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
      VCS_GIT_GITHUB_ICON            ''
      VCS_GIT_BITBUCKET_ICON         ''
      VCS_GIT_GITLAB_ICON            ''
      VCS_HG_ICON                    ''
      VCS_SVN_ICON                   ''
      RUST_ICON                      ''
      PYTHON_ICON                    ''
      SWIFT_ICON                     'Swift'
      GO_ICON                        'Go'
      PUBLIC_IP_ICON                 ''
      LOCK_ICON                      $'\UE0A2'
      EXECUTION_TIME_ICON            'Dur'
      SSH_ICON                       '(ssh)'
      VPN_ICON                       '(vpn)'
      KUBERNETES_ICON                $'\U2388'              # ⎈
    )
  ;;
esac

# Override the above icon settings with any user-defined variables.
case $POWERLEVEL9K_MODE in
  'flat')
    # Set the right locale to protect special characters
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
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

# Get a list of configured icons
#   * $1 string - If "original", then the original icons are printed,
#                 otherwise "print_icon" is used, which takes the users
#                 overrides into account.
get_icon_names() {
  # Iterate over a ordered list of keys of the icons array
  for key in ${(@kon)icons}; do
    echo -n "POWERLEVEL9K_$key: "
    if [[ "${1}" == "original" ]]; then
      # print the original icons as they are defined in the array above
      echo "${icons[$key]}"
    else
      # print the icons as they are configured by the user
      echo "$(print_icon "$key")"
    fi
  done
}
