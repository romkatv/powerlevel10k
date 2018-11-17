#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"

  P9K_HOME=$(pwd)
  ### Test specific
  # Create default folder and hg init it.
  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p "${FOLDER}"
  cd $FOLDER

  export HGUSER="Test bot <bot@example.com>"

  hg init 1>/dev/null
}

function tearDown() {
  # Go back to powerlevel9k folder
  cd "${P9K_HOME}"
  # Remove eventually created test-specific folder
  rm -fr "${FOLDER}" &>/dev/null
  # At least remove test folder completely
  rm -fr /tmp/powerlevel9k-test &>/dev/null
  unset FOLDER
  unset HGUSER
}

function testColorOverridingForCleanStateWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_CLEAN_FOREGROUND='cyan'
  local POWERLEVEL9K_VCS_CLEAN_BACKGROUND='white'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{006} default %k%F{007}%f " "$(build_left_prompt)"
}

function testColorOverridingForModifiedStateWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
  local POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'

  touch testfile
  hg add testfile
  hg commit -m "test" 1>/dev/null
  echo "test" > testfile

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{001} default ● %k%F{003}%f " "$(build_left_prompt)"
}

# There is no staging area in mercurial, therefore there are no "untracked"
# files.. In case there are added files, we show the VCS segment with a
# yellow background.
# This may be improved in future versions, to be a bit more consistent with
# the git part.
function testAddedFilesIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  touch "myfile.txt"
  hg add myfile.txt

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000} default ● %k%F{003}%f " "$(build_left_prompt)"
}

# We don't support tagging in mercurial right now..
function testTagIconWorks() {
  startSkipping # Skip test
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_TAG_ICON='T'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null
  hg tag "v0.0.1"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} default Tv0.0.1 %k%F{002}%f " "$(build_left_prompt)"
}

function testTagIconInDetachedHeadState() {
  startSkipping # Skip test
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_TAG_ICON='T'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" &>/dev/null
  hg tag "v0.0.1"
  touch "file2.txt"
  hg add file2.txt
  hg commit -m "Add File2" &>/dev/null
  hg checkout v0.0.1 &>/dev/null
  local hash=$(hg id)

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} ${hash} Tv0.0.1 %k%F{002}%f " "$(build_left_prompt)"
}

function testActionHintWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  touch "i-am-modified.txt"
  hg add i-am-modified.txt
  hg commit -m "Add File" &>/dev/null

  hg clone . ../vcs-test2 &>/dev/null
  echo "xx" >> i-am-modified.txt
  hg commit -m "Modified file" &>/dev/null

  cd ../vcs-test2
  echo "yy" >> i-am-modified.txt
  hg commit -m "Provoke conflict" 2>/dev/null
  hg pull 1>/dev/null
  hg merge --tool internal:merge >/dev/null 2>&1

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{003} %F{000} default %F{red}| merging%f %k%F{003}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=true
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null
  local hash=$(hg id | head -c ${POWERLEVEL9K_CHANGESET_HASH_LENGTH})

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init

  assertEquals "%K{002} %F{000}${hash}  default %k%F{002}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashIsNotShownIfShowChangesetIsFalse() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=false
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init

  assertEquals "%K{002} %F{000} default %k%F{002}%f " "$(build_left_prompt)"
}

function testMercurialIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_HG_ICON='HG-Icon'

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000}HG-Icon %f%F{000} default %k%F{002}%f " "$(build_left_prompt)"
}

function testBookmarkIconWorks() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_BOOKMARK_ICON='B'
  hg bookmark "initial"

  # Load Powerlevel9k
  source ${P9K_HOME}/powerlevel9k.zsh-theme

  assertEquals "%K{002} %F{000} default Binitial %k%F{002}%f " "$(build_left_prompt)"
}

function testBranchNameScriptingVulnerability() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  echo "#!/bin/sh\n\necho 'hacked'\n" > evil_script.sh
  chmod +x evil_script.sh

  hg branch '$(./evil_script.sh)' >/dev/null
  hg add . >/dev/null
  hg commit -m "Initial commit" >/dev/null

  assertEquals '%K{002} %F{000} $(./evil_script.sh) %k%F{002}%f ' "$(build_left_prompt)"
}

source shunit2/shunit2
