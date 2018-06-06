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

    if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' && \
            -n $(command git status ${FLAGS} | \grep -E '^\?\?' 2> /dev/null | tail -n1) ]]; then
        hook_com[unstaged]+=" $(print_icon 'VCS_UNTRACKED_ICON')"
        VCS_WORKDIR_HALF_DIRTY=true
    else
        VCS_WORKDIR_HALF_DIRTY=false
    fi
}

function +vi-git-aheadbehind() {
    local ahead behind branch_name
    local -a gitstatus

    branch_name=$(command git symbolic-ref --short HEAD 2>/dev/null)

    # for git prior to 1.7
    # ahead=$(command git rev-list origin/${branch_name}..HEAD | wc -l)
    ahead=$(command git rev-list "${branch_name}"@{upstream}..HEAD 2>/dev/null | wc -l)
    (( ahead )) && gitstatus+=( " $(print_icon 'VCS_OUTGOING_CHANGES_ICON')${ahead// /}" )

    # for git prior to 1.7
    # behind=$(command git rev-list HEAD..origin/${branch_name} | wc -l)
    behind=$(command git rev-list HEAD.."${branch_name}"@{upstream} 2>/dev/null | wc -l)
    (( behind )) && gitstatus+=( " $(print_icon 'VCS_INCOMING_CHANGES_ICON')${behind// /}" )

    hook_com[misc]+=${(j::)gitstatus}
}

function +vi-git-remotebranch() {
    local remote branch_name

    # Are we on a remote-tracking branch?
    remote=${$(command git rev-parse --verify HEAD@{upstream} --symbolic-full-name 2>/dev/null)/refs\/(remotes|heads)\/}
    branch_name=$(command git symbolic-ref --short HEAD 2>/dev/null)

    if [[ -n "$POWERLEVEL9K_VCS_SHORTEN_LENGTH" ]] && [[ -n "$POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH" ]]; then
     set_default POWERLEVEL9K_VCS_SHORTEN_DELIMITER $'\U2026'

     if [ ${#hook_com[branch]} -gt $POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH ] && [ ${#hook_com[branch]} -gt $POWERLEVEL9K_VCS_SHORTEN_LENGTH ]; then
       case "$POWERLEVEL9K_VCS_SHORTEN_STRATEGY" in
         truncate_middle)
           hook_com[branch]="$(echo "${branch_name:0:$POWERLEVEL9K_VCS_SHORTEN_LENGTH}")$POWERLEVEL9K_VCS_SHORTEN_DELIMITER$(echo "${branch_name: -$POWERLEVEL9K_VCS_SHORTEN_LENGTH}")"
         ;;
         truncate_from_right)
           hook_com[branch]="$(echo "${branch_name:0:$POWERLEVEL9K_VCS_SHORTEN_LENGTH}")$POWERLEVEL9K_VCS_SHORTEN_DELIMITER"
         ;;
       esac
     fi
    fi

    hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${hook_com[branch]}"
    # Always show the remote
    #if [[ -n ${remote} ]] ; then
    # Only show the remote if it differs from the local
    if [[ -n ${remote} ]] && [[ "${remote#*/}" != "${branch_name}" ]] ; then
        hook_com[branch]+="$(print_icon 'VCS_REMOTE_BRANCH_ICON')${remote// /}"
    fi
}

