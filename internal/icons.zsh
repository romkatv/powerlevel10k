typeset -gA icons

function _p9k_init_icons() {
  [[ $+_p9k__icon_mode == 1 && $_p9k__icon_mode == $POWERLEVEL9K_MODE/$POWERLEVEL9K_LEGACY_ICON_SPACING ]] && return
  typeset -g _p9k__icon_mode=$POWERLEVEL9K_MODE/$POWERLEVEL9K_LEGACY_ICON_SPACING

  if [[ $POWERLEVEL9K_LEGACY_ICON_SPACING == true ]]; then
    local s=
    local q=' '
  else
    local s=' '
    local q=
  fi

  case $POWERLEVEL9K_MODE in
    'flat'|'awesome-patched')
      # Awesome-Patched Font required! See:
      # https://github.com/gabrielelana/awesome-terminal-fonts/tree/patching-strategy/patched
      icons=(
        RULER_CHAR                     '\u2500'               # ─
        LEFT_SEGMENT_SEPARATOR         '\uE0B0'               # 
        RIGHT_SEGMENT_SEPARATOR        '\uE0B2'               # 
        LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
        LEFT_SUBSEGMENT_SEPARATOR      '\uE0B1'               # 
        RIGHT_SUBSEGMENT_SEPARATOR     '\uE0B3'               # 
        CARRIAGE_RETURN_ICON           '\u21B5'$s             # ↵
        ROOT_ICON                      '\uE801'               # 
        SUDO_ICON                      '\uE0A2'               # 
        RUBY_ICON                      '\uE847 '              # 
        AWS_ICON                       '\uE895'$s             # 
        AWS_EB_ICON                    '\U1F331'$q            # 🌱
        BACKGROUND_JOBS_ICON           '\uE82F '              # 
        TEST_ICON                      '\uE891'$s             # 
        TODO_ICON                      '\u2611'               # ☑
        BATTERY_ICON                   '\uE894'$s             # 
        DISK_ICON                      '\uE1AE '              # 
        OK_ICON                        '\u2714'               # ✔
        FAIL_ICON                      '\u2718'               # ✘
        SYMFONY_ICON                   'SF'
        NODE_ICON                      '\u2B22'$s             # ⬢
        NODEJS_ICON                    '\u2B22'$s             # ⬢
        MULTILINE_FIRST_PROMPT_PREFIX  '\u256D\U2500'         # ╭─
        MULTILINE_NEWLINE_PROMPT_PREFIX '\u251C\U2500'        # ├─
        MULTILINE_LAST_PROMPT_PREFIX   '\u2570\U2500 '        # ╰─
        APPLE_ICON                     '\uE26E'$s             # 
        WINDOWS_ICON                   '\uE26F'$s             # 
        FREEBSD_ICON                   '\U1F608'$q            # 😈
        ANDROID_ICON                   '\uE270'$s             # 
        LINUX_ICON                     '\uE271'$s             # 
        LINUX_ARCH_ICON                '\uE271'$s             # 
        LINUX_DEBIAN_ICON              '\uE271'$s             # 
        LINUX_RASPBIAN_ICON            '\uE271'$s             # 
        LINUX_UBUNTU_ICON              '\uE271'$s             # 
        LINUX_CENTOS_ICON              '\uE271'$s             # 
        LINUX_COREOS_ICON              '\uE271'$s             # 
        LINUX_ELEMENTARY_ICON          '\uE271'$s             # 
        LINUX_MINT_ICON                '\uE271'$s             # 
        LINUX_FEDORA_ICON              '\uE271'$s             # 
        LINUX_GENTOO_ICON              '\uE271'$s             # 
        LINUX_MAGEIA_ICON              '\uE271'$s             # 
        LINUX_NIXOS_ICON               '\uE271'$s             # 
        LINUX_MANJARO_ICON             '\uE271'$s             # 
        LINUX_DEVUAN_ICON              '\uE271'$s             # 
        LINUX_ALPINE_ICON              '\uE271'$s             # 
        LINUX_AOSC_ICON                '\uE271'$s             # 
        LINUX_OPENSUSE_ICON            '\uE271'$s             # 
        LINUX_SABAYON_ICON             '\uE271'$s             # 
        LINUX_SLACKWARE_ICON           '\uE271'$s             # 
        SUNOS_ICON                     '\U1F31E'$q            # 🌞
        HOME_ICON                      '\uE12C'$s             # 
        HOME_SUB_ICON                  '\uE18D'$s             # 
        FOLDER_ICON                    '\uE818'$s             # 
        NETWORK_ICON                   '\uE1AD'$s             # 
        ETC_ICON                       '\uE82F'$s             # 
        LOAD_ICON                      '\uE190 '              # 
        SWAP_ICON                      '\uE87D'$s             # 
        RAM_ICON                       '\uE1E2 '              # 
        SERVER_ICON                    '\uE895'$s             # 
        VCS_UNTRACKED_ICON             '\uE16C'$s             # 
        VCS_UNSTAGED_ICON              '\uE17C'$s             # 
        VCS_STAGED_ICON                '\uE168'$s             # 
        VCS_STASH_ICON                 '\uE133 '              # 
        #VCS_INCOMING_CHANGES_ICON     '\uE1EB '              # 
        #VCS_INCOMING_CHANGES_ICON     '\uE80D '              # 
        VCS_INCOMING_CHANGES_ICON      '\uE131 '              # 
        #VCS_OUTGOING_CHANGES_ICON     '\uE1EC '              # 
        #VCS_OUTGOING_CHANGES_ICON     '\uE80E '              # 
        VCS_OUTGOING_CHANGES_ICON      '\uE132 '              # 
        VCS_TAG_ICON                   '\uE817 '              # 
        VCS_BOOKMARK_ICON              '\uE87B'               # 
        VCS_COMMIT_ICON                '\uE821 '              # 
        VCS_BRANCH_ICON                '\uE220 '              # 
        VCS_REMOTE_BRANCH_ICON         '\u2192'               # →
        VCS_LOADING_ICON               ''
        VCS_GIT_ICON                   '\uE20E '              # 
        VCS_GIT_GITHUB_ICON            '\uE20E '              #
        VCS_GIT_BITBUCKET_ICON         '\uE20E '              #
        VCS_GIT_GITLAB_ICON            '\uE20E '              #
        VCS_HG_ICON                    '\uE1C3 '              # 
        VCS_SVN_ICON                   'svn'$q
        RUST_ICON                      'R'
        PYTHON_ICON                    '\uE63C'$s             #  (doesn't always work)
        SWIFT_ICON                     'Swift'
        GO_ICON                        'Go'
        PUBLIC_IP_ICON                 'IP'
        LOCK_ICON                      '\UE138'               # 
        EXECUTION_TIME_ICON            '\UE89C'$s             # 
        SSH_ICON                       'ssh'
        VPN_ICON                       '\UE138'
        KUBERNETES_ICON                '\U2388'$s             # ⎈
        DROPBOX_ICON                   '\UF16B'$s             #  (doesn't always work)
        DATE_ICON                      '\uE184'$s             # 
        TIME_ICON                      '\uE12E'$s             # 
        JAVA_ICON                      '\U2615'               # ☕︎
        LARAVEL_ICON                   ''
        RANGER_ICON                    '\u2B50'               # ⭐
        MIDNIGHT_COMMANDER_ICON        'mc'
        VIM_ICON                       'vim'
        TERRAFORM_ICON                 'tf'
        PROXY_ICON                     '\u2B82'               # ⮂
        DOTNET_ICON                    '.NET'
        DOTNET_CORE_ICON               '.NET'
        AZURE_ICON                     '\u2601'               # ☁
        DIRENV_ICON                    '\u25BC'               # ▼
        FLUTTER_ICON                   'F'
        GCLOUD_ICON                    'G'
        LUA_ICON                       'lua'
        PERL_ICON                      'perl'
        NNN_ICON                       'nnn'
        TIMEWARRIOR_ICON               'tw'
        NIX_SHELL_ICON                 'nix'
        WIFI_ICON                      'WiFi'
        ERLANG_ICON                    'erl'
        ELIXIR_ICON                    'elixir'
        POSTGRES_ICON                  'postgres'
      )
    ;;
    'awesome-fontconfig')
      # fontconfig with awesome-font required! See
      # https://github.com/gabrielelana/awesome-terminal-fonts
      icons=(
        RULER_CHAR                     '\u2500'               # ─
        LEFT_SEGMENT_SEPARATOR         '\uE0B0'               # 
        RIGHT_SEGMENT_SEPARATOR        '\uE0B2'               # 
        LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
        LEFT_SUBSEGMENT_SEPARATOR      '\uE0B1'               # 
        RIGHT_SUBSEGMENT_SEPARATOR     '\uE0B3'               # 
        CARRIAGE_RETURN_ICON           '\u21B5'               # ↵
        ROOT_ICON                      '\uF201'$s             # 
        SUDO_ICON                      '\uF09C'$s             # 
        RUBY_ICON                      '\uF219 '              # 
        AWS_ICON                       '\uF270'$s             # 
        AWS_EB_ICON                    '\U1F331'$q            # 🌱
        BACKGROUND_JOBS_ICON           '\uF013 '              # 
        TEST_ICON                      '\uF291'$s             # 
        TODO_ICON                      '\u2611'               # ☑
        BATTERY_ICON                   '\U1F50B'              # 🔋
        DISK_ICON                      '\uF0A0 '              # 
        OK_ICON                        '\u2714'               # ✔
        FAIL_ICON                      '\u2718'               # ✘
        SYMFONY_ICON                   'SF'
        NODE_ICON                      '\u2B22'               # ⬢
        NODEJS_ICON                    '\u2B22'               # ⬢
        MULTILINE_FIRST_PROMPT_PREFIX  '\u256D\U2500'         # ╭─
        MULTILINE_NEWLINE_PROMPT_PREFIX '\u251C\U2500'        # ├─
        MULTILINE_LAST_PROMPT_PREFIX   '\u2570\U2500 '        # ╰─
        APPLE_ICON                     '\uF179'$s             # 
        WINDOWS_ICON                   '\uF17A'$s             # 
        FREEBSD_ICON                   '\U1F608'$q            # 😈
        ANDROID_ICON                   '\uE17B'$s             #  (doesn't always work)
        LINUX_ICON                     '\uF17C'$s             # 
        LINUX_ARCH_ICON                '\uF17C'$s             # 
        LINUX_DEBIAN_ICON              '\uF17C'$s             # 
        LINUX_RASPBIAN_ICON            '\uF17C'$s             # 
        LINUX_UBUNTU_ICON              '\uF17C'$s             # 
        LINUX_CENTOS_ICON              '\uF17C'$s             # 
        LINUX_COREOS_ICON              '\uF17C'$s             # 
        LINUX_ELEMENTARY_ICON          '\uF17C'$s             # 
        LINUX_MINT_ICON                '\uF17C'$s             # 
        LINUX_FEDORA_ICON              '\uF17C'$s             # 
        LINUX_GENTOO_ICON              '\uF17C'$s             # 
        LINUX_MAGEIA_ICON              '\uF17C'$s             # 
        LINUX_NIXOS_ICON               '\uF17C'$s             # 
        LINUX_MANJARO_ICON             '\uF17C'$s             # 
        LINUX_DEVUAN_ICON              '\uF17C'$s             # 
        LINUX_ALPINE_ICON              '\uF17C'$s             # 
        LINUX_AOSC_ICON                '\uF17C'$s             # 
        LINUX_OPENSUSE_ICON            '\uF17C'$s             # 
        LINUX_SABAYON_ICON             '\uF17C'$s             # 
        LINUX_SLACKWARE_ICON           '\uF17C'$s             # 
        SUNOS_ICON                     '\uF185 '              # 
        HOME_ICON                      '\uF015'$s             # 
        HOME_SUB_ICON                  '\uF07C'$s             # 
        FOLDER_ICON                    '\uF115'$s             # 
        ETC_ICON                       '\uF013 '              # 
        NETWORK_ICON                   '\uF09E'$s             # 
        LOAD_ICON                      '\uF080 '              # 
        SWAP_ICON                      '\uF0E4'$s             # 
        RAM_ICON                       '\uF0E4'$s             # 
        SERVER_ICON                    '\uF233'$s             # 
        VCS_UNTRACKED_ICON             '\uF059'$s             # 
        VCS_UNSTAGED_ICON              '\uF06A'$s             # 
        VCS_STAGED_ICON                '\uF055'$s             # 
        VCS_STASH_ICON                 '\uF01C '              # 
        VCS_INCOMING_CHANGES_ICON      '\uF01A '              # 
        VCS_OUTGOING_CHANGES_ICON      '\uF01B '              # 
        VCS_TAG_ICON                   '\uF217 '              # 
        VCS_BOOKMARK_ICON              '\uF27B '              # 
        VCS_COMMIT_ICON                '\uF221 '              # 
        VCS_BRANCH_ICON                '\uF126 '              # 
        VCS_REMOTE_BRANCH_ICON         '\u2192'               # →
        VCS_LOADING_ICON               ''
        VCS_GIT_ICON                   '\uF1D3 '              # 
        VCS_GIT_GITHUB_ICON            '\uF113 '              # 
        VCS_GIT_BITBUCKET_ICON         '\uF171 '              # 
        VCS_GIT_GITLAB_ICON            '\uF296 '              # 
        VCS_HG_ICON                    '\uF0C3 '              # 
        VCS_SVN_ICON                   'svn'$q
        RUST_ICON                      '\uE6A8'               # 
        PYTHON_ICON                    '\uE63C'$s             # 
        SWIFT_ICON                     'Swift'
        GO_ICON                        'Go'
        PUBLIC_IP_ICON                 'IP'
        LOCK_ICON                      '\UF023'               # 
        EXECUTION_TIME_ICON            '\uF253'$s             # 
        SSH_ICON                       'ssh'
        VPN_ICON                       '\uF023' 
        KUBERNETES_ICON                '\U2388'               # ⎈
        DROPBOX_ICON                   '\UF16B'$s             # 
        DATE_ICON                      '\uF073 '              # 
        TIME_ICON                      '\uF017 '              # 
        JAVA_ICON                      '\U2615'               # ☕︎
        LARAVEL_ICON                   ''
        RANGER_ICON                    '\u2B50'               # ⭐
        MIDNIGHT_COMMANDER_ICON        'mc'
        VIM_ICON                       'vim'
        TERRAFORM_ICON                 'tf'
        PROXY_ICON                     '\u2B82'               # ⮂
        DOTNET_ICON                    '.NET'
        DOTNET_CORE_ICON               '.NET'
        AZURE_ICON                     '\u2601'               # ☁
        DIRENV_ICON                    '\u25BC'               # ▼
        FLUTTER_ICON                   'F'
        GCLOUD_ICON                    'G'
        LUA_ICON                       'lua'
        PERL_ICON                      'perl'
        NNN_ICON                       'nnn'
        TIMEWARRIOR_ICON               'tw'
        NIX_SHELL_ICON                 'nix'
        WIFI_ICON                      'WiFi'
        ERLANG_ICON                    'erl'
        ELIXIR_ICON                    'elixir'
        POSTGRES_ICON                  'postgres'
      )
    ;;
    'awesome-mapped-fontconfig')
      # mapped fontconfig with awesome-font required! See
      # https://github.com/gabrielelana/awesome-terminal-fonts
      # don't forget to source the font maps in your startup script
      if [ -z "$AWESOME_GLYPHS_LOADED" ]; then
          echo "Powerlevel9k warning: Awesome-Font mappings have not been loaded.
          Source a font mapping in your shell config, per the Awesome-Font docs
          (https://github.com/gabrielelana/awesome-terminal-fonts),
          Or use a different Powerlevel9k font configuration.";
      fi
      icons=(
        RULER_CHAR                     '\u2500'                                       # ─
        LEFT_SEGMENT_SEPARATOR         '\uE0B0'                                       # 
        RIGHT_SEGMENT_SEPARATOR        '\uE0B2'                                       # 
        LEFT_SEGMENT_END_SEPARATOR     ' '                                            # Whitespace
        LEFT_SUBSEGMENT_SEPARATOR      '\uE0B1'                                       # 
        RIGHT_SUBSEGMENT_SEPARATOR     '\uE0B3'                                       # 
        CARRIAGE_RETURN_ICON           '\u21B5'                                       # ↵
        ROOT_ICON                      "${CODEPOINT_OF_OCTICONS_ZAP:+\\u$CODEPOINT_OF_OCTICONS_ZAP}"
        SUDO_ICON                      "${CODEPOINT_OF_AWESOME_UNLOCK:+\\u$CODEPOINT_OF_AWESOME_UNLOCK$s}"
        RUBY_ICON                      "${CODEPOINT_OF_OCTICONS_RUBY:+\\u$CODEPOINT_OF_OCTICONS_RUBY }"
        AWS_ICON                       "${CODEPOINT_OF_AWESOME_SERVER:+\\u$CODEPOINT_OF_AWESOME_SERVER$s}"
        AWS_EB_ICON                    '\U1F331'$q                                      # 🌱
        BACKGROUND_JOBS_ICON           "${CODEPOINT_OF_AWESOME_COG:+\\u$CODEPOINT_OF_AWESOME_COG }"
        TEST_ICON                      "${CODEPOINT_OF_AWESOME_BUG:+\\u$CODEPOINT_OF_AWESOME_BUG$s}"
        TODO_ICON                      "${CODEPOINT_OF_AWESOME_CHECK_SQUARE_O:+\\u$CODEPOINT_OF_AWESOME_CHECK_SQUARE_O$s}"
        BATTERY_ICON                   "${CODEPOINT_OF_AWESOME_BATTERY_FULL:+\\U$CODEPOINT_OF_AWESOME_BATTERY_FULL$s}"
        DISK_ICON                      "${CODEPOINT_OF_AWESOME_HDD_O:+\\u$CODEPOINT_OF_AWESOME_HDD_O }"
        OK_ICON                        "${CODEPOINT_OF_AWESOME_CHECK:+\\u$CODEPOINT_OF_AWESOME_CHECK$s}"
        FAIL_ICON                      "${CODEPOINT_OF_AWESOME_TIMES:+\\u$CODEPOINT_OF_AWESOME_TIMES}"
        SYMFONY_ICON                   'SF'
        NODE_ICON                      '\u2B22'                                       # ⬢
        NODEJS_ICON                    '\u2B22'                                       # ⬢
        MULTILINE_FIRST_PROMPT_PREFIX  '\u256D\U2500'                                 # ╭─
        MULTILINE_NEWLINE_PROMPT_PREFIX '\u251C\U2500'                                # ├─
        MULTILINE_LAST_PROMPT_PREFIX   '\u2570\U2500 '                                # ╰─
        APPLE_ICON                     "${CODEPOINT_OF_AWESOME_APPLE:+\\u$CODEPOINT_OF_AWESOME_APPLE$s}"
        FREEBSD_ICON                   '\U1F608'$q                                    # 😈
        LINUX_ICON                     "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_ARCH_ICON                "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_DEBIAN_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_RASPBIAN_ICON            "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_UBUNTU_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_CENTOS_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_COREOS_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_ELEMENTARY_ICON          "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_MINT_ICON                "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_FEDORA_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_GENTOO_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_MAGEIA_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_NIXOS_ICON               "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_MANJARO_ICON             "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_DEVUAN_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_ALPINE_ICON              "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_AOSC_ICON                "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_OPENSUSE_ICON            "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_SABAYON_ICON             "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        LINUX_SLACKWARE_ICON           "${CODEPOINT_OF_AWESOME_LINUX:+\\u$CODEPOINT_OF_AWESOME_LINUX$s}"
        SUNOS_ICON                     "${CODEPOINT_OF_AWESOME_SUN_O:+\\u$CODEPOINT_OF_AWESOME_SUN_O }"
        HOME_ICON                      "${CODEPOINT_OF_AWESOME_HOME:+\\u$CODEPOINT_OF_AWESOME_HOME$s}"
        HOME_SUB_ICON                  "${CODEPOINT_OF_AWESOME_FOLDER_OPEN:+\\u$CODEPOINT_OF_AWESOME_FOLDER_OPEN$s}"
        FOLDER_ICON                    "${CODEPOINT_OF_AWESOME_FOLDER_O:+\\u$CODEPOINT_OF_AWESOME_FOLDER_O$s}"
        ETC_ICON                       "${CODEPOINT_OF_AWESOME_COG:+\\u$CODEPOINT_OF_AWESOME_COG }"
        NETWORK_ICON                   "${CODEPOINT_OF_AWESOME_RSS:+\\u$CODEPOINT_OF_AWESOME_RSS$s}"
        LOAD_ICON                      "${CODEPOINT_OF_AWESOME_BAR_CHART:+\\u$CODEPOINT_OF_AWESOME_BAR_CHART }"
        SWAP_ICON                      "${CODEPOINT_OF_AWESOME_DASHBOARD:+\\u$CODEPOINT_OF_AWESOME_DASHBOARD$s}"
        RAM_ICON                       "${CODEPOINT_OF_AWESOME_DASHBOARD:+\\u$CODEPOINT_OF_AWESOME_DASHBOARD$s}"
        SERVER_ICON                    "${CODEPOINT_OF_AWESOME_SERVER:+\\u$CODEPOINT_OF_AWESOME_SERVER$s}"
        VCS_UNTRACKED_ICON             "${CODEPOINT_OF_AWESOME_QUESTION_CIRCLE:+\\u$CODEPOINT_OF_AWESOME_QUESTION_CIRCLE$s}"
        VCS_UNSTAGED_ICON              "${CODEPOINT_OF_AWESOME_EXCLAMATION_CIRCLE:+\\u$CODEPOINT_OF_AWESOME_EXCLAMATION_CIRCLE$s}"
        VCS_STAGED_ICON                "${CODEPOINT_OF_AWESOME_PLUS_CIRCLE:+\\u$CODEPOINT_OF_AWESOME_PLUS_CIRCLE$s}"
        VCS_STASH_ICON                 "${CODEPOINT_OF_AWESOME_INBOX:+\\u$CODEPOINT_OF_AWESOME_INBOX }"
        VCS_INCOMING_CHANGES_ICON      "${CODEPOINT_OF_AWESOME_ARROW_CIRCLE_DOWN:+\\u$CODEPOINT_OF_AWESOME_ARROW_CIRCLE_DOWN }"
        VCS_OUTGOING_CHANGES_ICON      "${CODEPOINT_OF_AWESOME_ARROW_CIRCLE_UP:+\\u$CODEPOINT_OF_AWESOME_ARROW_CIRCLE_UP }"
        VCS_TAG_ICON                   "${CODEPOINT_OF_AWESOME_TAG:+\\u$CODEPOINT_OF_AWESOME_TAG }"
        VCS_BOOKMARK_ICON              "${CODEPOINT_OF_OCTICONS_BOOKMARK:+\\u$CODEPOINT_OF_OCTICONS_BOOKMARK}"
        VCS_COMMIT_ICON                "${CODEPOINT_OF_OCTICONS_GIT_COMMIT:+\\u$CODEPOINT_OF_OCTICONS_GIT_COMMIT }"
        VCS_BRANCH_ICON                "${CODEPOINT_OF_OCTICONS_GIT_BRANCH:+\\u$CODEPOINT_OF_OCTICONS_GIT_BRANCH }"
        VCS_REMOTE_BRANCH_ICON         "${CODEPOINT_OF_OCTICONS_REPO_PUSH:+\\u$CODEPOINT_OF_OCTICONS_REPO_PUSH$s}"
        VCS_LOADING_ICON               ''
        VCS_GIT_ICON                   "${CODEPOINT_OF_AWESOME_GIT:+\\u$CODEPOINT_OF_AWESOME_GIT }"
        VCS_GIT_GITHUB_ICON            "${CODEPOINT_OF_AWESOME_GITHUB_ALT:+\\u$CODEPOINT_OF_AWESOME_GITHUB_ALT }"
        VCS_GIT_BITBUCKET_ICON         "${CODEPOINT_OF_AWESOME_BITBUCKET:+\\u$CODEPOINT_OF_AWESOME_BITBUCKET }"
        VCS_GIT_GITLAB_ICON            "${CODEPOINT_OF_AWESOME_GITLAB:+\\u$CODEPOINT_OF_AWESOME_GITLAB }"
        VCS_HG_ICON                    "${CODEPOINT_OF_AWESOME_FLASK:+\\u$CODEPOINT_OF_AWESOME_FLASK }"
        VCS_SVN_ICON                   'svn'$q
        RUST_ICON                      '\uE6A8'                                       # 
        PYTHON_ICON                    '\U1F40D'                                      # 🐍
        SWIFT_ICON                     '\uE655'$s                                     # 
        PUBLIC_IP_ICON                 "${CODEPOINT_OF_AWESOME_GLOBE:+\\u$CODEPOINT_OF_AWESOME_GLOBE$s}"
        LOCK_ICON                      "${CODEPOINT_OF_AWESOME_LOCK:+\\u$CODEPOINT_OF_AWESOME_LOCK}"
        EXECUTION_TIME_ICON            "${CODEPOINT_OF_AWESOME_HOURGLASS_END:+\\u$CODEPOINT_OF_AWESOME_HOURGLASS_END$s}"
        SSH_ICON                       'ssh'
        VPN_ICON                       "${CODEPOINT_OF_AWESOME_LOCK:+\\u$CODEPOINT_OF_AWESOME_LOCK}"
        KUBERNETES_ICON                '\U2388'                                       # ⎈
        DROPBOX_ICON                   "${CODEPOINT_OF_AWESOME_DROPBOX:+\\u$CODEPOINT_OF_AWESOME_DROPBOX$s}"
        DATE_ICON                      '\uF073 '                                      # 
        TIME_ICON                      '\uF017 '                                      # 
        JAVA_ICON                      '\U2615'                                       # ☕︎
        LARAVEL_ICON                   ''
        RANGER_ICON                    '\u2B50'                                       # ⭐
        MIDNIGHT_COMMANDER_ICON        'mc'
        VIM_ICON                       'vim'
        TERRAFORM_ICON                 'tf'
        PROXY_ICON                     '\u2B82'                                       # ⮂
        DOTNET_ICON                    '.NET'
        DOTNET_CORE_ICON               '.NET'
        AZURE_ICON                     '\u2601'                                       # ☁
        DIRENV_ICON                    '\u25BC'                                       # ▼
        FLUTTER_ICON                   'F'
        GCLOUD_ICON                    'G'
        LUA_ICON                       'lua'
        PERL_ICON                      'perl'
        NNN_ICON                       'nnn'
        TIMEWARRIOR_ICON               'tw'
        NIX_SHELL_ICON                 'nix'
        WIFI_ICON                      'WiFi'
        ERLANG_ICON                    'erl'
        ELIXIR_ICON                    'elixir'
        POSTGRES_ICON                  'postgres'
      )
    ;;
    'nerdfont-complete'|'nerdfont-fontconfig')
      # nerd-font patched (complete) font required! See
      # https://github.com/ryanoasis/nerd-fonts
      # http://nerdfonts.com/#cheat-sheet
      icons=(
        RULER_CHAR                     '\u2500'               # ─
        LEFT_SEGMENT_SEPARATOR         '\uE0B0'               # 
        RIGHT_SEGMENT_SEPARATOR        '\uE0B2'               # 
        LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
        LEFT_SUBSEGMENT_SEPARATOR      '\uE0B1'               # 
        RIGHT_SUBSEGMENT_SEPARATOR     '\uE0B3'               # 
        CARRIAGE_RETURN_ICON           '\u21B5'               # ↵
        ROOT_ICON                      '\uE614'$q             # 
        SUDO_ICON                      '\uF09C'$s             # 
        RUBY_ICON                      '\uF219 '              # 
        AWS_ICON                       '\uF270'$s             # 
        AWS_EB_ICON                    '\UF1BD'$q$q           # 
        BACKGROUND_JOBS_ICON           '\uF013 '              # 
        TEST_ICON                      '\uF188'$s             # 
        TODO_ICON                      '\u2611'               # ☑
        BATTERY_ICON                   '\UF240 '              # 
        DISK_ICON                      '\uF0A0'$s             # 
        OK_ICON                        '\uF00C'$s             # 
        FAIL_ICON                      '\uF00D'               # 
        SYMFONY_ICON                   '\uE757'               # 
        NODE_ICON                      '\uE617 '              # 
        NODEJS_ICON                    '\uE617 '              # 
        MULTILINE_FIRST_PROMPT_PREFIX  '\u256D\U2500'         # ╭─
        MULTILINE_NEWLINE_PROMPT_PREFIX '\u251C\U2500'        # ├─
        MULTILINE_LAST_PROMPT_PREFIX   '\u2570\U2500 '        # ╰─
        APPLE_ICON                     '\uF179'               # 
        WINDOWS_ICON                   '\uF17A'$s             # 
        FREEBSD_ICON                   '\UF30C '              # 
        ANDROID_ICON                   '\uF17B'               # 
        LINUX_ARCH_ICON                '\uF303'               # 
        LINUX_CENTOS_ICON              '\uF304'$s             # 
        LINUX_COREOS_ICON              '\uF305'$s             # 
        LINUX_DEBIAN_ICON              '\uF306'               # 
        LINUX_RASPBIAN_ICON            '\uF315'               # 
        LINUX_ELEMENTARY_ICON          '\uF309'$s             # 
        LINUX_FEDORA_ICON              '\uF30a'$s             # 
        LINUX_GENTOO_ICON              '\uF30d'$s             # 
        LINUX_MAGEIA_ICON              '\uF310'               # 
        LINUX_MINT_ICON                '\uF30e'$s             # 
        LINUX_NIXOS_ICON               '\uF313'$s             # 
        LINUX_MANJARO_ICON             '\uF312'$s             # 
        LINUX_DEVUAN_ICON              '\uF307'$s             # 
        LINUX_ALPINE_ICON              '\uF300'$s             # 
        LINUX_AOSC_ICON                '\uF301'$s             # 
        LINUX_OPENSUSE_ICON            '\uF314'$s             # 
        LINUX_SABAYON_ICON             '\uF317'$s             # 
        LINUX_SLACKWARE_ICON           '\uF319'$s             # 
        LINUX_UBUNTU_ICON              '\uF31b'$s             # 
        LINUX_ICON                     '\uF17C'               # 
        SUNOS_ICON                     '\uF185 '              # 
        HOME_ICON                      '\uF015'$s             # 
        HOME_SUB_ICON                  '\uF07C'$s             # 
        FOLDER_ICON                    '\uF115'$s             # 
        ETC_ICON                       '\uF013'$s             # 
        NETWORK_ICON                   '\uFBF1'$s             # ﯱ
        LOAD_ICON                      '\uF080 '              # 
        SWAP_ICON                      '\uF464'$s             # 
        RAM_ICON                       '\uF0E4'$s             # 
        SERVER_ICON                    '\uF0AE'$s             # 
        VCS_UNTRACKED_ICON             '\uF059'$s             # 
        VCS_UNSTAGED_ICON              '\uF06A'$s             # 
        VCS_STAGED_ICON                '\uF055'$s             # 
        VCS_STASH_ICON                 '\uF01C '              # 
        VCS_INCOMING_CHANGES_ICON      '\uF01A '              # 
        VCS_OUTGOING_CHANGES_ICON      '\uF01B '              # 
        VCS_TAG_ICON                   '\uF02B '              # 
        VCS_BOOKMARK_ICON              '\uF461 '              # 
        VCS_COMMIT_ICON                '\uE729 '              # 
        VCS_BRANCH_ICON                '\uF126 '              # 
        VCS_REMOTE_BRANCH_ICON         '\uE728 '              # 
        VCS_LOADING_ICON               ''
        VCS_GIT_ICON                   '\uF1D3 '              # 
        VCS_GIT_GITHUB_ICON            '\uF113 '              # 
        VCS_GIT_BITBUCKET_ICON         '\uE703 '              # 
        VCS_GIT_GITLAB_ICON            '\uF296 '              # 
        VCS_HG_ICON                    '\uF0C3 '              # 
        VCS_SVN_ICON                   '\uE72D'$q             # 
        RUST_ICON                      '\uE7A8'$q             # 
        PYTHON_ICON                    '\UE73C '              # 
        SWIFT_ICON                     '\uE755'               # 
        GO_ICON                        '\uE626'               # 
        PUBLIC_IP_ICON                 '\UF0AC'$s             # 
        LOCK_ICON                      '\UF023'               # 
        EXECUTION_TIME_ICON            '\uF252'$s             # 
        SSH_ICON                       '\uF489'$s             # 
        VPN_ICON                       '\UF023'
        KUBERNETES_ICON                '\U2388'               # ⎈
        DROPBOX_ICON                   '\UF16B'$s             # 
        DATE_ICON                      '\uF073 '              # 
        TIME_ICON                      '\uF017 '              # 
        JAVA_ICON                      '\uE738'               # 
        LARAVEL_ICON                   '\ue73f'$q             # 
        RANGER_ICON                    '\uF00b '              # 
        MIDNIGHT_COMMANDER_ICON        'mc'
        VIM_ICON                       '\uE62B'               # 
        TERRAFORM_ICON                 '\uF1BB '              # 
        PROXY_ICON                     '\u2B82'               # ⮂
        DOTNET_ICON                    '\uE77F'               # 
        DOTNET_CORE_ICON               '\uE77F'               # 
        AZURE_ICON                     '\uFD03'               # ﴃ
        DIRENV_ICON                    '\u25BC'               # ▼
        FLUTTER_ICON                   'F'
        GCLOUD_ICON                    '\uF7B7'               # 
        LUA_ICON                       '\uE620'               # 
        PERL_ICON                      '\uE769'               # 
        NNN_ICON                       'nnn'
        TIMEWARRIOR_ICON               '\uF49B'               # 
        NIX_SHELL_ICON                 '\uF313 '              # 
        WIFI_ICON                      '\uF1EB '              # 
        ERLANG_ICON                    '\uE7B1 '              # 
        ELIXIR_ICON                    '\uE62D'               # 
        POSTGRES_ICON                  '\uE76E'               # 
      )
    ;;
    *)
      # Powerline-Patched Font required!
      # See https://github.com/Lokaltog/powerline-fonts
      icons=(
        RULER_CHAR                     '\u2500'               # ─
        LEFT_SEGMENT_SEPARATOR         '\uE0B0'               # 
        RIGHT_SEGMENT_SEPARATOR        '\uE0B2'               # 
        LEFT_SEGMENT_END_SEPARATOR     ' '                    # Whitespace
        LEFT_SUBSEGMENT_SEPARATOR      '\uE0B1'               # 
        RIGHT_SUBSEGMENT_SEPARATOR     '\uE0B3'               # 
        CARRIAGE_RETURN_ICON           '\u21B5'               # ↵
        ROOT_ICON                      '\u26A1'               # ⚡
        SUDO_ICON                      ''
        RUBY_ICON                      'Ruby'
        AWS_ICON                       'AWS'
        AWS_EB_ICON                    '\U1F331'$q            # 🌱
        BACKGROUND_JOBS_ICON           '\u2699'               # ⚙
        TEST_ICON                      ''
        TODO_ICON                      '\u2206'               # ∆
        BATTERY_ICON                   '\U1F50B'              # 🔋
        DISK_ICON                      'hdd' 
        OK_ICON                        '\u2714'               # ✔
        FAIL_ICON                      '\u2718'               # ✘
        SYMFONY_ICON                   'SF'
        NODE_ICON                      'Node'
        NODEJS_ICON                    'Node'
        MULTILINE_FIRST_PROMPT_PREFIX  '\u256D\U2500'         # ╭─
        MULTILINE_NEWLINE_PROMPT_PREFIX '\u251C\U2500'        # ├─
        MULTILINE_LAST_PROMPT_PREFIX   '\u2570\U2500 '        # ╰─
        APPLE_ICON                     'OSX'
        WINDOWS_ICON                   'WIN'
        FREEBSD_ICON                   'BSD'
        ANDROID_ICON                   'And'
        LINUX_ICON                     'Lx'
        LINUX_ARCH_ICON                'Arc'
        LINUX_DEBIAN_ICON              'Deb'
        LINUX_RASPBIAN_ICON            'RPi'
        LINUX_UBUNTU_ICON              'Ubu'
        LINUX_CENTOS_ICON              'Cen'
        LINUX_COREOS_ICON              'Cor'
        LINUX_ELEMENTARY_ICON          'Elm'
        LINUX_MINT_ICON                'LMi'
        LINUX_FEDORA_ICON              'Fed'
        LINUX_GENTOO_ICON              'Gen'
        LINUX_MAGEIA_ICON              'Mag'
        LINUX_NIXOS_ICON               'Nix'
        LINUX_MANJARO_ICON             'Man'
        LINUX_DEVUAN_ICON              'Dev'
        LINUX_ALPINE_ICON              'Alp'
        LINUX_AOSC_ICON                'Aos'
        LINUX_OPENSUSE_ICON            'OSu'
        LINUX_SABAYON_ICON             'Sab'
        LINUX_SLACKWARE_ICON           'Sla'
        SUNOS_ICON                     'Sun'
        HOME_ICON                      ''
        HOME_SUB_ICON                  ''
        FOLDER_ICON                    ''
        ETC_ICON                       '\u2699'               # ⚙
        NETWORK_ICON                   'IP'
        LOAD_ICON                      'L'
        SWAP_ICON                      'SWP'
        RAM_ICON                       'RAM'
        SERVER_ICON                    ''
        VCS_UNTRACKED_ICON             '?'
        VCS_UNSTAGED_ICON              '\u25CF'               # ●
        VCS_STAGED_ICON                '\u271A'               # ✚
        VCS_STASH_ICON                 '\u235F'               # ⍟
        VCS_INCOMING_CHANGES_ICON      '\u2193'               # ↓
        VCS_OUTGOING_CHANGES_ICON      '\u2191'               # ↑
        VCS_TAG_ICON                   ''
        VCS_BOOKMARK_ICON              '\u263F'               # ☿
        VCS_COMMIT_ICON                ''
        VCS_BRANCH_ICON                '\uE0A0 '              # 
        VCS_REMOTE_BRANCH_ICON         '\u2192'               # →
        VCS_LOADING_ICON               ''
        VCS_GIT_ICON                   ''
        VCS_GIT_GITHUB_ICON            ''
        VCS_GIT_BITBUCKET_ICON         ''
        VCS_GIT_GITLAB_ICON            ''
        VCS_HG_ICON                    ''
        VCS_SVN_ICON                   ''
        RUST_ICON                      'R'
        PYTHON_ICON                    'Py'
        SWIFT_ICON                     'Swift'
        GO_ICON                        'Go'
        PUBLIC_IP_ICON                 'IP'
        LOCK_ICON                      '\UE0A2' 
        EXECUTION_TIME_ICON            ''
        SSH_ICON                       'ssh'
        VPN_ICON                       'vpn'
        KUBERNETES_ICON                '\U2388'               # ⎈
        DROPBOX_ICON                   'Dropbox'
        DATE_ICON                      ''
        TIME_ICON                      ''
        JAVA_ICON                      '\U2615'               # ☕︎
        LARAVEL_ICON                   ''
        RANGER_ICON                    '\u2B50'               # ⭐
        MIDNIGHT_COMMANDER_ICON        'mc'
        VIM_ICON                       'vim'
        TERRAFORM_ICON                 'tf'
        PROXY_ICON                     '\u2194'               # ↔
        DOTNET_ICON                    '.NET'
        DOTNET_CORE_ICON               '.NET'
        AZURE_ICON                     '\u2601'               # ☁
        DIRENV_ICON                    '\u25BC'               # ▼
        FLUTTER_ICON                   'F'
        GCLOUD_ICON                    'G'
        LUA_ICON                       'lua'
        PERL_ICON                      'perl'
        NNN_ICON                       'nnn'
        TIMEWARRIOR_ICON               'tw'
        NIX_SHELL_ICON                 'nix'
        WIFI_ICON                      'WiFi'
        ERLANG_ICON                    'erl'
        ELIXIR_ICON                    'elixir'
        POSTGRES_ICON                  'postgres'
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
      icons[LEFT_SEGMENT_SEPARATOR]='\u2B80'                  # ⮀
      icons[RIGHT_SEGMENT_SEPARATOR]='\u2B82'                 # ⮂
      icons[VCS_BRANCH_ICON]='@'
    ;;
  esac
}

# Sadly, this is a part of public API. Its use is emphatically discouraged.
function _p9k_print_icon() {
  _p9k_init_icons
  local icon_name=$1
  local var_name=POWERLEVEL9K_${icon_name}
  if [[ -n "${(tP)var_name}" ]]; then
    echo -n "${(P)var_name}"
  else
    echo -n "${icons[$icon_name]}"
  fi
}

# Prints a list of configured icons.
#
#   * $1 string - If "original", then the original icons are printed,
#                 otherwise "print_icon" is used, which takes the users
#                 overrides into account.
function _p9k_get_icon_names() {
  _p9k_init_icons
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
