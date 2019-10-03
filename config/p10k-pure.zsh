# Config file for Powerlevel10k with the style of Pure (https://github.com/sindresorhus/pure).
#
# Differences from Pure:
#
#   - Git:
#     - `@c4d3ec2c` instead of something like `v1.4.0~11` when in detached HEAD state.
#     - No automatic `git fetch` (the same as in Pure with `PURE_GIT_PULL=0`).
#
# The replication of Pure prompt achieved with this config is almost exact. Apart from the
# differences listed above, prompt is identical to Pure. This includes even the bad parts.
# For example, just like in Pure, prompt will provide no indication of Git status being stale.
# When prompt doesn't fit on one line, it'll wrap around with no attempt to shorten anything.
# This is likely to make user experience worse than with any other Powerlevel10k config. If
# you like the general style of Pure but not particularly attached to all its quirks, type
# `p10k configure` while having Powerlevel10k theme active and pick lean style.

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh
  setopt no_unset

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      dir                       # current directory
      vcs                       # git status
      context                   # user@host
      command_execution_time    # previous command duration
      newline                   # \n
      virtualenv                # python virtual environment
      prompt_char               # prompt symbol
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Basic style options that define the overall look of your prompt.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # disable segment icons

  # Add an empty line before each prompt. 
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  # Magenta prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=magenta
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=red
  # Default prompt symbol.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  # Prompt symbol in command vi mode.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  # Prompt symbol in visual vi mode is the same as in command mode. This is unlikely
  # to be desired by anyone but that's how Pure does it.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='❮'

  # Grey Python Virtual Environment.
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=242

  # Blue current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=blue

  # Make Git prompt grey in all states. Also make stale prompts appear indistinguishable from
  # fresh ones. This is unlikely to be desired by anyone but that's how Pure does it.
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=242

  # Disable async loading indicator to make directories that aren't Git repositories
  # indistinguishable from large Git repositories without known state. This is unlikely
  # to be desired by anyone but that's how Pure does it.
  local vcs='${${P9K_CONTENT:#loading}:+'
  # 'feature' or '@72f5c8a' if not on a branch.
  vcs+='${${VCS_STATUS_LOCAL_BRANCH//\%/%%}:-%f@${VCS_STATUS_COMMIT[1,8]}}'
  # '*' if dirty.
  vcs+='${${${:-$VCS_STATUS_HAS_STAGED$VCS_STATUS_HAS_UNSTAGED$VCS_STATUS_HAS_UNTRACKED}:#000}:+*}'
  # ⇣ if behind the remote.
  vcs+='${${VCS_STATUS_COMMITS_BEHIND:#0}:+ %6F⇣}'
  # ⇡ if ahead of the remote; no leading space if also behind the remote: ⇣⇡.
  vcs+='${${VCS_STATUS_COMMITS_AHEAD:#0}:+${${(M)VCS_STATUS_COMMITS_BEHIND:#0}:+ }%6F⇡}}'
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION=$vcs

  # Context format when root: user@host. The first part white, the rest grey.
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT_EXPANSION='%7F%n%f%242F@%m%f'
  # Context format when connected over SSH: user@host. The whole thing grey.
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_CONTENT_EXPANSION='%242F%n@%m%f'
  # Don't show context when not rood and not connected over SSH.
  typeset -g POWERLEVEL9K_CONTEXT_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true

  # Show previous command duration only if it's >= 5s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  # Don't show fractional seconds. Thus, 7s rather than 7.3s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  # Duration format: 1d 2h 3m 4s.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  # Yellow previous command duration.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
