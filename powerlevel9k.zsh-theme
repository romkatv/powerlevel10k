# vim:ft=zsh ts=2 sw=2 sts=2
#
# powerlevel9k Theme
# https://github.com/bhilburn/powerlevel9k
#
# This theme was inspired by agnoster's Theme:
# https://gist.github.com/3712874
#
# The `vcs_info` hooks in this file are from Tom Upton:
# https://github.com/tupton/dotfiles/blob/master/zsh/zshrc
#
# In order for this theme to render correctly, you will need a Powerline-patched font:
# https://github.com/Lokaltog/powerline-fonts
#

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# The `CURRENT_BG` variable is used to remember what the last BG color used was
# when building the left-hand prompt. Because the RPROMPT is created from
# right-left but reads the opposite, this isn't necessary for the other side.
CURRENT_BG='NONE'

# These characters require the Powerline fonts to work properly. If see boxes or
# bizarre characters below, your fonts are not correctly installed.
LEFT_SEGMENT_SEPARATOR=''
RIGHT_SEGMENT_SEPARATOR=''
VCS_UNSTAGED_ICON='●'
VCS_STAGED_ICON='✚'

################################################################
# color scheme
################################################################

if [[ $POWERLEVEL9K_COLOR_SCHEME == "light" ]]; then
	DEFAULT_COLOR=white
	DEFAULT_COLOR_INVERTED=black
	DEFAULT_COLOR_DARK="252"
else
	DEFAULT_COLOR=black
	DEFAULT_COLOR_INVERTED=white
	DEFAULT_COLOR_DARK="236"
fi

################################################################
# vcs_info settings for git
################################################################

setopt prompt_subst
autoload -Uz vcs_info

local VCS_WORKDIR_DIRTY=false
local VCS_CHANGESET_PREFIX=''
if [ $POWERLEVEL9K_SHOW_CHANGESET ]; then
  # Just display the first 12 characters of our changeset-ID.
  VCS_CHANGESET_PREFIX="%F{$DEFAULT_COLOR_DARK}%12.12i@%f"
fi

zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:*' formats " $VCS_CHANGESET_PREFIX%F{$DEFAULT_COLOR}%b%c%u%m%f"
zstyle ':vcs_info:*' actionformats " %b %F{red}| %a%f"

zstyle ':vcs_info:*' stagedstr " %F{$DEFAULT_COLOR}$VCS_STAGED_ICON%f"
zstyle ':vcs_info:*' unstagedstr " %F{$DEFAULT_COLOR}$VCS_UNSTAGED_ICON%f"

zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-aheadbehind git-remotebranch git-tagname

# For Hg, only show the branch name
zstyle ':vcs_info:hg*:*' branchformat "%b"
# The `get-revision` function must be turned on for dirty-check to work for Hg
zstyle ':vcs_info:hg*:*' get-revision true

if [ $POWERLEVEL9K_SHOW_CHANGESET ]; then
  zstyle ':vcs_info:*' get-revision true
else
  # A little performance-boost for large repositories (especially Hg). If we
  # don't show the changeset, we can switch to simple mode.
  zstyle ':vcs_info:*' use-simple true
fi

## Debugging
#zstyle ':vcs_info:*+*:*' debug true

################################################################
# Prompt Segment Constructors
################################################################

# Begin a left prompt segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
left_prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "%{$bg%F{$CURRENT_BG}%}$LEFT_SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the left prompt, closing any open segments
left_prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$LEFT_SEGMENT_SEPARATOR"
  else
    echo -n " %{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Begin a right prompt segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground. No ending for the right prompt
# segment is needed (unlike the left prompt, above).
right_prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    echo -n " %f%F{$1}$RIGHT_SEGMENT_SEPARATOR%f%{$bg%}%{$fg%} "
  [[ -n $3 ]] && echo -n $3
}

################################################################
# Prompt Components
################################################################

# Context: user@hostname (who am I and where am I)
# Note that if $DEFAULT_USER is not set, this prompt segment will always print
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    $1_prompt_segment $DEFAULT_COLOR "011" "%(!.%{%F{yellow}%}.)$USER@%m"
  fi
}

# branch/detached head, dirty status
prompt_vcs() {
  local vcs_prompt="${vcs_info_msg_0_}"

  if [[ -n $vcs_prompt ]]; then
    if ( $VCS_WORKDIR_DIRTY ); then
      $1_prompt_segment yellow $DEFAULT_COLOR
    else
      $1_prompt_segment green $DEFAULT_COLOR
    fi

    echo -n "%F{$DEFAULT_COLOR}%f$vcs_prompt"
  fi
}