set_default POWERLEVEL9K_VCS_HIDE_TAGS false
function +vi-git-tagname() {
    if [[ "$POWERLEVEL9K_VCS_HIDE_TAGS" == "false" ]]; then
        # If we are on a tag, append the tagname to the current branch string.
        local tag
        tag=$(command git describe --tags --exact-match HEAD 2>/dev/null)

        if [[ -n "${tag}" ]] ; then
            # There is a tag that points to our current commit. Need to determine if we
            # are also on a branch, or are in a DETACHED_HEAD state.
            if [[ -z $(command git symbolic-ref HEAD 2>/dev/null) ]]; then
                # DETACHED_HEAD state. We want to append the tag name to the commit hash
                # and print it. Unfortunately, `vcs_info` blows away the hash when a tag
                # exists, so we have to manually retrieve it and clobber the branch
                # string.
                local revision
                revision=$(command git rev-list -n 1 --abbrev-commit --abbrev=${POWERLEVEL9K_VCS_INTERNAL_HASH_LENGTH} HEAD)
                hook_com[branch]="$(print_icon 'VCS_BRANCH_ICON')${revision} $(print_icon 'VCS_TAG_ICON')${tag}"
            else
                # We are on both a tag and a branch; print both by appending the tag name.
                hook_com[branch]+=" $(print_icon 'VCS_TAG_ICON')${tag}"
            fi
        fi
    fi
}

# Show count of stashed changes
# Port from https://github.com/whiteinge/dotfiles/blob/5dfd08d30f7f2749cfc60bc55564c6ea239624d9/.zsh_shouse_prompt#L268
function +vi-git-stash() {
  local -a stashes

  if [[ -s $(command git rev-parse --git-dir)/refs/stash ]] ; then
    stashes=$(command git stash list 2>/dev/null | wc -l)
    hook_com[misc]+=" $(print_icon 'VCS_STASH_ICON')${stashes// /}"
  fi
}

function +vi-hg-bookmarks() {
  if [[ -n "${hgbmarks[@]}" ]]; then
    hook_com[hg-bookmark-string]=" $(print_icon 'VCS_BOOKMARK_ICON')${hgbmarks[@]}"

    # To signal that we want to use the sting we just generated, set the special
    # variable `ret' to something other than the default zero:
    ret=1
    return 0
  fi
}

function +vi-vcs-detect-changes() {
  if [[ "${hook_com[vcs]}" == "git" ]]; then

    local remote=$(command git ls-remote --get-url 2> /dev/null)
    if [[ "$remote" =~ "github" ]] then
      vcs_visual_identifier='VCS_GIT_GITHUB_ICON'
    elif [[ "$remote" =~ "bitbucket" ]] then
      vcs_visual_identifier='VCS_GIT_BITBUCKET_ICON'
    elif [[ "$remote" =~ "stash" ]] then
      vcs_visual_identifier='VCS_GIT_BITBUCKET_ICON'
    elif [[ "$remote" =~ "gitlab" ]] then
      vcs_visual_identifier='VCS_GIT_GITLAB_ICON'
    else
      vcs_visual_identifier='VCS_GIT_ICON'
    fi

  elif [[ "${hook_com[vcs]}" == "hg" ]]; then
    vcs_visual_identifier='VCS_HG_ICON'
  elif [[ "${hook_com[vcs]}" == "svn" ]]; then
    vcs_visual_identifier='VCS_SVN_ICON'
  fi

  if [[ -n "${hook_com[staged]}" ]] || [[ -n "${hook_com[unstaged]}" ]]; then
    VCS_WORKDIR_DIRTY=true
  else
    VCS_WORKDIR_DIRTY=false
  fi
}

function +vi-svn-detect-changes() {
  local svn_status="$(svn status)"
  if [[ -n "$(echo "$svn_status" | \grep \^\?)" ]]; then
    hook_com[unstaged]+=" $(print_icon 'VCS_UNTRACKED_ICON')"
    VCS_WORKDIR_HALF_DIRTY=true
  fi
  if [[ -n "$(echo "$svn_status" | \grep \^\M)" ]]; then
    hook_com[unstaged]+=" $(print_icon 'VCS_UNSTAGED_ICON')"
    VCS_WORKDIR_DIRTY=true
  fi
  if [[ -n "$(echo "$svn_status" | \grep \^\A)" ]]; then
    hook_com[staged]+=" $(print_icon 'VCS_STAGED_ICON')"
    VCS_WORKDIR_DIRTY=true
  fi
}
