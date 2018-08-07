#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
}

function testColorOverridingForCleanStateWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_CLEAN_FOREGROUND='cyan'
  POWERLEVEL9K_VCS_CLEAN_BACKGROUND='white'

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null

  assertEquals "%K{015} %F{014} master %k%F{015}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  unset POWERLEVEL9K_VCS_CLEAN_BACKGROUND
}

function testColorOverridingForModifiedStateWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='red'
  POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null
  git config user.email "test@powerlevel9k.theme"
  git config user.name  "Testing Tester"
  touch testfile
  git add testfile
  git commit -m "test" 1>/dev/null
  echo "test" > testfile

  assertEquals "%K{011} %F{009} master ● %k%F{011}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_MODIFIED_FOREGROUND
  unset POWERLEVEL9K_VCS_MODIFIED_BACKGROUND
}

function testColorOverridingForUntrackedStateWorks() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='cyan'
  POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null
  touch testfile

  assertEquals "%K{011} %F{014} master ? %k%F{011}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND
  unset POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND
}

function testBranchNameTruncatingShortenLength() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_SHORTEN_LENGTH=6
  POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=3
  POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_from_right"

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null
  touch testfile

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"

  POWERLEVEL9K_VCS_SHORTEN_LENGTH=3
  assertEquals "%K{002} %F{000} mas… ? %k%F{002}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_SHORTEN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_STRATEGY
}

function testBranchNameTruncatingMinLength() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_SHORTEN_LENGTH=3
  POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=6
  POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_from_right"

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null
  touch testfile

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"

  POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=7

  assertEquals "%K{002} %F{000} master ? %k%F{002}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_SHORTEN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_STRATEGY
}

function testBranchNameTruncatingShortenStrategy() {
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs)
  POWERLEVEL9K_VCS_SHORTEN_LENGTH=3
  POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH=3
  POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_from_right"

  FOLDER=/tmp/powerlevel9k-test/vcs-test
  mkdir -p $FOLDER
  cd $FOLDER
  git init 1>/dev/null
  touch testfile

  assertEquals "%K{002} %F{000} mas… ? %k%F{002}%f " "$(build_left_prompt)"

  POWERLEVEL9K_VCS_SHORTEN_STRATEGY="truncate_middle"

  assertEquals "%K{002} %F{000} mas…ter ? %k%F{002}%f " "$(build_left_prompt)"

  cd -
  rm -fr /tmp/powerlevel9k-test

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_VCS_SHORTEN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH
  unset POWERLEVEL9K_VCS_SHORTEN_STRATEGY
}

source shunit2/source/2.1/src/shunit2