function +vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' && \
            $(git ls-files --others --exclude-standard | sed q | wc -l | tr -d ' ') != 0 ]]; then
        hook_com[unstaged]+=" %F{$DEFAULT_COLOR}?%f"
    fi
}

function +vi-git-aheadbehind() {
    local ahead behind branch_name
    local -a gitstatus

    branch_name=${$(git symbolic-ref --short HEAD 2>/dev/null)}

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${branch_name}..HEAD | wc -l)
    ahead=$(git rev-list ${branch_name}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    (( $ahead )) && gitstatus+=( " %F{$DEFAULT_COLOR}↑${ahead}%f" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${branch_name} | wc -l)
    behind=$(git rev-list HEAD..${branch_name}@{upstream} 2>/dev/null | wc -l | tr -d ' ')
    (( $behind )) && gitstatus+=( " %F{$DEFAULT_COLOR}↓${behind}%f" )

    hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
    local remote branch_name

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)/refs\/(remotes|heads)\/}
    branch_name=${$(git symbolic-ref --short HEAD 2>/dev/null)}

    hook_com[branch]="%F{$DEFAULT_COLOR}${hook_com[branch]}%f"
    # Always show the remote
    #if [[ -n ${remote} ]] ; then
    # Only show the remote if it differs from the local
    if [[ -n ${remote} && ${remote#*/} != ${branch_name} ]] ; then
        hook_com[branch]+="%F{$DEFAULT_COLOR}→%f%F{$DEFAULT_COLOR}${remote}%f"
    fi
}

function +vi-git-tagname() {
    local tag

    tag=$(git describe --tags --exact-match HEAD 2>/dev/null)
    [[ -n ${tag} ]] && hook_com[branch]=" %F{$DEFAULT_COLOR}${tag}%f"
}

function +vi-vcs-detect-changes() {
  if [[ -n ${hook_com[staged]} ]] || [[ -n ${hook_com[unstaged]} ]]; then
    VCS_WORKDIR_DIRTY=true
  else
    VCS_WORKDIR_DIRTY=false
  fi
}

# Dir: current working directory
prompt_dir() {
  $1_prompt_segment blue $DEFAULT_COLOR '%~'
}

# Virtualenv: current working virtualenv
# More information on virtualenv (Python):
# https://virtualenv.pypa.io/en/latest/virtualenv.html
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    $1_prompt_segment blue $DEFAULT_COLOR "(`basename $virtualenv_path`)"
  fi
}

# Left Status: (return code, root status, background jobs)
# This creates a status segment for the *left* prompt
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && $1_prompt_segment $DEFAULT_COLOR default "$symbols"
}

# Right Status: (return code, root status, background jobs)
# This creates a status segment for the *right* prompt. Exact same thing as
# above - just other side.
prompt_longstatus() {
  local symbols bg
  symbols=()

  if [[ $RETVAL -ne 0 ]]; then
    symbols+="%{%F{"226"}%}%? ↵"
    bg="009"
  else
    symbols+="%{%F{"046"}%}✓"
    bg="008"
  fi

  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && $1_prompt_segment $bg $DEFAULT_COLOR "$symbols"
}

# System time
prompt_time() {
  $1_prompt_segment $DEFAULT_COLOR_INVERTED $DEFAULT_COLOR '%D{%H:%M:%S} '
}

# Command number (in local history)
prompt_history() {
  $1_prompt_segment "244" $DEFAULT_COLOR '%h'
}

# Ruby Version Manager information
prompt_rvm() {
  local rvm_prompt
  rvm_prompt=`rvm-prompt`
  if [ "$rvm_prompt" != "" ]; then
    $1_prompt_segment "240" $DEFAULT_COLOR "$rvm_prompt "
  fi
}

# rbenv information
prompt_rbenv() {
  if [[ -n "$RBENV_VERSION" ]]; then
    $1_prompt_segment red $DEFAULT_COLOR "$RBENV_VERSION"
  fi
}

# Main prompt
build_left_prompt() {
  if (( ${#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS} == 0 )); then
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
  fi

  for element in $POWERLEVEL9K_LEFT_PROMPT_ELEMENTS; do
    prompt_$element "left"
  done

  left_prompt_end
}

# Right prompt
build_right_prompt() {
  RETVAL=$?

  if (( ${#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS} == 0 )); then
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(longstatus history time)
  fi

  for element in $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS; do
    prompt_$element "right"
  done
}

# Create the prompts
precmd() {
  vcs_info

  # Add a static hook to examine staged/unstaged changes.
  vcs_info_hookadd set-message vcs-detect-changes
}

PROMPT='%{%f%b%k%}$(build_left_prompt) '
RPROMPT='%{%f%b%k%}$(build_right_prompt)%{$reset_color%}'
