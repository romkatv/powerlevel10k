if [[ -o 'aliases' ]]; then
  'builtin' 'unsetopt' 'aliases'
  local p9k_classic_restore_aliases=1
else
  local p9k_classic_restore_aliases=0
fi

() {
  emulate -L zsh
  setopt no_unset

  # The list of segments shown on the left. Fill it with the most important segments.
  typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      # =========================[ Line #1 ]=========================
      dir                     # current directory
      vcs                     # git status
      # =========================[ Line #2 ]=========================
      newline
  )

  # The list of segments shown on the right. Fill it with less important segments.
  # Right prompt on the last prompt line (where you are typing your commands) gets
  # automatically hidden when the input line reaches it. Right prompt above the
  # last prompt line gets hidden if it would overlap with left prompt.
  typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
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
      context                 # user@host
      # =========================[ Line #2 ]=========================
      newline
      # public_ip             # public IP address
      # time                  # current time
  )

  # Default segment icons depend on the value of POWERLEVEL9K_MODE. For example, LOCK_ICON
  # can be printed as $'\uE0A2', $'\uE138' or $'\uF023' depending on POWERLEVEL9K_MODE. The
  # correct value of this parameter depends on the provider of the font your terminal is using.
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
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete

  # Add an empty line before each prompt.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  # Add a space between the prompt and the cursor.
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=' '
  # Align the first lines of the left and right prompt rather than the last lines.
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  # Don't show the trailing segment separator on left prompt lines without any segments.
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  # Connect left prompt lines with these symbols.
  typeset -g   POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='╭─'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='├─'
  typeset -g    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='╰─'
  # Connect right prompt lines with these symbols.
  typeset -g   POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX='─╮'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX='─┤'
  typeset -g    POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX='─╯'

  # Enable special styling for non-writable directories.
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true
  # If set to true, embed a hyperlink into the directory. Useful for quickly
  # opening a directory in the file manager simply by clicking the link.
  # Can also be handy when the directory is shortened, as it allows you to see
  # the full directory that was used in previous commands.
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  # Enable counters for staged, unstaged, etc. in git prompt.
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  # Show execution time of the last command if takes longer than this many seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Show this many fractional digits. Zero means round to seconds.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0

  # Context format: user@host.
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  # Don't show context unless running with privileges on via SSH.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true

  # Show Python version next to the virtual environment name.
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  # Separate environment name from Python version only with a space.
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # Show Python version next to the anaconda environment name.
  typeset -g POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION=true
  # Separate environment name from Python version only with a space.
  typeset -g POWERLEVEL9K_ANACONDA_{LEFT,RIGHT}_DELIMITER=

  # Don't show the current Python version if it's the same as global.
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false

  # Don't show node version if it's the same as global: $(nodenv version-name) == $(nodenv global).
  typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false

  # Show node version only when in a directory tree containing package.json.
  typeset -g P9K_NODE_VERSION_PROJECT_ONLY=true

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
  # $POWERLEVEL9K_KUBECONTEXT_TEST_BACKGROUND.
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      # '*prod*'  PROD    # These values are examples that are unlikely
      # '*test*'  TEST    # to match your needs. Customize them as needed.
      '*'       DEFAULT)
  # typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_BACKGROUND=1
  # typeset -g POWERLEVEL9K_KUBECONTEXT_TEST_BACKGROUND=2
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_BACKGROUND=3
  # Kubernetes context too long? You can shorten it by defining an expansion. The original
  # Kubernetes context that you see in your prompt is stored in ${P9K_CONTENT} when
  # the expansion is evaluated. To remove everything up to and including the last '/',
  # set POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='${P9K_CONTENT##*/}'. This is just,
  # an example which isn't necessarily the right expansion for you. Parameter expansions
  # are very flexible and fast, too. See reference:
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion.
  typeset POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='${P9K_CONTENT}'
  # Show the trailing "/default" in kubernetes context.
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE=true

  # Format for the current time: 09:51:02. See `man 3 strftime`.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  # If set to true, time will update when you hit enter. This way prompts for the past
  # commands will contain the start times of their commands as opposed to the default
  # behavior where they contain the end times of their preceding commands.
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
}

(( ! p9k_classic_restore_aliases )) || setopt aliases
'builtin' 'unset' 'p9k_classic_restore_aliases'
