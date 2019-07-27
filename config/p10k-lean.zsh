# Config for Powerlevel10k with lean prompt style. Doesn't require a custom font but can take
# advantage of it if available. The color scheme is suitable for dark terminal background.
#
# Once you've installed Powerlevel10k, run these commands to apply lean style.
#
#   curl -fsSL -o ~/p10k-lean.zsh https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh
#   echo 'source ~/p10k-lean.zsh' >>! ~/.zshrc
#
# To customize your prompt, open ~/p10k-lean.zsh in your favorite text editor, change it and
# restart ZSH. The file is well-documented.
#
# Tip: Looking for a nice color? Here's a one-liner to print colormap.
#
#   for i in {0..255}; do print -Pn "%${i}F${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'}; done

if [[ -o 'aliases' ]]; then
  # Temporarily disable aliases.
  'builtin' 'unsetopt' 'aliases'
  local p10k_lean_restore_aliases=1
else
  local p10k_lean_restore_aliases=0
fi

() {
  emulate -L zsh
  setopt no_unset

  # The list of segments shown on the left. Fill it with the most important segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      # =========================[ Line #1 ]=========================
      # os_icon               # os identifier
      dir                     # current directory
      vcs                     # git status
      # =========================[ Line #2 ]=========================
      newline
      prompt_char             # prompt symbol
  )

  # The list of segments shown on the right. Fill it with less important segments.
  # Right prompt on the last prompt line (where you are typing your commands) gets
  # automatically hidden when the input line reaches it. Right prompt above the
  # last prompt line gets hidden if it would overlap with left prompt.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      # =========================[ Line #1 ]=========================
      status                  # exit code of the last command
      command_execution_time  # duration of the last command
      background_jobs         # presence of background jobs
      # virtualenv            # python virtual environment (https://docs.python.org/3/library/venv.html)
      # anaconda              # conda environment (https://conda.io/)
      # pyenv                 # python environment (https://github.com/pyenv/pyenv)
      # nodenv                # node.js version from nodenv (https://github.com/nodenv/nodenv)
      # nvm                   # node.js version from nvm (https://github.com/nvm-sh/nvm)
      # nodeenv               # node.js environment (https://github.com/ekalinin/nodeenv)
      # node_version          # node.js version
      # kubecontext           # current kubernetes context (https://kubernetes.io/)
      # nordvpn               # nordvpn connection status, linux only (https://nordvpn.com/)
      # example               # example user-defined segment (see prompt_example function below)
      context                 # user@host
      # =========================[ Line #2 ]=========================
      newline
      # public_ip             # public IP address
      # battery               # internal battery
      # time                  # current time
  )

  # Basic style options that define the overall look of your prompt. You probably don't want to
  # change them.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol

  # To disable default icons for all segments, set POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=''.
  #
  # To enable default icons for all segments, don't define POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION
  # or set it to '${P9K_VISUAL_IDENTIFIER}'.
  #
  # To remove spaces from all default icons, set POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION
  # to '${P9K_VISUAL_IDENTIFIER// }'. You'll know that you you need this option if you see extra
  # spaces after icons.
  #
  # To enable default icons for one segment (e.g., dir), set
  # POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'.
  #
  # To assign a specific icon to one segment (e.g., dir), set
  # POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION='⭐'.
  #
  # To assign a specific icon to a segment in a given state (e.g., dir in state NOT_WRITABLE),
  # set POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='⭐'.
  #
  # Note: You can use $'\u2B50' instead of '⭐'. It's especially convenient when specifying
  # icons that your text editor cannot render. Don't forget to put $ and use single quotes when
  # defining icons via Unicode codepoints.
  #
  # Note: Many default icons cannot be displayed with system fonts. You'll need to install a
  # capable font to use them. See POWERLEVEL9K_MODE below.
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

  # This option makes a difference only when default icons are enabled for all or some prompt
  # segments (see POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION above). LOCK_ICON can be printed as
  # $'\uE0A2', $'\uE138' or $'\uF023' depending on POWERLEVEL9K_MODE. The correct value of this
  # parameter depends on the provider of the font your terminal is using.
  #
  #   Font Provider                    | POWERLEVEL9K_MODE
  #   ---------------------------------+-------------------
  #   Powerline                        | powerline
  #   Font Awesome                     | awesome-fontconfig
  #   Adobe Source Code Pro            | awesome-fontconfig
  #   Source Code Pro                  | awesome-fontconfig
  #   Awesome-Terminal Fonts (regular) | awesome-fontconfig
  #   Awesome-Terminal Fonts (patched) | awesome-patched
  #   Nerd Fonts                       | nerdfont-complete
  #   Other                            | compatible
  #
  # If this looks overwhelming, either stick with a preinstalled system font and set
  # POWERLEVEL9K_MODE=compatible, or install a font from https://github.com/ryanoasis/nerd-fonts
  # and set POWERLEVEL9K_MODE=nerdfont-complete. "Meslo LG S Regular Nerd Font Complete Mono" from
  # https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/S/Regular/complete is
  # very good.
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete

  # When set to true, icons appear before content on both sides of the prompt. When set
  # to false, icons go after content. If empty or not set, icons go before content in the left
  # prompt and after content in the right prompt.
  #
  # You can also override it for a specific segment:
  #
  #   POWERLEVEL9K_STATUS_ICON_BEFORE_CONTENT=false
  #
  # Or for a specific segment in specific state:
  #
  #   POWERLEVEL9K_DIR_NOT_WRITABLE_ICON_BEFORE_CONTENT=false
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true

  # Add an empty line before each prompt. If you set it to false, you might want to
  # set POWERLEVEL9K_SHOW_RULER=true or POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·' below.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Ruler, a.k.a. the horizontal line before each prompt. If you set it to true, you'll
  # probably want to set POWERLEVEL9K_PROMPT_ADD_NEWLINE=false above and
  # POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' ' below.
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_RULER_CHAR='─'        # reasonable alternative: '·'
  typeset -g POWERLEVEL9K_RULER_FOREGROUND=237

  # Filler between left and right prompt on the first prompt line. You can set it to '·' or '─'
  # to make it easier to see the alignment between left and right prompt and to separate prompt
  # from command output. It serves the same purpose as ruler (see above) without increasing
  # the number of prompt lines. You'll probably want to set POWERLEVEL9K_SHOW_RULER=false
  # if using this. You might also like POWERLEVEL9K_PROMPT_ADD_NEWLINE=false for more compact
  # prompt.
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    # The color of the filler.
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=237
    # Add a space between the end of left prompt and the filler.
    typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
    # Add a space between the filler and the start of right prompt.
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '
    # Start filler from the edge of the screen if there are no left segments on the first line.
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    # End filler on the edge of the screen if there are no right segments on the first line.
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi

  #################################[ os_icon: os identifier ]##################################
  # OS identifier color.
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=212
  # Display this icon instead of the default.
  # typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='⭐'

  ################################[ prompt_char: prompt symbol ]################################
  # Green prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=76
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=196
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='Ⅴ'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  ##################################[ dir: current directory ]##################################
  # Default current directory color.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=12
  # If directory is too long, shorten some of its segments to the shortest possible unique
  # prefix. The shortened directory can be tab-completed to the original.
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  # Replace removed segment suffixes with this symbol.
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  # Color of the shortened directory segments.
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=4
  # Color of the anchor directory segments. Anchor segments are never shortened. The first
  # segment is always an anchor.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  # Display anchor directory segments in bold.
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  # Don't shorten directories that contain files matching this pattern. They are anchors.
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.shorten_folder_marker|.bzr|CVS|.git|.hg|.svn|.terraform|.citc)'
  # Don't shorten this many last directory segments. They are anchors.
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  # Shorten directory if it's longer than this even if there is space for it. The value can
  # be either absolute (e.g., '80') or a percentage of terminal width (e.g, '50%'). If empty,
  # directory will be shortened only when prompt doesn't fit.
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  # If set to true, embed a hyperlink into the directory. Useful for quickly
  # opening a directory in the file manager simply by clicking the link.
  # Can also be handy when the directory is shortened, as it allows you to see
  # the full directory that was used in previous commands.
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  # Enable special styling for non-writable directories.
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
  # Show this icon when the current directory is not writable. POWERLEVEL9K_DIR_SHOW_WRITABLE
  # above must be set to true for this parameter to have effect.
  # POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # POWERLEVEL9K_DIR_CLASSES allows you to specify custom icons for different directories.
  # It must be an array with 3 * N elements. Each triplet consists of:
  #
  #   1. A pattern against which the current directory is matched. Matching is done with
  #      extended_glob option enabled.
  #   2. Directory class for the purpose of styling.
  #   3. Icon.
  #
  # Triplets are tried in order. The first triplet whose pattern matches $PWD wins. If there
  # are no matches, the directory will have no icon.
  #
  # Example:
  #
  #   typeset -g POWERLEVEL9K_DIR_CLASSES=(
  #       '~/work(/*)#'  WORK     '(╯°□°）╯︵ ┻━┻'
  #       '~(/*)#'       HOME     '⌂'
  #       '*'            DEFAULT  '')
  #
  # With these settings, the current directory in the prompt may look like this:
  #
  #   (╯°□°）╯︵ ┻━┻ ~/work/projects/important/urgent
  #
  # Or like this:
  #
  #   ⌂ ~/best/powerlevel10k
  #
  # You can also set different colors for directories of different classes. Remember to override
  # FOREGROUND, SHORTENED_FOREGROUND and ANCHOR_FOREGROUND for every directory class that you wish
  # to have its own color.
  #
  #   typeset -g POWERLEVEL9K_DIR_WORK_FOREGROUND=12
  #   typeset -g POWERLEVEL9K_DIR_WORK_SHORTENED_FOREGROUND=4
  #   typeset -g POWERLEVEL9K_DIR_WORK_ANCHOR_FOREGROUND=39
  #
  # typeset -g POWERLEVEL9K_DIR_CLASSES=()

  #####################################[ vcs: git status ]######################################
  # Git status: feature:master#tag ⇣42⇡42 *42 merge ~42 +42 !42 ?42.
  # We are using parameters defined by the gitstatus plugin. See reference:
  # https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
  local vcs=''
  # 'feature' or '@72f5c8a' if not on a branch.
  vcs+='${${VCS_STATUS_LOCAL_BRANCH:+%76F${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${VCS_STATUS_LOCAL_BRANCH//\%/%%}}'
  vcs+=':-%f@%76F${VCS_STATUS_COMMIT[1,8]}}'
  # ':master' if the tracking branch name differs from local branch.
  vcs+='${${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH}:+%f:%76F${VCS_STATUS_REMOTE_BRANCH//\%/%%}}'
  # '#tag' if on a tag.
  vcs+='${VCS_STATUS_TAG:+%f#%76F${VCS_STATUS_TAG//\%/%%}}'
  # ⇣42 if behind the remote.
  vcs+='${${VCS_STATUS_COMMITS_BEHIND:#0}:+ %76F⇣${VCS_STATUS_COMMITS_BEHIND}}'
  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  # If you want '⇣42 ⇡42' instead, replace '${${(M)VCS_STATUS_COMMITS_BEHIND:#0}:+ }' with ' '.
  vcs+='${${VCS_STATUS_COMMITS_AHEAD:#0}:+${${(M)VCS_STATUS_COMMITS_BEHIND:#0}:+ }%76F⇡${VCS_STATUS_COMMITS_AHEAD}}'
  # *42 if have stashes.
  vcs+='${${VCS_STATUS_STASHES:#0}:+ %76F*${VCS_STATUS_STASHES}}'
  # 'merge' if the repo is in an unusual state.
  vcs+='${VCS_STATUS_ACTION:+ %196F${VCS_STATUS_ACTION//\%/%%}}'
  # ~42 if have merge conflicts.
  vcs+='${${VCS_STATUS_NUM_CONFLICTED:#0}:+ %196F~${VCS_STATUS_NUM_CONFLICTED}}'
  # +42 if have staged changes.
  vcs+='${${VCS_STATUS_NUM_STAGED:#0}:+ %11F+${VCS_STATUS_NUM_STAGED}}'
  # !42 if have unstaged changes.
  vcs+='${${VCS_STATUS_NUM_UNSTAGED:#0}:+ %11F!${VCS_STATUS_NUM_UNSTAGED}}'
  # ?42 if have untracked files.
  vcs+='${${VCS_STATUS_NUM_UNTRACKED:#0}:+ %12F?${VCS_STATUS_NUM_UNTRACKED}}'
  # If P9K_CONTENT is not empty, leave it unchanged. It's either "loading" or from vcs_info.
  vcs="\${P9K_CONTENT:-$vcs}"

  # Branch icon. Set this parameter to $'\uF126 ' for the popular Powerline branch icon.
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=

  # Disable the default Git status formatting.
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  # Install our own Git status formatter.
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_CONTENT_EXPANSION=$vcs
  # When Git status is being refreshed asynchronously, display the last known repo status in grey.
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION=${${vcs//\%f}//\%<->F}
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244
  # Enable counters for staged, unstaged, etc.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  # Show status of repositories of these types. You can add svn and/or hg if you are
  # using them. If you do, your prompt may become slow even when your current directory
  # isn't in an svn or hg reposotiry.
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # These settings are used for respositories other than Git or when gitstatusd fails and
  # Powerlevel10k has to fall back to using vcs_info.
  typeset -g POWERLEVEL9K_VCS_{CLEAN,MODIFIED,UNTRACKED}_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=':'
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_STASH_ICON='*'
  typeset -g POWERLEVEL9K_VCS_TAG_ICON=$'%{\b#%}'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON=$'%{\b?%}'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON=$'%{\b!%}'
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON=$'%{\b+%}'

  ##########################[ status: exit code of the last command ]###########################
  # Enable OK_PIPE, ERROR_PIPE and ERROR_SIGNAL status states to allow us to enable, disable and
  # style them independently from the regular OK and ERROR state.
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  # Don't show status on success. prompt_char already indicates success with green color.
  typeset -g POWERLEVEL9K_STATUS_OK=false
  # Don't show status when it's just an error code (e.g., '1'). prompt_char already indicates errors
  # with red color and error codes aren't interesting enough to waste prompt real estate on them.
  typeset -g POWERLEVEL9K_STATUS_ERROR=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=9
  # Show status when the last command was terminated by a signal.
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=9
  # Use terse signal names: "INT" instead of "SIGINT(2)".
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  # Show status when a pipe command fails and the overall exit status is non-zero. It may look
  # like this: 0|1. prompt_char is red in this case.
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=9
  # Show status when a pipe command fails and the overall exit status is zero. It may look
  # like this: 1|0. prompt_char is green in this case.
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=9
  # Custom icons.
  # typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ###################[ command_execution_time: duration of the last command ]###################
  # Show duration of the last command if takes longer than this many seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  # Show this many fractional digits. Zero means round to seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Execution time color.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Custom icon.
  # typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='⭐'

  #######################[ background_jobs: presence of background jobs ]#######################
  # Don't show the number of background jobs.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  # Icon to show when there are background jobs.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⇶'
  # Background jobs icon color.
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_COLOR=2

  ##########[ nordvpn: nordvpn connection status, linux only (https://nordvpn.com/) ]###########
  # NordVPN connection indicator color when connected.
  typeset -g POWERLEVEL9K_NORDVPN_CONNECTED_FOREGROUND=4
  # NordVPN connection indicator color when not connected.
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_FOREGROUND=3
  # Custom icons.
  # typeset -g POWERLEVEL9K_NORDVPN_CONNECTED_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_NORDVPN_DISCONNECTED_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_NORDVPN_CONNECTING_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_NORDVPN_DISCONNECTING_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # Uncomment these two lines to hide NordVPN connection indicator when not connected.
  # typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
  # typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

  ####################################[ context: user@host ]####################################
  # Context format: user@host.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  # Default context color.
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=244
  # Context color when running with privileges.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=11
  # Don't show context unless running with privileges on in SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
  # Custom icon.
  # typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # Custom icon when root.
  # typeset -g POWERLEVEL9K_CONTEXT_ROOT_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ###[ virtualenv: python virtual environment (https://docs.python.org/3/library/venv.html) ]###
  # Python virtual environment color.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=6
  # Show Python version next to the virtual environment name.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  # Separate environment name from Python version only with a space.
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  # Custom icon.
  # typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION='⭐'

  #####################[ anaconda: conda environment (https://conda.io/) ]######################
  # Anaconda environment color.
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=6
  # Show Python version next to the anaconda environment name.
  typeset -g POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION=true
  # Separate environment name from Python version only with a space.
  typeset -g POWERLEVEL9K_ANACONDA_{LEFT,RIGHT}_DELIMITER=
  # Custom icon.
  # typeset -g POWERLEVEL9K_ANACONDA_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ################[ pyenv: python environment (https://github.com/pyenv/pyenv) ]################
  # Pyenv color.
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=6
  # Don't show the current Python version if it's the same as global.
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  # Custom icon.
  # typeset -g POWERLEVEL9K_PYENV_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ##########[ nodenv: node.js version from nodenv (https://github.com/nodenv/nodenv) ]##########
  # Nodenv color.
  typeset -g POWERLEVEL9K_NODENV_FOREGROUND=2
  # Don't show node version if it's the same as global: $(nodenv version-name) == $(nodenv global).
  typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false
  # Custom icon.
  # typeset -g POWERLEVEL9K_NODENV_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ##############[ nvm: node.js version from nvm (https://github.com/nvm-sh/nvm) ]###############
  # Nvm color.
  typeset -g POWERLEVEL9K_NVM_FOREGROUND=2
  # Custom icon.
  # typeset -g POWERLEVEL9K_NVM_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ############[ nodeenv: node.js environment (https://github.com/ekalinin/nodeenv) ]############
  # Nodeenv color.
  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=2
  # Custom icon.
  # typeset -g POWERLEVEL9K_NODEENV_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ##############################[ node_version: node.js version ]###############################
  # Node version color.
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=2
  # Show node version only when in a directory tree containing package.json.
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  # Custom icon.
  # typeset -g POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_EXPANSION='⭐'

  #############[ kubecontext: current kubernetes context (https://kubernetes.io/) ]#############
  # Kubernetes context classes for the purpose of using different colors with
  # different contexts.
  #
  # POWERLEVEL9K_KUBECONTEXT_CLASSES is an array with even number of elements.
  # The first element in each pair defines a pattern against which the current
  # kubernetes context (in the format it is displayed in the prompt) gets matched.
  # The second element defines the context class. Patterns are tried in order.
  # The first match wins.
  #
  # For example, if your current kubernetes context is "deathray-testing", its
  # class is TEST because "deathray-testing" doesn't match the pattern '*prod*'
  # but does match '*test*'. Hence it'll be shown with the color of
  # $POWERLEVEL9K_KUBECONTEXT_TEST_FOREGROUND.
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      # '*prod*'  PROD    # These values are examples that are unlikely
      # '*test*'  TEST    # to match your needs. Customize them as needed.
      '*'       DEFAULT)
  # typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=1
  # typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_VISUAL_IDENTIFIER_EXPANSION='⭐'
  # typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_FOREGROUND=2
  # typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_VISUAL_IDENTIFIER_EXPANSION='⭐'
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=5
  # typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Kubernetes context too long? You can shorten it by defining an expansion. The original
  # Kubernetes context that you see in your prompt is stored in ${P9K_CONTENT} when
  # the expansion is evaluated. To remove everything up to and including the last '/',
  # set POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='${P9K_CONTENT##*/}'. This is just,
  # an example which isn't necessarily the right expansion for you. Parameter expansions
  # are very flexible and fast, too. See reference:
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion.
  typeset POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='${P9K_CONTENT}'
  # Show the trailing "/default" in kubernetes context. This makes it easier to define
  # POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION by making the format of ${P9K_CONTENT} consistent.
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE=true

  ###############################[ public_ip: public IP address ]###############################
  # Public IP color.
  typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND=144
  # Custom icon.
  # typeset -g POWERLEVEL9K_PUBLIC_IP_VISUAL_IDENTIFIER_EXPANSION='⭐'

  ################################[ battery: internal battery ]#################################
  # Show battery in red when it's below this level and not connected to power supply.
  typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
  typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=1
  # Show battery in green when it's charging.
  typeset -g POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND=2
  # Show battery in yellow when not connected to power supply.
  typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=3
  # Battery pictograms going from low to high level of charge.
  typeset -g POWERLEVEL9K_BATTERY_STAGES='▁▂▃▄▅▆▇'
  # Display battery pictogram on black background.
  typeset -g POWERLEVEL9K_BATTERY_VISUAL_IDENTIFIER_EXPANSION='%0K${P9K_VISUAL_IDENTIFIER}%k'
  # Don't show battery when it's fully charged and connected to power supply.
  typeset -g POWERLEVEL9K_BATTERY_CHARGED_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  # Don't show the remaining time to charge/discharge.
  typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false

  ####################################[ time: current time ]####################################
  # Current time color.
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  # Format for the current time: 09:51:02. See `man 3 strftime`.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  # If set to true, time will update when you hit enter. This way prompts for the past
  # commands will contain the start times of their commands as opposed to the default
  # behavior where they contain the end times of their preceding commands.
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  # Custom icon.
  # typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Example of a user-defined prompt segment. Function prompt_example will be called on every
  # prompt if `example` prompt segment is added to POWERLEVEL9K_LEFT_PROMPT_ELEMENTS or
  # POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS. It displays an icon and blue text greeting the user.
  #
  # Type `p9k_prompt_segment -h` for documentation and a more sophisticated example.
  function prompt_example() {
    p9k_prompt_segment -f 4 -i '⭐' -t 'hello, %n'
  }

  # User-defined prompt segments can be customized the same way as built-in segments.
  typeset -g POWERLEVEL9K_EXAMPLE_FOREGROUND=4
  typeset -g POWERLEVEL9K_EXAMPLE_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'
}

(( ! p10k_lean_restore_aliases )) || setopt aliases
'builtin' 'unset' 'p10k_lean_restore_aliases'
