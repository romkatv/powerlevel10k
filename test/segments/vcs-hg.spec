#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

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
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_CLEAN_FOREGROUND='cyan'
  local POWERLEVEL9K_VCS_CLEAN_BACKGROUND='white'

  assertEquals "%K{white} %F{cyan} default %k%F{white}%f " "$(build_left_prompt)"
}

function testColorOverridingForModifiedStateWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
  local POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'

  touch testfile
  hg add testfile
  hg commit -m "test" 1>/dev/null
  echo "test" > testfile

  assertEquals "%K{yellow} %F{red} default ● %k%F{yellow}%f " "$(build_left_prompt)"
}

# There is no staging area in mercurial, therefore there are no "untracked"
# files.. In case there are added files, we show the VCS segment with a
# yellow background.
# This may be improved in future versions, to be a bit more consistent with
# the git part.
function testAddedFilesIconWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  touch "myfile.txt"
  hg add myfile.txt

  assertEquals "%K{yellow} %F{black} default ● %k%F{yellow}%f " "$(build_left_prompt)"
}

# We don't support tagging in mercurial right now..
function testTagIconWorks() {
  startSkipping # Skip test
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_TAG_ICON='T'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null
  hg tag "v0.0.1"

  assertEquals "%K{green} %F{black} default Tv0.0.1 %k%F{green}%f " "$(build_left_prompt)"
}

function testTagIconInDetachedHeadState() {
  startSkipping # Skip test
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
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

  assertEquals "%K{green} %F{black} ${hash} Tv0.0.1 %k%F{green}%f " "$(build_left_prompt)"
}

function testActionHintWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
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

  assertEquals "%K{yellow} %F{black} default %F{red}| merging%f %k%F{yellow}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=true
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null
  local hash=$(hg id | head -c ${POWERLEVEL9K_CHANGESET_HASH_LENGTH})

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init

  assertEquals "%K{green} %F{black}${hash}  default %k%F{green}%f " "$(build_left_prompt)"
}

function testShorteningCommitHashIsNotShownIfShowChangesetIsFalse() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_SHOW_CHANGESET=false
  local POWERLEVEL9K_CHANGESET_HASH_LENGTH='4'

  touch "file.txt"
  hg add file.txt
  hg commit -m "Add File" 1>/dev/null

  # This test needs to call powerlevel9k_vcs_init, where
  # the changeset is truncated.
  powerlevel9k_vcs_init

  assertEquals "%K{green} %F{black} default %k%F{green}%f " "$(build_left_prompt)"
}

function testMercurialIconWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_HG_ICON='HG-Icon'

  assertEquals "%K{green} %F{black%}HG-Icon %f%F{black} default %k%F{green}%f " "$(build_left_prompt)"
}

function testBookmarkIconWorks() {
  local POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  local POWERLEVEL9K_VCS_BOOKMARK_ICON='B'
  hg bookmark "initial"

  assertEquals "%K{green} %F{black} default Binitial %k%F{green}%f " "$(build_left_prompt)"
}

source shunit2/source/2.1/src/shunit2