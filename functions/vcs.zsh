# vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8
################################################################
# vcs
# This file holds supplemental VCS functions
# for the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

set_default POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY true
function +vi-git-untracked() {
    # TODO: check git >= 1.7.2 - see function git_compare_version()
    local FLAGS
    FLAGS=('--porcelain')

    if [[ "$POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY" == "false" ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi

    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' && \
            -n $(git status ${FLAGS} | grep -E '^??' 2> /dev/null | tail -n1) ]]; then
        hook_com[unstaged]+=" %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_UNTRACKED_ICON')%f"
        VCS_WORKDIR_HALF_DIRTY=true
    else
        VCS_WORKDIR_HALF_DIRTY=false
    fi
}

function +vi-git-aheadbehind() {
    local ahead behind branch_name
    local -a gitstatus

    branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${branch_name}..HEAD | wc -l)
    ahead=$(git rev-list "${branch_name}"@{upstream}..HEAD 2>/dev/null | wc -l)
    (( ahead )) && gitstatus+=( " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_OUTGOING_CHANGES_ICON')${ahead// /}%f" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${branch_name} | wc -l)
    behind=$(git rev-list HEAD.."${branch_name}"@{upstream} 2>/dev/null | wc -l)
    (( behind )) && gitstatus+=( " %F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_INCOMING_CHANGES_ICON')${behind// /}%f" )

    hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
    local remote branch_name

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)/refs\/(remotes|heads)\/}
    branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)

    hook_com[branch]="%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_BRANCH_ICON')${hook_com[branch]}%f"
    # Always show the remote
    #if [[ -n ${remote} ]] ; then
    # Only show the remote if it differs from the local
    if [[ -n ${remote} ]] && [[ "${remote#*/}" != "${branch_name}" ]] ; then
        hook_com[branch]+="%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_REMOTE_BRANCH_ICON')%f%F{$POWERLEVEL9K_VCS_FOREGROUND}${remote// /}%f"
    fi
}

function +vi-git-tagname() {
    local tag

    tag=$(git describe --tags --exact-match HEAD 2>/dev/null)
    [[ -n "${tag}" ]] && hook_com[branch]="%F{$POWERLEVEL9K_VCS_FOREGROUND}$(print_icon 'VCS_TAG_ICON')${tag}%f"
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
  if [[ "${hook_com[vcs]}" == "git" ]]; then
    vcs_visual_identifier='VCS_GIT_ICON'
  elif [[ "${hook_com[vcs]}" == "hg" ]]; then
    vcs_visual_identifier='VCS_HG_ICON'
  fi

  if [[ -n "${hook_com[staged]}" ]] || [[ -n "${hook_com[unstaged]}" ]]; then
    VCS_WORKDIR_DIRTY=true
  else
    VCS_WORKDIR_DIRTY=false
  fi
}
