#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder and git init it.
  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p "${FOLDER}"
  cd $FOLDER

  # Set username and email
  OLD_GIT_AUTHOR_NAME=$GIT_AUTHOR_NAME
  GIT_AUTHOR_NAME="Testing Tester"
  OLD_GIT_AUTHOR_EMAIL=$GIT_AUTHOR_EMAIL
  GIT_AUTHOR_EMAIL="test@powerlevel9k.theme"

  # Set default username if not already set!
  if [[ -z $(git config user.name) ]]; then
    GIT_AUTHOR_NAME_SET_BY_TEST=true
    git config --global user.name "${GIT_AUTHOR_NAME}"
  fi
  # Set default email if not already set!
  if [[ -z $(git config user.email) ]]; then
    GIT_AUTHOR_EMAIL_SET_BY_TEST=true
    git config --global user.email "${GIT_AUTHOR_EMAIL}"
  fi

  # Initialize FOLDER as git repository
  git init 1>/dev/null
}

function tearDown() {
  if [[ -n "${OLD_GIT_AUTHOR_NAME}" ]]; then
    GIT_AUTHOR_NAME=$OLD_GIT_AUTHOR
    unset OLD_GIT_AUTHOR_NAME
  else
    unset GIT_AUTHOR_NAME
  fi

  if [[ -n "${OLD_GIT_AUTHOR_EMAIL}" ]]; then
    GIT_AUTHOR_EMAIL=$OLD_GIT_AUTHOR_EMAIL
    unset OLD_GIT_AUTHOR_EMAIL
  else
    unset GIT_AUTHOR_EMAIL
  fi

  if [[ "${GIT_AUTHOR_NAME_SET_BY_TEST}" == "true" ]]; then
    git config --global --unset user.name
  fi
  if [[ "${GIT_AUTHOR_EMAIL_SET_BY_TEST}" == "true" ]]; then
    git config --global --unset user.email
  fi

  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}"
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test
  unset FOLDER
}

function testColorOverridingForCleanStateWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_CLEAN_FOREGROUND='cyan'
  local POWERLEVEL9K_VCS_CLEAN_BACKGROUND='white'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{006} master %k%F{007}%f " "$(build_left_prompt)"
}

function testColorOverridingForModifiedStateWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
  local POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'

  touch testfile
  git add testfile
  git commit -m "test" 1>/dev/null
  echo "test" > testfile
  
  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{001} master ● %k%F{003}%f " "$(build_left_prompt)"
}

function testColorOverridingForUntrackedStateWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='cyan'
  local POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'

  touch testfile

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{006} master ? %k%F{003}%f " "$(build_left_prompt)"
}

function testGitIconWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_GIT_ICON='Git-Icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000}Git-Icon %f%F{000} master %k%F{002}%f " "$(build_left_prompt)"
}

function testGitlabIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_GIT_GITLAB_ICON='GL-Icon'

  # Add a GitLab project as remote origin. This is
  # sufficient to show the GitLab-specific icon.
  git remote add origin https://gitlab.com/dritter/gitlab-test-project.git

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000}GL-Icon %f%F{000} master %k%F{002}%f " "$(build_left_prompt)"
}

function testBitbucketIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON='BB-Icon'

  # Add a BitBucket project as remote origin. This is
  # sufficient to show the BitBucket-specific icon.
  git remote add origin https://dritter@bitbucket.org/dritter/dr-test.git

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000}BB-Icon %f%F{000} master %k%F{002}%f " "$(build_left_prompt)"
}

function testGitHubIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_GIT_GITHUB_ICON='GH-Icon'

  # Add a GitHub project as remote origin. This is
  # sufficient to show the GitHub-specific icon.
  git remote add origin https://github.com/dritter/test.git

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000}GH-Icon %f%F{000} master %k%F{002}%f " "$(build_left_prompt)"
}

function testUntrackedFilesIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  # Create untracked file
  touch "i-am-untracked.txt"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"
}

function testStagedFilesIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_STAGED_ICON='+'

  # Create staged file
  touch "i-am-added.txt"
  git add i-am-added.txt &>/dev/null
  git commit -m "initial commit" &>/dev/null
  echo "xx" >> i-am-added.txt
  git add i-am-added.txt &>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000} master + %k%F{003}%f " "$(build_left_prompt)"
}

function testUnstagedFilesIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_UNSTAGED_ICON='M'

  # Create unstaged (modified, but not added to index) file
  touch "i-am-modified.txt"
  git add i-am-modified.txt
  git commit -m "Add File" 1>/dev/null
  echo "xx" > i-am-modified.txt

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000} master M %k%F{003}%f " "$(build_left_prompt)"
}

function testStashIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_STASH_ICON='S'

  # Create modified file
  touch "i-am-modified.txt"
  git add i-am-modified.txt
  git commit -m "Add File" 1>/dev/null
  echo "xx" > i-am-modified.txt
  git stash 1>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master S1 %k%F{002}%f " "$(build_left_prompt)"
}

function testTagIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_TAG_ICON='T'

  touch "file.txt"
  git add file.txt
  git commit -m "Add File" 1>/dev/null
  git tag "v0.0.1"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master Tv0.0.1 %k%F{002}%f " "$(build_left_prompt)"
}

function testTagIconInDetachedHeadState() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_TAG_ICON='T'

  touch "file.txt"
  git add file.txt
  git commit -m "Add File" &>/dev/null
  git tag "v0.0.1"
  touch "file2.txt"
  git add file2.txt
  git commit -m "Add File2" &>/dev/null
  git checkout v0.0.1 &>/dev/null
  local hash=$(git rev-list -n 1 --abbrev-commit --abbrev=8 HEAD)

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} ${hash} Tv0.0.1 %k%F{002}%f " "$(build_left_prompt)"
}

function testActionHintWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)

  touch "i-am-modified.txt"
  git add i-am-modified.txt
  git commit -m "Add File" &>/dev/null

  git clone . ../vcs-test2 &>/dev/null
  echo "xx" >> i-am-modified.txt
  git commit -a -m "Modified file" &>/dev/null

  cd ../vcs-test2
  echo "yy" >> i-am-modified.txt
  git commit -a -m "Provoke conflict" &>/dev/null
  git pull &>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000} master %F{red}| merge%f %k%F{003}%f " "$(build_left_prompt)"
}

function testIncomingHintWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='I'

  touch "i-am-modified.txt"
  git add i-am-modified.txt
  git commit -m "Add File" &>/dev/null

  git clone . ../vcs-test2 &>/dev/null
  echo "xx" >> i-am-modified.txt
  git commit -a -m "Modified file" &>/dev/null

  cd ../vcs-test2
  git fetch &>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master I1 %k%F{002}%f " "$(build_left_prompt)"
}

function testOutgoingHintWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='o'

  touch "i-am-modified.txt"
  git add i-am-modified.txt
  git commit -m "Add File" &>/dev/null

  git clone . ../vcs-test2 &>/dev/null

  cd ../vcs-test2

  echo "xx" >> i-am-modified.txt
  git commit -a -m "Modified file" &>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master o1 %k%F{002}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=true
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  git add file.txt
  git commit -m "Add File" 1>/dev/null
  local hash=$(git rev-list -n 1 --abbrev-commit --abbrev=3 HEAD)

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init
  assertEquals "%K{002} %F{000}${hash}  master %k%F{002}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashIsNotShownIfShowChangesetIsFalse() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=false
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  git add file.txt
  git commit -m "Add File" 1>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init
  assertEquals "%K{002} %F{000} master %k%F{002}%f " "$(build_left_prompt)"
}

function testDetectingUntrackedFilesInSubmodulesWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY="true"
  unset POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND

  mkdir ../submodule
  cd ../submodule
  git init 1>/dev/null
  touch "i-am-tracked.txt"
  git add . 1>/dev/null && git commit -m "Initial Commit" 1>/dev/null

  local submodulePath="${PWD}"

  cd -
  git submodule add "${submodulePath}" 2>/dev/null
  git commit -m "Add submodule" 1>/dev/null

  # Go into checked-out submodule path
  cd submodule
  # Create untracked file
  touch "i-am-untracked.txt"
  cd -

  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"
}

function testDetectinUntrackedFilesInMainRepoWithDirtySubmodulesWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY="true"
  unset POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND

  mkdir ../submodule
  cd ../submodule
  git init 1>/dev/null
  touch "i-am-tracked.txt"
  git add . 1>/dev/null && git commit -m "Initial Commit" 1>/dev/null

  local submodulePath="${PWD}"

  cd -
  git submodule add "${submodulePath}" 2>/dev/null
  git commit -m "Add submodule" 1>/dev/null

  # Create untracked file
  touch "i-am-untracked.txt"

  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"
}

function testDetectingUntrackedFilesInNestedSubmodulesWork() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY="true"
  unset POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND

  local mainRepo="${PWD}"

  mkdir ../submodule
  cd ../submodule
  git init 1>/dev/null
  touch "i-am-tracked.txt"
  git add . 1>/dev/null && git commit -m "Initial Commit" 1>/dev/null

  local submodulePath="${PWD}"

  mkdir ../subsubmodule
  cd ../subsubmodule
  git init 1>/dev/null
  touch "i-am-tracked-too.txt"
  git add . 1>/dev/null && git commit -m "Initial Commit" 1>/dev/null

  local subsubmodulePath="${PWD}"

  cd "${submodulePath}"
  git submodule add "${subsubmodulePath}" 2>/dev/null
  git commit -m "Add subsubmodule" 1>/dev/null
  cd "${mainRepo}"
  git submodule add "${submodulePath}" 2>/dev/null
  git commit -m "Add submodule" 1>/dev/null

  git submodule update --init --recursive 2>/dev/null

  cd submodule/subsubmodule
  # Create untracked file
  touch "i-am-untracked.txt"
  cd -

  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"
}

source shunit2/shunit2